import 'package:flutter/material.dart';

/// Centralized, single-source-of-truth color palette for SheGuard
/// meticulously extracted from the Master Visual Reference.
class AppColors {
  AppColors._();

  // --- BRAND & PRIMARY ---
  static const Color primaryNavy = Color(0xFF0C1E36);
  static const Color primaryNavyDark = Color(0xFF06172A);
  static const Color primaryNavyLight = Color(0xFF1E2D42);

  // --- EMERGENCY REDS ---
  static const Color emergencyRed = Color(0xFFEC1C3E);
  static const Color emergencyRedDark = Color(0xFFC21832);
  static const Color emergencyRedLight = Color(0xFFFDE8EA);
  static const Color emergencyRedGlow = Color(0x33EC1C3E);
  static const Color emergencyRedDeepBg = Color(0xFF2B0A11);

  // --- LIGHT SURFACES & BACKGROUNDS ---
  static const Color background = Color(0xFFF8F9FE);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFF1F5F9);
  static const Color border = Color(0xFFE2E8F0);
  static const Color chatUserBubble = Color(0xFFE2EAF4);
  static const Color chatUserBubbleBorder = Color(0xFFD3DFEE);

  // --- ARMED & EMERGENCY DARK SURFACES ---
  static const Color backgroundDark = Color(0xFF06172A);
  static const Color surfaceDark = Color(0xFF111E2E);
  static const Color surfaceDarkSecondary = Color(0xFF16263B);
  static const Color borderDark = Color(0xFF1E324A);

  // --- EMERGENCY SCREEN THEME TOKENS ---
  static const Color emergencyBackground = Color(0xFF1A070C);
  static const Color emergencySurface = Color(0xFF261017);
  static const Color emergencySurfaceSecondary = Color(0xFF331620);
  static const Color emergencyBorder = Color(0xFF451C28);

  // --- ARMED STATE GREEN BANNER ---
  static const Color armedBannerBg = Color(0xFF063D31);
  static const Color armedBannerBorder = Color(0xFF0D6853);

  // --- STATUS & ACCENTS ---
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color successDark = Color(0xFF064E3B);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFF78350F);

  static const Color infoBlue = Color(0xFF2563EB);
  static const Color infoBlueLight = Color(0xFFDBEAFE);

  static const Color purpleBadge = Color(0xFF8B5CF6);
  static const Color purpleBadgeLight = Color(0xFFEDE9FE);

  // --- TEXT COLORS ---
  static const Color textPrimary = Color(0xFF0C1E36);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color textOnDarkSecondary = Color(0xFFCBD5E1);
  static const Color textOnDarkMuted = Color(0xFF94A3B8);

  // --- ICONS ---
  static const Color iconSecondary = Color(0xFF64748B);
  static const Color iconSecondaryDark = Color(0xFF94A3B8);
}
