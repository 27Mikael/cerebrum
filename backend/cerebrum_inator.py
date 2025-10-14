import uvicorn
from pathlib import Path
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from local_server import on_startup, chat, quiz, review

def create_api_server():
    """
    Initializes server config and middleware.
    """

    # %%
    app = FastAPI()

    app.add_middleware(
        CORSMiddleware, 
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"]
    )

    # include routers
    app.include_router(chat.router)

    # %%
    @app.on_event("startup")
    async def startup():

        markdown_files_dir = Path("../data/storage/markdown")
        knowledgebase_dir = Path("../data/knowledgebase")
        embedding_model = "qwen3-embedding:4b-q4_K_M:"
        llm_model = "mistral:7b"

        # If these are async, fine. If not, remove await.
        on_startup.markdown_converter_inator(knowledgebase_dir, llm_model)
        on_startup.markdown_embedder_inator(markdown_files_dir, embedding_model)

    return app

app = create_api_server()

if __name__ == "__main__":
    # Important so uvicorn doesn't run on import
    uvicorn.run(app, host="0.0.0.0", port=8000)

