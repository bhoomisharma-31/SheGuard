/**
 * tasks/backgroundSync.js
 * P2 — SheGuard AI
 *
 * Schedules periodic background syncing of any locally-saved but unsynced
 * data (currently: locations) to Firestore, using expo-task-manager +
 * expo-background-fetch.
 *
 * IMPORTANT — realistic expectations:
 * Background fetch on both Android and iOS is OS-throttled. You CANNOT
 * guarantee it runs exactly every 30 seconds while backgrounded — the OS
 * decides actual timing (often 15+ minutes between runs in the background,
 * sometimes longer depending on battery optimization / Doze mode on
 * Android). This is a real platform limitation, not a bug in this file.
 *
 * This means: while the app is in the FOREGROUND, LocationAgent.js's own
 * 30-sec interval is what keeps location live and synced. This
 * backgroundSync task is a SAFETY NET — it ensures that if the app gets
 * backgrounded, killed, or loses network for a while, whatever got saved
 * locally but failed to sync eventually gets flushed to Firestore once
 * the OS allows a background run.
 *
 * Usage: call registerBackgroundSync() once on app startup (e.g. from
 * App.js or DecisionCoordinator.js — P3). Call unregisterBackgroundSync()
 * if you ever need to fully stop it (e.g. on logout).
 */

import * as TaskManager from 'expo-task-manager';
import * as BackgroundFetch from 'expo-background-fetch';
import { syncPendingLocations } from '../db/syncQueue';

const TASK_NAME = 'SHEGUARD_BACKGROUND_SYNC';

// Minimum interval the OS will *consider* running the task at.
// Actual execution is still OS-controlled and may run less often.
const MIN_INTERVAL_SECONDS = 15 * 60; // 15 minutes — realistic floor for background fetch

// Define the task. Must be called at module load time (outside any
// component/function), per expo-task-manager requirements.
TaskManager.defineTask(TASK_NAME, async () => {
    try {
        const { succeeded, failed } = await syncPendingLocations();
        console.log(`[backgroundSync] Task ran. Synced: ${succeeded}, failed: ${failed}`);

        if (succeeded > 0) {
            return BackgroundFetch.BackgroundFetchResult.NewData;
        }
        return BackgroundFetch.BackgroundFetchResult.NoData;
    } catch (err) {
        console.error('[backgroundSync] Task failed:', err);
        return BackgroundFetch.BackgroundFetchResult.Failed;
    }
});

/**
 * Registers the background sync task with the OS. Call once on app startup.
 * Safe to call multiple times — expo-background-fetch handles re-registration.
 */
export async function registerBackgroundSync() {
    try {
        const status = await BackgroundFetch.getStatusAsync();

        if (
            status === BackgroundFetch.BackgroundFetchStatus.Restricted ||
            status === BackgroundFetch.BackgroundFetchStatus.Denied
        ) {
            console.warn('[backgroundSync] Background fetch is restricted/denied at the OS level. Sync will only happen in foreground via LocationAgent.js.');
            return;
        }

        await BackgroundFetch.registerTaskAsync(TASK_NAME, {
            minimumInterval: MIN_INTERVAL_SECONDS,
            stopOnTerminate: false, // keep trying to run even if app was force-closed (Android)
            startOnBoot: true, // resume after phone restart
        });

        console.log('[backgroundSync] Registered successfully.');
    } catch (err) {
        console.error('[backgroundSync] Registration failed:', err);
    }
}

/**
 * Unregisters the background sync task. Call if needed (e.g. logout, ARM
 * fully deactivated and no pending data left to protect).
 */
export async function unregisterBackgroundSync() {
    try {
        const isRegistered = await TaskManager.isTaskRegisteredAsync(TASK_NAME);
        if (isRegistered) {
            await BackgroundFetch.unregisterTaskAsync(TASK_NAME);
            console.log('[backgroundSync] Unregistered.');
        }
    } catch (err) {
        console.error('[backgroundSync] Failed to unregister:', err);
    }
}