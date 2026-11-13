import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' show FirebaseUIAuth;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:math_puzzle_app/l10n/generated/app_localizations.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/app_providers.dart';
import '../../game/application/game_session.dart';
import '../../game/domain/game_engine.dart';
import '../../progress/presentation/progress_tracker.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final soundService = ref.read(appSoundServiceProvider);
    final soundEnabled = ref.watch(soundEnabledProvider);

    // Dados reais: o desafio (números sorteados) é o mesmo que o jogo vai
    // mostrar ao clicar em "Jogar", e as estatísticas vêm do progresso.
    final game = ref.watch(gameSessionProvider);
    final progress = ref.watch(progressTrackerProvider);
    final streakDays = progress.currentStreakAsOf(DateTime.now());

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
                  // Menu da conta: mostra quem está logado e permite sair.
                  // (Antes ia para /login, mas com o usuário logado o
                  // redirect do roteador voltava para a home.)
                  PopupMenuButton<String>(
                    tooltip: l10n.homeAccessAccount,
                    icon: const Icon(Icons.person_outline_rounded),
                    onOpened: playNavigation,
                    onSelected: (_) async {
                      // Pede confirmação: sair sem querer obrigaria a entrar
                      // de novo.
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: Text(l10n.accountSignOutConfirmTitle),
                          content: Text(l10n.accountSignOutConfirmBody),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(false),
                              child: Text(l10n.authCancel),
                            ),
                            FilledButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(true),
                              child: Text(l10n.accountSignOut),
                            ),
                          ],
                        ),
                      );
                      if (confirmed != true || !context.mounted) return;
                      // Zera o estado em memória de quem está saindo, para o
                      // próximo login não herdar o progresso e o desafio
                      // atual.
                      ref.invalidate(gameSessionProvider);
                      ref.invalidate(progressTrackerProvider);
                      // Sai do Firebase (e do Google); o redirect do
                      // roteador leva para a página de login.
                      FirebaseUIAuth.signOut(context: context);
                    },
                    itemBuilder: (context) {
                      final user = FirebaseAuth.instance.currentUser;
                      final who = (user?.displayName?.isNotEmpty ?? false)
                          ? user!.displayName!
                          : (user?.email ?? '');
                      return [
                        if (who.isNotEmpty) ...[
                          PopupMenuItem<String>(
                            enabled: false,
                            child: Text(who, overflow: TextOverflow.ellipsis),
                          ),
                          const PopupMenuDivider(),
                        ],
                        PopupMenuItem<String>(
                          value: 'signOut',
                          child: Row(
                            children: [
                              const Icon(Icons.logout_rounded, size: 20),
                              const SizedBox(width: 12),
                              Text(l10n.accountSignOut),
                            ],
                          ),
                        ),
                      ];
                    },
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
                        // Nível do desafio atual (no lugar do "24" fixo: o
                        // jogo não tem um alvo, e sim uma igualdade a montar).
                        Text(
                          _difficultyLabel(l10n, game.challenge.difficulty),
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 9,
                          runSpacing: 9,
                          children: [
                            for (final number in game.challenge.numbers)
                              _NumberTile(number),
                          ],
                        ),
                      ],
                    );
                    final hasProgress = game.hasContent && !game.solved;
                    final button = FilledButton.icon(
                      onPressed: () {
                        playPrimaryAction();
                        if (game.solved) {
                          ref
                              .read(gameSessionProvider.notifier)
                              .nextChallenge();
                        }
                        ref
                            .read(selectedSectionProvider.notifier)
                            .select(AppSection.game);
                        context.go(AppRoutes.game);
                      },
                      icon: Icon(
                        hasProgress
                            ? Icons.play_circle_outline_rounded
                            : Icons.play_arrow_rounded,
                      ),
                      label: Text(
                        hasProgress ? l10n.homeContinue : l10n.homePlayNow,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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
                              button,
                            ],
                          );
                  },
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
                          value: l10n.progressStreakDays(streakDays),
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: _SummaryTile(
                          icon: Icons.check_circle_outline_rounded,
                          tint: AppColors.violetBright,
                          label: l10n.homeChallenges,
                          value: '${progress.solvedCount}',
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: _SummaryTile(
                          icon: Icons.auto_awesome_outlined,
                          tint: AppColors.success,
                          // Era "Precisão" com "840 pts" fixo; o que existe de
                          // verdade é a pontuação acumulada.
                          label: l10n.progressScore,
                          value: '${progress.score}',
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

  /// Um case por nível; `switch` exaustivo (o compilador avisa se o enum mudar).
  String _difficultyLabel(AppLocalizations l10n, GameDifficulty difficulty) =>
      switch (difficulty) {
        GameDifficulty.easy => l10n.gameEasy,
        GameDifficulty.intermediate => l10n.gameIntermediate,
        GameDifficulty.advanced => l10n.gameAdvanced,
        GameDifficulty.hard => l10n.gameHard,
      };
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
      color: Theme.of(context).colorScheme.onPrimary,
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
            // Expanded: com zoom alto o rótulo quebra/encurta em vez de
            // estourar a linha.
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
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
    // maxWidth em vez de width fixa: em telas/zoom estreitos encolhe.
    constraints: const BoxConstraints(maxWidth: 220),
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