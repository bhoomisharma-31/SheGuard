import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// The "Resolve Alert" button at the bottom of the Emergency screen.
/// Matches Screen 4 of the master visual reference:
/// full-width bright red pill button with "✕ Resolve Alert".
class ResolveAlertButton extends StatelessWidget {
  final VoidCallback? onResolve;

  const ResolveAlertButton({
    super.key,
    this.onResolve,
  });

  void _showConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1F0E14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF351822), width: 1),
        ),
        title: const Text(
          'Resolve Alert',
          style: TextStyle(
            color: AppColors.textOnDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Resolve this emergency alert?',
          style: TextStyle(
            color: AppColors.textOnDarkSecondary,
            fontSize: 15,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textOnDarkMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onResolve?.call();
            },
            child: const Text(
              'Resolve',
              style: TextStyle(
                color: AppColors.emergencyRed,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () => _showConfirmDialog(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.emergencyRed,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: AppColors.emergencyRed.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        icon: const Icon(Icons.close_rounded, size: 20),
        label: const Text(
          'Resolve Alert',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
