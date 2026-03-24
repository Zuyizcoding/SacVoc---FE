/// Theme chính cho app Sắc Vóc.
///
/// Tuân thủ NGHIÊM NGẶT ui-ux-design.md:
///   #1 — Modern Minimalist: tối giản, tập trung nội dung
///   #2 — 8pt grid: mọi giá trị spacing là bội số 8
///   #3 — Nền #FAFAFA (không trắng tinh), bóng đổ mềm (colored shadow)
///   #4 — Font Poppins, phân cấp: Heading Bold > Body Regular > Caption Light
///
/// Cách dùng: MaterialApp(theme: AppTheme.light, ...)
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._(); // Không cho phép tạo instance

  // ═══════════════════════════════════════════
  // HỆ THỐNG MÀU (ui-ux-design #3)
  // ═══════════════════════════════════════════
  /// Nền chính — KHÔNG dùng trắng tinh (#FFFFFF) để giảm mỏi mắt
  static const Color scaffoldBackground = Color(0xFFFAFAFA);

  /// Surface cho Card/Dialog
  static const Color cardSurface = Colors.white;

  /// Primary — tông ấm hài hòa với concept "Sắc Vóc"
  static const Color primary = Color(0xFFE57373);      // Warm rose
  static const Color primaryDark = Color(0xFFD32F2F);
  static const Color primaryLight = Color(0xFFFFCDD2);

  /// Text
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textCaption = Color(0xFFBDBDBD);

  // ═══════════════════════════════════════════
  // SPACING — 8pt GRID (ui-ux-design #2)
  // ═══════════════════════════════════════════
  /// Mọi margin/padding PHẢI dùng các giá trị này
  static const double spacing4 = 4;    // half-unit (ngoại lệ cho icon gap)
  static const double spacing8 = 8;
  static const double spacing16 = 16;
  static const double spacing24 = 24;
  static const double spacing32 = 32;
  static const double spacing40 = 40;
  static const double spacing48 = 48;

  /// Border radius chuẩn
  static const double radiusSmall = 8;
  static const double radiusMedium = 16;
  static const double radiusLarge = 24;
  static const double radiusXL = 32;

  // ═══════════════════════════════════════════
  // SHADOW — Bóng đổ mềm (ui-ux-design #3)
  // ═══════════════════════════════════════════
  /// Bóng nhẹ cho Card — KHÔNG dùng bóng đen cứng
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: primary.withOpacity(0.06),  // colored shadow
      blurRadius: 16,                     // bội 8
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  /// Bóng trung bình cho bottom sheet, FAB
  static List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color: primary.withOpacity(0.1),
      blurRadius: 24,                    // bội 8
      offset: const Offset(0, 8),        // bội 8
      spreadRadius: 0,
    ),
  ];

  // ═══════════════════════════════════════════
  // THEME DATA — Light (ui-ux-design #1 Modern Minimalist)
  // ═══════════════════════════════════════════
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Poppins',  // ui-ux-design #4: Font hiện đại

    // Scaffold
    scaffoldBackgroundColor: scaffoldBackground,

    // Color Scheme
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      surface: scaffoldBackground,
    ),

    // AppBar — tối giản
    appBarTheme: const AppBarTheme(
      backgroundColor: scaffoldBackground,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 18,
        fontWeight: FontWeight.w600,  // SemiBold
        color: textPrimary,
      ),
    ),

    // Card — Glassmorphism-ready
    cardTheme: CardThemeData(
      color: cardSurface,
      elevation: 0,                         // Dùng boxShadow thay vì elevation
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: spacing16,
        vertical: spacing8,
      ),
    ),

    // Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: spacing24,
          vertical: spacing16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w600,  // SemiBold
        ),
      ),
    ),

    // Text Theme — phân cấp (ui-ux-design #4)
    textTheme: const TextTheme(
      // Heading — Bold
      headlineLarge: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 28,
        fontWeight: FontWeight.w700,  // Bold
        color: textPrimary,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 24,
        fontWeight: FontWeight.w600,  // SemiBold
        color: textPrimary,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),

      // Body — Regular
      bodyLarge: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 16,
        fontWeight: FontWeight.w400,  // Regular
        color: textPrimary,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        height: 1.5,
      ),

      // Caption — Light
      bodySmall: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 12,
        fontWeight: FontWeight.w300,  // Light
        color: textCaption,
      ),
      labelSmall: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 10,
        fontWeight: FontWeight.w300,
        color: textCaption,
      ),
    ),

    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacing16,
        vertical: spacing16,
      ),
    ),
  );
}
