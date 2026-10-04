/**
 * db/syncQueue.js
 * P2 — SheGuard AI
 *
 * Handles retrying data that failed to sync to Firestore in real-time
 * (e.g. LocationAgent.js couldn't reach Firestore because of no network).
 *
 * Flow:
 * 1. LocationAgent.js already saves every location locally via sqlite.js
 *    (saveLocationLocally), regardless of whether the live Firestore write
 *    succeeds or fails.
 * 2. If the live Firestore write fails, LocationAgent.js calls
 *    queueLocationForSync() here as a signal that a retry is needed.
 * 3. tasks/backgroundSync.js periodically calls syncPendingLocations(),
 *    which reads all unsynced rows from sqlite.js and attempts to push
 *    each one to Firestore, marking successes as synced.
 *
 * This file does NOT talk to expo-background-fetch directly — that
 * scheduling responsibility lives in tasks/backgroundSync.js. This file
 * only knows how to "sync what's pending, right now, when called."
 */

import { firestore } from '../services/firebase'; // P3-owned
import { doc, setDoc } from 'firebase/firestore';
import { getUnsyncedLocations, markLocationSynced } from './sqlite';

/**
 * Called by LocationAgent.js (or other agents) when a live sync attempt
 * fails. Currently a lightweight no-op beyond logging, since the data is
 * already saved locally with synced=0 by sqlite.js — this function exists
 * as an explicit signal/hook point in case queue-specific logic (e.g.
 * triggering an immediate retry attempt, incrementing a retry counter)
 * needs to be added later without changing LocationAgent.js's contract.
 *
 * @param {Object} params - the data that failed to sync (shape varies by type)
 */
export function queueLocationForSync(params) {
    console.log('[syncQueue] Queued for retry:', params.type || 'unknown', params.alertId);
    // Data is already persisted locally with synced=0 via sqlite.js at the
    // point this is called. No additional local write needed here today.
    // Future: could trigger an immediate best-effort retry attempt instead
    // of waiting for the next backgroundSync.js cycle.
}

/**
 * Attempts to sync all locally-saved but unsynced location rows to Firestore.
 * Call this from tasks/backgroundSync.js on a periodic schedule, and also
 * opportunistically whenever the app detects it has regained network
 * connectivity (see hooks/useNetworkStatus.js — P3).
 *
 * @returns {Promise<{ succeeded: number, failed: number }>}
 */
export async function syncPendingLocations() {
    const unsynced = await getUnsyncedLocations();

    let succeeded = 0;
    let failed = 0;

    for (const row of unsynced) {
        try {
            await setDoc(
                doc(firestore, 'alerts', row.alert_id),
                {
                    latitude: row.latitude,
                    longitude: row.longitude,
                    lastUpdated: row.timestamp,
                    active: true,
                },
                { merge: true }
            );
            await markLocationSynced(row.id);
            succeeded++;
        } catch (err) {
            console.error('[syncQueue] Failed to sync location row', row.id, err);
            failed++;
            // Leave synced=0 — will be retried on the next sync cycle.
        }
    }

    if (unsynced.length > 0) {
        console.log(`[syncQueue] Sync cycle complete: ${succeeded} succeeded, ${failed} failed.`);
    }

    return { succeeded, failed };
}