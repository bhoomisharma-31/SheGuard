import { useState, useCallback, useRef } from 'react';
import { View, Text, StyleSheet, Pressable, Alert } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useFocusEffect } from '@react-navigation/native';
import { doc, getDoc } from 'firebase/firestore';
import * as FileSystem from 'expo-file-system/legacy';
import { firestore } from '../services/firebase';
import AlarmAgent from '../agents/AlarmAgent';
import { requestCallPermission } from '../agents/CommunicationAgent';
import { colors } from '../theme';
import useShakeDetect from '../hooks/useShakeDetect';

const DEVICE_ID_FILE = FileSystem.documentDirectory + 'sheguard_device_id.txt';

async function getDeviceId() {
    try {
        const fileInfo = await FileSystem.getInfoAsync(DEVICE_ID_FILE);
        if (fileInfo.exists) {
            const existingId = await FileSystem.readAsStringAsync(DEVICE_ID_FILE);
            if (existingId) return existingId;
        }
    } catch (err) {
        console.warn('[HomeScreen] Could not read device id:', err);
    }
    return null;
}

const STATUS_CONFIG = {
    disarmed: { label: 'Disarmed', color: colors.muted, bg: '#EDEAE4' },
    armed: { label: 'Armed — Listening', color: colors.brass, bg: '#F3E8DA' },
    sending: { label: 'Sending SOS…', color: colors.danger, bg: '#F8DEDA' },
    triggered: { label: 'SOS Active', color: colors.danger, bg: '#F8DEDA' },
};

export default function HomeScreen() {
    const [alarmState, setAlarmState] = useState(AlarmAgent.getState());
    const [busy, setBusy] = useState(false);
    const [sosSending, setSosSending] = useState(false);
    const [profile, setProfile] = useState(null);
    const shakeHandlingRef = useRef(false);

    useFocusEffect(
        useCallback(() => {
            setAlarmState(AlarmAgent.getState());
            loadProfile();
        }, [])
    );

    // --- Shake detection (only fires when armed) ---
    const handleShake = useCallback(async (event) => {
        // Guard: already handling a shake or already triggered
        if (shakeHandlingRef.current) return;
        const state = AlarmAgent.getState();
        if (!state.isArmed || state.isTriggered) return;

        const currentProfile = profile;
        if (!currentProfile || !currentProfile.userId || !currentProfile.guardianNumber) {
            console.warn('[HomeScreen] Shake detected but no profile — ignoring.');
            return;
        }

        shakeHandlingRef.current = true;
        setSosSending(true);
        try {
            await requestCallPermission();
            await AlarmAgent.trigger({
                userId: currentProfile.userId,
                guardianNumber: currentProfile.guardianNumber,
                reason: event?.source ? `Shake detected (${event.source})` : 'Shake detected',
            });
            setAlarmState(AlarmAgent.getState());
        } catch (err) {
            console.error('[HomeScreen] Shake-triggered SOS failed:', err);
            Alert.alert('Shake SOS failed', err.message);
        } finally {
            setSosSending(false);
            shakeHandlingRef.current = false;
        }
    }, [profile]);

    useShakeDetect({
        isArmed: alarmState.isArmed,
        onShake: handleShake,
    });

    const loadProfile = async () => {
        const deviceId = await getDeviceId();
        if (!deviceId) return;
        try {
            const snap = await getDoc(doc(firestore, 'settings', deviceId));
            if (snap.exists()) {
                const data = snap.data();
                setProfile({ userId: data.userId, guardianNumber: data.guardianNumber });
            }
        } catch (err) {
            console.error('[HomeScreen] Failed to load profile:', err);
        }
    };

    const requireProfile = () => {
        if (!profile || !profile.userId || !profile.guardianNumber) {
            Alert.alert('Setup required', "Please add your name and guardian's number in Settings first.");
            return false;
        }
        return true;
    };

    const handleArm = async () => {
        if (busy) return;
        if (!requireProfile()) return;
        setBusy(true);
        try {
            await requestCallPermission();
            await AlarmAgent.arm({ userId: profile.userId, guardianNumber: profile.guardianNumber });
            setAlarmState(AlarmAgent.getState());
        } catch (err) {
            Alert.alert('Arm failed', err.message);
        } finally {
            setBusy(false);
        }
    };

    const handleSOS = async () => {
        if (busy) return;
        if (!requireProfile()) return;
        setBusy(true);
        setSosSending(true); // instant visual feedback — flips before any of the slow work starts
        try {
            await requestCallPermission();
            await AlarmAgent.trigger({
                userId: profile.userId,
                guardianNumber: profile.guardianNumber,
                reason: 'Direct SOS',
            });
            setAlarmState(AlarmAgent.getState());
        } catch (err) {
            Alert.alert('SOS failed', err.message);
        } finally {
            setSosSending(false);
            setBusy(false);
        }
    };

    const handleDisarm = async () => {
        if (busy) return;
        setBusy(true);
        try {
            await AlarmAgent.disarm();
            setAlarmState(AlarmAgent.getState());
        } catch (err) {
            Alert.alert('Disarm failed', err.message);
        } finally {
            setBusy(false);
        }
    };

    const statusKey = sosSending
        ? 'sending'
        : alarmState.isTriggered
            ? 'triggered'
            : alarmState.isArmed
                ? 'armed'
                : 'disarmed';
    const status = STATUS_CONFIG[statusKey];

    return (
        <SafeAreaView style={styles.container}>
            <Text style={styles.title}>SheGuard AI</Text>

            <View style={[styles.statusBadge, { backgroundColor: status.bg }]}>
                <View style={[styles.statusDot, { backgroundColor: status.color }]} />
                <Text style={[styles.statusText, { color: status.color }]}>{status.label}</Text>
            </View>

            <View style={styles.buttonArea}>
                <Pressable style={[styles.button, styles.sosButton]} onPress={handleSOS} disabled={busy}>
                    <Text style={styles.buttonText}>SOS</Text>
                </Pressable>

                {!alarmState.isArmed ? (
                    <Pressable style={[styles.button, styles.armButton]} onPress={handleArm} disabled={busy}>
                        <Text style={styles.buttonText}>ARM</Text>
                    </Pressable>
                ) : (
                    <Pressable style={[styles.button, styles.disarmButton]} onPress={handleDisarm} disabled={busy}>
                        <Text style={styles.buttonText}>DISARM</Text>
                    </Pressable>
                )}
            </View>
        </SafeAreaView>
    );
}

const styles = StyleSheet.create({
    container: { flex: 1, backgroundColor: colors.background, alignItems: 'center', paddingTop: 40 },
    title: { fontSize: 26, fontWeight: '700', color: colors.ink, marginBottom: 20 },
    statusBadge: {
        flexDirection: 'row', alignItems: 'center',
        paddingHorizontal: 16, paddingVertical: 8, borderRadius: 20, marginBottom: 44,
    },
    statusDot: { width: 8, height: 8, borderRadius: 4, marginRight: 8 },
    statusText: { fontSize: 14, fontWeight: '600' },
    buttonArea: { width: '100%', alignItems: 'center', gap: 22 },
    button: { width: 180, height: 180, borderRadius: 90, justifyContent: 'center', alignItems: 'center' },
    armButton: { backgroundColor: colors.ink },
    sosButton: { backgroundColor: colors.danger },
    disarmButton: { backgroundColor: colors.safe, width: 140, height: 140, borderRadius: 70 },
    buttonText: { color: colors.white, fontSize: 22, fontWeight: '700', letterSpacing: 0.5 },
});