import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:math_puzzle_app/l10n/generated/app_localizations.dart';

import '../features/game/domain/game_engine.dart';
import '../providers/auth_providers.dart';
import 'app_loading_indicator.dart';

/// Lista os desafios que o usuário já resolveu (lidos do Firestore).
///
/// Cada chave salva tem o formato `nivel:1,2,5,9:divisaoInteira`; aqui ela
/// vira um chip como "Fácil · 1 2 5 9".
class SolvedNumbersPanel extends ConsumerWidget {
  const SolvedNumbersPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

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

        // Parseia cada chave no formato "nivel:n1,n2,n3,n4:intDiv"
        final items = <({List<int> numbers, GameDifficulty difficulty})>[];
        for (final key in snapshot.data ?? const <String>{}) {
          final parts = key.split(':');
          if (parts.length < 2) continue;
          final numbers = parts[1]
              .split(',')
              .map(int.tryParse)
              .whereType<int>()
              .toList();
          if (numbers.isEmpty) continue;
          numbers.sort();
          final difficulty = GameDifficulty.values.firstWhere(
            (v) => v.name == parts[0],
            orElse: () => GameDifficulty.easy,
          );
          items.add((numbers: numbers, difficulty: difficulty));
        }

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
                avatar: CircleAvatar(
                  backgroundColor: scheme.primaryContainer,
                  child: Text(
                    _levelInitial(item.difficulty),
                    style: TextStyle(
                      color: scheme.onPrimaryContainer,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                label: Text(item.numbers.join('  ·  ')),
                backgroundColor: scheme.surfaceContainerLow,
                side: BorderSide(
                  color: scheme.outlineVariant,
                  width: 1,
                ),
              ),
          ],
        );
      },
    );
  }

  String _levelInitial(GameDifficulty difficulty) => switch (difficulty) {
    GameDifficulty.easy => 'F',
    GameDifficulty.intermediate => 'I',
    GameDifficulty.advanced => 'A',
    GameDifficulty.hard => 'D',
  };
}
