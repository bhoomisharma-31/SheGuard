import { useState, useCallback } from 'react';
import { View, Text, StyleSheet, TextInput, Pressable, Alert, ActivityIndicator } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useFocusEffect } from '@react-navigation/native';
import { doc, getDoc, setDoc } from 'firebase/firestore';
import * as FileSystem from 'expo-file-system/legacy';
import { firestore } from '../services/firebase';
import { colors } from '../theme';

const DEVICE_ID_FILE = FileSystem.documentDirectory + 'sheguard_device_id.txt';

async function getOrCreateDeviceId() {
    try {
        const fileInfo = await FileSystem.getInfoAsync(DEVICE_ID_FILE);
        if (fileInfo.exists) {
            const existingId = await FileSystem.readAsStringAsync(DEVICE_ID_FILE);
            if (existingId) return existingId;
        }
    } catch (err) {
        console.warn('[SettingsScreen] Could not read existing device id, generating new one:', err);
    }
    const newId = `device_${Date.now()}_${Math.random().toString(36).slice(2, 10)}`;
    await FileSystem.writeAsStringAsync(DEVICE_ID_FILE, newId);
    return newId;
}

export default function SettingsScreen() {
    const [deviceId, setDeviceId] = useState(null);
    const [userId, setUserId] = useState('');
    const [guardianDigits, setGuardianDigits] = useState('');
    const [loading, setLoading] = useState(true);
    const [saving, setSaving] = useState(false);
    const [mode, setMode] = useState('view');
    const [hasSavedProfile, setHasSavedProfile] = useState(false);

    useFocusEffect(
        useCallback(() => {
            initSettings();
        }, [])
    );

    const initSettings = async () => {
        setLoading(true);
        try {
            const id = await getOrCreateDeviceId();
            setDeviceId(id);
            const snap = await getDoc(doc(firestore, 'settings', id));
            if (snap.exists()) {
                const data = snap.data();
                setUserId(data.userId || '');
                setGuardianDigits(data.guardianNumber || '');
                setHasSavedProfile(true);
                setMode('view');
            } else {
                setHasSavedProfile(false);
                setMode('edit');
            }
        } catch (err) {
            console.error('[SettingsScreen] Failed to load settings:', err);
            Alert.alert('Could not load settings', 'Check your connection and try again.');
        } finally {
            setLoading(false);
        }
    };

    const validate = () => {
        if (!userId.trim()) {
            Alert.alert('Missing name', 'Please enter your name.');
            return false;
        }
        if (!/^\d{10}$/.test(guardianDigits)) {
            Alert.alert('Invalid number', 'Guardian number must be exactly 10 digits.');
            return false;
        }
        return true;
    };

    const handleSave = async () => {
        if (!validate() || !deviceId) return;
        setSaving(true);
        try {
            await setDoc(
                doc(firestore, 'settings', deviceId),
                { userId: userId.trim(), guardianNumber: guardianDigits },
                { merge: true }
            );
            setHasSavedProfile(true);
            setMode('view');
        } catch (err) {
            console.error('[SettingsScreen] Failed to save settings:', err);
            Alert.alert('Save failed', err.message);
        } finally {
            setSaving(false);
        }
    };

    const handleGuardianChange = (text) => {
        setGuardianDigits(text.replace(/[^0-9]/g, '').slice(0, 10));
    };

    if (loading) {
        return (
            <SafeAreaView style={styles.container}>
                <ActivityIndicator size="large" color={colors.brass} />
            </SafeAreaView>
        );
    }

    return (
        <SafeAreaView style={styles.container}>
            <Text style={styles.title}>Settings</Text>

            {mode === 'view' ? (
                <View style={styles.card}>
                    <View style={styles.infoRow}>
                        <Text style={styles.infoLabel}>Your Name</Text>
                        <Text style={styles.infoValue}>{userId}</Text>
                    </View>
                    <View style={styles.divider} />
                    <View style={styles.infoRow}>
                        <Text style={styles.infoLabel}>Guardian's Number</Text>
                        <Text style={styles.infoValue}>+91 {guardianDigits}</Text>
                    </View>
                    <Pressable style={styles.editButton} onPress={() => setMode('edit')}>
                        <Text style={styles.editButtonText}>Edit</Text>
                    </Pressable>
                </View>
            ) : (
                <View style={styles.card}>
                    <View style={styles.field}>
                        <Text style={styles.label}>Your Name</Text>
                        <TextInput
                            style={styles.input}
                            value={userId}
                            onChangeText={setUserId}
                            placeholder="Enter your name"
                            placeholderTextColor={colors.muted}
                            autoCapitalize="words"
                        />
                    </View>

                    <View style={styles.field}>
                        <Text style={styles.label}>Guardian's Number</Text>
                        <View style={styles.phoneRow}>
                            <Text style={styles.prefix}>+91</Text>
                            <TextInput
                                style={styles.phoneInput}
                                value={guardianDigits}
                                onChangeText={handleGuardianChange}
                                placeholder="10-digit number"
                                placeholderTextColor={colors.muted}
                                keyboardType="number-pad"
                                maxLength={10}
                            />
                        </View>
                    </View>

                    <Pressable style={styles.saveButton} onPress={handleSave} disabled={saving}>
                        <Text style={styles.saveButtonText}>{saving ? 'Saving...' : 'Save'}</Text>
                    </Pressable>

                    {hasSavedProfile && (
                        <Pressable style={styles.cancelButton} onPress={() => setMode('view')} disabled={saving}>
                            <Text style={styles.cancelButtonText}>Cancel</Text>
                        </Pressable>
                    )}
                </View>
            )}
        </SafeAreaView>
    );
}

const styles = StyleSheet.create({
    container: { flex: 1, backgroundColor: colors.background, paddingHorizontal: 24, paddingTop: 40 },
    title: { fontSize: 26, fontWeight: '700', color: colors.ink, marginBottom: 28 },
    card: { backgroundColor: colors.white, borderRadius: 12, padding: 20 },
    infoRow: { paddingVertical: 12 },
    infoLabel: { fontSize: 13, color: colors.muted, marginBottom: 4 },
    infoValue: { fontSize: 17, color: colors.ink, fontWeight: '600' },
    divider: { height: 1, backgroundColor: '#EDE9E3' },
    editButton: { marginTop: 20, backgroundColor: colors.ink, borderRadius: 8, paddingVertical: 13, alignItems: 'center' },
    editButtonText: { color: colors.white, fontSize: 15, fontWeight: '600' },
    field: { marginBottom: 20 },
    label: { fontSize: 13, color: colors.muted, marginBottom: 8 },
    input: { borderWidth: 1, borderColor: '#E4DFD6', borderRadius: 8, paddingHorizontal: 14, paddingVertical: 12, fontSize: 16, color: colors.ink },
    phoneRow: { flexDirection: 'row', alignItems: 'center', borderWidth: 1, borderColor: '#E4DFD6', borderRadius: 8, paddingHorizontal: 14 },
    prefix: { fontSize: 16, color: colors.ink, marginRight: 8, fontWeight: '600' },
    phoneInput: { flex: 1, paddingVertical: 12, fontSize: 16, color: colors.ink },
    saveButton: { backgroundColor: colors.brass, borderRadius: 8, paddingVertical: 14, alignItems: 'center', marginTop: 4 },
    saveButtonText: { color: colors.white, fontSize: 16, fontWeight: '700' },
    cancelButton: { marginTop: 10, paddingVertical: 10, alignItems: 'center' },
    cancelButtonText: { color: colors.muted, fontSize: 14 },
});