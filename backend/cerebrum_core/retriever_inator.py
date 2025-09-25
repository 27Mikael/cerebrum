from typing import List
from pathlib import Path
from langchain_chroma import Chroma
from langchain_ollama import OllamaEmbeddings


class RetrieverInator:
    """
    Loads chroma dbs into memory
    retrieves relevant info for rag query
    grades retrieved data on relevance to query
    """

    def __init__(self, vectorstores_dbs: List[str], model_name: str) -> None:
        self.vectorstores_dbs = [Path(d) for d in vectorstores_dbs]
        self.embeddings = OllamaEmbeddings(model=model_name)
        self.vectorstores = [ 
            Chroma(persist_directory=str(d),
            embedding_function=self.embeddings)for d in self.vectorstores_dbs
        ]

    def retrieve_inator(self, k: int=3) -> List:
        """
        Return list of all retrieved vectorstores
        """
        retrieved_stores = [
            vectorstore.as_retriever(search_kwargs={"k": k})
            for vectorstore in self.vectorstores
        ]
        return retrieved_stores

    def review_inator(self):
        """
            Ensure that retrieved documents are relevant to the query
        """
        pass

