import json
import shutil
import logging
from typing import List
from pathlib import Path
from datetime import datetime

from pydantic import BaseModel
from fastapi import APIRouter, HTTPException

from cerebrum_core.retriever_inator import RetrieverInator
from cerebrum_core.file_manager_inator import CerebrumPaths
from cerebrum_core.model_inator import CreateStudyBubble, NoteOut, NoteBase, StudyBubble


bubble_router = APIRouter(prefix="/bubbles", tags=["Study Bubble API"])

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Config
llm_model = "granite4:micro"
embedding_model = "qwen3-embedding:4b-q4_K_M"

CEREBRUM_PATHS = CerebrumPaths()
ROOT_KB_DIR = CEREBRUM_PATHS.get_kb_dir()

# Base directories
STUDY_BUBBLES_DIR = CEREBRUM_PATHS.get_bubbles_dir()
STUDY_BUBBLES_DIR.mkdir(parents=True, exist_ok=True)

VECTORSTORES_DIR = ROOT_KB_DIR / "vectorstores"
VECTORSTORES_DIR.mkdir(parents=True, exist_ok=True)


# ------------------------------ UTILITIES ------------------------------ #

def get_bubble_path(bubble_id: str) -> Path:
    path = STUDY_BUBBLES_DIR / bubble_id
    return path


def get_notes_dir(bubble_id: str) -> Path:
    """
    Always returns:
    DATA_DIR/study_bubbles/<bubble_id>/notes
    """
    bubble_path = get_bubble_path(bubble_id)
    notes_path = bubble_path / "notes"
    notes_path.mkdir(parents=True, exist_ok=True)
    return notes_path


def list_notes(notes_dir: Path) -> List[NoteOut]:
    notes = []
    for file in notes_dir.glob("*.md"):
        content = file.read_text(encoding="utf-8")
        title = content.splitlines()[0] if content else file.stem
        notes.append(NoteOut(title=title, content=content, filename=file.name))
    return notes


# --------------------------- STUDY BUBBLE CRUD -------------------------- #

@bubble_router.get("/", response_model=List[StudyBubble])
def list_study_bubbles():
    """
    List all study bubbles.
    """
    bubbles = []
    for folder in STUDY_BUBBLES_DIR.iterdir():
        if not folder.is_dir():
            continue

        info_file = folder / "info.json"
        if not info_file.exists():
            continue

        data = json.loads(info_file.read_text())

        bubbles.append(StudyBubble(**data))

    return bubbles


@bubble_router.post("/create")
def create_study_bubble(data: CreateStudyBubble) -> StudyBubble:
    """
    Create a study bubble folder and info file.
    """
    bubble_id = data.name.replace(" ", "_").lower()
    bubble_path = get_bubble_path(bubble_id)

    if bubble_path.exists():
        raise HTTPException(status_code=400, detail="Bubble already exists")

    bubble_path.mkdir(parents=True, exist_ok=True)
    (bubble_path / "chat").mkdir(parents=True, exist_ok=True)
    (bubble_path / "notes").mkdir(parents=True, exist_ok=True)
    (bubble_path / "quizzes").mkdir(parents=True, exist_ok=True)

    bubble_data = StudyBubble(
        id=bubble_id,
        name = data.name,
        description=data.description,
        domains=data.domains,
        user_goals=data.user_goals,
        created_at=datetime.now(),
    )

    info_file = bubble_path / "info.json"
    info_file.write_text(bubble_data.model_dump_json(indent=4), encoding="utf-8")

    return bubble_data

@bubble_router.get("/{bubble_id}")
def get_study_bubble(bubble_id: str) -> StudyBubble:
    """
    Fetch a single study bubble's info.
    """
    bubble_path = get_bubble_path(bubble_id)
    info_file = bubble_path / "info.json"

    if not info_file.exists():
        raise HTTPException(status_code=404, detail="Study bubble not found")

    data = json.loads(info_file.read_text())
    return StudyBubble(**data)


@bubble_router.delete("/{bubble_id}")
def delete_study_bubble(bubble_id: str):
    """
    Delete a bubble and its notes.
    """
    bubble_path = get_bubble_path(bubble_id)

    if not bubble_path.exists():
        raise HTTPException(status_code=404, detail="Study bubble not found")

    # Recursively delete the folder
    shutil.rmtree(bubble_path)

    return {"detail": "Study bubble deleted successfully"}


# ------------------------------- NOTES CRUD ------------------------------ #

@bubble_router.get("/{bubble_id}/notes")
def list_notes_in_bubble(bubble_id: str):
    notes_dir = get_notes_dir(bubble_id)
    return list_notes(notes_dir)


@bubble_router.post("/{bubble_id}/create/notes", response_model=NoteOut)
def create_note(bubble_id: str, note: NoteBase):
    notes_dir = get_notes_dir(bubble_id)

    safe_title = note.title.replace(" ", "_")
    filename = f"{safe_title}.md"
    file_path = notes_dir / filename

    # Avoid collisions
    counter = 1
    while file_path.exists():
        filename = f"{safe_title}_{counter}.md"
        file_path = notes_dir / filename
        counter += 1

    file_path.write_text(note.content, encoding="utf-8")

    return NoteOut(title=note.title, content=note.content, filename=filename)


@bubble_router.get("/{bubble_id}/notes/get/{filename}", response_model=NoteOut)
def get_note(bubble_id: str, filename: str):
    notes_dir = get_notes_dir(bubble_id)
    file_path = notes_dir / filename

    if not file_path.exists():
        raise HTTPException(status_code=404, detail="Note not found")

    content = file_path.read_text(encoding="utf-8")
    title = content.splitlines()[0] if content else file_path.stem

    return NoteOut(title=title, content=content, filename=filename)


@bubble_router.put("/{bubble_id}/notes/update/{filename}", response_model=NoteOut)
def update_note(bubble_id: str, filename: str, note: NoteBase):
    notes_dir = get_notes_dir(bubble_id)
    file_path = notes_dir / filename

    if not file_path.exists():
        raise HTTPException(status_code=404, detail="Note not found")

    file_path.write_text(note.content, encoding="utf-8")

    return NoteOut(title=note.title, content=note.content, filename=filename)


@bubble_router.delete("/{bubble_id}/notes/delete/{filename}")
def delete_note(bubble_id: str, filename: str):
    notes_dir = get_notes_dir(bubble_id)
    file_path = notes_dir / filename

    if not file_path.exists():
        raise HTTPException(status_code=404, detail="Note not found")

    file_path.unlink()

    return {"detail": "Note deleted successfully"}


# ---------------------------- CHAT ENDPOINT ------------------------------ #

class Query(BaseModel):
    text: str


@bubble_router.post("/{bubble_id}/chat")
async def chat_in_bubble(bubble_id: str, query: Query):
    """
    Chat inside a specific study bubble.
    """
    vectorstore_root = VECTORSTORES_DIR

    processor = RetrieverInator(
        vectorstores_root=str(vectorstore_root),
        embedding_model=embedding_model,
        llm_model=llm_model,
    )

    # TRANSLATE USER QUERY
    translated_query = processor.translator_inator(
        user_query=query.text
    )
    logger.info("Translated Query: %s", translated_query)

    # CONSTRUCT CONTEXT
    processor.constructor_inator(translated_query=translated_query)

    # RETRIEVE
    processor.retrieve_inator()

    # GENERATE RESPONSE
    response = processor.generate_inator(user_query=query.text)

    return {"reply": response}

