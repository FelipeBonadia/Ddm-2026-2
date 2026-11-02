import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/routing/app_router.dart';
import '../models/interface_preferences.dart';
import '../services/sound_service.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = createAppRouter();
  ref.onDispose(router.dispose);
  return router;
});

enum AppSection { home, game, progress, settings }

extension AppSectionRoute on AppSection {
  String get route => switch (this) {
    AppSection.home => AppRoutes.home,
    AppSection.game => AppRoutes.game,
    AppSection.progress => AppRoutes.progress,
    AppSection.settings => AppRoutes.settings,
  };
}

AppSection? sectionForLocation(String location) {
  for (final section in AppSection.values) {
    if (section.route == location) return section;
  }
  return null;
}

class InterfacePreferencesNotifier extends Notifier<InterfacePreferences> {
  static const _localeKey = 'selected_locale';
  static const _soundEnabledKey = 'sound_enabled';
  static const _themeModeKey = 'theme_mode';
  static const _textScaleKey = 'text_scale';
  static const _fontFamilyKey = 'font_family';
  static const _seedColorKey = 'seed_color';

  @override
  InterfacePreferences build() {
    Future.microtask(_loadPreferences);
    return const InterfacePreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final localeValue = prefs.getString(_localeKey);
    final soundEnabled = prefs.getBool(_soundEnabledKey) ?? false;
    final themeModeValue = prefs.getString(_themeModeKey);
    final textScale = prefs.getDouble(_textScaleKey) ?? 1.0;
    final fontFamily = prefs.getString(_fontFamilyKey) ?? 'Space Grotesk';
    final seedColorValue =
        prefs.getInt(_seedColorKey) ?? const Color(0xFF9B7BFF).toARGB32();

    state = state.copyWith(
      locale: _resolveLocale(localeValue),
      soundEnabled: soundEnabled,
      themeMode: _resolveThemeMode(themeModeValue),
      textScale: textScale,
      fontFamily: fontFamily,
      seedColor: Color(seedColorValue),
    );
  }

  Locale _resolveLocale(String? value) {
    if (value == null || value.isEmpty) {
      final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
      if (deviceLocale.languageCode == 'pt') {
        return const Locale('pt', 'BR');
      }
      return const Locale('en');
    }

    final parts = value.split('_');
    if (parts.length == 2) {
      return Locale(parts[0], parts[1]);
    }
    return Locale(value);
  }

  ThemeMode _resolveThemeMode(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode value) async {
    state = state.copyWith(themeMode: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, value.name);
  }

  Future<void> setTextScale(double value) async {
    state = state.copyWith(textScale: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_textScaleKey, value);
  }

  Future<void> setFontFamily(String value) async {
    state = state.copyWith(fontFamily: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fontFamilyKey, value);
  }

  Future<void> setSeedColor(Color value) async {
    state = state.copyWith(seedColor: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_seedColorKey, value.toARGB32());
  }

  Future<void> setLocale(Locale value) async {
    state = state.copyWith(locale: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, value.toString());
  }

  Future<void> setSoundEnabled(bool value) async {
    state = state.copyWith(soundEnabled: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEnabledKey, value);
  }
}

final interfacePreferencesProvider =
    NotifierProvider<InterfacePreferencesNotifier, InterfacePreferences>(
      InterfacePreferencesNotifier.new,
    );

final appLocaleProvider = Provider<Locale>(
  (ref) => ref.watch(
    interfacePreferencesProvider.select((preferences) => preferences.locale),
  ),
);

final soundEnabledProvider = Provider<bool>(
  (ref) => ref.watch(
    interfacePreferencesProvider.select(
      (preferences) => preferences.soundEnabled,
    ),
  ),
);

final appSoundServiceProvider = Provider<AppSoundService>((ref) {
  final service = AppSoundService();
  ref.onDispose(() => unawaited(service.dispose()));
  return service;
});

final themeModeProvider = Provider<ThemeMode>(
  (ref) => ref.watch(
    interfacePreferencesProvider.select((preferences) => preferences.themeMode),
  ),
);

class SelectedSectionNotifier extends Notifier<AppSection> {
  @override
  AppSection build() => AppSection.home;

  void select(AppSection section) => state = section;
}

final selectedSectionProvider =
    NotifierProvider<SelectedSectionNotifier, AppSection>(
      SelectedSectionNotifier.new,
    );
