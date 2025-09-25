# %%
from cerebrum_core.file_getter_inator import file_walker_inator
from cerebrum_core.ingest_inator import IngestInator
from pathlib import Path

import pymupdf4llm


#%%

# %%
model_name="mistral:7b"
embedding_model ="embeddinggemma:latest"

# given knowledgebase
# heirachy is /domain/subject/topic/subtopic
knowledgebase_dir =  Path("../data/knowledgebase")
walked_knowledgebase = file_walker_inator(knowledgebase_dir, max_depth=4)
for file_info in walked_knowledgebase:
    print(file_info["filepath"])
#%%

# %%
# detect new documents and convert to markdown
markdown_files_dir = Path("./storage/markdown")
walked_markdown_files = file_walker_inator(markdown_files_dir, max_depth=4)
for file_info in walked_knowledgebase:
    vectorstores_db = f"./storage/vectorstores/{file_info['domain']}/{file_info['subject']}"

    markdown_files = pymupdf4llm.to_markdown(file_info["filepath"])
    Path(markdown_files_dir / f"{file_info['filestem']}.md").write_bytes(markdown_files.encode())

    # chunk and embedd
    markdown_chunks = IngestInator(
        filepath=file_info["filepath"],
        embedding_model=embedding_model,
        vectorstores_db= vectorstores_db
    )
#%%


# %%
# take in user prompt(input)
#   Prompt translation:
#       transform question into query for database parsing
#       select appropriate translation method based on question
#       step back / rewrite / sub-question / HyDE
#
#   Query Construction:
#       using translated question
#       construct a query that can reference relevant vectorstores
#
#       Routing (direct query to relevant vectorstores):
#           logical vs semantic routing
#
# generate response
#   retrieve relevant info from vectorstores
#    TODO: CORRECTIONAL RAG
#       refine response before before passing on to the user
#%%


# 
