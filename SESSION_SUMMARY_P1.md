# SheGuard AI — P1 Deploy Session Summary

Reference document covering everything done in this session: taking the
already-complete backend from "working locally" to "deployed, live, and
tested in production." Use this to catch a new chat up to speed, or as a
record of decisions and reasoning.

---

## What was accomplished

Diagnosed and fixed a forced third-party SDK deprecation, rotated all
secrets, set up git for the first time, pushed to GitHub, deployed to
Render, and verified all 4 backend routes live against the deployed URL.

### 1. Root cause: Google fully deprecated `google-generativeai`

What looked like a simple stale-model-name bug (`gemini-2.0-flash` fallback
in `rag.py`) turned out to be two separate problems stacked on top of each
other:

- **Surface bug:** `rag.py` still had `"gemini-2.0-flash"` hardcoded as its
  fallback model string (line 4 docstring + line 103 code), while
  `agents.py` and `audio_analysis.py` already correctly defaulted to
  `gemini-3.6-flash`. Fixed by matching all three files.
- **Real blocker (found after rotating the API key didn't help):**
  `google-generativeai` (the old Gemini Python SDK) is fully end-of-life —
  "All support... has ended. It will no longer be receiving updates or bug
  fixes." Even on its final release (0.8.6), it could not authenticate with
  current-format API keys at all (`ACCESS_TOKEN_TYPE_UNSUPPORTED` /
  `UNAUTHENTICATED` errors), regardless of key validity.

**Fix:** migrated `rag.py`, `agents.py`, and `audio_analysis.py` from
`google.generativeai` to Google's official replacement, **`google-genai`**.
Model name and all behavior unchanged — only the client/auth plumbing
changed (`genai.configure()` + `GenerativeModel()` → a singleton
`genai.Client()` + `client.models.generate_content()`). Audio inline bytes
changed from a plain dict to `types.Part.from_bytes()`.

### 2. Key rotation

Rotated all three API keys as precautionary cleanup (the Gemini key was
already dead and had to be rotated regardless; Firebase and Fast2SMS were
rotated out of caution since the live `.env` values had been shared in a
chat upload earlier):
- Gemini API key (regenerated at aistudio.google.com)
- Firebase service account key (new private key generated from Firebase
  Console → Service Accounts)
- Fast2SMS API key (regenerated from the Dev API tab)

### 3. `main.py`: CORS + startup re-ingestion hook

Added two things the backend needed before it could be deployed
meaningfully:
- **CORS** (`CORSMiddleware`, `allow_origins=["*"]`) — needed before the
  mobile app can call the deployed backend from any network.
- **Startup re-ingestion hook** (`lifespan` context manager calling
  `scripts/ingest.py`'s `ingest_all()` before the API starts serving) —
  needed because Render's free tier wipes the filesystem on every ~15-min
  idle spin-down, not just redeploys. Without this, `data/chroma_store/`
  would silently go empty after any idle period, and RAG would quietly
  degrade to `has_context: false` forever with no error. `ingest_all()`
  already skips already-ingested files by filename, so this is a
  near-instant no-op on a warm filesystem.

### 4. `.gitignore` + first-ever `git init`

This was the project's first-ever git repository — no history to scrub,
clean slate. Decisions made:
- **Root-level repo** (`sheguard-ai-main/`, not `backend/` alone) — so
  `mobile/` can be added to the same repo later once P2/P3 finish, giving
  the whole team one shared URL.
- **Scoped first commit:** only `backend/`, `data/`, `scripts/`, and
  `.gitignore` were staged and committed — `mobile/` stays untracked until
  P2/P3 say it's ready. Git allows committing a subset of a directory's
  contents with no restructuring needed later.
- **`.gitignore` bug caught and fixed:** the first version used the pattern
  `data/chroma_store/`, which git anchors to the repo root only. The real
  Chroma store lives at `backend/data/chroma_store/` — a different path —
  so the pattern silently missed it, and the vector-store binary files got
  staged by accident. Fixed by changing the pattern to `**/chroma_store/`
  (matches at any depth), then `git rm -r --cached` to unstage the files
  that had already been added before the fix.
- Verified `.env` exclusion directly with `git check-ignore -v
  backend/.env` before ever running `git add`, as a sanity check.

### 5. `requirements.txt` cleanup

Two rounds of fixes:
- Initial SDK migration: `google-generativeai==0.8.2` → `google-genai`,
  plus `pydantic==2.9.2` → `pydantic==2.13.5` (installing `google-genai`
  forced a pydantic upgrade as a shared dependency).
- **Duplicate-line bug:** the pydantic/google-genai lines were initially
  *added* without removing the old ones, leaving two conflicting pydantic
  version pins in the same file. Render's build failed with
  `ResolutionImpossible` as a result. Fixed by replacing the entire file
  with one clean line per package.

### 6. Render deployment — two build failures before success

- **First failure:** `PYTHON_VERSION=3.13.1` (set as a "safety" measure to
  match local dev) caused `numpy==1.26.4` (pinned by `chromadb==0.5.5`) to
  have no prebuilt Linux wheel available, forcing a slow source compile
  that looked likely to time out. Fixed by changing `PYTHON_VERSION` to
  `3.12.7` — a version with prebuilt wheels available for this numpy
  version. Local dev stays on 3.13.x; this only affects Render's build
  environment.
- **`PORT` env var removed:** initially copied `PORT=8000` from the local
  `.env` into Render's environment variables. Render auto-injects its own
  `PORT` value and the start command (`--port $PORT`) is designed to read
  that — manually setting a conflicting value risks the classic
  "deploys successfully but times out / Bad Gateway" failure mode. Removed
  before the final successful deploy.
- **Git identity fixed** before pushing: the first local commit used an
  auto-generated placeholder git identity
  (`rashiwawale@Rashis-MacBook-Air.local`) — fixed with `git config
  --global` + `git commit --amend --reset-author` so GitHub commits
  attribute correctly to the real account.

### 7. Live testing — all 4 routes verified against the deployed URL

Final deployed URL: **`https://sheguard-ai-09r1.onrender.com`**

| Route | Result |
|---|---|
| `GET /health` | ✅ Confirmed via direct URL (Swagger's own "Try it out" button failed once with a browser-side fetch quirk, unrelated to the backend — direct URL hit is the more reliable test and it returned correctly) |
| `POST /rag-query` | ✅ Real grounded answer, `has_context: true`, `sources_used: 3` |
| `POST /analyze-voice` | ✅ Tested with real base64 audio — correctly transcribed and classified `threat_level: "high"`, `confidence: 0.98` on a distress sample. (One side issue: pasting the base64 string directly from a line-wrapped `.txt` file into Swagger broke JSON parsing with "Invalid control character" — fixed by stripping newlines with `tr -d '\n'` before pasting.) |
| `POST /trigger-alert` | ✅ logic verified — reached Fast2SMS and got a real API response (tested with a placeholder number, correctly got "Numbers Missing" back, confirming the pipeline executes correctly end-to-end). Full successful SMS delivery was confirmed earlier on the **local** backend only; not yet re-fired with a real number against the live Render URL. |

The build log also confirmed the startup re-ingestion hook works correctly
on a genuinely fresh cloud filesystem: `Ingested 'guidlines.pdf' - 5 chunks
added` on first boot, with ChromaDB's ~79MB embedding model downloading
automatically as part of that same cold start.

---

## Where things stand

**P1 (backend): 100% complete and deployed.** All 4 routes live and
functioning on Render. The only unclosed loose end is a full real-SMS test
against the live URL specifically (logic is identical to what already
worked locally, so this is a low-risk gap, not a known issue).

---

## Next steps (not done this session)

- Optional: fire one real `/trigger-alert` test with a live guardian number
  against the Render URL, to close the last verification gap.
- Message sent to P3 flagging the new permanent backend URL (replacing the
  local-WiFi-IP that `LocationAgent.js` was hardcoded to), CORS being
  enabled, and the cold-start delay behavior to expect.
- `mobile/` to be added to the same git repo once P2/P3 call their work
  ready — no restructuring needed, just `git add mobile/` into the existing
  repo.
- Automatic (no-tap) guardian calling is still a placeholder
  (`CommunicationAgent.js` logs but doesn't call) — `react-native-
  immediate-call-library` was found to be built on a dead/unmaintained
  toolchain incompatible with the current setup; a custom native Android
  module is the planned real fix, after voice/shake work lands (P3's
  tracking item, noted here for full-picture visibility).