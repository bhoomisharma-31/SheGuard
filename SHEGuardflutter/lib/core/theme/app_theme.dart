import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  // Brand colors mapped directly to centralized AppColors tokens
  static const Color primaryNavy = AppColors.primaryNavy;
  static const Color primaryNavyDark = AppColors.primaryNavyDark;
  
  static const Color emergencyCoral = AppColors.emergencyRed;
  static const Color emergencyCoralDark = AppColors.emergencyRedDark;
  static const Color emergencyCoralGlow = AppColors.emergencyRedLight;
  static const Color emergencyCoralOuterGlow = AppColors.emergencyRedGlow;
  
  static const Color background = AppColors.background;
  static const Color cardBackground = AppColors.surface;
  static const Color cardBorder = AppColors.border;
  
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color textMuted = AppColors.textMuted;
  
  static const Color statusGreen = AppColors.success;
  static const Color statusGreenLight = AppColors.successLight;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primaryNavy,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryNavy,
        secondary: AppColors.emergencyRed,
        surface: AppColors.surface,
        error: AppColors.emergencyRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: AppColors.primaryNavy),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.emergencyRed,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
