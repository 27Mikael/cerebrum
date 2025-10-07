import json

from pathlib import Path
from langchain_chroma import Chroma
from langchain_ollama import OllamaEmbeddings
from langchain_ollama import OllamaLLM

from agents.rose import RosePrompts
from cerebrum_core.model_inator import TranslatedQuery

class RetrieverInator:
    """
    Loads chroma dbs into memory
    retrieves relevant info for rag query
    grades retrieved data on relevance to query
    """

    def __init__(self, vectorstores_dirs: str, embedding_model: str, llm_model: str) -> None:
        self.embeddings = OllamaEmbeddings(model=embedding_model)
        self.llm_model = OllamaLLM(model=llm_model )
        self.vectorstores =Chroma(
            persist_directory=vectorstores_dirs,
            embedding_function=self.embeddings
        )

    def translator_inator(self, user_query: str, context: str):
        """
             translates user input into vectorstore queries
        """

        # WARN: look into question(query) specific translation
        #       step back / rewrite / sub-question / HyDE

        translation_prompt = RosePrompts.get_prompt("rose_query_translator")
        if not translation_prompt:
            raise ValueError("Prompt 'rose_query_translator' not found in RosePrompts")

        filled_prompt = translation_prompt.format(user_query=user_query, context=context)
        translated_query = self.llm_model.invoke(filled_prompt)

        try: 
            parsed_query = json.loads(translated_query)
        except json.JSONDecodeError:
            raise ValueError(f"LLM did not return valid JSON: {translated_query}")

        return TranslatedQuery(**parsed_query)

    def constructor_inator(self,translated_query: TranslatedQuery, vectorstores_dir: Path) :
        """
            constructs vectorstore queries from user input

        """
        target_path = vectorstores_dir
        queries = [translated_query.rewritten] + translated_query.subqueries
        return {"vectorstor_path": target_path, "queries":queries}

    def retrieve_inator(self, query: str, k: int=3):
        """
            queries vectorstores
        """
        retriever = self.vectorstores.as_retriever(search_kwargs={"k":k})
        results = retriever.invoke(query)
        return results
