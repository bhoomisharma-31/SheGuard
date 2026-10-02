"""
SheGuard AI - Audio Analysis Module (P1)
Server-side voice transcription + threat analysis pipeline.

Primary transcription happens on-device (Whisper Tiny TFLite / Web Speech
API, per P3's mobile stack). This module provides a server-side path for
cases where the mobile app sends raw audio instead of a pre-transcribed
string - using Gemini's native audio understanding for transcription,
keeping the stack consistent (no separate heavy speech-to-text dependency).

Flow:
1. process_voice_analysis() is called from main.py's /analyze-voice route.
2. Decodes the base64 audio sent from the mobile app.
3. Transcribes it using Gemini (audio input support, passed inline).
4. Passes the transcript to agents.py's analyze_threat() for scoring.
5. Returns both the transcript and the threat assessment.
"""

import os
import base64
from google import genai
from google.genai import types

import agents as agents_module


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
# Transcription
# ---------------------------------------------------------------------------

def transcribe_audio(audio_base64: str, mime_type: str = "audio/m4a") -> str:
    """
    Transcribes base64-encoded audio to text using Gemini's audio understanding.

    Args:
        audio_base64: base64-encoded audio data (no data URI prefix)
        mime_type: audio format sent by the client (e.g. "audio/m4a", "audio/wav")

    Returns:
        The transcribed text. Empty string if audio couldn't be decoded.
    """
    try:
        audio_bytes = base64.b64decode(audio_base64)
    except (ValueError, TypeError) as e:
        raise ValueError(f"Invalid base64 audio data: {e}")

    client = _get_genai_client()
    model_name = os.getenv("GEMINI_MODEL", "gemini-3.6-flash")

    prompt = (
        "Transcribe the speech in this audio exactly as spoken. "
        "Return ONLY the transcript text, no commentary, no formatting."
    )

    # Pass audio inline (as a blob) rather than via the Files API - this uses
    # the same simple key-based auth as regular generateContent calls, and
    # avoids needing broader API key permissions the Files/discovery API requires.
    audio_part = types.Part.from_bytes(data=audio_bytes, mime_type=mime_type)
    response = client.models.generate_content(
        model=model_name,
        contents=[prompt, audio_part],
    )
    return response.text.strip()


# ---------------------------------------------------------------------------
# Main entrypoint - called from main.py's /analyze-voice route
# ---------------------------------------------------------------------------

def process_voice_analysis(audio_base64: str, user_id: str) -> dict:
    """
    Full voice analysis pipeline: transcribe audio, then assess threat level.

    Returns:
        dict with keys: transcript, threat_level, confidence, reasoning
    """
    transcript = transcribe_audio(audio_base64)

    if not transcript:
        return {
            "transcript": "",
            "threat_level": "low",
            "confidence": 0.0,
            "reasoning": "No speech detected in audio.",
        }

    threat_result = agents_module.analyze_threat(transcript)

    return {
        "transcript": transcript,
        "threat_level": threat_result["threat_level"],
        "confidence": threat_result["confidence"],
        "reasoning": threat_result["reasoning"],
    }