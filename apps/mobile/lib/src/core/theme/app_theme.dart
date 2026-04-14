import 'package:flutter/material.dart';

class AppTheme {
  static const displayFontFamily = 'CormorantGaramond';

  static const _sand = Color(0xFFF4E7D3);
  static const _clay = Color(0xFFB96C3D);
  static const _ink = Color(0xFF182127);
  static const _sage = Color(0xFF5C7A72);
  static const _gold = Color(0xFFD7A93A);
  static const _paper = Color(0xFFFFFAF4);

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _clay,
      brightness: Brightness.light,
      primary: _clay,
      secondary: _sage,
      surface: _paper,
    );
    final baseTextTheme = ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
    ).textTheme;
    final textTheme = baseTextTheme.copyWith(
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontFamily: displayFontFamily,
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: _ink,
        height: 1.04,
        letterSpacing: 0.2,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontFamily: displayFontFamily,
        fontSize: 27,
        fontWeight: FontWeight.w700,
        color: _ink,
        height: 1.02,
        letterSpacing: 0.15,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontFamily: displayFontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: _ink,
        height: 1.08,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontFamily: displayFontFamily,
        fontSize: 19,
        fontWeight: FontWeight.w600,
        color: _ink,
        height: 1.1,
        letterSpacing: 0.12,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontFamily: displayFontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: _ink,
        letterSpacing: 0.18,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        fontSize: 16,
        height: 1.45,
        color: _ink,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontSize: 14,
        height: 1.4,
        color: _ink,
      ),
    );

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _paper,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: _ink,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFFE8DAC7)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: _sand,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            fontFamily: displayFontFamily,
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
            color: _ink,
            letterSpacing: 0.2,
          );
        }),
      ),
      textTheme: textTheme,
      chipTheme: ChipThemeData(
        backgroundColor: _sand,
        selectedColor: _gold.withValues(alpha: 0.22),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _ink,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}
