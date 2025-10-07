import pathlib
import pymupdf
import tiktoken
import pymupdf4llm

from langchain_chroma import Chroma
from langchain_ollama import OllamaEmbeddings

from cerebrum_core.ingest_inator import IngestInator
from cerebrum_core.retriever_inator import RetrieverInator

# %%
doc = pathlib.Path("../data/storage/markdown/biology/biochem/Lehninger Principles of Biochemistry 8th edition by by David L n - Lehninger Principles of Biochemistry eighth edition by by David L Nelson (2021) - libgen.li.pdf.md")

pdf_path = pathlib.Path("../data/knowledgebase/biology/biochem/Lehninger Principles of Biochemistry 8th edition by by David L n - Lehninger Principles of Biochemistry eighth edition by by David L Nelson (2021) - libgen.li.pdf")

pages = pymupdf4llm.to_markdown(pdf_path,show_progress=True)
pathlib.Path("output.md").write_bytes(pages.encode())
print(pages)

# get metadata
pdf = pymupdf.open(pdf_path)
print(pdf.metadata)

# test query translation
retriever = RetrieverInator(
    vectorstores_dirs=".",
    embedding_model="qwen3-embedding:4b-q4_K_M",
    llm_model="mistral:7b"
)
user_query = "How does the mitochondria generate ATP during respiration?"
context = "The user is studying energy metabolism for an undergraduate biology exam."
translation = retriever.translator_inator(user_query=user_query, context=context)
print(translation.rewritten)
#%%

# %%
tokenizer = tiktoken.encoding_for_model("gpt-4o-mini")
chunky = IngestInator(
    md_filepath=doc,
    embedding_model="mistral:7b",
    vectorstores_dir="",
)

sanitized = chunky.sanitize_inator(name="Lehninger Principles of Biochemistry 8th edition by by David L n - Lehninger Principles of Biochemistry eighth edition by by David L Nelson (2021) - libgen.li.pdf",llm_model="mistral:7b")

print(sanitized)
print(sanitized.title)
result = chunky.chunk_inator(markdown_filepath=doc)

d = result
print(d)
print(d[21].page_content[:20])
print(d[21].metadata)

total_tokens = 0
chunk_token_counts = []
for doc in result:
    content = doc.page_content
    toke = tokenizer.encode(content)
    n_tokens = len(toke)
    chunk_token_counts.append(n_tokens)
    total_tokens += n_tokens

    if total_tokens == max(chunk_token_counts):
        print(doc.page_content)

print(f"Total tokens across all chunks: {total_tokens}")
print(f"Largest chunk: {max(chunk_token_counts)} tokens")
print(f"Smallest chunk: {min(chunk_token_counts)} tokens")
#

testdb = Chroma(
    collection_name="test",
    persist_directory=".",
    embedding_function=OllamaEmbeddings(model="qwen3-embedding:4b-q4_K_M")
)
testdb.add_documents([result[22]])
print(testdb._collection.get(include=["documents"]))

#%%


