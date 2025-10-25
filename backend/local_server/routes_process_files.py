# %%
import pymupdf
from pathlib import Path
from fastapi import APIRouter, BackgroundTasks, Request

from cerebrum_core.ingest_inator import IngestInator
from cerebrum_core.file_manager_inator import file_walker_inator
from cerebrum_core.utils.progress_bar import progress_bar

router = APIRouter(prefix="/process")

markdown_files_dir = Path("../data/storage/markdown")
knowledgebase_dir = Path("../data/knowledgebase")
embedding_model = "qwen3-embedding:4b-q4_K_M"
llm_model = "mistral:7b"


# ==========================================================
# CONVERTER
# ==========================================================
def markdown_converter_inator(knowledgebase_dir: Path, llm_model: str, registry):
    """Convert PDF files to Markdown"""
    walked_knowledgebase = file_walker_inator(knowledgebase_dir, max_depth=4)

    for file_info in walked_knowledgebase:
        assert file_info is not None, "file info cannot be empty"

        print(f"Converting {file_info['filename']}")
        try:
            with pymupdf.open(file_info["filepath"]) as pdf:
                metadata = pdf.metadata

            markdown_files = IngestInator(filepath=file_info["filepath"])
            sanitized_metadata = markdown_files.sanitize_inator(
                filename=file_info["filestem"],
                metadata=metadata,
                llm_model=llm_model
            )

            hash_id = registry.hash_inator(filename=sanitized_metadata.title)
            registry.register_inator(
                original_name=file_info["filestem"],
                sanitized_name=sanitized_metadata.title
            )
            is_converted = registry.check_inator(field="converted",hash_id=hash_id)
            if is_converted:
                continue
            markdown_files.markdown_inator(metadata=sanitized_metadata)
            registry.updater_inator(status="converted", hash_id=hash_id)

        except Exception as e:
            print(f"Failed for {file_info['filename']}: {e}")


# ==========================================================
# EMBEDDER
# ==========================================================
def markdown_embedder_inator(markdown_files_dir: Path, embedding_model: str, registry):
    """Chunk and embed Markdown files into vectorstores"""
    walked_markdown_dir = file_walker_inator(markdown_files_dir, max_depth=4)

    for md_file in walked_markdown_dir:
        print(md_file["filename"])
        try:
            vectorstores_path = Path(
                f"../data/storage/vectorstores/{md_file['domain']}/{md_file['subject']}"
            )
            vectorstores_path.mkdir(parents=True, exist_ok=True)

            markdown_chunks = IngestInator(
                filepath=md_file["filepath"],
                embedding_model=embedding_model,
                vectorstores_path=vectorstores_path
            )

            hash_id = registry.hash_inator(md_file["filestem"])
            is_embedded = registry.check_inator(field="embedded",hash_id=hash_id)
            if is_embedded:
                print(f"skipping {md_file['filestem']}")
                continue
            chunks = markdown_chunks.chunk_inator(markdown_filepath=md_file["filepath"])
            total = len(chunks)

            for idx, chunk in enumerate(chunks, start=1):
                markdown_chunks.embedd_inator(chunk=chunk, collection_name=md_file["subject"])
                progress_bar(idx, total)

                # last updated chunk
                # registry.update_last_embedded_chunk(hash_id, idx)

            # TODO: implement a hash fetcher
            registry.updater_inator(status="embedded", hash_id=hash_id)

        except Exception as e:
            print(f"Failed for {md_file['filename']}: {e}")


# ==========================================================
# ROUTES
# ==========================================================
@router.get("/")
async def stats(request: Request):
    reg = request.app.state.registry
    data = reg.show_all_inator() or []
    return {"registry": data}

@router.post("/reset/{status}")
async def reset(status: str,request: Request,  hash_id: str | None = None):
    reg = request.app.state.registry
    data = reg.reset_inator(status, hash_id)
    return data

@router.post("/markdowninator")
async def convert_files(background_tasks: BackgroundTasks, request: Request):
    """Queue Markdown conversion in background"""
    reg = request.app.state.registry
    background_tasks.add_task(markdown_converter_inator, knowledgebase_dir, llm_model, reg)
    return {"message": "Conversion started in background"}


@router.post("/embeddinator")
async def embedd_files(background_tasks: BackgroundTasks, request: Request):
    """Queue Markdown embedding in background"""
    reg = request.app.state.registry
    background_tasks.add_task(markdown_embedder_inator, markdown_files_dir, embedding_model, reg)
    return {"message": "Embedding started in background"}

