import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  // ═══════════════════════════════════════════════════════════════════
  // DESIGN TOKENS - حواف أكبر مثل التصميم
  // ═══════════════════════════════════════════════════════════════════

  static const double radiusSm = 12.0;   // كان 8
  static const double radiusMd = 16.0;   // كان 12
  static const double radiusLg = 20.0;   // كان 16
  static const double radiusXl = 24.0;   // كان 20
  static const double radiusXxl = 28.0;  // جديد - للكاردات الكبيرة

  // ═══════════════════════════════════════════════════════════════════
  // LIGHT THEME
  // ═══════════════════════════════════════════════════════════════════

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryContainer,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.secondaryContainer,
        tertiary: AppColors.accent,
        error: AppColors.error,
        onError: Colors.white,
        errorContainer: AppColors.errorContainer,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.divider,
        onSurfaceVariant: AppColors.textSecondary,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: _buildTextTheme(false),
      primaryTextTheme: _buildTextTheme(false),

      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd), // 16
          ),
          textStyle: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.divider, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: GoogleFonts.cairo(fontSize: 14, color: AppColors.textTertiary),
        labelStyle: GoogleFonts.cairo(fontSize: 14, color: AppColors.textSecondary),
        prefixIconColor: AppColors.textTertiary,
        suffixIconColor: AppColors.textTertiary,
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
          // ✅ بدون side/border
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXxl),
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXxl)),
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        selectedLabelStyle: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.cairo(fontSize: 12),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return AppColors.textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.divider;
        }),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: AppColors.textTertiary, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // DARK THEME
  // ═══════════════════════════════════════════════════════════════════

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryContainerDark,
        secondary: AppColors.secondaryLight,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.secondaryContainerDark,
        tertiary: AppColors.accentLight,
        error: AppColors.error,
        onError: Colors.white,
        errorContainer: Color(0xFF7F1D1D),
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimaryDark,
        surfaceContainerHighest: AppColors.dividerDark,
        onSurfaceVariant: AppColors.textSecondaryDark,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: _buildTextTheme(true),
      primaryTextTheme: _buildTextTheme(true),

      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textPrimaryDark,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryDark,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          side: const BorderSide(color: AppColors.dividerDark, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          textStyle: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: AppColors.dividerDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: AppColors.dividerDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: GoogleFonts.cairo(fontSize: 14, color: AppColors.textTertiaryDark),
        labelStyle: GoogleFonts.cairo(fontSize: 14, color: AppColors.textSecondaryDark),
        prefixIconColor: AppColors.textTertiaryDark,
        suffixIconColor: AppColors.textTertiaryDark,
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.cardDark,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
          // ✅ بدون side/border
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceDark,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXxl),
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXxl)),
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.textTertiaryDark,
        selectedLabelStyle: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.cairo(fontSize: 12),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      dividerTheme: const DividerThemeData(color: AppColors.dividerDark, thickness: 1),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return AppColors.textTertiaryDark;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.dividerDark;
        }),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: AppColors.textTertiaryDark, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // TEXT THEME
  // ═══════════════════════════════════════════════════════════════════

  static TextTheme _buildTextTheme(bool isDark) {
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return TextTheme(
      displayLarge: GoogleFonts.cairo(fontSize: 57, fontWeight: FontWeight.w700, color: textColor),
      displayMedium: GoogleFonts.cairo(fontSize: 45, fontWeight: FontWeight.w700, color: textColor),
      displaySmall: GoogleFonts.cairo(fontSize: 36, fontWeight: FontWeight.w600, color: textColor),
      headlineLarge: GoogleFonts.cairo(fontSize: 32, fontWeight: FontWeight.w600, color: textColor),
      headlineMedium: GoogleFonts.cairo(fontSize: 28, fontWeight: FontWeight.w600, color: textColor),
      headlineSmall: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w600, color: textColor),
      titleLarge: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w600, color: textColor),
      titleMedium: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
      titleSmall: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
      bodyLarge: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w400, color: textColor),
      bodyMedium: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w400, color: textColor),
      bodySmall: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w400, color: secondaryColor),
      labelLarge: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
      labelMedium: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
      labelSmall: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w500, color: secondaryColor),
    );
  }
}