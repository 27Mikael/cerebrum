from local_server.api_server import create_api_server
import uvicorn

if __name__ == "__main__":
    app = create_api_server(
        model_name="mistral:7b",
        vectorstores_db="../backend/storage/vectordb/"
    )
    uvicorn.run(app, host="0.0.0.0", port=8000)
