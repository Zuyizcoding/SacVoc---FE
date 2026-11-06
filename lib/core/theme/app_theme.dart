import 'package:flutter/material.dart';

import 'app_tokens.dart';

/// App theme (Material 3, Light-only) built from semantic tokens.
///
/// IMPORTANT: Colors in `AppColors` are the single source of truth.
/// Replace them with converted Figma OKLCH→HEX values once provided.
class AppTheme {
  AppTheme._();

  // Backward-compatible aliases (used by older widgets).
  static const Color scaffoldBackground = AppColors.background;
  static const Color cardSurface = AppColors.surface;
  static const Color primary = AppColors.primary;
  static const Color primaryDark = AppColors.primary;
  static const Color primaryLight = AppColors.accent;
  static const Color textPrimary = AppColors.foreground;
  static const Color textSecondary = AppColors.mutedForeground;
  static const Color textCaption = AppColors.mutedForeground;

  static const double spacing4 = AppSpacing.s4;
  static const double spacing8 = AppSpacing.s8;
  static const double spacing16 = AppSpacing.s16;
  static const double spacing24 = AppSpacing.s24;
  static const double spacing32 = AppSpacing.s32;
  static const double spacing40 = AppSpacing.s40;
  static const double spacing48 = AppSpacing.s48;

  static const double radiusSmall = AppRadii.md;
  static const double radiusMedium = AppRadii.lg;
  static const double radiusLarge = AppRadii.xl;
  static const double radiusXL = AppRadii.xl;

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: AppColors.shadowTint(0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ];

  static ThemeData get light {
    final scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.primaryForeground,
      secondary: AppColors.secondary,
      onSecondary: AppColors.secondaryForeground,
      error: AppColors.destructive,
      onError: AppColors.destructiveForeground,
      surface: AppColors.surface,
      onSurface: AppColors.surfaceForeground,
      outline: AppColors.border,
    );

    final baseTextTheme = const TextTheme(
      headlineLarge: TextStyle(
        fontFamily: AppTextStyles.fontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        fontFamily: AppTextStyles.fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        fontFamily: AppTextStyles.fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        fontFamily: AppTextStyles.fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        fontFamily: AppTextStyles.fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontFamily: AppTextStyles.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontFamily: AppTextStyles.fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w300,
      ),
      labelSmall: TextStyle(
        fontFamily: AppTextStyles.fontFamily,
        fontSize: 10,
        fontWeight: FontWeight.w300,
      ),
    );

    final textTheme = baseTextTheme.apply(
      bodyColor: AppColors.foreground,
      displayColor: AppColors.foreground,
    );

    final filledButtonStyle = FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(56),
      shape: const StadiumBorder(),
      textStyle: AppTextStyles.buttonLabel(AppColors.primaryForeground),
    );

    final outlinedButtonStyle = OutlinedButton.styleFrom(
      minimumSize: const Size.fromHeight(56),
      shape: const StadiumBorder(),
      side: BorderSide(color: AppColors.border),
      textStyle: AppTextStyles.buttonLabel(AppColors.foreground),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: AppTextStyles.fontFamily,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: scheme,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.foreground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.foreground,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(style: filledButtonStyle),
      outlinedButtonTheme: OutlinedButtonThemeData(style: outlinedButtonStyle),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          borderSide: BorderSide(color: AppColors.ring, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s16,
        ),
      ),
    );
  }
}
