import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════
//  MatchProfile — Sarı / Altın Premium Açık Tema
//  ──────────────────────────────────────
//  Açık gri zemin, canlı altın vurgular,
//  beyaz kartlar, koyu profil başlıkları.
//  Referans: Hotline-style social app UI.
// ══════════════════════════════════════════════════

// ── Yeni Açık Tema Renkleri ──
const Color scaffoldBg = Color(0xFFF4F4F4);
const Color cardWhite = Color(0xFFFFFFFF);
const Color surfaceElevated = Color(0xFFFAFAFA);
const Color borderLight = Color(0xFFE8E8E8);
const Color dividerColor = Color(0xFFEEEEEE);
const Color primaryYellow = Color(0xFFF5C518);
const Color primaryDark = Color(0xFFD4A800);
const Color primaryTextAccent = Color(0xFFB8930F);  // Darker yellow for readable text on light backgrounds
const Color primaryLight = Color(0xFFFFF3C4);
const Color primarySoft = Color(0xFFFFF8E1);
const Color accentOrange = Color(0xFFFF9800);
const Color warmBg = Color(0xFFFFFBF0);
const Color textPrimary = Color(0xFF1A1A1A);
const Color textSecondary = Color(0xFF6B7280);
const Color textMuted = Color(0xFF9CA3AF);
const Color textOnDark = Color(0xFFF5F5F5);
const Color textOnYellow = Color(0xFF1A1A1A);
const Color successGreen = Color(0xFF22C55E);
const Color cautionRed = Color(0xFFEF4444);
const Color warningAmber = Color(0xFFF59E0B);
const Color infoBlue = Color(0xFF3B82F6);

// ── Koyu Yüzeyler (Profil hero, koyu kartlar) ──
const Color darkBg = Color(0xFF1A1A1A);
const Color darkCard = Color(0xFF2A2A2A);
const Color darkSurface = Color(0xFF3A3A3A);

// ═══════════════════════════════════════════════════
//  GERİYE UYUMLULUK — eski isimleri yeni açık temaya eşle
//  Tüm mevcut widget/page kodlarında t.noir, t.charcoal vb
//  kullanılıyor. Onları doğrudan açık karşılıklarına eşliyoruz.
// ═══════════════════════════════════════════════════

// Zemin → açık eşdeğerleri
const Color noir = scaffoldBg;             // eski: koyu arka plan → yeni: açık gri
const Color charcoal = cardWhite;          // eski: koyu kart → yeni: beyaz kart
const Color graphite = surfaceElevated;    // eski: koyu yüzey → yeni: açık yüzey
const Color smoky = borderLight;           // eski: koyu kenar → yeni: açık kenar
const Color slate = borderLight;

// Vurgu → altın sarı eşdeğerleri
const Color roseGold = Color(0xFF92600F);    // Deep amber — readable on white
const Color blushRose = Color(0xFF8B5E3C);   // Warm brown — readable on white
const Color dustyRose = textMuted;
const Color peach = accentOrange;
const Color warmGold = Color(0xFF92600F);    // Same deep amber
const Color goldAccent = Color(0xFFB8930F);  // Slightly lighter but still readable

// Metin → koyu eşdeğerleri
const Color ivoryText = textPrimary;       // eski: açık metin → yeni: koyu metin
const Color softText = textSecondary;
const Color mutedText = textMuted;
const Color whisperText = textMuted;

// Durum
const Color roseCaution = cautionRed;
const Color softGreen = successGreen;
const Color amber = warningAmber;
const Color deepCard = cardWhite;
const Color shimmer = Color(0x10F5C518);

ThemeData buildAppTheme() {
  final ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: primaryYellow,
    brightness: Brightness.light,
    surface: scaffoldBg,
  ).copyWith(
    primary: primaryYellow,
    secondary: primaryDark,
    tertiary: accentOrange,
    onSurface: textPrimary,
    surface: scaffoldBg,
    onPrimary: textOnYellow,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    brightness: Brightness.light,
    scaffoldBackgroundColor: scaffoldBg,
    splashFactory: InkSparkle.splashFactory,
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1.12,
        letterSpacing: -0.8,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1.16,
        letterSpacing: -0.4,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.2,
        letterSpacing: -0.2,
      ),
      titleLarge: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.1,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.1,
      ),
      bodyLarge: TextStyle(
        fontSize: 15.5,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        height: 1.6,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        height: 1.55,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textMuted,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.5,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: cardWhite,
      margin: EdgeInsets.zero,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardWhite,
      alignLabelWithHint: true,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: TextStyle(
        color: primaryDark.withValues(alpha: 0.8),
        fontWeight: FontWeight.w500,
        fontSize: 13,
      ),
      floatingLabelStyle: TextStyle(
        color: primaryDark.withValues(alpha: 0.9),
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      helperStyle: TextStyle(
        color: textMuted.withValues(alpha: 0.7),
        fontSize: 12,
        height: 1.4,
      ),
      hintStyle: TextStyle(
        color: textMuted.withValues(alpha: 0.5),
        fontSize: 14,
        height: 1.4,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: primaryYellow, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: cautionRed, width: 1.5),
      ),
      contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: primarySoft,
      selectedColor: primaryLight,
      side: BorderSide(color: primaryYellow.withValues(alpha: 0.3)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelStyle: const TextStyle(
        color: textPrimary,
        fontWeight: FontWeight.w500,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      checkmarkColor: primaryDark,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primaryYellow,
        foregroundColor: textOnYellow,
        disabledBackgroundColor: primaryYellow.withValues(alpha: 0.3),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryDark,
        side: BorderSide(color: primaryYellow.withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      backgroundColor: cardWhite,
      surfaceTintColor: Colors.transparent,
      indicatorColor: primaryLight,
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>(
        (Set<WidgetState> states) => TextStyle(
          fontSize: 10.5,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w400,
          color: states.contains(WidgetState.selected)
              ? textPrimary
              : textMuted,
          letterSpacing: 0.3,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>(
        (Set<WidgetState> states) => IconThemeData(
          size: 22,
          color: states.contains(WidgetState.selected)
              ? textPrimary
              : textMuted,
        ),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) =>
            states.contains(WidgetState.selected) ? primaryYellow : textMuted,
      ),
      trackColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) => states.contains(WidgetState.selected)
            ? primaryLight
            : borderLight,
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: primaryYellow,
      inactiveTrackColor: borderLight,
      thumbColor: primaryYellow,
      overlayColor: primaryYellow.withValues(alpha: 0.12),
      trackHeight: 3,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: primaryYellow,
      linearTrackColor: borderLight,
    ),
    dividerTheme: DividerThemeData(
      color: dividerColor,
      thickness: 0.5,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) =>
            states.contains(WidgetState.selected) ? primaryYellow : Colors.transparent,
      ),
      checkColor: WidgetStateProperty.all(textOnYellow),
      side: BorderSide(color: borderLight, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderLight),
        ),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: cardWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: cardWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryYellow,
      foregroundColor: textOnYellow,
      elevation: 4,
      shape: StadiumBorder(),
    ),
  );
}
