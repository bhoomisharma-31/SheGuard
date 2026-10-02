"""
SheGuard AI - RAG Module (P1)
Retrieval-Augmented Generation for safety-related queries.
Stack: ChromaDB (vector store) + Gemini API (gemini-3.6-flash) for generation.

Flow:
1. rag_query() is called from main.py's /rag-query route.
2. Retrieves top-matching document chunks from ChromaDB for the query.
3. Sends the query + retrieved context to Gemini, asking it to answer
   using only that context.
4. Returns the answer along with which source chunks were used.

NOTE: ChromaDB will be empty until scripts/ingest.py is built and run with
real documents (safety guides, helpline info, etc.). Until then, this module
will correctly report "no relevant information found" for every query -
that's expected, not a bug.
"""

import os
import chromadb
from google import genai


# ---------------------------------------------------------------------------
# ChromaDB client (singleton pattern - init once, reuse)
# ---------------------------------------------------------------------------

_chroma_client = None
_collection = None

COLLECTION_NAME = "safety_docs"


def _init_chroma():
    """
    Initializes a persistent ChromaDB client using CHROMA_DB_PATH from .env.
    Safe to call multiple times - only initializes once.
    """
    global _chroma_client, _collection

    if _chroma_client is not None:
        return _collection

    db_path = os.getenv("CHROMA_DB_PATH", "./data/chroma_store")
    os.makedirs(db_path, exist_ok=True)

    _chroma_client = chromadb.PersistentClient(path=db_path)
    _collection = _chroma_client.get_or_create_collection(name=COLLECTION_NAME)
    return _collection


# ---------------------------------------------------------------------------
# Gemini setup
# ---------------------------------------------------------------------------

_genai_client = None


def _get_genai_client():
    """Creates (once) and returns a google-genai Client using the API key from .env."""
    global _genai_client

    if _genai_client is not None:
        return _genai_client

    api_key = os.getenv("GEMINI_API_KEY")
    if not api_key:
        raise RuntimeError("GEMINI_API_KEY missing in .env")
    _genai_client = genai.Client(api_key=api_key)
    return _genai_client


# ---------------------------------------------------------------------------
# Retrieval
# ---------------------------------------------------------------------------

def query_documents(query: str, n_results: int = 3) -> list[dict]:
    """
    Retrieves the top-matching document chunks from ChromaDB for a query.

    Returns:
        List of dicts with 'text' and 'metadata' keys. Empty list if the
        collection has no documents yet (expected before ingest.py is run).
    """
    collection = _init_chroma()

    if collection.count() == 0:
        return []

    results = collection.query(query_texts=[query], n_results=n_results)

    chunks = []
    documents = results.get("documents", [[]])[0]
    metadatas = results.get("metadatas", [[]])[0]

    for text, meta in zip(documents, metadatas):
        chunks.append({"text": text, "metadata": meta or {}})

    return chunks


# ---------------------------------------------------------------------------
# Generation
# ---------------------------------------------------------------------------

def generate_answer(query: str, context_chunks: list[dict]) -> str:
    """
    Generates an answer using Gemini, grounded in the retrieved context chunks.
    If no context is available, asks Gemini to say so rather than guessing.
    """
    client = _get_genai_client()
    model_name = os.getenv("GEMINI_MODEL", "gemini-3.6-flash")

    if not context_chunks:
        prompt = (
            "You are SheGuard AI, a women's safety assistant. "
            "No relevant reference material was found in the knowledge base for "
            "the following question. Politely say you don't have specific "
            "information on this topic yet, and suggest contacting local "
            "emergency services or a trusted contact if it's urgent. "
            f"\n\nQuestion: {query}"
        )
    else:
        context_text = "\n\n".join(
            f"[Source {i+1}]: {chunk['text']}" for i, chunk in enumerate(context_chunks)
        )
        prompt = (
            "You are SheGuard AI, a women's safety assistant. Answer the "
            "question using ONLY the reference material below. If the "
            "material doesn't fully answer it, say what you can and note "
            "the gap. Keep the answer concise and practical.\n\n"
            f"Reference material:\n{context_text}\n\n"
            f"Question: {query}"
        )

    response = client.models.generate_content(model=model_name, contents=prompt)
    return response.text


# ---------------------------------------------------------------------------
# Main entrypoint - called from main.py's /rag-query route
# ---------------------------------------------------------------------------

def rag_query(query: str, user_id: str | None = None) -> dict:
    """
    Executes the full RAG flow: retrieve context + generate grounded answer.

    Returns:
        dict with keys: answer, sources_used (count), has_context (bool)
    """
    chunks = query_documents(query)
    answer = generate_answer(query, chunks)

    return {
        "answer": answer,
        "sources_used": len(chunks),
        "has_context": len(chunks) > 0,
    }