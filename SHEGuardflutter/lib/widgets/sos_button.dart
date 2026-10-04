import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SosButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isDark;

  const SosButton({
    super.key,
    this.onTap,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Concentric circular halo matching reference
        Container(
          width: 210,
          height: 210,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark
                ? AppColors.emergencyRed.withValues(alpha: 0.10)
                : const Color(0xFFFFF1F2),
          ),
          alignment: Alignment.center,
          child: Container(
            width: 178,
            height: 178,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? AppColors.emergencyRed.withValues(alpha: 0.18)
                  : const Color(0xFFFDE8EA),
            ),
            alignment: Alignment.center,
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onTap,
                customBorder: const CircleBorder(),
                splashColor: Colors.white.withValues(alpha: 0.3),
                highlightColor: Colors.white.withValues(alpha: 0.1),
                child: Ink(
                  width: 148,
                  height: 148,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFFF2E4C),
                        AppColors.emergencyRed,
                        AppColors.emergencyRedDark,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.emergencyRed.withValues(alpha: isDark ? 0.5 : 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.crisis_alert_rounded,
                        size: 38,
                        color: Colors.white,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'SOS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Tap to send emergency alert',
          style: TextStyle(
            color: isDark ? AppColors.textOnDarkSecondary : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
