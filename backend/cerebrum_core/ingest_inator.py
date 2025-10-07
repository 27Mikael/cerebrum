import json
import asyncio
import pymupdf4llm

from pathlib import Path
from langchain_chroma import Chroma
from langchain_ollama import OllamaLLM
from langchain_core.documents import Document
from langchain_ollama import OllamaEmbeddings
from langchain_text_splitters import  MarkdownHeaderTextSplitter

from agents.rose import RosePrompts
from cerebrum_core.model_inator import FileMetadata



class IngestInator:
    """
    ingestinator is  supposed to take files from the storage dir
        1. chunk them up
        2. index information
        3. embed information
    """

    def __init__(self, md_filepath: Path, embedding_model = None, vectorstores_dir = None) -> None:
        self.vectorstores_dir = vectorstores_dir
        self.md_filepath = md_filepath
        self.embedding_model = embedding_model
        self.chunks: list[Document] = []

    def sanitize_inator(self, name: str , llm_model: str):
        """
            renames files to chromadb ready strings
            while also preserving or updating metadata
            offloading renaming and sanitization to llm
        """
        # to do this i must provide file metadata
        # i must provide string name
        # and allow for a template the llm must follow
        model = OllamaLLM(model=llm_model)
        santize_prompt = RosePrompts.get_prompt("rose_rename")
        if not santize_prompt:
            raise ValueError("Prompt 'rose_reanme' not fount in RosePrompts")
        filled_prompt = santize_prompt.format(filename=name)
        sanitized_prompt = model.invoke(filled_prompt)

        # return sanitized_prompt
        try: 
            parsed_prompt = json.loads(sanitized_prompt)
        except json.JSONDecodeError:
            raise ValueError(f"LLM did not return valid model: {sanitized_prompt}")

        return FileMetadata(**parsed_prompt)


    def markdown_inator(
        self,
        domain:str,
        subject:str,
        filename:str,
    ):
        """
            convert files to markdown
        """
  
        markdown_dir = Path("../data/storage/markdown") / domain / subject
        markdown_dir.mkdir(parents=True, exist_ok=True)

        md_text = pymupdf4llm.to_markdown(self.md_filepath)

        md_output = markdown_dir / f"{filename}.md"
        md_output.write_bytes(md_text.encode())


    def chunk_inator(self, markdown_filepath: Path) -> list[Document]:
        """
        input markdown files
        split md according at header_levels
        """
        # TODO: dynamic chunking - depending on context window of embedding llm
        # if chunk is split and no headers in chunk use recursivetextsplitter
        # TODO: chunk into 3-4k tokens
        md_text = markdown_filepath.read_text()

        header_levels = [
            ("#", "Header 1"),
            ("##", "Header 2"),
            ("###", "Header 3"),
            ("####", "Header 4"),
            ("#####", "Header 5")
        ]
        splitter = MarkdownHeaderTextSplitter(
            headers_to_split_on=header_levels,
            strip_headers=False
        )

        self.chunks = splitter.split_text(md_text)
        return self.chunks

    def embedd_inator(self, collection_name) -> None:
        """
        store chunks in vectorstores
        """
        assert self.embedding_model is not None, "embedding_model is required"
        assert self.vectorstores_dir is not None, "vectorstores_dir is required"

        # embedding
        # WARN: look into making this framework agnostic
        # (split it into a seperate embedding funcion)
        embedding_llm = OllamaEmbeddings(model=self.embedding_model)
        chromadb = Chroma(
            collection_name=collection_name,
            persist_directory=str(self.vectorstores_dir),
            embedding_function=embedding_llm
        )

        chromadb.add_documents(self.chunks)
        asyncio.run(chromadb.persist())

    # WARN: for later if chroma stores are too big
    def index_inator(self):
        pass


    def token_inator(self):
        pass





