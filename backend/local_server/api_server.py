from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from langchain_ollama import OllamaLLM
from cerebrum_core.embed_inator import load_embeddings_and_db
from cerebrum_core.ingest_inator import *
from local_server import data_router
import logging



logging.basicConfig(level=logging.INFO)

app = FastAPI()

app.include_router(data_router.router)

def create_api_server(model_name, vectorstores_db):
    
    # chunk generation using the files in the storage
    # embedding the chunks into queriable chroma dbs for
    # RAG logic to ensure that the right information is pulled
    #
    # features: By topic based chats, quizzes, flashcards and exams
    #           topic related stats on progress and scores
    #           auto-generated quiz content based on users learning goals
    #           feed user notes into RAG for querying and advice
    #
    # user some sort of user authentication to ensure correct accoess permissions
    #

    app.add_middleware(
        CORSMiddleware, 
        allow_origins=["*"],
        allow_credentials=True, 
        allow_methods=["*"],
        allow_headers=["*"]
    )

    _, db = load_embeddings_and_db(model_name, vectorstores_db)
    llm = OllamaLLM(model=model_name)

    class Query(BaseModel):
        question: str

    @app.get("/")
    async def root():
        return {"message": "🌹 Rose is alive."}


    @app.post("/ask")
    async def ask_rose(query: Query):
        question = query.question.strip()
        logging.info(f"Received question: {question}")

        results = db.similarity_search(question, k=3)
        if results:
            context = "\n--\n".join([doc.page_content for doc in results])
            logging.info(
                "Found similar documents, adding to context"
            )
        else:
            context = "No helpful documents were found."
            logging.warning(
                "No similar documents were found. Falling back to LLM only"
            )

        prompt = f"""
You are Rose, a patient guide. Only give hints, never answers.

Use these excerpts:

{context}

Question: {question}

Hint:
    """
        response = llm(prompt)
        return {"hint":response.strip()}
   
    return app

