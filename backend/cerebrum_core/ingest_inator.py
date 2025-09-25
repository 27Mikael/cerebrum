import pymupdf4llm
from langchain.vectorstores import Chroma
from langchain_core.documents import Document
from langchain_ollama import OllamaEmbeddings
from langchain_text_splitters import  MarkdownHeaderTextSplitter


class IngestInator:
    """
    ingestinator is  supposed to take files from the storage dir
        1. chunk them up
        2. index information
        3. embed information
    """

    def __init__(self, filepath: str, embedding_model: str, vectorstores_db: str) -> None:
        self.vectorstores_db = vectorstores_db
        self.filepath = filepath
        self.embedding_model = embedding_model
        self.header_levels = [
            ("#", "Header 1"),
            ("##", "Header 2"),
            ("###", "Header 3")
        ]
        
        # embedding
        # WARN: look into making this framework agnostic
        # (split it into a seperate embedding funcion)
        self.embedding_llm = OllamaEmbeddings(model=self.embedding_model)
        self.db = Chroma(
            persist_directory=str(self.vectorstores_db),
            embedding_function=self.embedding_llm
        )
        self.splitter = MarkdownHeaderTextSplitter(
            headers_to_split_on=self.header_levels,
            strip_headers=False
        )

    def chunk_inator(self) -> list[Document]:
        """
        convert pdfs to markdown
        split md according at header_levels
        """
        md_text = pymupdf4llm.to_markdown(self.filepath)
        chunks = self.splitter.split_text(md_text)
        return chunks

    def embedd_inator(self):
        """
        store chunks in vectorstores
        """

        chunks = self.chunk_inator()
        self.db.add_documents(chunks)
        self.db.persist()

    # WARN: for later if chroma stores are too big
    def index_inator(self):
        pass




