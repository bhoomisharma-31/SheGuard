/**
 * LocationAgent.js
 * P2 — SheGuard AI
 *
 * Responsibility:
 * - Once ARMed and a trigger occurs, fetch device location continuously
 *   every 30 seconds until STOPPED (ARM deactivated or agent explicitly stopped).
 * - First location fetch also fires the one-time SMS alert via the backend
 *   (/trigger-alert), so the guardian is not spammed with repeated SMS.
 * - Every subsequent location update (including the first) is written to
 *   Firestore under alerts/{alertId}, so a guardian can view live location
 *   via a web link (Option B — no app install required for guardian).
 * - Every location fetch is also saved locally via db/sqlite.js, so the
 *   last known location survives if network drops or the phone loses signal.
 * - alertId is now passed IN by AlarmAgent.trigger() (shared across
 *   LocationAgent, CommunicationAgent, and EvidenceAgent, and the local
 *   event log) rather than generated here — falls back to generating its
 *   own only if called without one (e.g. direct/standalone use).
 *
 * Does NOT decide when to arm/trigger — that decision lives with
 * DecisionCoordinator.js (P3). This agent only starts/stops when told to.
 */

import * as Location from 'expo-location';
import { firestore } from '../services/firebase'; // P3-owned firebase.js — expects an initialized Firestore instance exported as `firestore`
import { doc, setDoc } from 'firebase/firestore';
import { saveLocationLocally } from '../db/sqlite'; // P2-owned — to be implemented
import { queueLocationForSync } from '../db/syncQueue'; // P2-owned — to be implemented
import { BACKEND_URL } from '../config'; // P3-owned shared config — single source of truth for the backend URL

const LOCATION_INTERVAL_MS = 30 * 1000; // 30 seconds
const BACKEND_TRIGGER_ALERT_URL = `${BACKEND_URL}/trigger-alert`;

class LocationAgent {
    constructor() {
        this.intervalId = null;
        this.isTracking = false;
        this.alertId = null;
        this.hasFiredInitialAlert = false;
    }

    /**
     * Starts continuous location tracking.
     * @param {Object} params
     * @param {string} [params.alertId] - shared alert id from AlarmAgent.trigger();
     *   falls back to generating one from userId+timestamp if not given.
     * @param {string} params.userId - current user's id
     * @param {string} params.guardianNumber - guardian's phone number (E.164 or 10-digit, per Fast2SMS format)
     * @param {string} [params.reason] - optional reason string for the initial alert
     */
    async start({ alertId, userId, guardianNumber, reason }) {
        if (this.isTracking) {
            console.warn('[LocationAgent] start() called but already tracking. Ignoring.');
            return;
        }

        try {
            const { status } = await Location.requestForegroundPermissionsAsync();
            if (status !== 'granted') {
                console.warn('[LocationAgent] Foreground location permission not granted.');
                return;
            }
        } catch (permErr) {
            console.warn('[LocationAgent] Error requesting foreground location:', permErr);
            return;
        }

        try {
            // Background permission is optional / platform dependent
            const bgPermission = await Location.requestBackgroundPermissionsAsync();
            if (bgPermission.status !== 'granted') {
                console.warn('[LocationAgent] Background location permission denied — tracking will work while app is foregrounded.');
            }
        } catch (bgErr) {
            console.warn('[LocationAgent] Background permission not available in this environment:', bgErr);
        }

        this.isTracking = true;
        this.hasFiredInitialAlert = false;
        this.alertId = alertId || `${userId}_${Date.now()}`; // use the shared id from AlarmAgent if given

        // Fetch immediately, then on an interval
        await this._fetchAndHandleLocation({ userId, guardianNumber, reason });

        this.intervalId = setInterval(() => {
            this._fetchAndHandleLocation({ userId, guardianNumber, reason });
        }, LOCATION_INTERVAL_MS);

        console.log('[LocationAgent] Tracking started. alertId =', this.alertId);
    }

    /**
     * Stops continuous location tracking. Call this when ARM is deactivated.
     */
    stop() {
        if (this.intervalId) {
            clearInterval(this.intervalId);
            this.intervalId = null;
        }
        this.isTracking = false;
        console.log('[LocationAgent] Tracking stopped.');
    }

    /**
     * Returns a single current location reading without starting continuous tracking.
     * Useful for one-off checks (e.g. showing user their current location in Settings).
     */
    async getCurrentLocation() {
        const { status } = await Location.requestForegroundPermissionsAsync();
        if (status !== 'granted') {
            throw new Error('LOCATION_PERMISSION_DENIED');
        }
        const position = await Location.getCurrentPositionAsync({
            accuracy: Location.Accuracy.High,
        });
        return {
            latitude: position.coords.latitude,
            longitude: position.coords.longitude,
            timestamp: position.timestamp,
        };
    }

    // ---------------------------------------------------------------------
    // Internal
    // ---------------------------------------------------------------------

    async _fetchAndHandleLocation({ userId, guardianNumber, reason }) {
        let position;
        try {
            position = await Location.getCurrentPositionAsync({
                accuracy: Location.Accuracy.High,
            });
        } catch (err) {
            console.error('[LocationAgent] Failed to fetch location:', err);
            return; // skip this cycle; next interval tick will retry
        }

        const locationData = {
            latitude: position.coords.latitude,
            longitude: position.coords.longitude,
            timestamp: position.timestamp,
        };

        // 1. Always save locally first (offline-safe, survives network/phone issues)
        try {
            await saveLocationLocally({ alertId: this.alertId, ...locationData });
        } catch (err) {
            console.error('[LocationAgent] Local save failed:', err);
        }

        // 2. Fire the one-time SMS alert on the FIRST location fetch only
        if (!this.hasFiredInitialAlert) {
            this.hasFiredInitialAlert = true;
            try {
                await this._sendInitialAlert({ userId, guardianNumber, reason, ...locationData });
            } catch (err) {
                console.error('[LocationAgent] Initial alert failed:', err);
                // Do not block continued tracking if the SMS trigger fails —
                // queue it for retry via syncQueue instead.
                queueLocationForSync({ type: 'initial_alert', alertId: this.alertId, userId, guardianNumber, reason, ...locationData });
            }
        }

        // 3. Write/update live location to Firestore for guardian web tracking (Option B)
        try {
            await this._updateFirestoreLocation(locationData);
        } catch (err) {
            console.error('[LocationAgent] Firestore update failed, queueing for sync:', err);
            queueLocationForSync({ type: 'location_update', alertId: this.alertId, ...locationData });
        }
    }

    async _sendInitialAlert({ userId, guardianNumber, reason, latitude, longitude }) {
        const response = await fetch(BACKEND_TRIGGER_ALERT_URL, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                user_id: userId,
                guardian_number: guardianNumber,
                latitude,
                longitude,
                reason: reason || 'SOS triggered',
            }),
        });

        if (!response.ok) {
            throw new Error(`trigger-alert responded with status ${response.status}`);
        }
        console.log('[LocationAgent] Initial SMS alert sent successfully.');
    }

    async _updateFirestoreLocation({ latitude, longitude, timestamp }) {
        // Document is updated in place (not a new doc per update) so the
        // guardian's web page can use a real-time listener (onSnapshot) on
        // a single fixed path: alerts/{alertId}
        // Modular API (v26+) — old .collection().doc().set() chaining
        // was removed; this is the current syntax.
        await setDoc(
            doc(firestore, 'alerts', this.alertId),
            {
                latitude,
                longitude,
                lastUpdated: timestamp,
                active: true,
            },
            { merge: true }
        );
    }
}

export default new LocationAgent();