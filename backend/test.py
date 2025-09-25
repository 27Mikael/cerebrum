import pathlib
from cerebrum_core.ingest_inator import IngestInator
import pymupdf4llm
import pymupdf

# %%
doc = "../data/knowledgebase/programming/languages/python/Python Tricks the book.pdf"
pages = pymupdf4llm.to_markdown(doc)
pathlib.Path("output.md").write_bytes(pages.encode())
print(pages)
docu = pymupdf.open(doc)
print(docu.metadata)
#%%

# %%
chunky = IngestInator(
    doc,
    embedding_model="mistral:7b",
    vectorstores_db="",
)

result = chunky.chunk_inator()
print(result)
# chunk_inator returns
print(result[0].page_content)
print(result[21])
print(len( result ))
#%%
