import { useState, useRef } from 'react';
import { View, Text, StyleSheet, TextInput, Pressable, FlatList, ActivityIndicator, KeyboardAvoidingView, Platform } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { colors } from '../theme';
import { BACKEND_URL } from '../config';

export default function LegalHelpScreen({ navigation }) {
    const [messages, setMessages] = useState([
        { id: 'intro', role: 'assistant', text: 'Ask me anything about your safety rights, helplines, or what to do in an emergency.' },
    ]);
    const [input, setInput] = useState('');
    const [sending, setSending] = useState(false);
    const listRef = useRef(null);

    const handleSend = async () => {
        const query = input.trim();
        if (!query || sending) return;

        setMessages((prev) => [...prev, { id: `u_${Date.now()}`, role: 'user', text: query }]);
        setInput('');
        setSending(true);

        try {
            const response = await fetch(`${BACKEND_URL}/rag-query`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ query }),
            });
            if (!response.ok) throw new Error(`Server responded with ${response.status}`);
            const data = await response.json();
            setMessages((prev) => [...prev, { id: `a_${Date.now()}`, role: 'assistant', text: data.answer }]);
        } catch (err) {
            console.error('[LegalHelpScreen] Query failed:', err);
            setMessages((prev) => [
                ...prev,
                { id: `err_${Date.now()}`, role: 'assistant', text: "Couldn't reach the server. Check your connection and try again." },
            ]);
        } finally {
            setSending(false);
            setTimeout(() => listRef.current?.scrollToEnd({ animated: true }), 100);
        }
    };

    const renderMessage = ({ item }) => (
        <View style={[styles.bubble, item.role === 'user' ? styles.userBubble : styles.assistantBubble]}>
            <Text style={item.role === 'user' ? styles.userText : styles.assistantText}>{item.text}</Text>
        </View>
    );

    return (
        <SafeAreaView style={styles.container} edges={['top', 'left', 'right', 'bottom']}>
            <View style={styles.header}>
                <Text style={styles.title}>Legal Help</Text>
                <Pressable onPress={() => navigation.goBack()} hitSlop={12}>
                    <Ionicons name="close" size={24} color={colors.muted} />
                </Pressable>
            </View>

            <KeyboardAvoidingView
                style={styles.flexOne}
                behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
                keyboardVerticalOffset={Platform.OS === 'ios' ? 90 : 0}
            >
                <FlatList
                    ref={listRef}
                    data={messages}
                    keyExtractor={(item) => item.id}
                    renderItem={renderMessage}
                    contentContainerStyle={styles.listContent}
                    onContentSizeChange={() => listRef.current?.scrollToEnd({ animated: true })}
                />

                {sending && (
                    <View style={styles.loadingRow}>
                        <ActivityIndicator size="small" color={colors.brass} />
                    </View>
                )}

                <View style={styles.inputRow}>
                    <TextInput
                        style={styles.input}
                        value={input}
                        onChangeText={setInput}
                        placeholder="Ask a question..."
                        placeholderTextColor={colors.muted}
                        multiline
                    />
                    <Pressable
                        style={[styles.sendButton, (!input.trim() || sending) && styles.sendButtonDisabled]}
                        onPress={handleSend}
                        disabled={!input.trim() || sending}
                    >
                        <Text style={styles.sendButtonText}>Send</Text>
                    </Pressable>
                </View>
            </KeyboardAvoidingView>
        </SafeAreaView>
    );
}

const styles = StyleSheet.create({
    container: { flex: 1, backgroundColor: colors.background },
    flexOne: { flex: 1 },
    header: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', paddingHorizontal: 20, paddingTop: 16, paddingBottom: 8 },
    title: { fontSize: 22, fontWeight: '700', color: colors.ink },
    listContent: { paddingHorizontal: 20, paddingBottom: 12 },
    bubble: { maxWidth: '82%', borderRadius: 14, paddingVertical: 10, paddingHorizontal: 14, marginVertical: 6 },
    userBubble: { backgroundColor: colors.ink, alignSelf: 'flex-end' },
    assistantBubble: { backgroundColor: colors.white, alignSelf: 'flex-start', borderWidth: 1, borderColor: '#EDE9E3' },
    userText: { color: colors.white, fontSize: 15, lineHeight: 21 },
    assistantText: { color: colors.ink, fontSize: 15, lineHeight: 21 },
    loadingRow: { paddingHorizontal: 20, paddingBottom: 4 },
    inputRow: { flexDirection: 'row', alignItems: 'flex-end', paddingHorizontal: 16, paddingVertical: 12, borderTopWidth: 1, borderTopColor: '#EDE9E3', backgroundColor: colors.white },
    input: { flex: 1, borderWidth: 1, borderColor: '#E4DFD6', borderRadius: 20, paddingHorizontal: 16, paddingVertical: 10, fontSize: 15, color: colors.ink, maxHeight: 100, marginRight: 10 },
    sendButton: { backgroundColor: colors.brass, borderRadius: 20, paddingHorizontal: 18, paddingVertical: 11 },
    sendButtonDisabled: { backgroundColor: '#D8CFC2' },
    sendButtonText: { color: colors.white, fontSize: 14, fontWeight: '600' },
});