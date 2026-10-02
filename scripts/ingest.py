"""
SheGuard AI - Document Ingestion Script (P1)
One-time (re-runnable) script that extracts text from PDFs in data/,
chunks it, and loads it into ChromaDB for rag.py to query.

Usage:
    Drop safety-related PDFs (helpline directories, self-defense guides,
    legal rights info, etc.) into the data/ folder, then run:

        python scripts/ingest.py

    Run it again anytime you add new PDFs - it skips files already ingested
    (tracked by filename) to avoid duplicate chunks.
"""

import os
import sys
import glob
import pdfplumber
import chromadb

# Allow running this script directly (adds backend/ to path so we can
# reuse the same ChromaDB config/collection name as rag.py)
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "backend"))

from dotenv import load_dotenv
load_dotenv(os.path.join(os.path.dirname(__file__), "..", "backend", ".env"))

COLLECTION_NAME = "safety_docs"
DATA_DIR = os.path.join(os.path.dirname(__file__), "..", "data")
CHUNK_SIZE = 500
CHUNK_OVERLAP = 50


# ---------------------------------------------------------------------------
# ChromaDB client
# ---------------------------------------------------------------------------

def _get_collection():
    """Connects to the same persistent ChromaDB store rag.py uses."""
    db_path = os.getenv("CHROMA_DB_PATH", "./data/chroma_store")
    # CHROMA_DB_PATH in .env is relative to backend/ - resolve it from there
    if not os.path.isabs(db_path):
        db_path = os.path.join(os.path.dirname(__file__), "..", "backend", db_path)
    os.makedirs(db_path, exist_ok=True)

    client = chromadb.PersistentClient(path=db_path)
    return client.get_or_create_collection(name=COLLECTION_NAME)


# ---------------------------------------------------------------------------
# PDF text extraction
# ---------------------------------------------------------------------------

def extract_text_from_pdf(pdf_path: str) -> str:
    """Extracts all text from a PDF file using pdfplumber."""
    text_parts = []
    with pdfplumber.open(pdf_path) as pdf:
        for page in pdf.pages:
            page_text = page.extract_text()
            if page_text:
                text_parts.append(page_text)
    return "\n".join(text_parts)


# ---------------------------------------------------------------------------
# Chunking
# ---------------------------------------------------------------------------

def chunk_text(text: str, chunk_size: int = CHUNK_SIZE, overlap: int = CHUNK_OVERLAP) -> list[str]:
    """
    Splits text into overlapping word-based chunks for better retrieval
    granularity than embedding one giant document as a single vector.
    """
    words = text.split()
    if not words:
        return []

    chunks = []
    start = 0
    while start < len(words):
        end = start + chunk_size
        chunk = " ".join(words[start:end])
        if chunk.strip():
            chunks.append(chunk)
        start += chunk_size - overlap

    return chunks


# ---------------------------------------------------------------------------
# Ingestion
# ---------------------------------------------------------------------------

def ingest_pdf(pdf_path: str, collection) -> int:
    """
    Ingests a single PDF: extracts text, chunks it, adds to ChromaDB.
    Skips ingestion if this file's chunks already exist (by filename match).

    Returns:
        Number of chunks added (0 if skipped or file had no extractable text).
    """
    filename = os.path.basename(pdf_path)

    existing = collection.get(where={"source": filename})
    if existing["ids"]:
        print(f"  Skipping '{filename}' - already ingested ({len(existing['ids'])} chunks)")
        return 0

    text = extract_text_from_pdf(pdf_path)
    if not text.strip():
        print(f"  Warning: no extractable text in '{filename}'")
        return 0

    chunks = chunk_text(text)
    if not chunks:
        return 0

    ids = [f"{filename}_chunk_{i}" for i in range(len(chunks))]
    metadatas = [{"source": filename, "chunk_index": i} for i in range(len(chunks))]

    collection.add(documents=chunks, ids=ids, metadatas=metadatas)
    print(f"  Ingested '{filename}' - {len(chunks)} chunks added")
    return len(chunks)


def ingest_all(data_dir: str = DATA_DIR) -> None:
    """Scans data_dir for all PDF files and ingests each one."""
    pdf_paths = glob.glob(os.path.join(data_dir, "*.pdf"))

    if not pdf_paths:
        print(f"No PDF files found in '{data_dir}'.")
        print("Add safety-related PDFs there and re-run this script.")
        return

    collection = _get_collection()
    total_chunks = 0

    print(f"Found {len(pdf_paths)} PDF file(s) in '{data_dir}':")
    for pdf_path in pdf_paths:
        total_chunks += ingest_pdf(pdf_path, collection)

    print(f"\nDone. Collection '{COLLECTION_NAME}' now has {collection.count()} total chunks.")


if __name__ == "__main__":
    ingest_all()