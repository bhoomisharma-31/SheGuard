"""
SheGuard AI - Backend (P1)
FastAPI entrypoint with 4 core routes.
Stack: FastAPI + Gemini API (gemini-3.6-flash), ChromaDB + pdfplumber (RAG), Fast2SMS.
No S3, no siren/torch, no timer — per project decisions.
"""

import os
import sys
from contextlib import asynccontextmanager
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

import alert as alert_module
import rag as rag_module
import audio_analysis as audio_analysis_module

load_dotenv()

# Reuse scripts/ingest.py's ingest_all() rather than duplicating ingestion
# logic here. Resolved relative to this file (not the caller's cwd), so it
# works whether main.py runs locally from backend/ or on Render.
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "scripts"))
from ingest import ingest_all


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Render's free tier wipes the filesystem on every spin-down (not just
    # redeploys) - ChromaDB's index can't be assumed to survive between
    # runs. Rebuild it from the committed PDFs in data/ on every boot.
    # ingest_all() already skips files it has already ingested by filename,
    # so this is a near-instant no-op on a warm/unwiped filesystem and only
    # does real work right after a fresh wipe (adds a few seconds then).
    try:
        ingest_all()
    except Exception as e:
        # Never let a RAG-ingestion hiccup block the whole API from starting
        print(f"[startup] RAG ingestion skipped/failed: {e}")
    yield


app = FastAPI(title="SheGuard AI Backend", version="0.1.0", lifespan=lifespan)

# Mobile app has no fixed origin (Expo dev client / native build), so allow
# all origins for now. Tighten this once there's a real deployed frontend
# domain to pin it to.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------------------------------------------------------------------
# Request/response models
# ---------------------------------------------------------------------------

class VoiceAnalysisRequest(BaseModel):
    audio_base64: str
    user_id: str


class AlertRequest(BaseModel):
    user_id: str
    guardian_number: str
    latitude: float
    longitude: float
    reason: str | None = None


class RagQueryRequest(BaseModel):
    query: str
    user_id: str | None = None


# ---------------------------------------------------------------------------
# Routes
# ---------------------------------------------------------------------------

@app.get("/health")
def health_check():
    """Simple healthcheck for localhost run."""
    return {"status": "ok", "service": "SheGuard AI Backend"}


@app.post("/analyze-voice")
def analyze_voice(payload: VoiceAnalysisRequest):
    """
    Runs voice/threat analysis pipeline: transcribes audio via Gemini,
    then scores threat level via agents.py's ThreatAgent.
    """
    result = audio_analysis_module.process_voice_analysis(
        audio_base64=payload.audio_base64,
        user_id=payload.user_id,
    )
    return result


@app.post("/trigger-alert")
def trigger_alert(payload: AlertRequest):
    """
    Triggers alarm workflow: vibration alert (client-side) + Fast2SMS to guardian.
    ARM must already be set client-side before this endpoint is ever called.
    """
    result = alert_module.trigger_alert(
        user_id=payload.user_id,
        guardian_number=payload.guardian_number,
        latitude=payload.latitude,
        longitude=payload.longitude,
        reason=payload.reason,
    )

    if not result["sms_success"]:
        raise HTTPException(
            status_code=502,
            detail={
                "message": "Alert logged, but SMS failed to send",
                "sms_response": result["sms_response"],
                "alert_id": result["alert_id"],
            },
        )

    return {
        "status": "alert_sent",
        "alert_id": result["alert_id"],
        "sms_response": result["sms_response"],
    }


@app.post("/rag-query")
def rag_query(payload: RagQueryRequest):
    """
    Queries ChromaDB (ingested via scripts/ingest.py + pdfplumber) and
    generates a response using Gemini API.
    """
    result = rag_module.rag_query(query=payload.query, user_id=payload.user_id)
    return result


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host=os.getenv("HOST", "0.0.0.0"),
        port=int(os.getenv("PORT", 8000)),
        reload=True,
    )