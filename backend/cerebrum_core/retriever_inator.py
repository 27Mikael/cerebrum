import json

from pathlib import Path
from langchain_chroma import Chroma
from langchain_ollama import OllamaEmbeddings
from langchain_ollama import OllamaLLM

from agents.rose import RosePrompts
from cerebrum_core.model_inator import TranslatedQuery
from cerebrum_core.file_manager_inator import knowledgebase_index_inator

class RetrieverInator:
    """
    Loads chroma dbs into memory
    retrieves relevant info for rag query
    grades retrieved data on relevance to query
    """

    def __init__(self, vectorstores_root: str, embedding_model: str, llm_model: str) -> None:
        self.vectorstores_root = vectorstores_root
        self.embedding_model = OllamaEmbeddings(model=embedding_model)
        self.llm_model = OllamaLLM(model=llm_model) 
        self.constructed_query = {}

    def translator_inator(self, user_query: str, vectorstores_root: str):
        """
             translates user input into vectorstore queries
        """

        # WARN: look into question(query) specific translation
        #       match each subquery to its relevant domain/subject
        #       step back / rewrite / sub-question / HyDE

        translation_prompt = RosePrompts.get_prompt("rose_query_translator")
        if not translation_prompt:
            raise ValueError("Prompt 'rose_query_translator' not found in RosePrompts")

        available_stores = knowledgebase_index_inator(Path(vectorstores_root))

        filled_prompt = translation_prompt.format(
            user_query=user_query,
            available_stores=available_stores
        )
        translated_query = self.llm_model.invoke(filled_prompt)

        try: 
            parsed_query = json.loads(translated_query)
        except json.JSONDecodeError:
            raise ValueError(f"LLM did not return valid JSON: {translated_query}")

        return TranslatedQuery(**parsed_query)

    def constructor_inator(self,translated_query: TranslatedQuery) :
        """
            constructs vectorstore queries from user input

        """
        # WARN: vectorstore matching has not been implemented
        # the constructor returns subqueries and routes to relevant vectorstores 
        self.constructed_query = {
            "routes": [
                {"subquery": subquery,
                 "path":f"{self.vectorstores_root}/{subquery.domain}/{subquery.subject}" }
                for subquery in translated_query.subqueries
            ]
        }

        return self.constructed_query

    def retrieve_inator(self,k: int=3):
        """
            queries vectorstores using constructed_query
            and generates final response
        """
        all_results = []

        # TODO: similarity_search vs as_retriever 
        for route in self.constructed_query["routes"]:
            store = Chroma (
                persist_directory=route["path"],
                embedding_function=self.embedding_model
            )
            retrieve = store.as_retriever(search_kwargs={"k": k})
            result = retrieve.invoke(route["subquery"].text)
            all_results.append(result)

        return all_results
