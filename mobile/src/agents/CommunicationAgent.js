/**
 * CommunicationAgent.js
 * P3 — SheGuard AI
 *
 * PLACEHOLDER — automatic (no-tap) calling was attempted via
 * react-native-immediate-call-library, but that package (and the whole
 * "immediate call" npm ecosystem) is unmaintained and incompatible with
 * this project's current Gradle/AGP setup (uses jcenter() + AGP 2.3.2
 * from ~2017). Removed rather than patched.
 *
 * Real fix, deferred: a small custom native Android module doing the
 * ACTION_CALL intent directly (~20-30 lines of Kotlin), bypassing the
 * dead package ecosystem entirely. Until that's built, these functions
 * are safe no-ops — trigger() still calls them, nothing crashes, no
 * call is placed.
 */

import { Linking } from 'react-native';

export async function requestCallPermission() {
    return true;
}

export async function callGuardian(guardianNumber) {
    if (!guardianNumber) {
        console.warn('[CommunicationAgent] No guardian number provided');
        return;
    }
    const cleanNumber = guardianNumber.replace(/[^0-9+]/g, '');
    const phoneUrl = `tel:${cleanNumber}`;
    try {
        const supported = await Linking.canOpenURL(phoneUrl);
        if (supported) {
            console.log('[CommunicationAgent] Initiating call to:', cleanNumber);
            await Linking.openURL(phoneUrl);
        } else {
            console.warn('[CommunicationAgent] tel: URL not supported on this device');
        }
    } catch (err) {
        console.error('[CommunicationAgent] Failed to initiate call:', err);
    }
}