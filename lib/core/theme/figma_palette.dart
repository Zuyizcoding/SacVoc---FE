import 'package:flutter/material.dart';

/// Figma source-of-truth palette (Light-only).
///
/// Replace the hex values below with sRGB HEX from Figma Inspect/Styles.
/// Do NOT keep OKLCH in code.
///
/// NOTE: Current defaults mirror the existing token values to avoid breaking the
/// build. Once you paste the real Figma values here, the whole app will update
/// consistently via Theme/`AppColors`.
class FigmaPalette {
  FigmaPalette._();

  // Brand
  // Chosen from provided RGB list to avoid the app looking black.
  static const Color brandPrimary = Color(0xFF2A9D8F); // teal
  static const Color onBrandPrimary = Color(0xFFFFFFFF);
  static const Color brandSecondary = Color(0xFFF5D7C3); // peach pastel
  static const Color onBrandSecondary = Color(0xFF030213);

  // CSS theme tokens (raw)
  static const Color white = Color(0xFFFFFFFF); // #fff/#ffffff
  static const Color veryDark = Color(0xFF030213); // #030213
  static const Color muted = Color(0xFFECECF0); // #ececf0
  static const Color mutedForeground = Color(0xFF717182); // #717182
  static const Color accent = Color(0xFFE9EBEF); // #e9ebef
  static const Color destructive = Color(0xFFD4183D); // #d4183d
  static const Color inputBg = Color(0xFFF3F3F5); // #f3f3f5
  static const Color switchBackground = Color(0xFFCBCED4); // #cbced4

  // CTA gradient ("Get Started" in Figma)
  // Warm pastel gradient from provided list (coral -> sandy orange).
  static const Color brandGradientStart = Color(0xFFE76F51); // coral
  static const Color brandGradientEnd = Color(0xFFF4A261); // sandy brown/orange

  // Surfaces
  static const Color background = Color(0xFFF3F3F5); // off-white / pastel-ish
  static const Color onBackground = Color(0xFF030213);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF030213);

  // Text
  static const Color textPrimary = Color(0xFF030213);
  static const Color textSecondary = Color(0xFF717182);

  // Outline / borders
  static const Color outline = Color(0xFFCBCED4); // switch-background

  // States
  static const Color error = Color(0xFFD4183D);
  static const Color onError = Color(0xFFFFFFFF);

  // Semantic status colors (adjust to match Figma)
  // Defaults are chosen from the provided TSX palette list.
  static const Color success = Color(0xFF2A9D8F); // teal
  static const Color warning = Color(0xFFE9C46A); // gold
  static const Color danger = Color(0xFFD4183D); // destructive

  // Focus ring
  static const Color ring = Color(0xFFCBCED4);

  // Inputs
  static const Color inputBackground = Color(0xFFFFFFFF);

  // Cards
  static const Color shadowColor = Color(0x14000000); // 8% black

  // Extracted component colors (raw)
  static const Color black = Color(0xFF000000);
  static const Color gray = Color(0xFF808080);
  static const Color grayCCC = Color(0xFFCCCCCC);
  static const Color grayC8 = Color(0xFFC8C8C8);

  static const Color saddleBrown = Color(0xFF8B4513);
  static const Color brown = Color(0xFF8D5524);
  static const Color peru = Color(0xFFCD853F);
  static const Color chocolate = Color(0xFFD2691E);
  static const Color tanBeige = Color(0xFFD4A574);
  static const Color coral = Color(0xFFE76F51);
  static const Color gold = Color(0xFFE9C46A);
  static const Color khaki = Color(0xFFF0E68C);
  static const Color sandyBrown = Color(0xFFF4A261);
  static const Color peach = Color(0xFFF5D7C3);

  // Optional: app-wide background gradient.
  // If Figma uses a gradient page background, set these.
  static const Color? backgroundGradientStart = null;
  static const Color? backgroundGradientEnd = null;

  static LinearGradient get ctaGradient => LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [brandGradientStart, brandGradientEnd],
      );

  static LinearGradient? get backgroundGradient {
    final start = backgroundGradientStart;
    final end = backgroundGradientEnd;
    if (start == null || end == null) return null;

    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [start, end],
    );
  }
}
