import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:math_puzzle_app/l10n/generated/app_localizations.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';

import 'core/theme/app_theme.dart';
import 'providers/app_providers.dart';

class MathPuzzleApp extends ConsumerWidget {
  const MathPuzzleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(interfacePreferencesProvider);
    final locale = ref.watch(appLocaleProvider);
    // Valor inicial do som (o `ref.listen` abaixo só reage a mudanças).
    ref
        .read(appSoundServiceProvider)
        .setSoundEnabled(ref.read(soundEnabledProvider));
    ref.listen(soundEnabledProvider, (_, enabled) {
      ref.read(appSoundServiceProvider).setSoundEnabled(enabled);
    });

    return MaterialApp.router(
      // Título traduzido (aba do navegador / seletor de apps), em vez de
      // um texto fixo.
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
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
      localizationsDelegates: [
        ...AppLocalizations.localizationsDelegates,
        // Traduz os textos das telas e botões do firebase_ui_auth
        // (entrar, criar conta, esqueci a senha, erros, botão do Google...).
        FirebaseUILocalizations.delegate,
      ],
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
