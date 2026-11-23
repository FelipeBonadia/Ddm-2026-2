import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:math_puzzle_app/l10n/generated/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_providers.dart';
import '../../../widgets/app_loading_indicator.dart';
import '../../../widgets/solved_numbers_panel.dart';
import '../../game/domain/game_engine.dart';
import '../../shared/presentation/feature_frame.dart';
import '../presentation/progress_tracker.dart';

class ProgressPage extends ConsumerWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final progress = ref.watch(progressTrackerProvider);
    final user = ref.watch(currentUserProvider);

    // Fallback: se não há usuário logado, mostra aviso em vez de dados vazios
    if (user == null) {
      return AppFeatureFrame(
        title: l10n.progressTitle,
        subtitle: l10n.progressSubtitle,
        child: _EmptyHistory(
          title: 'Faça login para ver seu progresso',
          hint: 'Seus dados são salvos por conta. Entre com e-mail ou Google.',
        ),
      );
    }

    final accountLabel =
        user.displayName?.isNotEmpty == true
            ? '${user.displayName} (${user.email ?? ''})'
            : (user.email ?? user.uid);

    return AppFeatureFrame(
      title: l10n.progressTitle,
      subtitle: l10n.progressSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner mostrando a conta ativa — útil para confirmar qual usuário
          // está visualizando os dados.
          _AccountBanner(accountLabel: accountLabel),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatTile(
                label: l10n.progressResolved,
                value: '${progress.solvedCount}',
                icon: Icons.check_circle_outline_rounded,
              ),
              _StatTile(
                label: l10n.progressScore,
                value: '${progress.score}',
                icon: Icons.stars_rounded,
              ),
              _StatTile(
                label: l10n.progressBestStreak,
                value: l10n.progressStreakDays(progress.bestStreakDays),
                icon: Icons.local_fire_department_rounded,
              ),
              if (progress.currentStreakAsOf(DateTime.now()) > 0)
                _StatTile(
                  label: l10n.progressCurrentStreak,
                  value: l10n.progressStreakDays(
                    progress.currentStreakAsOf(DateTime.now()),
                  ),
                  icon: Icons.whatshot_rounded,
                ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            l10n.progressSolvedNumbers,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          const SolvedNumbersPanel(),
          const SizedBox(height: 28),
          Text(
            l10n.progressHistoryTitle,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          if (progress.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: AppLoadingIndicator(),
            )
          else if (progress.hasError && progress.entries.isEmpty)
            _EmptyHistory(
              title: l10n.progressEmptyTitle,
              hint: l10n.progressLoadError,
            )
          else if (progress.entries.isEmpty)
            _EmptyHistory(
              title: l10n.progressEmptyTitle,
              hint: l10n.progressEmptyHint,
            )
          else
            for (final entry in progress.entries)
              _HistoryTile(
                expression: entry.leftSide,
                result: entry.rightSide,
                caption: l10n.progressHistoryCaption(
                  _dateLabel(entry.solvedAt, l10n.localeName),
                  _difficultyLabel(l10n, entry.difficulty),
                ),
              ),
        ],
      ),
    );
  }

  /// Um case por nível do enum [GameDifficulty]. Como é um `switch`
  /// exaustivo, se um nível for adicionado/removido o compilador avisa.
  String _difficultyLabel(AppLocalizations l10n, GameDifficulty difficulty) =>
      switch (difficulty) {
        GameDifficulty.easy => l10n.progressDifficultyEasy,
        GameDifficulty.intermediate => l10n.progressDifficultyIntermediate,
        GameDifficulty.advanced => l10n.progressDifficultyAdvanced,
        GameDifficulty.hard => l10n.progressDifficultyHard,
      };

  String _dateLabel(DateTime date, String locale) =>
      intl.DateFormat.MMMd(locale).format(date);
}

class _AccountBanner extends StatelessWidget {
  const _AccountBanner({required this.accountLabel});

  final String accountLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.account_circle_outlined, size: 16, color: scheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              accountLabel,
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 220,
    child: Container(
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
              Icon(icon, size: 17, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    ),
  );
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.expression,
    required this.result,
    required this.caption,
  });

  final String expression;
  final String result;
  final String caption;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 9),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Theme.of(context).dividerColor),
    ),
    child: Row(
      children: [
        const Icon(Icons.check_rounded, color: AppColors.success, size: 19),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                expression,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                caption,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        Text(
          '= $result',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

/// Mostrado só quando ainda não existe nenhum desafio resolvido — em vez de
/// preencher a tela com números de mentira.
class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({required this.title, required this.hint});

  final String title;
  final String hint;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Theme.of(context).dividerColor),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.timeline_outlined,
              size: 18,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          hint,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}
