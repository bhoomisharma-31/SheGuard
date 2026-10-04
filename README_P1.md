# SheGuard AI

A multi-agent women's safety mobile app. This README covers the backend
(P1, complete and **deployed**) and what P2/P3 need to know to build on top of it.

---

## Team & Ownership

| Owner | Scope |
|---|---|
| **P1** | `backend/` — FastAPI server, all AI/data logic (✅ complete, ✅ deployed) |
| **P2** | `mobile/src/agents/{LocationAgent,AlarmAgent,EvidenceAgent}.js`, `mobile/src/db/`, `mobile/src/tasks/` |
| **P3** | `mobile/src/agents/{VoiceAgent,ThreatAgent,CommunicationAgent,DecisionCoordinator}.js`, `mobile/src/hooks/`, `mobile/src/screens/`, `mobile/src/navigation/`, `mobile/src/services/firebase.js` |

**Rule:** don't edit files outside your scope. The backend exposes a fixed
API contract (see below) — build against that, not against backend
internals.

---

## 🚀 Live Backend

**Base URL:** `https://sheguard-ai-09r1.onrender.com`

This is now the permanent URL for all mobile integration — replace any
`localhost` or local WiFi IP in mobile code with this. No more
per-network IP juggling.

**Known behavior:** Render's free tier spins the service down after ~15
minutes of inactivity and wipes its filesystem on every spin-down (not just
redeploys). The first request after an idle period can take 10-30+ seconds
(cold start: container boot + re-downloading the RAG embedding model +
re-ingesting the PDF) before responding normally. This is expected, not a
bug — see "Startup re-ingestion" below for why it's safe.

---

## Tech Stack

- **Backend:** FastAPI, Gemini API (`gemini-3.6-flash`) via the **`google-genai`** SDK, ChromaDB + pdfplumber (RAG), Firebase (Firestore + FCM), Fast2SMS (SMS alerts)
- **Mobile:** React Native (Expo bare workflow), Firebase Firestore + FCM, expo-location, expo-sqlite, expo-audio
- **Deploy target:** Render (backend, ✅ live) + Expo EAS (mobile)

**Project decisions (do not deviate without team agreement):**
- Alarm = vibration only. No siren, no torch.
- ARM button required client-side before any alert can trigger.
- No AWS/S3. No timer feature.
- SMS provider is **Fast2SMS**, not Twilio (switched after hitting Twilio's
  India-number trial restrictions — see Session Summary for details).

> ⚠️ **SDK change (forced, not a stack change):** Google fully deprecated
> `google-generativeai` (end-of-life, no more updates/bug fixes, and it
> stopped authenticating with current API keys entirely). The backend now
> uses Google's official replacement, **`google-genai`**. The model
> (`gemini-3.6-flash`) and all behavior are unchanged — only the client
> library and its auth plumbing changed.

---

## Folder Structure

```
sheguard-ai-main/
├── backend/                     ← P1 (complete, deployed)
│   ├── main.py                  FastAPI app, 4 routes, CORS, startup re-ingestion hook
│   ├── alert.py                 Fast2SMS + Firestore alert logging
│   ├── rag.py                   ChromaDB retrieval + Gemini generation (google-genai)
│   ├── agents.py                ThreatAgent (Gemini-based threat scoring, google-genai)
│   ├── audio_analysis.py        Audio transcription (Gemini, google-genai) + threat pipeline
│   ├── requirements.txt
│   ├── .env.example             Template — copy to .env and fill in real keys
│   └── venv/                    Local virtual environment (not committed)
├── data/                        Source PDFs for RAG (drop safety docs here)
│   └── guidlines.pdf            Already ingested — Govt of India women's safety doc
├── scripts/
│   └── ingest.py                Also called automatically on every backend startup (see below)
├── .gitignore                   Root-level — excludes .env, venv/, __pycache__/, chroma_store/
└── mobile/src/                  ← P2 + P3 (in progress, pushed to repo separately when ready)
    ├── agents/
    ├── hooks/
    ├── screens/
    ├── navigation/
    ├── services/firebase.js
    ├── db/
    └── tasks/
```

---

## Running the Backend Locally

```bash
cd backend
python -m venv venv                      # first time only
source venv/bin/activate                 # every new terminal
pip install -r requirements.txt          # first time only
cp .env.example .env                     # first time only, then fill in real keys
uvicorn main:app --reload
```

Server runs at `http://127.0.0.1:8000`. Interactive docs (test routes in
browser) at `http://127.0.0.1:8000/docs`.

**Every new terminal tab needs `source venv/bin/activate`** before running
Python/pip/uvicorn commands. Plain `curl` doesn't need it.

---

## Environment Variables (`.env`)

Copy `.env.example` to `.env` and fill in real values. Never commit `.env` —
only `.env.example` should be tracked in git (enforced by `.gitignore`).

| Variable | Where to get it |
|---|---|
| `GEMINI_API_KEY` | https://aistudio.google.com/apikey |
| `GEMINI_MODEL` | `gemini-3.6-flash` (do not use `gemini-2.0-flash` — deprecated) |
| `FIREBASE_PROJECT_ID` / `FIREBASE_PRIVATE_KEY` / `FIREBASE_CLIENT_EMAIL` | Firebase Console → Project Settings → Service Accounts → Generate new private key (downloads a JSON with all 3 values) |
| `FAST2SMS_API_KEY` | https://www.fast2sms.com → Dev API tab (needs ₹100+ wallet top-up to unlock API route) |
| `CHROMA_DB_PATH` | Leave as `./data/chroma_store` (auto-created, auto-rebuilt on startup) |

**Note on `FIREBASE_PRIVATE_KEY` formatting:** must be wrapped in double
quotes in `.env`, with literal `\n` characters preserved exactly as copied
from the downloaded JSON — do not manually reformat it.

---

## Deploying to Render

The backend is already deployed, but for reference (e.g. redeploying from
scratch, or spinning up a staging instance):

1. Push `backend/`, `data/`, `scripts/`, and `.gitignore` to a GitHub repo (root-level repo, scoped `git add` — see Session Summary for the exact history of how this was set up).
2. Render → New → Web Service → connect the repo.
3. **Root Directory:** `backend` (Render still clones the whole repo — `data/` and `scripts/` stay reachable via relative paths from `backend/main.py`, this setting only changes where build/start commands run from).
4. **Build Command:** `pip install -r requirements.txt`
5. **Start Command:** `uvicorn main:app --host 0.0.0.0 --port $PORT` (must use Render's injected `$PORT` — do **not** also set a manual `PORT` env var, it conflicts with Render's own port assignment).
6. **Environment Variables:** all 7 keys from `.env`, plus `PYTHON_VERSION` → **`3.12.7`** (not 3.13.x — `chromadb==0.5.5` pins `numpy==1.26.4`, which has no prebuilt Linux wheel for Python 3.13 and will try to compile from source, risking a build timeout).
7. Deploy. Watch the build log for `Your service is live 🎉`.

---

## Startup re-ingestion (why RAG survives Render's free tier)

Render's free tier wipes the filesystem on every idle spin-down, not just
redeploys — so `data/chroma_store/` (the vector index) would silently go
empty after ~15 minutes of inactivity, with no error, just `has_context:
false` on every query forever after.

Fix: `main.py` now calls `scripts/ingest.py`'s `ingest_all()` on every
startup, inside a FastAPI `lifespan` hook, before the API starts serving
requests. `ingest_all()` already skips files it's already ingested (tracked
by filename), so this is a near-instant no-op on a warm filesystem and only
does real work (a few seconds) right after a fresh wipe. If ingestion fails
for any reason, it's caught and logged — `/health`, `/trigger-alert`, and
`/analyze-voice` still come up fine even if RAG is temporarily broken.

---

## API Routes (the contract P2/P3 build against)

### `GET /health`
Healthcheck. No auth, no body.
```json
→ {"status": "ok", "service": "SheGuard AI Backend"}
```

### `POST /analyze-voice`
Transcribes audio and scores threat level.
```json
Request:
{
  "audio_base64": "<base64-encoded audio, e.g. m4a/wav>",
  "user_id": "string"
}

Response:
{
  "transcript": "string",
  "threat_level": "low" | "medium" | "high",
  "confidence": 0.0-1.0,
  "reasoning": "string"
}
```

### `POST /trigger-alert`
Sends SMS to guardian + logs alert to Firestore. **ARM must be enabled
client-side before calling this** — the backend does not re-check ARM state.
```json
Request:
{
  "user_id": "string",
  "guardian_number": "10-digit Indian number, no +91 prefix",
  "latitude": float,
  "longitude": float,
  "reason": "string (optional)"
}

Response (200):
{
  "status": "alert_sent",
  "alert_id": "string",
  "sms_response": {...}
}

Response (502 - SMS failed but still logged):
{
  "detail": {
    "message": "Alert logged, but SMS failed to send",
    "sms_response": {...},
    "alert_id": "string"
  }
}
```

### `POST /rag-query`
Answers safety-related questions using ingested documents + Gemini.
```json
Request:
{
  "query": "string",
  "user_id": "string (optional)"
}

Response:
{
  "answer": "string",
  "sources_used": integer,
  "has_context": boolean
}
```

**Note:** `has_context: false` means no relevant document was found —
Gemini still gives a safe generic answer, it doesn't fail. To get grounded
answers, add more PDFs to `data/` and re-run `python scripts/ingest.py`
(or just redeploy — it runs automatically on every startup now).

---

## Adding More Knowledge to the RAG System

1. Drop a relevant PDF (safety guides, helpline directories, legal info) into `data/`
2. Commit and push — the next deploy's startup hook will ingest it automatically. (Or locally: `python scripts/ingest.py`)
3. Re-running is safe — it skips files already ingested (tracked by filename)

---

## All Routes Verified Live (not just localhost)

| Route | Status | Notes |
|---|---|---|
| `GET /health` | ✅ | Confirmed via direct URL hit |
| `POST /rag-query` | ✅ | Real grounded answers, `has_context: true`, `sources_used: 3` |
| `POST /analyze-voice` | ✅ | Real audio tested — correctly returned `threat_level: "high"`, `confidence: 0.98` on a distress sample |
| `POST /trigger-alert` | ✅ (logic verified) | Route executes end-to-end and reaches Fast2SMS correctly (tested with a placeholder number, got a real rejection response back — confirms the pipeline works). A full successful SMS send was confirmed earlier on the **local** backend; not yet re-confirmed with a real number against the live Render URL specifically. |

---

## Known Limitations / Things to Watch

- Firebase's Files API (used for large audio uploads) needs broader key
  permissions than a standard AI Studio key has — `audio_analysis.py`
  works around this by passing audio inline rather than uploading it as a
  file resource. Works fine for short clips; very large audio files may
  need a different approach later.
- Fast2SMS Quick SMS route (`route=q`, no DLT registration) is used —
  fine for this project's scale, but has per-message costs (~₹5/SMS) and a
  wallet balance requirement to keep API access active.
- Render free-tier cold starts (10-30+ seconds after idle) are expected
  behavior, not a bug — see "Live Backend" section above.
- `PYTHON_VERSION` on Render is pinned to `3.12.7`, not matching local dev
  environments on `3.13.x` — this is intentional (see Deploy section) and
  doesn't affect behavior, only build-time wheel availability.