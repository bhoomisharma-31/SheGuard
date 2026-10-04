import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class SafetyModeCard extends StatelessWidget {
  final bool isArmed;
  final ValueChanged<bool> onToggle;

  const SafetyModeCard({
    super.key,
    required this.isArmed,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Shield icon with soft background container
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.emergencyCoralGlow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: AppTheme.emergencyCoral,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          // Title and Subtitle
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Arm Safety Mode',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Enable shake & voice detection',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          // Clean ON/OFF Toggle Switch
          Switch(
            value: isArmed,
            onChanged: onToggle,
            activeThumbColor: Colors.white,
            activeTrackColor: AppTheme.emergencyCoral,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFCBD5E1),
          ),
        ],
      ),
    );
  }
}
