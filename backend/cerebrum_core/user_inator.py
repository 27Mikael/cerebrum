import requests

OLLAMA_LOCAL_URL = "http://127.0.0.1:11434"

def fetch_models():
    available_models = []
    response = requests.get(f"{OLLAMA_LOCAL_URL}/api/tags")
    response.raise_for_status()
    models_dict = response.json()

    for model in models_dict['models']:
        available_models.append(model["name"])

    return available_models

print(fetch_models())

