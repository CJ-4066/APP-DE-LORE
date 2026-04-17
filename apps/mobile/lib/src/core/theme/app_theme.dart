import 'package:flutter/material.dart';

import 'app_palette.dart';

class AppTheme {
  static const displayFontFamily = 'CormorantGaramond';

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppPalette.indigo,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppPalette.indigo,
      onPrimary: AppPalette.moonIvory,
      secondary: AppPalette.royalViolet,
      onSecondary: AppPalette.moonIvory,
      primaryContainer: AppPalette.softLilac,
      onPrimaryContainer: AppPalette.midnight,
      secondaryContainer: AppPalette.petal,
      onSecondaryContainer: AppPalette.indigo,
      tertiary: AppPalette.flameGold,
      onTertiary: AppPalette.midnight,
      surface: AppPalette.moonIvory,
      onSurface: AppPalette.butterflyInk,
      outline: AppPalette.borderStrong,
      error: AppPalette.berry,
      onError: AppPalette.moonIvory,
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
        color: AppPalette.butterflyInk,
        height: 1.04,
        letterSpacing: 0.2,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontFamily: displayFontFamily,
        fontSize: 27,
        fontWeight: FontWeight.w700,
        color: AppPalette.butterflyInk,
        height: 1.02,
        letterSpacing: 0.15,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontFamily: displayFontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppPalette.butterflyInk,
        height: 1.08,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontFamily: displayFontFamily,
        fontSize: 19,
        fontWeight: FontWeight.w600,
        color: AppPalette.butterflyInk,
        height: 1.1,
        letterSpacing: 0.12,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontFamily: displayFontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppPalette.butterflyInk,
        letterSpacing: 0.18,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        fontSize: 16,
        height: 1.45,
        color: AppPalette.butterflyInk,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontSize: 14,
        height: 1.4,
        color: AppPalette.butterflyInk,
      ),
    );

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppPalette.petalSoft,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppPalette.butterflyInk,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppPalette.moonIvory,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppPalette.border),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppPalette.petalSoft,
        indicatorColor: AppPalette.roseQuartz.withValues(alpha: 0.72),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppPalette.indigo
                : AppPalette.mutedLavender,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            fontFamily: displayFontFamily,
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? AppPalette.indigo
                : AppPalette.mutedLavender,
            letterSpacing: 0.2,
          );
        }),
      ),
      textTheme: textTheme,
      chipTheme: ChipThemeData(
        backgroundColor: AppPalette.petal,
        selectedColor: AppPalette.roseQuartz.withValues(alpha: 0.8),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppPalette.indigo,
          foregroundColor: AppPalette.moonIvory,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppPalette.indigo,
          foregroundColor: AppPalette.moonIvory,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppPalette.indigo,
          side: const BorderSide(color: AppPalette.borderStrong),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppPalette.moonIvory,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppPalette.borderStrong),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppPalette.borderStrong),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: AppPalette.royalViolet,
            width: 1.4,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppPalette.berry),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: AppPalette.berry,
            width: 1.4,
          ),
        ),
        hintStyle: const TextStyle(
          color: AppPalette.mutedLavender,
        ),
        labelStyle: const TextStyle(
          color: AppPalette.mutedLavender,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppPalette.midnight,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppPalette.moonIvory,
        ),
        behavior: SnackBarBehavior.floating,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppPalette.moonIvory,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppPalette.moonIvory,
        surfaceTintColor: Colors.transparent,
      ),
      dividerColor: AppPalette.borderSoft,
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppPalette.indigo,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppPalette.royalViolet,
        selectionColor: AppPalette.roseQuartz.withValues(alpha: 0.55),
        selectionHandleColor: AppPalette.royalViolet,
      ),
    );
  }
}
