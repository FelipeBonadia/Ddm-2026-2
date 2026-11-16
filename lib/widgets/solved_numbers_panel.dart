import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:math_puzzle_app/l10n/generated/app_localizations.dart';

import '../features/game/domain/game_engine.dart';
import '../providers/auth_providers.dart';
import 'app_loading_indicator.dart';

/// Lista os desafios que o usuário já resolveu (lidos do Firestore).
///
/// Cada chave salva tem o formato `nivel:1,2,5,9:divisaoInteira`; aqui ela
/// vira um chip como "1259 · Fácil".
class SolvedNumbersPanel extends ConsumerWidget {
  const SolvedNumbersPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return FutureBuilder<Set<String>>(
      future: ref.watch(solvedChallengesProvider.future),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: AppLoadingIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Text(l10n.progressLoadError);
        }
        final items = <({int number, GameDifficulty difficulty})>[];
        for (final key in snapshot.data ?? const <String>{}) {
          final parts = key.split(':');
          if (parts.length < 2) continue;
          final number = int.tryParse(parts[1].replaceAll(',', ''));
          if (number == null) continue;
          final difficulty = GameDifficulty.values.firstWhere(
            (value) => value.name == parts[0],
            orElse: () => GameDifficulty.intermediate,
          );
          items.add((number: number, difficulty: difficulty));
        }
        if (items.isEmpty) {
          return const Text('—');
        }
        items.sort((a, b) {
          final byLevel = a.difficulty.index.compareTo(b.difficulty.index);
          return byLevel != 0 ? byLevel : a.number.compareTo(b.number);
        });
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final item in items)
              Chip(
                label: Text(
                  '${item.number} · ${_levelLabel(l10n, item.difficulty)}',
                ),
              ),
          ],
        );
      },
    );
  }

  String _levelLabel(AppLocalizations l10n, GameDifficulty difficulty) =>
      switch (difficulty) {
        GameDifficulty.easy => l10n.progressDifficultyEasy,
        GameDifficulty.intermediate => l10n.progressDifficultyIntermediate,
        GameDifficulty.advanced => l10n.progressDifficultyAdvanced,
        GameDifficulty.hard => l10n.progressDifficultyHard,
      };
}
