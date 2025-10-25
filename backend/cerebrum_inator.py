import uvicorn
from fastapi import FastAPI
from contextlib import asynccontextmanager
from fastapi.middleware.cors import CORSMiddleware

from cerebrum_core.file_manager_inator import FileRegisterInator
from local_server import routes_process_files
# %%
#
@asynccontextmanager
async def lifespan(app: FastAPI):

    registry = FileRegisterInator()
    app.state.registry = registry

    app.include_router(routes_process_files.router)
    yield


def create_api_server():
    """
    Initializes server config and middleware.
    """

    # %%
    app = FastAPI(lifespan=lifespan)

    app.add_middleware(
        CORSMiddleware, 
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"]
    )

    # include routers
#    app.include_router(chat.router)
    return app

app = create_api_server()

if __name__ == "__main__":
    # Important so uvicorn doesn't run on import
    uvicorn.run(app, host="0.0.0.0", port=8000)

