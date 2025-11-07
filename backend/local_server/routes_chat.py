import logging
from fastapi import APIRouter
from pydantic import BaseModel
from cerebrum_core.retriever_inator import *

router = APIRouter(prefix="/chat", tags=["Chat API"])

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

llm_model="granite3.1-dense:2b"
embedding_model="qwen3-embedding:4b-q4_K_M"
vectorstores_root="../data/storage/vectorstores"

class Query(BaseModel):
    text : str

@router.post("/")
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
        user_query=query.text
    )

    logger.info("Translated wuery dict: %s", translated_query)
    # TODO: dynamically generate the vectorstores
    process_query.constructor_inator(translated_query=translated_query)

    process_query.retrieve_inator()
    response = process_query.generate_inator(user_query=query.text)
    return {"reply": response}

