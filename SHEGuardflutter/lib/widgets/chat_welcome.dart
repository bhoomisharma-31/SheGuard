import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'quick_suggestion.dart';

/// The welcome / empty state view for Ask SheGuard.
/// Shows human, safety-focused guidance and quick suggestion cards.
class ChatWelcome extends StatelessWidget {
  final ValueChanged<String> onSuggestionSelected;

  const ChatWelcome({
    super.key,
    required this.onSuggestionSelected,
  });

  static const List<Map<String, dynamic>> suggestions = [
    {
      'text': 'Is this situation dangerous?',
      'icon': Icons.help_outline_rounded,
    },
    {
      'text': 'What should I do right now?',
      'icon': Icons.near_me_outlined,
    },
    {
      'text': 'What are my legal rights?',
      'icon': Icons.gavel_rounded,
    },
    {
      'text': 'How can I stay safe on this route?',
      'icon': Icons.alt_route_rounded,
    },
    {
      'text': 'Legal information',
      'icon': Icons.shield_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),

          // Calm shield badge
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primaryNavy.withValues(alpha: 0.07),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: AppColors.primaryNavy,
              size: 28,
            ),
          ),

          const SizedBox(height: 16),

          // Title
          const Text(
            'How can I help?',
            style: TextStyle(
              color: AppColors.primaryNavy,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Subtitle
          const Text(
            'Ask about safety, legal information, or what to do next.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 28),

          // Suggestions section
          ...suggestions.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: QuickSuggestionCard(
                text: item['text'] as String,
                icon: item['icon'] as IconData,
                onTap: () => onSuggestionSelected(item['text'] as String),
              ),
            ),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
