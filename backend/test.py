import pathlib
import pymupdf
import tiktoken
import pymupdf4llm
from langchain_chroma import Chroma
from langchain_ollama import OllamaEmbeddings
from cerebrum_core.file_manager_inator import knowledgebase_index_inator
from cerebrum_core.ingest_inator import IngestInator
from cerebrum_core.retriever_inator import RetrieverInator

# %%
doc = pathlib.Path("../data/storage/markdown/biology/biochemistry/Lehninger Principles of Biochemistry 8th edition by by David L n - Lehninger Principles of Biochemistry eighth edition by by David L Nelson (2021) - libgen.li.pdf.md")

pdf_path = pathlib.Path("../data/knowledgebase/biology/biochemistry/Lehninger Principles of Biochemistry 8th edition by by David L n - Lehninger Principles of Biochemistry eighth edition by by David L Nelson (2021) - libgen.li.pdf")

query = "Explain how proteins form supramolecular complexes and the role of noncovalent interactions."
retrieve = RetrieverInator(
    vectorstores_root = "../data/storage/vectorstores",
    embedding_model="qwen3-embedding:4b-q4_K_M",
    llm_model = "mistral:7b"
)

translated_query = retrieve.translator_inator(
    user_query=query,
    vectorstores_root="../data/storage/vectorstores"
)
print(translated_query)

constructor = retrieve.constructor_inator(
    translated_query=translated_query,
)
print(constructor["routes"])

for route in constructor["routes"]:
    print(route["subquery"].text)
    print(route["path"])

response = retrieve.retrieve_inator()
print(response)

test = knowledgebase_index_inator(pathlib.Path("../data/storage/vectorstores"))
print(test)

#%%


