/**
 * useShakeDetect.js
 * SheGuard AI — Shake Detection Hook
 *
 * Uses expo-sensors Accelerometer to detect deliberate phone shaking.
 * Only active when the app is in ARM state (isArmed === true).
 *
 * Detection algorithm:
 * - Reads accelerometer data at ~60 Hz (16 ms interval).
 * - Computes total acceleration magnitude: sqrt(x² + y² + z²).
 * - Subtracts gravity (~1g) to get excess acceleration.
 * - If excess acceleration exceeds SHAKE_THRESHOLD for
 *   REQUIRED_CONSECUTIVE_SHAKES consecutive readings, a shake is
 *   triggered.
 * - After a successful trigger, a COOLDOWN_MS period prevents
 *   re-triggering from the same shaking action.
 *
 * Lifecycle:
 * - Subscribes to Accelerometer when isArmed becomes true.
 * - Unsubscribes when isArmed becomes false or component unmounts.
 * - No listeners or timers run when disarmed.
 *
 * Usage:
 *   useShakeDetect({
 *     isArmed: alarmState.isArmed,
 *     onShake: () => { ... },
 *   });
 */

import { useEffect, useRef, useCallback } from 'react';
import { Accelerometer } from 'expo-sensors';

// --- Tuning constants ---

// Acceleration magnitude threshold (in g, where stationary is ~1.0g).
// 1.75g filters out normal walking, tilts, and gentle movement,
// but reliably catches deliberate shaking.
const SHAKE_MAGNITUDE_THRESHOLD = 1.75;

// Excess acceleration threshold (|magnitude - 1.0|).
// 0.85g means at least 0.85g beyond gravity.
const SHAKE_EXCESS_THRESHOLD = 0.85;

// Number of distinct acceleration peaks required within the time window.
// 2 peaks (e.g. forward + backward) represent a clear intentional shake gesture,
// while filtering out single bumps, drops, or setting phone down.
const REQUIRED_SHAKE_PEAKS = 2;

// Minimum time (ms) between two counted peaks to avoid double-counting a single stroke.
const MIN_INTERVAL_BETWEEN_PEAKS_MS = 120;

// Maximum time window (ms) during which the required peaks must occur.
const SHAKE_WINDOW_MS = 1000;

// Cooldown period (ms) after a successful trigger to prevent duplicate SOS alerts.
const COOLDOWN_MS = 4000;

// Sensor update interval in milliseconds (~25 Hz).
// Lightweight on battery and low-end Android CPUs, with ample sampling resolution.
const SENSOR_INTERVAL_MS = 40;

/**
 * @param {Object} params
 * @param {boolean} params.isArmed — current ARM state from AlarmAgent
 * @param {(event: { source: string, timestamp: number }) => void} params.onShake — callback fired once per valid shake
 */
export default function useShakeDetect({ isArmed, onShake }) {
    const subscriptionRef = useRef(null);
    const peakCountRef = useRef(0);
    const firstPeakTimeRef = useRef(0);
    const lastPeakTimeRef = useRef(0);
    const cooldownUntilRef = useRef(0);

    // Keep fresh reference to onShake callback
    const onShakeRef = useRef(onShake);
    useEffect(() => {
        onShakeRef.current = onShake;
    }, [onShake]);

    const resetPeaks = () => {
        peakCountRef.current = 0;
        firstPeakTimeRef.current = 0;
        lastPeakTimeRef.current = 0;
    };

    const handleAccelerometerData = useCallback(({ x, y, z }) => {
        const now = Date.now();

        // If in cooldown period following a trigger, ignore all data
        if (now < cooldownUntilRef.current) {
            return;
        }

        // Calculate total magnitude in g-units
        const magnitude = Math.sqrt(x * x + y * y + z * z);
        const excess = Math.abs(magnitude - 1.0);

        // Check if movement exceeds deliberate shake threshold
        const isSpike = magnitude >= SHAKE_MAGNITUDE_THRESHOLD || excess >= SHAKE_EXCESS_THRESHOLD;

        if (isSpike) {
            const timeSinceLastPeak = now - lastPeakTimeRef.current;
            const timeSinceFirstPeak = now - firstPeakTimeRef.current;

            // If time window has expired since first peak, restart count
            if (peakCountRef.current > 0 && timeSinceFirstPeak > SHAKE_WINDOW_MS) {
                resetPeaks();
            }

            // Only count if enough time passed since previous peak (avoids same peak duplicate)
            if (timeSinceLastPeak >= MIN_INTERVAL_BETWEEN_PEAKS_MS) {
                if (peakCountRef.current === 0) {
                    firstPeakTimeRef.current = now;
                }
                lastPeakTimeRef.current = now;
                peakCountRef.current += 1;

                console.log(`[useShakeDetect] Peak ${peakCountRef.current}/${REQUIRED_SHAKE_PEAKS} (mag: ${magnitude.toFixed(2)}g, excess: ${excess.toFixed(2)}g)`);

                if (peakCountRef.current >= REQUIRED_SHAKE_PEAKS) {
                    // Valid deliberate shake detected!
                    console.log('[useShakeDetect] Shake confirmed! Firing trigger.');
                    cooldownUntilRef.current = now + COOLDOWN_MS;
                    resetPeaks();

                    const event = {
                        source: 'SHAKE',
                        timestamp: now,
                    };

                    if (typeof onShakeRef.current === 'function') {
                        try {
                            onShakeRef.current(event);
                        } catch (err) {
                            console.error('[useShakeDetect] Error in onShake callback:', err);
                        }
                    }
                }
            }
        }
    }, []);

    useEffect(() => {
        // Only active when isArmed is true
        if (!isArmed) {
            if (subscriptionRef.current) {
                subscriptionRef.current.remove();
                subscriptionRef.current = null;
                resetPeaks();
                console.log('[useShakeDetect] Disarmed — accelerometer listener removed.');
            }
            return;
        }

        // If already listening, do not re-add
        if (subscriptionRef.current) return;

        let isMounted = true;

        (async () => {
            try {
                const available = await Accelerometer.isAvailableAsync();
                if (!available) {
                    console.warn('[useShakeDetect] Accelerometer not available on this device.');
                    return;
                }

                if (!isMounted) return;

                Accelerometer.setUpdateInterval(SENSOR_INTERVAL_MS);
                subscriptionRef.current = Accelerometer.addListener(handleAccelerometerData);
                resetPeaks();
                console.log('[useShakeDetect] Armed — accelerometer active (25Hz).');
            } catch (err) {
                console.error('[useShakeDetect] Failed to initialize accelerometer:', err);
            }
        })();

        return () => {
            isMounted = false;
            if (subscriptionRef.current) {
                subscriptionRef.current.remove();
                subscriptionRef.current = null;
                resetPeaks();
                console.log('[useShakeDetect] Cleanup — accelerometer listener removed.');
            }
        };
    }, [isArmed, handleAccelerometerData]);
}
