import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:math_puzzle_app/l10n/generated/app_localizations.dart';

import '../features/game/domain/game_engine.dart';
import '../features/progress/presentation/progress_tracker.dart';
import '../providers/auth_providers.dart';
import 'app_loading_indicator.dart';

/// Lista os desafios que o usuário já resolveu.
///
/// Unifica as fontes de dados: lê os registros em tempo real do
/// [progressTrackerProvider] e também as chaves salvas no
/// [solvedChallengesProvider], garantindo que o progresso sempre
/// reflita as partidas da conta do usuário.
class SolvedNumbersPanel extends ConsumerWidget {
  const SolvedNumbersPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    final progress = ref.watch(progressTrackerProvider);
    final solvedChallenges =
        ref.watch(solvedChallengesProvider).value ?? const <String>{};

    if (progress.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: AppLoadingIndicator(),
      );
    }

    if (progress.hasError &&
        progress.entries.isEmpty &&
        solvedChallenges.isEmpty) {
      return Text(l10n.progressLoadError);
    }

    // Mapa para evitar duplicatas: chave única por "dificuldade:n1,n2,n3,n4"
    final uniqueItems =
        <String, ({List<int> numbers, GameDifficulty difficulty})>{};

    // 1. Extrai do histórico do progresso (subcoleção /progress)
    for (final entry in progress.entries) {
      final List<int> numbers;
      final key = entry.challengeKey;
      if (key != null) {
        final parts = key.split(':');
        if (parts.length >= 2) {
          numbers = parts[1]
              .split(',')
              .map(int.tryParse)
              .whereType<int>()
              .toList()
            ..sort();
        } else {
          numbers = _extractNumbers('${entry.leftSide} ${entry.rightSide}');
        }
      } else {
        numbers = _extractNumbers('${entry.leftSide} ${entry.rightSide}');
      }

      if (numbers.isNotEmpty) {
        final itemKey = '${entry.difficulty.name}:${numbers.join(',')}';
        uniqueItems[itemKey] = (numbers: numbers, difficulty: entry.difficulty);
      }
    }

    // 2. Extrai também de solvedChallenges (documento users/{uid}), se houver
    for (final key in solvedChallenges) {
      final parts = key.split(':');
      if (parts.length < 2) continue;
      final numbers = parts[1]
          .split(',')
          .map(int.tryParse)
          .whereType<int>()
          .toList()
        ..sort();
      if (numbers.isEmpty) continue;
      final difficulty = GameDifficulty.values.firstWhere(
        (v) => v.name == parts[0],
        orElse: () => GameDifficulty.easy,
      );
      final itemKey = '${difficulty.name}:${numbers.join(',')}';
      uniqueItems[itemKey] = (numbers: numbers, difficulty: difficulty);
    }

    final items = uniqueItems.values.toList();

    if (items.isEmpty) {
      return Text(
        l10n.progressEmptyHint,
        style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
      );
    }

    // Ordena: primeiro por dificuldade, depois pelos números
    items.sort((a, b) {
      final byLevel = a.difficulty.index.compareTo(b.difficulty.index);
      if (byLevel != 0) return byLevel;
      for (var i = 0; i < a.numbers.length && i < b.numbers.length; i++) {
        final c = a.numbers[i].compareTo(b.numbers[i]);
        if (c != 0) return c;
      }
      return a.numbers.length.compareTo(b.numbers.length);
    });

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final item in items)
          Chip(
            avatar: Icon(
              Icons.tag_rounded,
              size: 16,
              color: scheme.primary,
            ),
            label: Text(
              '${_levelLabel(l10n, item.difficulty)} · ${item.numbers.join('  ·  ')}',
            ),
            backgroundColor: scheme.surfaceContainerLow,
            side: BorderSide(
              color: scheme.outlineVariant,
              width: 1,
            ),
          ),
      ],
    );
  }

  static List<int> _extractNumbers(String text) {
    final matches = RegExp(r'\b[1-9]\b').allMatches(text);
    final numbers = matches
        .map((m) => int.tryParse(m.group(0)!))
        .whereType<int>()
        .toList()
      ..sort();
    return numbers;
  }

  String _levelLabel(AppLocalizations l10n, GameDifficulty difficulty) =>
      switch (difficulty) {
        GameDifficulty.easy => l10n.progressDifficultyEasy,
        GameDifficulty.intermediate => l10n.progressDifficultyIntermediate,
        GameDifficulty.advanced => l10n.progressDifficultyAdvanced,
        GameDifficulty.hard => l10n.progressDifficultyHard,
      };
}
