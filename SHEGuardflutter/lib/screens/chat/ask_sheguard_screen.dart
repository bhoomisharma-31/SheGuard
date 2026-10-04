import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../screens/emergency/emergency_screen.dart';
import '../../widgets/chat_message_bubble.dart';
import '../../widgets/chat_welcome.dart';
import '../../widgets/chat_input_bar.dart';
import '../../widgets/quick_suggestion.dart';

/// The Ask SheGuard Chat screen matching Screen 3 of the Master Visual Reference.
///
/// A calm, trustworthy safety assistant UI prototype.
/// Pure UI/demo — no real AI, RAG, backend API, or emergency services connected.
class AskSheGuardScreen extends StatefulWidget {
  final String? initialQuery;
  final bool startWithSampleConversation;

  const AskSheGuardScreen({
    super.key,
    this.initialQuery,
    this.startWithSampleConversation = false,
  });

  @override
  State<AskSheGuardScreen> createState() => _AskSheGuardScreenState();
}

class _AskSheGuardScreenState extends State<AskSheGuardScreen> {
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.startWithSampleConversation) {
      _loadSampleConversation();
    } else if (widget.initialQuery != null &&
        widget.initialQuery!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleSendMessage(widget.initialQuery!);
      });
    }
  }

  void _loadSampleConversation() {
    _messages.addAll([
      ChatMessage(
        text: "Hi, I'm SheGuard.\nHow can I help you today?",
        isUser: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      ChatMessage(
        text: 'How do I file an FIR?',
        isUser: true,
        timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
      ChatMessage(
        text:
            'To file an FIR, you can:\n\n1. Visit the nearest police station\n2. Provide details of the incident\n3. Carry a valid ID proof\n\nWould you like a detailed guide or nearest police stations?',
        isUser: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
    ]);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _generateLocalMockResponse(String userText) {
    final lower = userText.toLowerCase().trim();

    if (lower.contains('how do i file an fir') || lower.contains('file an fir') || lower.contains('fir')) {
      return 'To file an FIR, you can:\n\n1. Visit the nearest police station\n2. Provide details of the incident\n3. Carry a valid ID proof\n\nWould you like a detailed guide or nearest police stations?';
    } else if (lower.contains('what should i do right now')) {
      return 'If you feel unsafe, move to a safer or more populated place and contact someone you trust. If you are in immediate danger, use SOS.';
    } else if (lower.contains('guide me with steps')) {
      return 'Steps to file an FIR:\n1. Report to duty officer at nearest police station\n2. Give detailed oral or written statement\n3. Sign only after reading the recorded statement\n4. Collect your free copy of the FIR.';
    } else if (lower.contains('nearest police station') || lower.contains('police stations')) {
      return 'Nearest Police Station: Vashi Police Station (1.2 km away).\nEmergency Desk: 24/7 Women Help Desk available.';
    } else if (lower.contains('rights') || lower.contains('tell me my rights')) {
      return 'Key Rights:\n1. Zero FIR: You can file an FIR at any police station regardless of jurisdiction.\n2. Statement to female officer: Your statement must be recorded by a woman police officer.\n3. Right to free legal aid.';
    } else if (lower.contains('is this situation dangerous')) {
      return 'Trust your instincts. If something feels uncomfortable or threatening, move toward a well-lit, populated area and alert your trusted contacts or use SOS.';
    } else if (lower.contains('legal rights') || lower.contains('legal information')) {
      return 'You have the right to personal safety and immediate assistance. For legal protections, filing a zero FIR, or official emergency support, contact 1091/112 or use the SOS trigger.';
    } else if (lower.contains('route') || lower.contains('stay safe on this route')) {
      return 'Stay in well-lit, active streets. Share your live location with trusted contacts and keep your device accessible with SheGuard ready.';
    }

    return "I'm here to help. This is a demo response for the chat UI.";
  }

  void _handleSendMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: trimmed,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
    });
    _scrollToBottom();

    // Local mock response
    final responseText = _generateLocalMockResponse(trimmed);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      setState(() {
        _messages.add(
          ChatMessage(
            text: responseText,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
      _scrollToBottom();
    });
  }

  void _onEmergencySosTapped() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EmergencyScreen(
          triggerSource: 'Manual SOS (Chat)',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primaryNavy),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        centerTitle: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 0.8),
              ),
              child: const Center(
                child: Icon(
                  Icons.smart_toy_outlined,
                  size: 18,
                  color: AppColors.primaryNavy,
                ),
              ),
            ),
            const Text(
              'Ask SheGuard',
              style: TextStyle(
                color: AppColors.primaryNavy,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.primaryNavy),
            onPressed: () {},
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- TOP EMERGENCY ESCALATION BANNER ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              color: AppColors.emergencyRedLight,
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: AppColors.emergencyRed,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Need immediate help?',
                      style: TextStyle(
                        color: AppColors.emergencyRed,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      onPressed: _onEmergencySosTapped,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emergencyRed,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'SOS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- CHAT / EMPTY STATE AREA ---
            Expanded(
              child: _messages.isEmpty
                  ? ChatWelcome(
                      onSuggestionSelected: (suggestion) {
                        _handleSendMessage(suggestion);
                      },
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 16.0,
                      ),
                      itemCount: _messages.length + 1,
                      itemBuilder: (context, index) {
                        if (index < _messages.length) {
                          return ChatMessageBubble(message: _messages[index]);
                        }

                        // Compact suggestion chips matching Screen 3 of master reference
                        return Padding(
                          padding: const EdgeInsets.only(left: 40.0, top: 8.0, bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              QuickSuggestionChip(
                                text: 'Guide me with steps',
                                onTap: () => _handleSendMessage('Guide me with steps'),
                              ),
                              QuickSuggestionChip(
                                text: 'Show nearest police stations',
                                onTap: () => _handleSendMessage('Show nearest police stations'),
                              ),
                              QuickSuggestionChip(
                                text: 'Tell me my rights',
                                onTap: () => _handleSendMessage('Tell me my rights'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            // --- INPUT BAR ---
            ChatInputBar(
              controller: _textController,
              onSend: _handleSendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
