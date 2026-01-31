import 'package:flutter/material.dart';

/// Professional color system for Maharat app with Dark Mode support
abstract class AppColors {
  // ═══════════════════════════════════════════════════════════════════
  // BRAND COLORS (Same in both themes)
  // ═══════════════════════════════════════════════════════════════════

  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryContainer = Color(0xFFE0E7FF);

  static const Color secondary = Color(0xFF14B8A6);
  static const Color secondaryLight = Color(0xFF2DD4BF);
  static const Color secondaryDark = Color(0xFF0D9488);
  static const Color secondaryContainer = Color(0xFFCCFBF1);

  static const Color accent = Color(0xFFF59E0B);
  static const Color accentLight = Color(0xFFFBBF24);
  static const Color accentContainer = Color(0xFFFEF3C7);

  // ═══════════════════════════════════════════════════════════════════
  // SEMANTIC COLORS
  // ═══════════════════════════════════════════════════════════════════

  static const Color success = Color(0xFF22C55E);
  static const Color successContainer = Color(0xFFDCFCE7);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningContainer = Color(0xFFFEF3C7);

  static const Color error = Color(0xFFEF4444);
  static const Color errorContainer = Color(0xFFFEE2E2);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoContainer = Color(0xFFDBEAFE);

  // ═══════════════════════════════════════════════════════════════════
  // LIGHT THEME COLORS
  // ═══════════════════════════════════════════════════════════════════

  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE2E8F0);

  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textDisabled = Color(0xFFCBD5E1);

  // ═══════════════════════════════════════════════════════════════════
  // DARK THEME COLORS
  // ═══════════════════════════════════════════════════════════════════

  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF334155);
  static const Color dividerDark = Color(0xFF475569);

  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFFCBD5E1);
  static const Color textTertiaryDark = Color(0xFF94A3B8);
  static const Color textDisabledDark = Color(0xFF64748B);

  static const Color primaryContainerDark = Color(0xFF312E81);
  static const Color secondaryContainerDark = Color(0xFF134E4A);

  // ══════════════════════════════════════════════════════���════════════
  // SPECIAL COLORS
  // ═══════════════════════════════════════════════════════════════════

  static const Color star = Color(0xFFFBBF24);
  static const Color online = Color(0xFF22C55E);
  static const Color offline = Color(0xFF94A3B8);

  // ═══════════════════════════════════════════════════════════════════
  // GRADIENTS
  // ═══════════════════════════════════════════════════════════════════

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6366F1), Color(0xFF14B8A6)],
  );

  static const LinearGradient walletGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
  );

  // ═══════════════════════════════════════════════════════════════════
  // SHADOWS
  // ═══════════════════════════════════════════════════════════════════

  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: textPrimary.withOpacity(0.04),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: textPrimary.withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get shadowLg => [
    BoxShadow(
      color: textPrimary.withOpacity(0.12),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get primaryGlow => [
    BoxShadow(
      color: primary.withOpacity(0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
}