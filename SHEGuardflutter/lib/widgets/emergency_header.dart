import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Top header section for the Emergency screen matching Master Reference (Screen 4).
/// Shows red glowing siren icon with concentric emergency halo rings and bold title.
class EmergencyHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const EmergencyHeader({
    super.key,
    this.title = 'EMERGENCY ACTIVE',
    this.subtitle = 'Help is being coordinated',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Concentric glowing emergency halo with central siren circle
        Container(
          width: 104,
          height: 104,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.emergencyRed.withValues(alpha: 0.12),
          ),
          child: Center(
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.emergencyRed.withValues(alpha: 0.22),
              ),
              child: Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color(0xFFFF334B),
                        AppColors.emergencyRed,
                        AppColors.emergencyRedDark,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x66EC1C3E),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.notifications_active_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFFE2A0AA),
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
