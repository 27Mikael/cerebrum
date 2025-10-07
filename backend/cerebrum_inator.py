# %%
import fastapi

from pathlib import Path

from agents.rose import RosePrompts

from langchain_core.prompts import PromptTemplate

from cerebrum_core.ingest_inator import IngestInator
from cerebrum_core.retriever_inator import RetrieverInator
from cerebrum_core.file_manager_inator import file_walker_inator
#%%

# %%
llm_model="mistral:7b"
embedding_model ="embeddinggemma:latest"

vectorstores_dir = Path("../storage/vectordb")
knowledgebase_dir =  Path("../data/knowledgebase")
markdown_files_dir = Path("../data/storage/markdown")
vectorstores_dir = Path("../data/storage/vectorstores")

walked_markdown_dir = file_walker_inator(markdown_files_dir, max_depth=4)
walked_knowledgebase = file_walker_inator(knowledgebase_dir, max_depth=4)

context = "Placeholder {notes, or texts}"
user_query = "Placeholder {api query here}"
roses_perogative = RosePrompts.get_prompt("rose_hint")
rompt_template = PromptTemplate.from_template(f"{roses_perogative}")
#%%

# %%
# given knowledgebase
# heirachy is /domain/subject/topic/subtopic
# WARN: convert pdf files to md 
for file_info in walked_knowledgebase:
    print(file_info["filename"])
    try:
        # convert to markdown
        markdown_files = IngestInator(
            md_filepath=file_info["filepath"],
            embedding_model="",
            vectorstores_dir= ""
        )
        markdown_files.markdown_inator(
            domain=file_info["domain"],
            subject=file_info["subject"],
            filename=file_info["filename"]
        )

    except Exception as e:
        print(f"Failed for {file_info['filename']}: {e}")

#%%


# %%
# WARN:  chunk and embed markdown files into vectorstores
# clean up filenames more
# look into implemnenting online embedding apis from cohere open ai and hugging face
# use tiktoken to count tokens per file and total tokens
for md_file in walked_markdown_dir:
    print(md_file["filename"])
    try:
        # prepare vectorstore directory
        vectorstores_dir = Path(
            f"../data/storage/vectorstores/{md_file['domain']}/{md_file['subject']}"
        )
        vectorstores_dir.mkdir(parents=True, exist_ok=True)

        # chunk and embedd
        markdown_chunks = IngestInator(
            md_filepath=md_file["filepath"],
            embedding_model=embedding_model,
            vectorstores_dir=vectorstores_dir
        )
        sanitized_md = markdown_chunks.sanitize_inator(
            name=md_file["filestem"],
            llm_model=llm_model
        )
        print(sanitized_md)
        markdown_chunks.chunk_inator(markdown_filepath=md_file["filepath"])
        markdown_chunks.embedd_inator(collection_name=sanitized_md)
    except Exception as e:
        print(f"Failed for {md_file['filename']}: {e}")
#%%


# %%
walked_vectorstores = file_walker_inator(vectorstores_dir, max_depth=4)
for vectorstore_info in walked_vectorstores:
    retriever = RetrieverInator(
        vectorstore_info["filepath"],
        embedding_model=embedding_model,
        llm_model=llm_model
    )
#   Query translation:
    translated_query = retriever.translator_inator(user_query=user_query, context=context)
    print(translated_query)

#   Query Construction:
    constructed_query = retriever.constructor_inator(translated_query, vectorstore_info["path"])
    print(constructed_query)
   

#   Routing (direct query to relevant vectorstores):
    retriever.retrieve_inator(query="Placeholder")

#   generate response

#%%


# %%
# TODO: find a way to implement memory{quiz grades, exam grades and track progress}
#
# take in user notes(input)
#   markdown files that are then split according to headers
#   or direct to text chunking if no header heirachy
#
#       should be able to assess user notes, {interests} and {goals}:
#       guide user learning to achieve goals {path user goals step by step}
#       match users learning pace as stated in {goals}
#
#       give feedback {hints} on user notes and any inaccurate/incomplete notes
#           should nudge user to the relevant resources covering the topic
#           create quizzes and examinations from user notes {grade them too}
#
#           generate quizzes in an active recall fashion
#              tailor to per domain {structure and approach}
#%%
