"""
SheGuard AI - Agents Module (P1)
Server-side ThreatAgent: analyzes a voice transcript using Gemini to assess
danger level as a second opinion alongside the mobile app's rule-based
ThreatAgent.js (P3).

Flow:
1. analyze_threat() is called from main.py's /analyze-voice route, after
   audio_analysis.py has converted audio to a text transcript.
2. Sends the transcript to Gemini with a strict prompt asking it to classify
   threat level and explain why - designed to avoid false positives on
   normal conversation.
3. Returns a structured result the mobile app can act on.

NOTE: This is a supplementary AI-based check, not the primary trigger.
Per project decisions, ARM must be enabled client-side before any alert
fires - this module only assesses threat level, it does not trigger alerts
itself. main.py decides what to do with the result.
"""

import os
import json
from google import genai


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
# Threat analysis prompt
# ---------------------------------------------------------------------------

_THREAT_PROMPT_TEMPLATE = """You are ThreatAgent, part of a women's safety app called SheGuard AI. \
You will be given a transcript of audio captured from a user's phone microphone. \
Your job is to assess whether the transcript indicates the user may be in danger.

Be conservative: normal conversation, background noise transcribed as words, \
or ambiguous phrases should NOT be classified as high threat. Only classify as \
"high" if there is clear evidence of distress, a threat from another person, \
someone being followed/attacked, or explicit calls for help.

Respond with ONLY a JSON object in this exact format, no other text:
{{
  "threat_level": "low" | "medium" | "high",
  "confidence": <float between 0 and 1>,
  "reasoning": "<one sentence explanation>"
}}

Transcript: "{transcript}"
"""


def analyze_threat(transcript: str, context: str | None = None) -> dict:
    """
    Analyzes a voice transcript for signs of danger using Gemini.

    Args:
        transcript: the text transcript of captured audio
        context: optional extra context (e.g. time of day, location description)

    Returns:
        dict with keys: threat_level ("low"/"medium"/"high"), confidence (float),
        reasoning (str). Falls back to a safe "low" default with an error note
        if Gemini's response can't be parsed - never lets a parsing issue
        block the app.
    """
    client = _get_genai_client()
    model_name = os.getenv("GEMINI_MODEL", "gemini-3.6-flash")

    prompt = _THREAT_PROMPT_TEMPLATE.format(transcript=transcript)
    if context:
        prompt += f"\nAdditional context: {context}"

    response = client.models.generate_content(model=model_name, contents=prompt)
    raw_text = response.text.strip()

    # Gemini sometimes wraps JSON in ```json ... ``` - strip that if present
    if raw_text.startswith("```"):
        raw_text = raw_text.strip("`")
        if raw_text.startswith("json"):
            raw_text = raw_text[4:].strip()

    try:
        result = json.loads(raw_text)
        return {
            "threat_level": result.get("threat_level", "low"),
            "confidence": float(result.get("confidence", 0.0)),
            "reasoning": result.get("reasoning", ""),
        }
    except (json.JSONDecodeError, ValueError, TypeError):
        # Fail safe: never crash the endpoint over a parsing hiccup
        return {
            "threat_level": "low",
            "confidence": 0.0,
            "reasoning": f"Could not parse model response: {raw_text[:200]}",
        }