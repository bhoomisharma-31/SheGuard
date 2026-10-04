/**
 * AlarmAgent.js
 * P2 — SheGuard AI
 *
 * Responsibility:
 * - Manages ARM / DISARM / TRIGGER state for the safety flow.
 * - Per project decision: alarm = VIBRATION ONLY. No siren, no torch.
 * - TWO independent entry points into trigger(), per P3's clarification:
 *   1. ARM → (later) automatic signal from ThreatAgent/VoiceAgent → trigger()
 *      ARM must be active first — this is the "not sure yet, listening" path.
 *   2. SOS pressed directly → trigger() — user already knows it's an
 *      emergency, no ARM step needed first. SOS itself IS the confirmation
 *      of intent, same as ARM+signal would be otherwise. This path
 *      requires userId/guardianNumber to be passed directly into
 *      trigger() (since arm() was never called to set them).
 * - On TRIGGER (either path): gives a single brief confirmation buzz (2
 *   short pulses, NOT repeating) so the user feels it registered without
 *   drawing attention during an active threat. Then starts LocationAgent,
 *   CommunicationAgent, and EvidenceAgent IN PARALLEL — these don't
 *   depend on each other finishing first, so running them together
 *   instead of sequentially is what actually makes SOS feel as fast as
 *   ARM/DISARM. A single alertId is generated once here and shared by
 *   all three, rather than each generating its own.
 * - On DISARM: logs the event, stops LocationAgent, and stops
 *   EvidenceAgent if it was recording. Works correctly regardless of
 *   which path (ARM or direct SOS) led to the triggered state.
 *
 * Does NOT decide WHEN to arm/trigger/disarm (e.g. which gesture, button,
 * or voice keyword causes it) — that UI/UX decision belongs to
 * DecisionCoordinator.js (P3). This agent only exposes clean methods for
 * that coordinator to call.
 */

import * as Haptics from 'expo-haptics';
import { saveAlarmEventLocally } from '../db/sqlite';
import LocationAgent from './LocationAgent';
import EvidenceAgent from './EvidenceAgent';
import { callGuardian } from './CommunicationAgent';

// Gap between the two confirmation pulses (single buzz, not repeating).
const CONFIRMATION_PULSE_GAP_MS = 200;

class AlarmAgent {
    constructor() {
        this.isArmed = false;
        this.isTriggered = false;
        this.currentAlertContext = null; // { userId, guardianNumber } — set on arm()
    }

    /**
     * Arms the app. Must be called before trigger() will do anything.
     * @param {Object} params
     * @param {string} params.userId
     * @param {string} params.guardianNumber
     */
    async arm({ userId, guardianNumber }) {
        if (this.isArmed) {
            console.warn('[AlarmAgent] arm() called but already armed. Ignoring.');
            return;
        }

        this.isArmed = true;
        this.currentAlertContext = { userId, guardianNumber };

        await this._logEvent('armed');
        console.log('[AlarmAgent] Armed.');
    }

    /**
     * Triggers the alarm. Two ways this gets called:
     *
     * 1. ARM already active (arm() was called earlier, e.g. by an
     *    automatic ThreatAgent/VoiceAgent signal) — just call
     *    trigger({ reason }). Uses the context already set by arm().
     *
     * 2. Direct SOS — user presses SOS with no prior ARM step. Call
     *    trigger({ userId, guardianNumber, reason }) — SOS itself is the
     *    confirmation of intent, so this bypasses the ARM requirement by
     *    design (not a safety-gate removal, a second independent entry
     *    point). Internal state is set to armed+triggered so disarm()
     *    works correctly afterward either way.
     *
     * @param {Object} [params]
     * @param {string} [params.userId] - required only if calling without a prior arm()
     * @param {string} [params.guardianNumber] - required only if calling without a prior arm()
     * @param {string} [params.reason] - optional reason string passed through to LocationAgent's initial alert
     */
    async trigger({ userId, guardianNumber, reason } = {}) {
        if (this.isTriggered) {
            console.warn('[AlarmAgent] trigger() called but already triggered. Ignoring.');
            return;
        }

        if (!this.isArmed) {
            // Direct SOS path — no prior arm() call. Requires context to be
            // passed in directly since arm() never ran to set it.
            if (!userId || !guardianNumber) {
                console.error('[AlarmAgent] trigger() called without arm() and without userId/guardianNumber — cannot proceed.');
                throw new Error('MISSING_CONTEXT_FOR_SOS');
            }
            this.isArmed = true;
            this.currentAlertContext = { userId, guardianNumber };
            await this._logEvent('armed'); // implicit — keeps local event log consistent with what actually happened
        }

        this.isTriggered = true;

        const { userId: ctxUserId, guardianNumber: ctxGuardianNumber } = this.currentAlertContext;
        // Generated once here and shared by LocationAgent, CommunicationAgent,
        // and EvidenceAgent below — fixes the earlier inconsistency where
        // each one (and every _logEvent call) generated its own separate id.
        const alertId = `${ctxUserId}_${Date.now()}`;

        await this._logEvent('triggered', alertId);
        this._playConfirmationBuzz();

        // Location tracking, the automatic guardian call, and evidence
        // recording don't depend on each other finishing first — run them
        // together instead of one after another. This is the real fix for
        // SOS feeling slow compared to ARM/DISARM: most of the delay was
        // these three waiting in a queue for no real reason.
        const results = await Promise.allSettled([
            LocationAgent.start({ alertId, userId: ctxUserId, guardianNumber: ctxGuardianNumber, reason }),
            callGuardian(ctxGuardianNumber),
            EvidenceAgent.start({ alertId }),
        ]);

        const labels = ['LocationAgent', 'CommunicationAgent', 'EvidenceAgent'];
        results.forEach((result, i) => {
            if (result.status === 'rejected') {
                console.error(`[AlarmAgent] Failed to start ${labels[i]} on trigger:`, result.reason);
                // Non-fatal by design — vibration + local logging already
                // happened, and the other two agents still ran independently.
                // Trigger is not fully silent even if one piece fails (e.g.
                // location permission denied, mic permission denied).
            }
        });

        console.log('[AlarmAgent] Triggered.');
    }

    /**
     * Disarms the app. Stops location tracking and evidence recording.
     */
    async disarm() {
        if (!this.isArmed) {
            console.warn('[AlarmAgent] disarm() called but not armed. Ignoring.');
            return;
        }

        LocationAgent.stop();

        if (EvidenceAgent.getState().isRecording) {
            try {
                await EvidenceAgent.stop();
            } catch (err) {
                console.error('[AlarmAgent] Failed to stop EvidenceAgent on disarm:', err);
            }
        }

        await this._logEvent('disarmed');

        this.isArmed = false;
        this.isTriggered = false;
        this.currentAlertContext = null;

        console.log('[AlarmAgent] Disarmed.');
    }

    /**
     * Returns current state — useful for UI (P3) to reflect armed/triggered status.
     */
    getState() {
        return {
            isArmed: this.isArmed,
            isTriggered: this.isTriggered,
        };
    }

    // ---------------------------------------------------------------------
    // Internal
    // ---------------------------------------------------------------------

    /**
     * Single discreet confirmation: two short pulses, then nothing.
     * Deliberately NOT repeating — a loud/ongoing vibration during an
     * active trigger could draw unwanted attention, working against the
     * discretion this app needs during a real threat.
     */
    _playConfirmationBuzz() {
        // Using impactAsync (Heavy) instead of notificationAsync — more
        // physically noticeable "thud" on most Android devices, including
        // Samsung, where notification-style haptics can be too subtle to feel.
        Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Heavy);
        setTimeout(() => {
            Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Heavy);
        }, CONFIRMATION_PULSE_GAP_MS);
    }

    /**
     * @param {string} eventType - 'armed' | 'triggered' | 'disarmed'
     * @param {string} [alertId] - shared alert id from trigger(); arm()/disarm()
     *   calls (which aren't tied to one specific trigger session) fall back
     *   to generating their own, same as before.
     */
    async _logEvent(eventType, alertId) {
        if (!this.currentAlertContext) return;
        try {
            await saveAlarmEventLocally({
                alertId: alertId || `${this.currentAlertContext.userId}_${Date.now()}`,
                eventType,
                timestamp: Date.now(),
            });
        } catch (err) {
            console.error('[AlarmAgent] Failed to log event locally:', err);
        }
    }
}

export default new AlarmAgent();