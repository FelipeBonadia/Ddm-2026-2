import 'package:flutter/material.dart';

class InterfacePreferences {
  const InterfacePreferences({
    this.themeMode = ThemeMode.dark,
    this.textScale = 1,
    this.fontFamily = 'Space Grotesk',
    this.seedColor = const Color(0xFF9B7BFF),
    this.locale = const Locale('pt', 'BR'),
    this.soundEnabled = false,
  });

  final ThemeMode themeMode;
  final double textScale;
  final String fontFamily;
  final Color seedColor;
  final Locale locale;
  final bool soundEnabled;

  InterfacePreferences copyWith({
    ThemeMode? themeMode,
    double? textScale,
    String? fontFamily,
    Color? seedColor,
    Locale? locale,
    bool? soundEnabled,
  }) => InterfacePreferences(
    themeMode: themeMode ?? this.themeMode,
    textScale: textScale ?? this.textScale,
    fontFamily: fontFamily ?? this.fontFamily,
    seedColor: seedColor ?? this.seedColor,
    locale: locale ?? this.locale,
    soundEnabled: soundEnabled ?? this.soundEnabled,
  );
}
