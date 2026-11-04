import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_constants.dart';
import '../core/routing/app_router.dart';
import '../providers/app_providers.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  static const List<String> _members = <String>[
    'Rick Robert Tomaz Rezende',
    'Felipe Bonadia',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleProvider);

    return SignInScreen(
      providers: [
        EmailAuthProvider(),
        GoogleProvider(
          clientId: 'REPLACE_WITH_WEB_CLIENT_ID.apps.googleusercontent.com',
        ),
      ],
      headerMaxExtent: 260,
      headerBuilder: (context, constraints, shrinkOffset) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calculate, size: 64, color: Colors.deepPurple),
              const SizedBox(height: 12),
              Text(
                AppConstants.appName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              for (final name in _members)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(name, style: const TextStyle(fontSize: 14)),
                ),
            ],
          ),
        );
      },
      footerBuilder: (context, _) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LanguageFlag(
                flag: '🇧🇷',
                label: 'Português',
                selected: locale.languageCode == 'pt',
                onTap: () => ref
                    .read(interfacePreferencesProvider.notifier)
                    .setLocale(const Locale('pt', 'BR')),
              ),
              const SizedBox(width: 16),
              _LanguageFlag(
                flag: '🇺🇸',
                label: 'English',
                selected: locale.languageCode == 'en',
                onTap: () => ref
                    .read(interfacePreferencesProvider.notifier)
                    .setLocale(const Locale('en')),
              ),
            ],
          ),
        );
      },
      actions: [
        AuthStateChangeAction<SignedIn>((context, state) {
          context.go(AppRoutes.home);
        }),
      ],
    );
  }
}

class _LanguageFlag extends StatelessWidget {
  const _LanguageFlag({
    required this.flag,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String flag;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
      ),
    );
  }
}
