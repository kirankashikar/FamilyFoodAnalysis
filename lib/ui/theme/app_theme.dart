import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// "Modernist" design system tokens — warm off-white/red-orange palette,
/// Archivo type, zero border radius, hairline dividers. Field names are kept
/// from the previous emerald/teal palette so the ~20 screens that already
/// reference AppColors.* don't need call-site changes; only the values move.
class AppColors {
  // Core surfaces & text
  static const Color bg = Color(0xFFF3F2F2);
  static const Color surface = Color(0xFFEAE9E9);
  static const Color text = Color(0xFF201E1D);
  static const Color divider = Color(0x66201E1D); // text @ 40%

  // Neutral ramp
  static const Color neutral100 = Color(0xFFF8F4F4);
  static const Color neutral300 = Color(0xFFD7D3D3);
  static const Color neutral400 = Color(0xFFBAB6B6);
  static const Color neutral600 = Color(0xFF7D7979);
  static const Color neutral800 = Color(0xFF444141);
  static const Color neutral900 = Color(0xFF2D2B2B);

  // Accent ramp (red-orange)
  static const Color accent = Color(0xFFEC3013);
  static const Color accent100 = Color(0xFFFFF2EF);
  static const Color accent400 = Color(0xFFFF9783);
  static const Color accent600 = Color(0xFFDD2B0F);
  static const Color accent700 = Color(0xFFAE1800);
  static const Color accent800 = Color(0xFF7C1405);
  static const Color accent2_500 = Color(0xFFEF6853);

  // Dark-mode companion (not in the source design — same accent, warm dark
  // neutrals; the mockup's own "dark card on light bg" trick, inverted).
  static const Color darkBg = Color(0xFF201E1D); // == text
  static const Color darkSurface = Color(0xFF2D2B2B); // == neutral900
  static const Color darkBorder = Color(0x33F3F2F2); // bg @ ~20%

  // Existing semantic names, repointed onto the tokens above so call sites
  // across the app don't need to change.
  static const Color primary = accent;
  static const Color primaryDark = accent700;
  static const Color primaryLight = accent;
  static const Color secondary = accent600;
  static const Color warmAmber = accent700;
  static const Color roseAlert = accent700;
  static const Color purpleVibrant = neutral800;

  static const Color darkCard = neutral900;
  static const Color darkCardElevated = neutral800;
  static const Color lightCard = surface;
  static const Color lightCardElevated = neutral100;
  static const Color lightBorder = divider;

  static const Color lightBg = bg;
  static const Color lightSurface = surface;

  // Macronutrient colors (matches the dashboard donut/macro-bar mockup)
  static const Color proteinColor = accent;
  static const Color carbsColor = accent2_500;
  static const Color fatColor = neutral400;
  static const Color fiberColor = accent600;
  static const Color sodiumColor = neutral600;
  static const Color caloriesColor = accent;

  /// Theme-aware muted/secondary text (text @ 55% in light, bg @ 65% in dark).
  static Color muted(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xA6F3F2F2) // bg @ ~65%
        : const Color(0x8C201E1D); // text @ 55%
  }

  /// Theme-aware hairline divider/border color.
  static Color dividerColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkBorder : divider;
  }

  // Ink-tinted elevation, matching the design's --shadow-sm/md/lg tokens.
  static List<BoxShadow> shadowSm(bool isDark) => [
        BoxShadow(
          color: (isDark ? Colors.black : neutral900).withValues(alpha: 0.14),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> shadowMd(bool isDark) => [
        BoxShadow(
          color: (isDark ? Colors.black : neutral900).withValues(alpha: 0.16),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ];

  static List<BoxShadow> shadowLg(bool isDark) => [
        BoxShadow(
          color: (isDark ? Colors.black : neutral900).withValues(alpha: 0.22),
          blurRadius: 32,
          offset: const Offset(0, 12),
        ),
      ];
}

class AppTheme {
  static TextTheme _textTheme(Brightness brightness) {
    final base = brightness == Brightness.dark
        ? Typography.material2021().white
        : Typography.material2021().black;
    return GoogleFonts.archivoTextTheme(base);
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBg,
      primaryColor: AppColors.accent,
      textTheme: _textTheme(Brightness.dark),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        secondary: AppColors.secondary,
        surface: AppColors.darkSurface,
        error: AppColors.roseAlert,
        onPrimary: AppColors.bg,
        onSecondary: AppColors.bg,
        onSurface: AppColors.bg,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBg,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.archivo(
          color: AppColors.bg,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: AppColors.bg),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.bg,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: GoogleFonts.archivo(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.bg,
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: GoogleFonts.archivo(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.accent, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: AppColors.darkBorder),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bg,
      primaryColor: AppColors.accent,
      textTheme: _textTheme(Brightness.light),
      colorScheme: const ColorScheme.light(
        primary: AppColors.accent,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.roseAlert,
        onPrimary: AppColors.bg,
        onSecondary: AppColors.bg,
        onSurface: AppColors.text,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bg,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.archivo(
          color: AppColors.text,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: AppColors.text),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.bg,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: GoogleFonts.archivo(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.text,
          side: const BorderSide(color: AppColors.divider, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: GoogleFonts.archivo(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.divider),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.divider),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.accent, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: AppColors.neutral600),
      ),
    );
  }
}
