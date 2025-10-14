# %%
import pymupdf

from pathlib import Path

from cerebrum_core.ingest_inator import IngestInator
from cerebrum_core.file_manager_inator import file_walker_inator
#%%

# %%
# given knowledgebase
# heirachy is /domain/subject/topic/subtopic
def markdown_converter_inator(knowledgebase_dir: Path, llm_model: str):
    # WARN: convert pdf files to md 
    walked_knowledgebase = file_walker_inator(knowledgebase_dir, max_depth=4)

    for file_info in walked_knowledgebase:
        print(file_info["filename"])

        # extract pdf metadata and feed it into file info
        with pymupdf.open(file_info["filepath"]) as pdf:
            try:
                # convert to markdown
                markdown_files = IngestInator(
                    filepath=file_info["filepath"]
                )

                sanitized_metadata = markdown_files.sanitize_inator(
                    filename=file_info["filestem"],
                    metadata=pdf.metadata,
                    llm_model=llm_model
                )

                markdown_files.markdown_inator(metadata=sanitized_metadata)

            except Exception as e:
                print(f"Failed for {file_info['filename']}: {e}")
#%%


# %%
# WARN:  chunk and embed markdown files into vectorstores
# look into implemnenting online embedding apis from cohere open ai and hugging face
# use tiktoken to count tokens per file and total tokens

def markdown_embedder_inator(markdown_files_dir: Path, embedding_model: str):
    walked_markdown_dir = file_walker_inator(markdown_files_dir, max_depth=4)

    for md_file in walked_markdown_dir:
        print(md_file["filename"])
        try:
            # prepare vectorstore directory
            vectorstores_root = Path(
                f"../data/storage/vectorstores/{md_file['domain']}/{md_file['subject']}"
            )
            vectorstores_root.mkdir(parents=True, exist_ok=True)

            # chunk and embedd
            markdown_chunks = IngestInator(
                filepath=md_file["filepath"],
                embedding_model=embedding_model,
                vectorstores_root=vectorstores_root
            )

            markdown_chunks.chunk_inator(markdown_filepath=md_file["filepath"])
            markdown_chunks.embedd_inator(collection_name=md_file["filestem"])

        except Exception as e:
            print(f"Failed for {md_file['filename']}: {e}")
#%%
