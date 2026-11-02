import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:math_puzzle_app/l10n/generated/app_localizations.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/app_providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final soundService = ref.read(appSoundServiceProvider);
    final soundEnabled = ref.watch(soundEnabledProvider);

    void playNavigation() => soundService.playNavigation(enabled: soundEnabled);
    void playPrimaryAction() =>
        soundService.playPrimaryAction(enabled: soundEnabled);

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppConstants.contentMaxWidth,
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(28, 30, 28, 38),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.homeGreeting,
                          style: const TextStyle(
                            color: AppColors.cyan,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          l10n.homeSubtitle,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                height: 1.12,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.homeAccessAccount,
                    onPressed: () {
                      playNavigation();
                      context.go(AppRoutes.login);
                    },
                    icon: const Icon(Icons.person_outline_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final content = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.homeChallengeTitle,
                          style: const TextStyle(
                            color: AppColors.violetBright,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          '24',
                          style: Theme.of(context).textTheme.displayMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                height: 1.1,
                              ),
                        ),
                        const SizedBox(height: 18),
                        const Wrap(
                          spacing: 9,
                          runSpacing: 9,
                          children: [
                            _NumberTile(3),
                            _NumberTile(4),
                            _NumberTile(6),
                            _NumberTile(8),
                          ],
                        ),
                      ],
                    );
                    final button = FilledButton.icon(
                      onPressed: () {
                        playPrimaryAction();
                        ref
                            .read(selectedSectionProvider.notifier)
                            .select(AppSection.game);
                        context.go(AppRoutes.game);
                      },
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(l10n.homePlayNow),
                    );
                    return constraints.maxWidth < 560
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              content,
                              const SizedBox(height: 22),
                              button,
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(child: content),
                              const SizedBox(width: 20),
                              SizedBox(width: 170, child: button),
                            ],
                          );
                  },
                ),
              ),
              const SizedBox(height: 26),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () {
                    playPrimaryAction();
                    ref
                        .read(selectedSectionProvider.notifier)
                        .select(AppSection.game);
                    context.go(AppRoutes.game);
                  },
                  icon: const Icon(Icons.play_circle_outline_rounded),
                  label: Text(l10n.homeContinue),
                ),
              ),
              const SizedBox(height: 26),
              Text(
                l10n.homeYourSpace,
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.homeStatsLabel,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.9,
                ),
              ),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 650 ? 3 : 1;
                  final width =
                      (constraints.maxWidth - (columns - 1) * 12) / columns;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: width,
                        child: _SummaryTile(
                          icon: Icons.local_fire_department_rounded,
                          tint: AppColors.cyan,
                          label: l10n.homeSequence,
                          value: l10n.homeStreakValue,
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: _SummaryTile(
                          icon: Icons.check_circle_outline_rounded,
                          tint: AppColors.violetBright,
                          label: l10n.homeChallenges,
                          value: '12',
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: _SummaryTile(
                          icon: Icons.auto_awesome_outlined,
                          tint: AppColors.success,
                          label: l10n.homePrecision,
                          value: '840 pts',
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 26),
              Text(
                l10n.homeStepTitle,
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _StepTile(
                    number: '01',
                    label: l10n.homeStepOne,
                    icon: Icons.pin_outlined,
                  ),
                  _StepTile(
                    number: '02',
                    label: l10n.homeStepTwo,
                    icon: Icons.functions_rounded,
                  ),
                  _StepTile(
                    number: '03',
                    label: l10n.homeStepThree,
                    icon: Icons.flag_outlined,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumberTile extends StatelessWidget {
  const _NumberTile(this.value);
  final int value;

  @override
  Widget build(BuildContext context) => Container(
    width: 52,
    height: 52,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Theme.of(context).dividerColor),
    ),
    child: Text(
      '$value',
      style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
    ),
  );
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.icon,
    required this.tint,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final Color tint;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 116),
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: Theme.of(context).dividerColor),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: tint),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 13),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.number,
    required this.label,
    required this.icon,
  });
  final String number;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: 220,
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Row(
      children: [
        Icon(icon, size: 19, color: AppColors.cyan),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                number,
                style: const TextStyle(
                  color: AppColors.violetBright,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
