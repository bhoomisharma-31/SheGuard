import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Compact suggestion chip matching Screen 3 of the Master Visual Reference.
/// Displayed below conversation:
/// - "Guide me with steps"
/// - "Show nearest police stations"
/// - "Tell me my rights"
class QuickSuggestionChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const QuickSuggestionChip({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.primaryNavy,
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Lightweight suggestion card for the welcome / empty state.
class QuickSuggestionCard extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final IconData? icon;

  const QuickSuggestionCard({
    super.key,
    required this.text,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: AppColors.primaryNavy.withValues(alpha: 0.05),
        highlightColor: AppColors.primaryNavy.withValues(alpha: 0.02),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: AppColors.primaryNavy),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: AppColors.primaryNavy,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
