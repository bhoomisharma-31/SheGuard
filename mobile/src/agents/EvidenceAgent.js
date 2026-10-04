/**
 * EvidenceAgent.js
 * P2 — SheGuard AI
 *
 * Responsibility:
 * - Records audio evidence during an active trigger, using expo-audio
 *   (NOT expo-av — expo-av was removed from this project after it caused
 *   a native build crash; expo-audio is the correct, maintained library
 *   for SDK 57).
 * - Recording starts when trigger() is called (coordinated alongside
 *   AlarmAgent.trigger() by DecisionCoordinator.js — P3) and stops when
 *   stop() is called (on disarm).
 * - The actual audio file stays on the device filesystem. Only a
 *   REFERENCE to it (uri, type, timestamp) is saved locally via
 *   sqlite.js's evidence table — matches the design already in place.
 *
 * expo-audio API notes (different from expo-av):
 * - Uses the `AudioRecorder` class directly (not a hook, since this is a
 *   singleton service class, not a React component).
 * - Permissions come from `AudioModule.requestRecordingPermissionsAsync()`.
 * - Recording is started with prepareToRecordAsync() then record().
 * - Stopping returns the file at `recorder.uri`.
 */

import { AudioModule, RecordingPresets, setAudioModeAsync } from 'expo-audio';
import { saveEvidenceReferenceLocally } from '../db/sqlite';

class EvidenceAgent {
    constructor() {
        this.recorder = null;
        this.isRecording = false;
        this.currentAlertId = null;
    }

    /**
     * Starts audio recording. Call this when a trigger occurs (alongside
     * AlarmAgent.trigger()).
     * @param {Object} params
     * @param {string} params.alertId - used to associate the recording with the current alert
     */
    async start({ alertId }) {
        if (this.isRecording) {
            console.warn('[EvidenceAgent] start() called but already recording. Ignoring.');
            return;
        }

        const permission = await AudioModule.requestRecordingPermissionsAsync();
        if (!permission.granted) {
            console.error('[EvidenceAgent] Microphone permission denied.');
            throw new Error('MICROPHONE_PERMISSION_DENIED');
        }

        await setAudioModeAsync({
            playsInSilentMode: true,
            allowsRecording: true,
        });

        this.currentAlertId = alertId;
        this.recorder = new AudioModule.AudioRecorder(RecordingPresets.HIGH_QUALITY);

        try {
            await this.recorder.prepareToRecordAsync();
            this.recorder.record();
            this.isRecording = true;
            console.log('[EvidenceAgent] Recording started.');
        } catch (err) {
            console.error('[EvidenceAgent] Failed to start recording:', err);
            this.recorder = null;
            throw err;
        }
    }

    /**
     * Stops audio recording. Saves a local reference to the resulting file.
     * Call this when disarm() happens (or when recording needs to end for
     * any other reason, e.g. max duration reached — not yet implemented).
     */
    async stop() {
        if (!this.isRecording || !this.recorder) {
            console.warn('[EvidenceAgent] stop() called but not currently recording. Ignoring.');
            return null;
        }

        try {
            await this.recorder.stop();
            const fileUri = this.recorder.uri;

            await saveEvidenceReferenceLocally({
                alertId: this.currentAlertId,
                fileUri,
                fileType: 'audio/m4a', // HIGH_QUALITY preset default container on both platforms
                timestamp: Date.now(),
            });

            console.log('[EvidenceAgent] Recording stopped and saved:', fileUri);

            this.isRecording = false;
            this.recorder = null;
            this.currentAlertId = null;

            return fileUri;
        } catch (err) {
            console.error('[EvidenceAgent] Failed to stop/save recording:', err);
            this.isRecording = false;
            this.recorder = null;
            throw err;
        }
    }

    /**
     * Returns current recording state — useful for UI (P3) to show a
     * recording indicator.
     */
    getState() {
        return {
            isRecording: this.isRecording,
        };
    }
}

export default new EvidenceAgent();