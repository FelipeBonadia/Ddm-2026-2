import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import '../../models/interface_preferences.dart';

abstract final class AppTheme {
  static ThemeData light(InterfacePreferences preferences) =>
      _build(preferences, Brightness.light);

  static ThemeData dark(InterfacePreferences preferences) =>
      _build(preferences, Brightness.dark);

  static ThemeData _build(
    InterfacePreferences preferences,
    Brightness brightness,
  ) {
    final isDark = brightness == Brightness.dark;
    final background = isDark
        ? AppColors.background
        : AppColors.lightBackground;
    final surface = isDark ? AppColors.surface : AppColors.lightSurface;
    final textPrimary = isDark
        ? AppColors.textPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.textSecondary
        : AppColors.lightTextSecondary;
    final border = isDark ? AppColors.border : AppColors.lightBorder;
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: preferences.seedColor,
          brightness: brightness,
          surface: surface,
        ).copyWith(
          primary: preferences.seedColor,
          secondary: AppColors.cyan,
          onSurface: textPrimary,
        );
    final baseTextTheme = brightness == Brightness.dark
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: GoogleFonts.getTextTheme(
        preferences.fontFamily,
        baseTextTheme,
      ).apply(bodyColor: textPrimary, displayColor: textPrimary),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
      ),
      dividerColor: border,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: preferences.seedColor,
          foregroundColor: isDark
              ? AppColors.background
              : AppColors.lightSurface,
          minimumSize: const Size(48, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: border),
          minimumSize: const Size(44, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: TextStyle(color: textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
      ),
    );
  }
}
