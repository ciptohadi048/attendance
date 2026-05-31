import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Builds the [ThemeData] for the app from a single set of color tokens.
///
/// Both a dark theme (the primary "Modern Industrial" look) and a light theme
/// are provided so a dark-mode toggle (bonus +3) can switch between them while
/// staying visually consistent. Typography uses Inter via google_fonts for a
/// clean enterprise feel.
class AppTheme {
  AppTheme._();

  static const double radius = 16;
  static const double inputRadius = 14;

  /// Shared text theme so font scaling/typography is identical in both modes.
  static TextTheme _textTheme(Color primary, Color secondary) {
    final base = GoogleFonts.interTextTheme();
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        color: primary,
        fontWeight: FontWeight.w800,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        color: primary,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: base.titleLarge?.copyWith(
        color: primary,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: base.titleMedium?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: base.bodyLarge?.copyWith(color: primary),
      bodyMedium: base.bodyMedium?.copyWith(color: secondary),
      bodySmall: base.bodySmall?.copyWith(color: secondary),
      titleSmall: base.titleSmall?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
      ),
      labelLarge: base.labelLarge?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: base.labelMedium?.copyWith(color: secondary),
      labelSmall: base.labelSmall?.copyWith(color: secondary),
    );
  }

  // ---------------------------------------------------------------------------
  // DARK THEME (primary)
  // ---------------------------------------------------------------------------
  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: AppColors.safetyOrange,
      onPrimary: AppColors.white,
      secondary: AppColors.orange400,
      onSecondary: AppColors.deepNavy,
      surface: AppColors.navy700,
      onSurface: AppColors.textPrimary,
      error: AppColors.danger,
      onError: AppColors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.navy800,
      textTheme: _textTheme(AppColors.textPrimary, AppColors.textSecondary),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.navy800,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        color: AppColors.navy700,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: _inputTheme(
        fill: AppColors.navy600,
        border: AppColors.navy500,
        hint: AppColors.textMuted,
      ),
      elevatedButtonTheme: _elevatedButtonTheme(),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.safetyOrange),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.navy500, thickness: 1),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.navy600,
        contentTextStyle: TextStyle(color: AppColors.textPrimary),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LIGHT THEME (dark-mode toggle off)
  // ---------------------------------------------------------------------------
  static ThemeData get light {
    const scheme = ColorScheme.light(
      primary: AppColors.safetyOrange,
      onPrimary: AppColors.white,
      secondary: AppColors.deepNavy,
      onSecondary: AppColors.white,
      surface: AppColors.lightSurface,
      onSurface: AppColors.textOnLight,
      error: AppColors.danger,
      onError: AppColors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      textTheme: _textTheme(AppColors.textOnLight, const Color(0xFF55617A)),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.textOnLight,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: const BorderSide(color: AppColors.lightBorder),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: _inputTheme(
        fill: AppColors.lightSurface,
        border: AppColors.lightBorder,
        hint: const Color(0xFF94A3B8),
      ),
      elevatedButtonTheme: _elevatedButtonTheme(),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.orange600),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.lightBorder, thickness: 1),
    );
  }

  // ---------------------------------------------------------------------------
  // Shared component themes
  // ---------------------------------------------------------------------------
  static InputDecorationTheme _inputTheme({
    required Color fill,
    required Color border,
    required Color hint,
  }) {
    OutlineInputBorder side(Color c, [double w = 1.2]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: BorderSide(color: c, width: w),
        );
    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      hintStyle: TextStyle(color: hint),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: side(border),
      enabledBorder: side(border),
      focusedBorder: side(AppColors.safetyOrange, 1.6),
      errorBorder: side(AppColors.danger),
      focusedErrorBorder: side(AppColors.danger, 1.6),
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.safetyOrange,
        foregroundColor: AppColors.white,
        disabledBackgroundColor: AppColors.orange600.withValues(alpha: 0.5),
        elevation: 0,
        minimumSize: const Size.fromHeight(54),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(inputRadius)),
      ),
    );
  }
}
