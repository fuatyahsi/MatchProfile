import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════
//  Dark Luxe Palette — Noir Rose · Charcoal · Rose Gold
//  Hiç mor/purple yok. Koyu arka plan. Premium feminen.
// ══════════════════════════════════════════════════

const Color noir = Color(0xFF1A1418);            // Deepest background
const Color charcoal = Color(0xFF252023);         // Card background dark
const Color graphite = Color(0xFF312B30);         // Elevated surface
const Color smoky = Color(0xFF3E363C);            // Border / divider
const Color roseGold = Color(0xFFD4A08A);         // Primary accent — warm rose gold
const Color blushRose = Color(0xFFCF8E8E);        // Secondary accent
const Color dustyRose = Color(0xFFB87878);        // Tertiary rose
const Color peach = Color(0xFFE8B89D);            // Warm highlight
const Color warmGold = Color(0xFFD4B896);         // Gold accent
const Color goldAccent = Color(0xFFC9A96E);       // Rich gold
const Color ivoryText = Color(0xFFF2E8E0);        // Primary text — warm ivory
const Color softText = Color(0xFFA89A94);         // Secondary text
const Color mutedText = Color(0xFF7A6E6A);        // Tertiary/dim text
const Color roseCaution = Color(0xFFD4736C);      // Warning/caution — warm red
const Color softGreen = Color(0xFF7BAF8E);        // Positive signals
const Color amber = Color(0xFFDBA76A);            // Moderate warning
const Color deepCard = Color(0xFF1E191C);         // Card base dark
const Color shimmer = Color(0x18D4A08A);          // Subtle glow overlay

ThemeData buildAppTheme() {
  final ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: roseGold,
    brightness: Brightness.dark,
    surface: noir,
  ).copyWith(
    primary: roseGold,
    secondary: blushRose,
    tertiary: warmGold,
    onSurface: ivoryText,
    surface: noir,
    onPrimary: noir,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: noir,
    splashFactory: InkSparkle.splashFactory,
    textTheme: TextTheme(
      headlineLarge: const TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        color: ivoryText,
        height: 1.08,
        letterSpacing: -1.2,
      ),
      headlineMedium: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: ivoryText,
        height: 1.12,
        letterSpacing: -0.6,
      ),
      headlineSmall: const TextStyle(
        fontSize: 21,
        fontWeight: FontWeight.w700,
        color: ivoryText,
        height: 1.16,
        letterSpacing: -0.2,
      ),
      titleLarge: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: ivoryText,
        letterSpacing: -0.1,
      ),
      titleMedium: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: ivoryText,
      ),
      bodyLarge: TextStyle(
        fontSize: 15,
        color: ivoryText.withValues(alpha: 0.9),
        height: 1.55,
      ),
      bodyMedium: TextStyle(
        fontSize: 13.5,
        color: ivoryText.withValues(alpha: 0.85),
        height: 1.5,
      ),
      bodySmall: const TextStyle(
        fontSize: 12,
        color: softText,
        height: 1.4,
      ),
      labelLarge: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: ivoryText,
        letterSpacing: 0.3,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: ivoryText,
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: charcoal.withValues(alpha: 0.85),
      margin: EdgeInsets.zero,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: graphite.withValues(alpha: 0.7),
      labelStyle: const TextStyle(
        color: roseGold,
        fontWeight: FontWeight.w600,
        fontSize: 13.5,
      ),
      hintStyle: TextStyle(color: softText.withValues(alpha: 0.5), fontSize: 13.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: smoky.withValues(alpha: 0.6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: roseGold, width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: graphite,
      selectedColor: roseGold.withValues(alpha: 0.2),
      side: BorderSide(color: smoky.withValues(alpha: 0.5)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelStyle: const TextStyle(
        color: ivoryText,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      checkmarkColor: roseGold,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: roseGold,
        foregroundColor: noir,
        disabledBackgroundColor: roseGold.withValues(alpha: 0.2),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: roseGold,
        side: BorderSide(color: roseGold.withValues(alpha: 0.35)),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 78,
      backgroundColor: charcoal.withValues(alpha: 0.98),
      surfaceTintColor: Colors.transparent,
      indicatorColor: roseGold.withValues(alpha: 0.15),
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>(
        (Set<WidgetState> states) => TextStyle(
          fontSize: 11,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w800
              : FontWeight.w500,
          color: states.contains(WidgetState.selected) ? roseGold : mutedText,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>(
        (Set<WidgetState> states) => IconThemeData(
          size: 22,
          color: states.contains(WidgetState.selected)
              ? roseGold
              : mutedText.withValues(alpha: 0.7),
        ),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) => ivoryText,
      ),
      trackColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) => states.contains(WidgetState.selected)
            ? roseGold.withValues(alpha: 0.5)
            : smoky,
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: roseGold,
      inactiveTrackColor: smoky,
      thumbColor: ivoryText,
      overlayColor: roseGold.withValues(alpha: 0.12),
      trackHeight: 5,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 11),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: roseGold,
      linearTrackColor: graphite,
    ),
    dividerTheme: DividerThemeData(
      color: smoky.withValues(alpha: 0.5),
      thickness: 1,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) =>
            states.contains(WidgetState.selected) ? roseGold : Colors.transparent,
      ),
      checkColor: WidgetStateProperty.all(noir),
      side: BorderSide(color: smoky.withValues(alpha: 0.8), width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: graphite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: smoky.withValues(alpha: 0.6)),
        ),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: charcoal,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: charcoal,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
  );
}
