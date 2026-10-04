# SheGuard AI — P2 README (Mobile Offline Agents)

This document is for **P3** (and anyone else) integrating with P2's work.
P2 owns: `LocationAgent.js`, `AlarmAgent.js`, `EvidenceAgent.js`, `db/`,
`tasks/`. You should not need to read the internals of these files to use
them — this doc covers everything you need to call them correctly.

---

## The big picture

The real app only has **3 buttons: ARM, DISARM, SOS** (per project
decisions). P2's agents map directly onto this:

- **ARM** → app is "listening" but not doing anything alarming yet. If
  your `ThreatAgent`/`VoiceAgent` detects something later, call
  `AlarmAgent.trigger({ reason })` — no need to pass user/guardian info,
  `arm()` already set it.
- **SOS** (direct emergency, no ARM step) → user already knows it's an
  emergency, so this bypasses ARM by design — SOS itself is the
  confirmation of intent. Call
  `AlarmAgent.trigger({ userId, guardianNumber, reason })` directly.

Either path leads to the same result: confirmation buzz, one-time SMS
to guardian, live location tracking (every 30s), and audio evidence
recording — all started together automatically.
- **DISARM** → stops all of the above.

You do NOT need to call `LocationAgent` or `EvidenceAgent` directly —
`AlarmAgent` orchestrates both of them internally. Just call
`AlarmAgent`'s methods below.

---

## What to call — `AlarmAgent.js`

```js
import AlarmAgent from '../agents/AlarmAgent'; // adjust path as needed
```

### `AlarmAgent.arm({ userId, guardianNumber })`
Call when the user presses ARM.
- `userId` (string) — current user's id
- `guardianNumber` (string) — guardian's 10-digit Indian mobile number,
  **no +91 prefix** (confirmed against P1's `alert.py` — it expects
  plain 10-digit numbers, comma-separated if multiple)

  ⚠️ **P2 does NOT fetch this for you.** Per project decision, the
  guardian number is saved in Firestore — your screen (likely
  `SettingsScreen.jsx`) is responsible for reading it from Firestore
  and passing it into `arm()`. `AlarmAgent` just takes whatever string
  you give it.

### `AlarmAgent.trigger({ userId, guardianNumber, reason })`
**Two independent ways to call this** — matches the real app having two
separate paths into an alert:

**Path 1 — ARM was already active** (e.g. your `ThreatAgent`/`VoiceAgent`
detected something after the user pressed ARM):
```js
AlarmAgent.trigger({ reason: 'Voice keyword detected' });
```
No need to pass `userId`/`guardianNumber` here — `arm()` already set them.

**Path 2 — Direct SOS, no ARM step** (user presses SOS immediately,
already knows it's an emergency — SOS itself is the confirmation of
intent, so this bypasses the ARM requirement by design):
```js
AlarmAgent.trigger({ userId, guardianNumber, reason: 'Direct SOS' });
```
Here you MUST pass `userId` and `guardianNumber` directly, since `arm()`
was never called to set them. If you call `trigger()` without prior
`arm()` AND without these two params, it throws `MISSING_CONTEXT_FOR_SOS`.

**Either way:**
- `reason` (string, optional) — e.g. `"Manual SOS"` or
  `"Voice keyword detected"` — passed through to the SMS alert context.
- After a direct-SOS trigger, `getState()` correctly reports
  `{ isArmed: true, isTriggered: true }` — internal state stays
  consistent no matter which path was used, so `disarm()` works
  correctly afterward either way.
- **Idempotent-ish:** calling `trigger()` twice in a row while already
  triggered is a no-op (logged as ignored), so you don't need to
  debounce your SOS button.

### `AlarmAgent.disarm()`
Call when the user presses DISARM. Stops location tracking, stops
evidence recording, resets state.

### `AlarmAgent.getState()`
Returns `{ isArmed: boolean, isTriggered: boolean }` — use this to drive
your UI (e.g. show/hide an "active alert" banner).

---

## What happens automatically inside `trigger()` (for your context, not for you to call)

1. Confirmation buzz — 2 short vibration pulses, not repeating. Deliberately
   NOT a loud/ongoing vibration (discretion matters during a real threat).
2. `LocationAgent.start()` — fires ONE SMS via P1's `/trigger-alert`
   backend route (URL now read from `config.js`'s `BACKEND_URL`), then
   updates location every 30 seconds until stopped.
3. `CommunicationAgent.callGuardian()` — automatically "calls" the
   guardian (currently a no-op placeholder — see note below).
4. `EvidenceAgent.start()` — begins audio recording.
5. All of the above run **locally-first**: every location + event is
   saved to on-device SQLite immediately, so nothing is lost if network
   drops. Failed network/Firestore writes are automatically queued for
   retry (see `db/syncQueue.js`).

Currently these three actions (location, call, evidence) run as
sequential awaits, each in its own try/catch so one failing doesn't
block the others — see the "not yet incorporated" note below for a
planned `Promise.allSettled()` change.

---

## ⚠️ Note: `expo-av` is no longer in the stack

The original project context file still lists `expo-av (audio
recording)` in the stack section — that's now outdated. `expo-av` was
removed and replaced with `expo-audio` project-wide (see session summary
for why). If you see `expo-av` referenced anywhere, treat it as stale.

---

## ⚠️ Dependency YOU need to provide: `services/firebase.js`

`LocationAgent.js` imports:
```js
import { firestore } from '../services/firebase';
```

This file must export an **initialized Firestore instance** named
`firestore`. Until it exists (or if it's broken), live location updates
fail gracefully (caught, logged, queued for retry) — everything else
(SMS, evidence recording, local storage) works fine without it.

**Firestore write shape P2 now uses — UPDATED, modular API (v26+):**

`@react-native-firebase/firestore` v26 fully removed the old
`.collection().doc().set()` chaining. P2's code (both
`LocationAgent.js` and `syncQueue.js`) was migrated to the modular API:

```js
import { doc, setDoc } from '@react-native-firebase/firestore';

await setDoc(
  doc(firestore, 'alerts', alertId),
  { latitude, longitude, lastUpdated: timestamp, active: true },
  { merge: true }
);
```

If anything else in the app (your screens, other agents) still uses the
old chained syntax against this same `firestore` instance, it will throw
— make sure any Firestore reads/writes you add use the modular
`import { ... } from '@react-native-firebase/firestore'` functions too.

This is the same document (`alerts/{alertId}`, updated in place, not a
new doc per update) your guardian-tracking web page (Option B, per
project decision — no app install needed for guardian) will read from
with a real-time listener (`onSnapshot`) once that's built.

---

## `config.js` — single source of truth for the backend URL

`mobile/src/config.js` now holds `BACKEND_URL`. `LocationAgent.js` reads
the trigger-alert endpoint from there instead of a hardcoded local IP.
Backend is live at `https://sheguard-ai-09r1.onrender.com` (per P1/P3) —
if you add any other backend calls, import `BACKEND_URL` from
`config.js` rather than hardcoding another URL, so there's one place to
change if the deployment URL ever changes.

---

## Guardian call — `AlarmAgent.trigger()` now calls `CommunicationAgent.callGuardian()`

As part of `trigger()`, P2's code now also calls:
```js
import { callGuardian } from './CommunicationAgent'; // P3-owned
...
await callGuardian(guardianNumber);
```

⚠️ **`CommunicationAgent.js` is currently a safe no-op placeholder** (per
P3) — it does not actually place a phone call yet. The library originally
tried (`react-native-immediate-call-library`) is built on a dead/
unmaintained toolchain (`jcenter()`, pre-2018 Gradle) incompatible with
this project's setup. A real auto-call feature needs a custom native
Android module — planned as a follow-up once voice/shake detection work
is further along. Nothing on P2's side needs to change for this; just
know that "guardian gets called automatically" is wired up and will
start working the moment `callGuardian()` has a real implementation —
zero changes needed in `AlarmAgent.js` when that lands.

---

## ⚠️ Not yet incorporated — flagging so this doc stays accurate

P3 described two further planned edits to `AlarmAgent.js` /
`LocationAgent.js` that have **not yet been applied to the code shown in
this repo / reflected below**:
- Parallelizing the three trigger-time actions (`LocationAgent.start`,
  `callGuardian`, `EvidenceAgent.start`) with `Promise.allSettled()`
  instead of sequential awaits, to cut SOS latency.
- Generating a single shared `alertId` once per `trigger()` call and
  passing it to `LocationAgent`, `EvidenceAgent`, and `_logEvent()`
  (fixing each agent currently being able to generate its own separate
  id for the same alert).

If/when the actual updated code for these two changes is available,
P2's working copy and this doc need to be updated to match — until
then, treat `trigger()`'s current behavior as: sequential awaits, and
each agent may generate its own `alertId` internally unless one is
passed in.

---

## Known limitations / things to know

- **`expo-av` was removed and replaced with `expo-audio`** project-wide
  after it caused native crashes on SDK 57. If you see any reference to
  `expo-av` anywhere, it's stale — use `expo-audio`.
- **Vibration is subtle on the test device** (Samsung M32) — using
  `Haptics.impactAsync(Heavy)`. Not yet confirmed as a device-specific
  quirk vs. something to revisit.
- **Background sync (`tasks/backgroundSync.js`) is written but not
  live-verified** — Android/iOS throttle background fetch heavily (OS
  decides timing, often 15+ min). Foreground tracking (the 30-sec
  interval) is fully reliable; background is a best-effort safety net.
- **`CommunicationAgent.callGuardian()` is a no-op placeholder** — see
  above. Guardian is currently notified by SMS only (working); the
  automatic phone call is not live yet.
- **`Promise.allSettled()` parallelization and shared `alertId` are
  planned but not yet in this working copy** — see flagged section
  above.

---

## Files P2 owns (for reference)

```
mobile/src/agents/LocationAgent.js   — continuous location tracking + SMS + Firestore
mobile/src/agents/AlarmAgent.js      — ARM/TRIGGER/DISARM orchestration (call this one)
mobile/src/agents/EvidenceAgent.js   — audio recording (expo-audio)
mobile/src/db/sqlite.js              — local offline storage (locations, alarm_events, evidence)
mobile/src/db/syncQueue.js           — retry logic for failed Firestore writes
mobile/src/tasks/backgroundSync.js   — periodic background sync (call registerBackgroundSync() once at app startup)
```

If you need background sync registered, call this once (e.g. in `App.js`
or wherever your app initializes):
```js
import { registerBackgroundSync } from '../tasks/backgroundSync';
registerBackgroundSync();
```