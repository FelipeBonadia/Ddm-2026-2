import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:math_puzzle_app/l10n/generated/app_localizations.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'providers/app_providers.dart';

class MathPuzzleApp extends ConsumerWidget {
  const MathPuzzleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(interfacePreferencesProvider);
    final locale = ref.watch(appLocaleProvider);
    ref.listen(soundEnabledProvider, (_, enabled) {
      ref.read(appSoundServiceProvider).setSoundEnabled(enabled);
    });

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(preferences),
      darkTheme: AppTheme.dark(preferences),
      themeMode: ref.watch(themeModeProvider),
      locale: locale,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(preferences.textScale),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        if (deviceLocale == null) {
          return const Locale('pt', 'BR');
        }

        for (final supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == deviceLocale.languageCode) {
            return supportedLocale;
          }
        }

        return const Locale('pt', 'BR');
      },
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
