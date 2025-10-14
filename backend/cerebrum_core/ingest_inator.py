import json
from fastapi import File
import yaml
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

    def __init__(self, filepath: Path, embedding_model = None, vectorstores_root = None) -> None:
        self.vectorstores_root = vectorstores_root
        self.filepath = filepath
        self.embedding_model = embedding_model
        self.chunks: list[Document] = []

    def _yaml_inator(self, metadata: FileMetadata) -> str:
        yaml_dump = yaml.dump(metadata.model_dump(), sort_keys=False)
        return f"---\n{yaml_dump}---\n\n"

    def sanitize_inator(self, filename: str, metadata: dict | None, llm_model: str):
        """
            renames files to chromadb ready strings
            while also preserving or updating metadata
            offloading renaming and sanitization to llm
        """
        model = OllamaLLM(model=llm_model)
        santize_prompt = RosePrompts.get_prompt("rose_rename")
        if not santize_prompt:
            raise ValueError("Prompt 'rose_rename' not fount in RosePrompts")
        filled_prompt = santize_prompt.format(filename=filename, metadata=metadata)
        sanitized_prompt = model.invoke(filled_prompt)

        try: 
            parsed_prompt = json.loads(sanitized_prompt)
        except json.JSONDecodeError:
            raise ValueError(f"LLM did not return valid model: {sanitized_prompt}")

        return FileMetadata(**parsed_prompt)


    def markdown_inator(self, metadata: FileMetadata):
        """
            convert files to markdown
        """
        domain = metadata.domain
        subject = metadata.subject
        filename = metadata.title

        # add yaml front matter to the documents
  
        markdown_dir = Path("../data/storage/markdown") / domain / subject
        markdown_dir.mkdir(parents=True, exist_ok=True)

        md_body = pymupdf4llm.to_markdown(self.filepath, show_progress=True)

        yaml_front = self._yaml_inator(metadata)
        full_md = f"{yaml_front}{md_body}"

        md_output = markdown_dir / f"{filename}.md"
        md_output.write_text(full_md, encoding="utf-8")


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
            ("#####", "Header 5"),
            ("######", "Header 6")
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
        assert self.vectorstores_root is not None, "vectorstores_root is required"

        # embedding
        # WARN: look into making this framework agnostic
        # (split it into a seperate embedding funcion)
        embedding_llm = OllamaEmbeddings(model=self.embedding_model)
        chromadb = Chroma(
            collection_name=collection_name,
            persist_directory=str(self.vectorstores_root),
            embedding_function=embedding_llm
        )

        # add legible chunk ids for each documents
        # probably in a style that matches filemeta data
        # 
        chromadb.add_documents(self.chunks)
        asyncio.run(chromadb.persist())

    # WARN: for later if chroma stores are too big
    def index_inator(self):
        pass


    def token_inator(self):
        pass





