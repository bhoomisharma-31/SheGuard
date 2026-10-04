# SheGuard AI — P2 Build Session Summary

Reference document covering everything done in this session. Use this to
catch a new chat up to speed, or as a record of decisions and reasoning.

---

## What was accomplished

Built, wired together, and **fully live-tested on a physical Android
device** (Samsung M32) the entire P2 mobile offline-agent layer for
SheGuard AI.

### 1. Native environment setup
- Expo bare workflow initialized inside `mobile/`, merged cleanly with
  P1's pre-existing `mobile/src/` folder structure (no files overwritten).
- Installed: `expo-location`, `expo-sqlite`, `expo-audio` (see note
  below), `expo-background-fetch`, `expo-task-manager`, `expo-haptics`,
  `@react-native-firebase/app`, `@react-native-firebase/firestore`.
- Android permissions configured in both `AndroidManifest.xml` and
  `app.json` (`android.permissions`), so they persist across future
  `expo prebuild` runs: `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`,
  `ACCESS_BACKGROUND_LOCATION`, `RECORD_AUDIO`, `FOREGROUND_SERVICE`,
  `FOREGROUND_SERVICE_LOCATION`, `POST_NOTIFICATIONS`, `VIBRATE`.
- Android package name corrected from an auto-generated
  `com.anonymous.mobile_temp` to the proper `com.sheguard.app`.
- Firebase apps registered in the `sheguard-8e01b` console for both
  Android (`google-services.json`) and iOS (`GoogleService-Info.plist`),
  even though iOS is future scope — needed because the Firebase Gradle
  plugin checks for both files during any Android prebuild.

### 2. Native build troubleshooting (the bulk of today's friction)
Real, non-trivial issues hit and resolved, in order:
- **Missing Android SDK** — installed via Homebrew
  (`android-commandlinetools`), set `ANDROID_HOME`, accepted licenses,
  installed `platform-tools`, `platforms;android-36`, `build-tools;36.0.0`.
- **JDK 26 incompatibility** — the default installed Java version was too
  new for Android's Gradle/jlink tooling. Installed JDK 17 (Temurin)
  specifically and pointed Gradle at it via
  `org.gradle.java.home` in `android/gradle.properties`, without
  disturbing the system-wide JDK 26 install.
- **CocoaPods + Firebase SPM conflict (iOS)** — `react-native-firebase`'s
  Swift Package Manager resolution conflicted with static linkage. Fixed
  with `$RNFirebaseDisableSPM = true` and `use_modular_headers!` at the
  top of `ios/Podfile`.
- **`expo-av` native crash** — `UnsatisfiedLinkError: dlopen failed:
  cannot locate symbol ..." referenced by "libexpo-av.so"` on every
  app launch. Root cause: `expo-av` is deprecated in SDK 57 and its
  native binaries don't link correctly. **Fixed by fully removing
  `expo-av` and replacing it with `expo-audio`** (the official
  replacement) project-wide. This was a real fix, not a workaround —
  confirmed by a clean rebuild resolving the crash completely.
- **`expo-audio`'s `AudioRecorder` API** — initial implementation
  imported `AudioRecorder` as a top-level export per official docs
  examples, but the installed version (57.0.4) only exposes it as
  `AudioModule.AudioRecorder`. Confirmed by inspecting the package's
  actual build output rather than trusting docs alone. Fixed by
  importing `AudioModule` and calling
  `new AudioModule.AudioRecorder(RecordingPresets.HIGH_QUALITY)`.

### 3. Agents built — all three fully written and tested

**`LocationAgent.js`**
- `start({ userId, guardianNumber, reason })` — fetches location
  immediately, then every 30 seconds until `stop()`.
- First fetch fires a one-time SMS via P1's `/trigger-alert` endpoint
  (subsequent fetches do NOT re-send SMS — avoids spamming the guardian).
- Every fetch saves locally first (SQLite, offline-safe), then attempts
  a live Firestore write to `alerts/{alertId}` (merged/updated in place,
  not new documents) for future guardian web tracking.
- Firestore writes currently fail gracefully (P3's `services/firebase.js`
  doesn't exist yet) — caught and queued for retry, confirmed working
  as designed via live device testing.

**`AlarmAgent.js`**
- `arm()`, `trigger()`, `disarm()`, `getState()`.
- Enforces the "ARM required before trigger" safety gate.
- `trigger()` gives a **single brief confirmation buzz** (2 short
  pulses via `Haptics.impactAsync(Heavy)`, NOT repeating) — deliberately
  changed from an initial repeating-vibration design after discussing
  that a loud/ongoing alarm would work against discretion during a real
  threat. Not yet confirmed felt on the test device (Samsung M32) —
  flagged as a minor open item.
- `trigger()` orchestrates BOTH `LocationAgent.start()` and
  `EvidenceAgent.start()` together — this was a deliberate design
  correction mid-session once the real app flow was clarified: the
  actual UI only has ARM/DISARM/SOS, so trigger must do everything
  automatically, not require separate manual actions.
- `disarm()` stops both agents together.

**`EvidenceAgent.js`**
- `start({ alertId })` / `stop()` / `getState()`.
- Uses `expo-audio`'s `AudioModule.AudioRecorder` (HIGH_QUALITY preset).
- Saves only a **reference** to the recorded file (uri, type, timestamp)
  locally via `sqlite.js` — the actual audio file stays on-device
  filesystem (`file:///data/user/0/com.sheguard.app/cache/Audio/...`).

### 4. Local storage layer

**`db/sqlite.js`**
- `locations` table — fully implemented: `saveLocationLocally()`,
  `getUnsyncedLocations()`, `markLocationSynced()`,
  `getLastKnownLocation()`.
- `alarm_events` and `evidence` tables — schema created, minimal insert
  functions (`saveAlarmEventLocally()`, `saveEvidenceReferenceLocally()`).
- Every table has a `synced` flag (0/1) supporting the retry-queue design.
- Uses `expo-sqlite`'s modern async API (`openDatabaseAsync`, SDK 57).

**`db/syncQueue.js`**
- `queueLocationForSync()` — called by `LocationAgent` on Firestore
  write failure (data is already safe locally via `sqlite.js`; this is
  an explicit retry-signal hook point).
- `syncPendingLocations()` — reads all unsynced rows, attempts to push
  each to Firestore, marks successes. Called by `backgroundSync.js`.

**`tasks/backgroundSync.js`**
- Registers a periodic background task via `expo-task-manager` +
  `expo-background-fetch` that calls `syncPendingLocations()`.
- Explicitly documented as a **safety net, not a guarantee** — OS
  throttles background fetch heavily (Android/iOS both, often 15+ min
  between runs). Foreground tracking (LocationAgent's own 30-sec
  interval) is what's actually reliable; this exists for
  backgrounded/killed-app scenarios.
- **Written but not live-verified** — would require backgrounding the
  app for 15+ minutes to observe, not done this session.

### 5. End-to-end testing (real device, real backend, real SMS)

Built a temporary test screen (`App.js` — ARM/TRIGGER/DISARM +
RECORD/STOP buttons, later simplified once AlarmAgent absorbed
Evidence orchestration) to verify the full chain without waiting for
P3's real UI.

Confirmed working, with real evidence:
- Backend (`uvicorn main:app --host 0.0.0.0 --reload`) reachable from
  phone over WiFi via Mac's local IP (`192.168.0.102:8000`) — required
  `--host 0.0.0.0` since default `127.0.0.1` binding isn't
  phone-reachable.
- **Real SMS delivered** to a real phone number via the full chain:
  App → `AlarmAgent.trigger()` → `LocationAgent.start()` → POST
  `/trigger-alert` → P1's `alert.py` → Fast2SMS → real SMS received.
- Backend logs confirm multiple clean `POST /trigger-alert` → `200 OK`
  responses across repeated ARM/TRIGGER/DISARM cycles.
- Audio evidence recording confirmed: file saved to a real on-device
  path, logged and referenced correctly.
- Local SQLite + sync retry queue confirmed working exactly as
  designed — Firestore failures (expected, pending P3's `firebase.js`)
  were caught and queued rather than crashing anything.

### 6a. Changes made after P3 started integrating (relayed by P2 through the team)

Once P3 began building their screens/`services/firebase.js` and testing
against P2's agents, P3 relayed several required/attempted changes.
These were implemented exactly as specified where P2 received actual
code-level instructions, and are flagged as unconfirmed where only a
prose description was given — per the project rule to follow the
context exactly and not introduce unconfirmed deviations.

**Implemented in this session (P2 has the actual code):**

- **Firestore modular API migration** — `@react-native-firebase/firestore`
  v26 fully removed the old `.collection().doc().set()` chaining. P3
  flagged this exact breakage. Fixed in `LocationAgent.js`'s
  `_updateFirestoreLocation()`:
  ```js
  import { doc, setDoc } from '@react-native-firebase/firestore';
  ...
  await setDoc(
    doc(firestore, 'alerts', this.alertId),
    { latitude, longitude, lastUpdated: timestamp, active: true },
    { merge: true }
  );
  ```
  Proactively applied the same fix to `syncQueue.js`'s
  `syncPendingLocations()` (same root cause, same chained-API pattern) —
  confirmed `EvidenceAgent.js` and `sqlite.js` contain no Firestore code
  at all, so no fix was needed there.
- **`CommunicationAgent.callGuardian()` wired into `AlarmAgent.trigger()`**
  — guardian is now "called" automatically as part of trigger, no manual
  action needed:
  ```js
  import { callGuardian } from './CommunicationAgent';
  ...
  await callGuardian(ctxGuardianNumber);
  ```
  Per P3: `CommunicationAgent.js` currently ships as a **safe no-op
  placeholder** — it does not place a real call yet. The originally
  attempted library (`react-native-immediate-call-library`) depends on a
  dead/unmaintained toolchain (`jcenter()`, pre-2018 Gradle) incompatible
  with the current build setup. A real implementation needs a custom
  native Android module, planned as a follow-up after voice/shake
  detection work. Guardian notification today is effectively SMS-only
  (working); the auto-call is scaffolded but inert.

**Described by P3, NOT yet seen as actual code in P2's working copy —
flagged here instead of guessed at:**

- **`mobile/src/config.js`** (new file, P3-introduced) as the single
  source of truth for `BACKEND_URL`, intended to replace
  `LocationAgent.js`'s previously hardcoded local dev IP
  (`192.168.0.102:8000`). Backend is reportedly now deployed live at
  `https://sheguard-ai-09r1.onrender.com` (per P1/P3), which would
  remove the "same WiFi only" limitation entirely once wired in.
- **Shared `alertId`** — P3 described generating one `alertId` per
  `trigger()` call and passing it into `LocationAgent.start()`,
  `EvidenceAgent.start()`, and `_logEvent()`, fixing a bug where each
  agent generated its own separate id for the same alert. Described as
  an edit to `LocationAgent.js`'s `start()` signature (optional
  `alertId` param) and to `AlarmAgent.js`.
- **`Promise.allSettled()` parallelization** — P3 described changing
  `AlarmAgent.trigger()`'s three trigger-time actions (location, call,
  evidence) from sequential awaits to `Promise.allSettled()`, to cut
  measured SOS latency from ~7–10s to ~5–7s.

**Why these three are flagged instead of implemented:** only a prose
description of these changes was relayed, not the actual diff/code as
P3 left it. To avoid silently deviating from what P3 actually wrote
(and risking a mismatch when P2 and P3's code is combined), P2's
working copy of `AlarmAgent.js`/`LocationAgent.js` still has: sequential
try/catch awaits for the three trigger-time actions, no shared
`alertId` param plumbed through, and `BACKEND_TRIGGER_ALERT_URL` still
hardcoded in `LocationAgent.js` rather than imported from `config.js`.
**Next step: get the actual updated files/diff from P3 (or confirmation
to implement from the description) before this is reconciled.**

### 6. Design decisions made this session (worth remembering)

- **Guardian tracking: Option B chosen** — a web link (via Firebase
  Hosting reading Firestore live) rather than requiring the guardian to
  install the app and log in (Option A). Option A is explicitly deferred
  to future scope, to be revisited after the base app (SMS + location)
  is fully working. (Also saved to persistent memory.)
- **SMS fires once per trigger, not repeatedly** — location updates
  after the first go to Firestore only, to avoid spamming the guardian.
- **Vibration redesigned mid-session**: originally a repeating buzz
  every 800ms; changed to a single brief 2-pulse confirmation after
  discussing that discretion matters more than an obvious alarm during
  a real threat.
- **AlarmAgent orchestrates Evidence + Location together** — corrected
  from an initial design where they were separate manual actions, once
  it was clarified the real app only has ARM/DISARM/SOS buttons and SOS
  must do everything automatically.
- **Two independent entry points into `trigger()`** — added after P3
  clarified the real intended flow. Originally `trigger()` had a hard
  safety gate requiring `arm()` first. P3 clarified that SOS is a
  **separate emergency path**, not "trigger without arm": a user
  pressing SOS directly already knows it's an emergency and shouldn't
  need to ARM first. Updated `trigger()` to accept optional
  `{ userId, guardianNumber }` directly so it can self-establish context
  when called without a prior `arm()` — while the ARM-then-auto-trigger
  path (via ThreatAgent/VoiceAgent) is unchanged and still relies on
  `arm()` having set that context. Internal state (`isArmed`,
  `isTriggered`) stays consistent regardless of which path was used, so
  `disarm()` works correctly either way. **This change has not been
  live-tested yet** — written and reasoned through, but verification is
  planned together with P3 once their SOS button/UI exists, since it's
  the natural integration point to test both paths at once.

---

## Where things stand

**P2 (mobile offline agents): ~90% complete, now actively integrating with P3.**
All owned code (3 agents, local storage, sync retry) is written, wired
together correctly, and was proven working end-to-end on a real device
with a real SMS delivered (local backend, at the time). Since then, P3
has started building their side and integration has begun:
- Firestore modular API migration done (`LocationAgent.js`, `syncQueue.js`).
- `callGuardian()` wired into `trigger()` (currently a no-op on P3's
  side — see 6a above).
- Two independent entry points into `trigger()` (ARM-gated vs. direct
  SOS) — written, **not yet live-tested with P3**; per explicit team
  decision, this will be tested together with P3, not solo, once
  integration is further along.
- `config.js` (`BACKEND_URL`), shared `alertId`, and
  `Promise.allSettled()` parallelization are **described by P3 but not
  yet reconciled into P2's working copy** — flagged in detail in
  section 6a. This is the main outstanding gap before docs and code are
  in full agreement.

**P1 (backend): 100% complete**, and per P3's relay, now **deployed
live** at `https://sheguard-ai-09r1.onrender.com` (previously only
verified running locally/reachable over WiFi).

**P3 (mobile UI/voice/navigation/Firebase): in progress.**
Actively integrating with P2's agents — has made/requested the changes
in section 6a above. `services/firebase.js` presumably exists now (or is
in progress) since Firestore-related changes are being tested.

## Next steps (not done this session)

- **Reconcile `config.js`, shared `alertId`, and `Promise.allSettled()`**
  — get the actual updated code/diff from P3 (or confirmation to
  implement from their description) and apply to P2's working copy of
  `AlarmAgent.js` / `LocationAgent.js`. Currently only described in
  prose, not yet real code on P2's side.
- **Test the SOS-without-ARM `trigger()` path together with P3** — per
  explicit instruction, not to be tested solo. Do this once the above
  reconciliation is done and P3's SOS button/UI exists.
- Confirm whether `services/firebase.js` now exists and whether live
  Firestore writes are succeeding (previously failed gracefully as
  expected, pending this file).
- Background sync live verification (optional, low priority).
- Guardian web-tracking page (Option B) — future scope, not yet started,
  no owner assigned yet.
- Revisit vibration feedback (not felt on test device despite using
  `impactAsync(Heavy)`) — low priority.
- `.gitignore` still needs adding before any GitHub push (P1's task,
  worth a reminder to the team).
- Real guardian auto-call (`CommunicationAgent.js`) needs a custom
  native Android module — deferred, not P2's task, but worth tracking
  since `AlarmAgent.trigger()` already calls it.