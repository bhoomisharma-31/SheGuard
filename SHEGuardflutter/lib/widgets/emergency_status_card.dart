import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Status indicator type for emergency cards.
enum EmergencyStatusType {
  active,    // Green pill/dot — ready / available / sent
  pending,   // Amber pill/dot — analyzing / in progress
  inactive,  // Gray pill/dot — unavailable / not started
}

/// A status card matching the Emergency Active screen (Screen 4 in master reference).
/// Features dark burgundy/charcoal surface, rounded icon badge, white title,
/// muted subtitle, and a status badge pill or chevron.
class EmergencyStatusCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String title;
  final String status;
  final EmergencyStatusType statusType;
  final String? badgeText;
  final VoidCallback? onTap;

  const EmergencyStatusCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.title,
    required this.status,
    this.statusType = EmergencyStatusType.active,
    this.badgeText,
    this.onTap,
  });

  Color get _badgeBgColor {
    switch (statusType) {
      case EmergencyStatusType.active:
        return const Color(0xFF0F5132); // Deep forest green
      case EmergencyStatusType.pending:
        return const Color(0xFF663C00); // Deep amber brown
      case EmergencyStatusType.inactive:
        return const Color(0xFF2D3748);
    }
  }

  Color get _badgeTextColor {
    switch (statusType) {
      case EmergencyStatusType.active:
        return const Color(0xFF22C55E); // Bright green
      case EmergencyStatusType.pending:
        return const Color(0xFFF59E0B); // Amber
      case EmergencyStatusType.inactive:
        return AppColors.textOnDarkMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1F0E14),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF351822), width: 1),
          ),
          child: Row(
            children: [
              // Leading rounded badge
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              // Title and status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textOnDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      status,
                      style: const TextStyle(
                        color: AppColors.textOnDarkSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              // Trailing badge or chevron
              if (badgeText != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _badgeBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badgeText!,
                    style: TextStyle(
                      color: _badgeTextColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ] else if (onTap != null) ...[
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.textOnDarkMuted,
                ),
              ] else ...[
                // Small dot indicator
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _badgeTextColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
