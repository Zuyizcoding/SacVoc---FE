import 'package:flutter/material.dart';

import 'figma_palette.dart';

/// Semantic design tokens for the app (Light theme only).
///
/// Values are mapped from the provided CSS tokens (`:root`) and OKLCH colors
/// are converted to sRGB.
class AppColors {
  AppColors._();

  // Semantic tokens (similar to Figma/CSS variables)
  static const Color background = FigmaPalette.background;
  static const Color foreground = FigmaPalette.textPrimary;

  static const Color surface = FigmaPalette.surface;
  static const Color surfaceForeground = FigmaPalette.onSurface;

  static const Color primary = FigmaPalette.brandPrimary;
  static const Color primaryForeground = FigmaPalette.onBrandPrimary;

  static const Color secondary = FigmaPalette.brandSecondary;
  static const Color secondaryForeground = FigmaPalette.onBrandSecondary;

  static const Color muted = FigmaPalette.brandSecondary;
  static const Color mutedForeground = FigmaPalette.textSecondary;

  static const Color accent = FigmaPalette.brandSecondary;
  static const Color accentForeground = FigmaPalette.textPrimary;

  static const Color destructive = FigmaPalette.error;
  static const Color destructiveForeground = FigmaPalette.onError;

  static const Color border = FigmaPalette.outline;
  static const Color inputBackground = FigmaPalette.inputBackground;
  static const Color ring = FigmaPalette.ring;

  static Color shadowTint([double opacity = 0.08]) =>
      FigmaPalette.shadowColor.withValues(alpha: opacity);
}

class AppSpacing {
  AppSpacing._();

  static const double s4 = 4;
  static const double s8 = 8;
  static const double s16 = 16;
  static const double s24 = 24;
  static const double s32 = 32;
  static const double s40 = 40;
  static const double s48 = 48;

  // Common layout defaults (list 1-column)
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(
    horizontal: s24,
    vertical: s16,
  );
}

class AppRadii {
  AppRadii._();

  // Mapped from CSS: --radius = 0.625rem (10px at 16px base)
  static const double sm = 6; // radius - 4
  static const double md = 8; // radius - 2
  static const double lg = 10; // radius
  static const double xl = 14; // radius + 4

  // Alias tương thích mã cũ; số trong tên không phải kích thước pixel.
  // Code hiện tại dùng sm/md/lg/xl để tránh hiểu nhầm.
  static const double r8 = md;
  static const double r16 = lg;
  static const double r24 = xl;
  static const double r32 = xl;

  static const double pill = 999;
}

class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Poppins';

  static TextStyle buttonLabel(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
      );
}
