import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:math_puzzle_app/l10n/generated/app_localizations.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/app_providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  void _playSelection() {
    final enabled = ref.read(soundEnabledProvider);
    ref.read(appSoundServiceProvider).playSelection(enabled: enabled);
  }

  void _showUnavailableMessage() {
    final enabled = ref.read(soundEnabledProvider);
    ref.read(appSoundServiceProvider).playWarning(enabled: enabled);
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l10n.loginUnavailable)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 820;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppConstants.contentMaxWidth,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(28),
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Expanded(child: _BrandPanel()),
                            const SizedBox(width: 50),
                            SizedBox(
                              width: 390,
                              child: _buildLoginPanel(context, showTeam: false),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [_buildLoginPanel(context, showTeam: true)],
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoginPanel(BuildContext context, {required bool showTeam}) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(
      interfacePreferencesProvider.select((value) => value.locale),
    );
    final controller = ref.read(interfacePreferencesProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.violet,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.functions_rounded,
            color: AppColors.background,
            size: 28,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.appLabel,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(color: AppColors.cyan, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 9),
        Text(
          l10n.loginTitle,
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Text(
          l10n.loginSubtitle,
          style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _showUnavailableMessage,
            icon: const Icon(Icons.account_circle_outlined),
            label: Text(l10n.loginGoogle),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _showUnavailableMessage,
            icon: const Icon(Icons.mail_outline_rounded),
            label: Text(l10n.loginEmail),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.loginLanguage,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.9,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<Locale>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment<Locale>(
              value: Locale('pt', 'BR'),
              label: Text('🇧🇷 Português'),
            ),
            ButtonSegment<Locale>(
              value: Locale('en'),
              label: Text('🇺🇸 English'),
            ),
          ],
          selected: {locale},
          onSelectionChanged: (selection) {
            if (selection.isNotEmpty) {
              _playSelection();
              controller.setLocale(selection.first);
            }
          },
        ),
        if (showTeam) ...[const SizedBox(height: 20), const _TeamPanel()],
        const SizedBox(height: 20),
        TextButton.icon(
          onPressed: () {
            final enabled = ref.read(soundEnabledProvider);
            ref.read(appSoundServiceProvider).playBack(enabled: enabled);
            context.go(AppRoutes.home);
          },
          icon: const Icon(Icons.arrow_back_rounded),
          label: Text(l10n.loginBack),
        ),
      ],
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      constraints: const BoxConstraints(minHeight: 470),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.violet,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.functions_rounded,
                  color: AppColors.background,
                  size: 27,
                ),
              ),
              const SizedBox(width: 13),
              Text(
                l10n.appLabel,
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 38),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.loginBrandTag,
                  style: const TextStyle(
                    color: AppColors.cyan,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.loginBrandHeading,
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w700, height: 1.1),
                ),
                const SizedBox(height: 20),
                const _NumberMotif(),
              ],
            ),
          ),
          const _TeamPanel(),
        ],
      ),
    );
  }
}

class _TeamPanel extends StatelessWidget {
  const _TeamPanel();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.loginTeamTitle,
            style: const TextStyle(
              color: AppColors.cyan,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.loginTeamNames,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberMotif extends StatelessWidget {
  const _NumberMotif();

  @override
  Widget build(BuildContext context) => const Wrap(
    spacing: 9,
    children: [
      _MotifTile('3', AppColors.violet),
      _MotifTile('＋', AppColors.cyan),
      _MotifTile('6', AppColors.success),
      _MotifTile('＝', AppColors.violetBright),
      _MotifTile('24', AppColors.cyan),
    ],
  );
}

class _MotifTile extends StatelessWidget {
  const _MotifTile(this.label, this.tint);

  final String label;
  final Color tint;

  @override
  Widget build(BuildContext context) => Container(
    width: 42,
    height: 42,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(11),
    ),
    child: Text(
      label,
      style: TextStyle(color: tint, fontWeight: FontWeight.w700),
    ),
  );
}
