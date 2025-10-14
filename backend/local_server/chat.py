import logging

from langchain_ollama import OllamaLLM
from fastapi import APIRouter
from pydantic import BaseModel
from cerebrum_core.retriever_inator import *

router = APIRouter(prefix="/chat", tags=["Data API"])

llm_model="mistral:7b"
embedding_model ="embeddinggemma:latest"
vectorstores_root = "../data/storage/vectordb"

class Query(BaseModel):
    text : str

@router.get("/chat")
async def ask_rose(query: Query):
    """
        Determine the ontology of the Study Bubble
            Reasoning Thread (thinking process, users/llms)
    """
    # {"message": "🌹 Rose is ready to chat."}
    # TODO: route to the correct vectorstores then generate response
    # given query; process query {translate and construct db query}
    process_query = RetrieverInator(
        vectorstores_root=vectorstores_root,
        embedding_model=embedding_model,
        llm_model=llm_model
    )

    translated_query = process_query.translator_inator(
        user_query=query.text,
        vectorstores_root=vectorstores_root
    )
    # TODO: dynamically generate the vectorstores
    process_query.constructor_inator(
        translated_query=translated_query
    )

    response = process_query.retrieve_inator()
    return response

