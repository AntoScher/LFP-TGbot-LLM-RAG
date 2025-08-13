import os
import glob
import logging
from typing import List, Tuple

from langchain_community.embeddings import HuggingFaceEmbeddings
from langchain_community.vectorstores import Chroma


logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)


def find_files(root: str) -> List[str]:
    # Индексируем только текстовые форматы
    patterns = ["*.txt", "*.md"]
    files: List[str] = []
    for pattern in patterns:
        files.extend(glob.glob(os.path.join(root, pattern)))
    return files


def read_text_file(path: str) -> str:
    with open(path, "r", encoding="utf-8", errors="ignore") as f:
        return f.read()


def load_texts(paths: List[str]) -> Tuple[List[str], List[dict]]:
    texts: List[str] = []
    metadatas: List[dict] = []
    for path in paths:
        ext = os.path.splitext(path)[1].lower()
        try:
            if ext in [".txt", ".md"]:
                content = read_text_file(path)
            else:
                continue
            content = (content or "").strip()
            if not content:
                logger.warning(f"Empty content skipped: {path}")
                continue
            texts.append(content)
            metadatas.append({"source": path})
        except Exception as e:
            logger.warning(f"Failed to load {path}: {e}")
    return texts, metadatas


def main():
    root = os.getenv("KB_PATH", "knowledge_base")
    persist_dir = (
        os.getenv("PERSIST_DIRECTORY")
        or os.getenv("CHROMA_DB_PATH")
        or "./chroma_db"
    )

    logger.info(f"Loading documents from: {root}")
    paths = find_files(root)
    if not paths:
        logger.warning("No documents found to ingest")
        return

    logger.info(f"Found {len(paths)} files, loading...")
    texts, metadatas = load_texts(paths)
    if not texts:
        logger.warning("No documents loaded")
        return

    logger.info("Initializing embeddings...")
    embedder = HuggingFaceEmbeddings(
        model_name="sentence-transformers/all-MiniLM-L6-v2",
        model_kwargs={"device": "cpu"}
    )

    logger.info(f"Building/Updating Chroma at: {persist_dir}")
    vectordb = Chroma.from_texts(
        texts=texts,
        embedding=embedder,
        metadatas=metadatas,
        persist_directory=persist_dir
    )
    vectordb.persist()
    logger.info("Ingestion completed successfully")


if __name__ == "__main__":
    main()


