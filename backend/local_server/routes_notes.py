from typing import List
from pathlib import Path
from fastapi import APIRouter, HTTPException

from cerebrum_core.model_inator import NoteOut, NoteBase

router = APIRouter(prefix="/notes", tags=["Notes API"])

NOTES_DIR = Path("/home/harbinger/data/storage/notes")
NOTES_DIR.mkdir(exist_ok=True)
 

def list_notes() -> List[NoteOut]:
    notes = []
    for file in NOTES_DIR.glob("*.md"):
        content = file.read_text()
        title = content.splitlines()[0] if content else file.stem
        notes.append(NoteOut(title=title, content=content, filename=file.name))
    return notes

# list all notes
@router.get("/")
def get_notes():
    return list_notes()

# fetch one note
@router.get("/{noteId}") #filename
def get_note(filename: str):
    file_path = NOTES_DIR / filename
    if not file_path.exists():
        raise HTTPException(status_code=404, detail="Notes not found")
    content = file_path.read_text()
    title = content.splitlines()[0] if content else file_path.stem
    return NoteOut(title=title, content=content, filename=file_path.name)

# create note
@router.post("/", response_model=NoteOut)
def create_note(note: NoteBase):
    filename = f"{note.title.replace(' ', '_')}.md"
    file_path = NOTES_DIR / filename
    counter = 1
    while file_path.exists():
        filename = f"{note.title.replace(' ', '_')}_{counter}.md"
        file_path = NOTES_DIR /filename
        counter += 1
    file_path.write_text(note.content)
    return NoteOut(title=note.title, content=note.content,filename=file_path.name)

# update note
@router.put("/{filename}", response_model=NoteOut)
def update_note(filename: str, note: NoteBase):
    file_path = NOTES_DIR / filename
    if not file_path.exists():
        raise HTTPException(status_code=404, detail="Notes not found")
    file_path.write_text(note.content)
    return NoteOut(title=note.title, content=note.content,filename=file_path.name)

# delete note
@router.delete("/{filename}")
def delete_note(filename:str):
    file_path = NOTES_DIR / filename
    if not file_path.exists():
        raise HTTPException(status_code=404, detail="Note not found")
    file_path.unlink()
    return {"detail": "Note deleted successfully"}
