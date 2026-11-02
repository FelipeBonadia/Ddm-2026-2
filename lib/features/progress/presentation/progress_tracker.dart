import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../game/domain/game_engine.dart';

final progressTrackerProvider =
    NotifierProvider<ProgressTrackerController, ProgressState>(
      ProgressTrackerController.new,
    );

/// Diferença em dias de calendário. Converte para UTC antes de subtrair:
/// com horário de verão, `difference` entre duas meias-noites locais pode
/// dar 23h ou 25h, e `inDays` arredondaria errado (23h → 0 dias).
int _calendarDaysBetween(DateTime from, DateTime to) => DateTime.utc(
  to.year,
  to.month,
  to.day,
).difference(DateTime.utc(from.year, from.month, from.day)).inDays;

/// Um desafio resolvido corretamente. Cada campo vem direto do estado real
/// do jogo no instante em que a resposta foi aceita — nada aqui é fixo ou
/// inventado.
class ProgressEntry {
  const ProgressEntry({
    required this.leftSide,
    required this.rightSide,
    required this.difficulty,
    required this.solvedAt,
  });

  final String leftSide;
  final String rightSide;
  final GameDifficulty difficulty;
  final DateTime solvedAt;
}

class ProgressState {
  const ProgressState({
    this.entries = const [],
    this.currentStreakDays = 0,
    this.bestStreakDays = 0,
    this.lastSolvedDay,
  });

  /// Mais recente primeiro.
  final List<ProgressEntry> entries;
  final int currentStreakDays;
  final int bestStreakDays;

  /// Apenas ano/mês/dia (sem hora), usado para calcular a sequência.
  final DateTime? lastSolvedDay;

  int get solvedCount => entries.length;

  /// Sequência vigente em [now]. `currentStreakDays` só é atualizado quando o
  /// jogador acerta; se ele ficou mais de um dia sem jogar, a sequência já
  /// acabou, mesmo que o número guardado ainda seja positivo.
  int currentStreakAsOf(DateTime now) {
    final last = lastSolvedDay;
    if (last == null) return 0;
    final today = DateTime(now.year, now.month, now.day);
    return _calendarDaysBetween(last, today) <= 1 ? currentStreakDays : 0;
  }

  /// Pontuação derivada das dificuldades resolvidas de verdade. A regra
  /// (fácil=10, intermediário=20, avançado=30, difícil=40) é um ponto de
  /// partida — ajuste como quiser. O que importa é que ela nasce de
  /// desafios reais, não de um número fixo na tela.
  int get score =>
      entries.fold(0, (sum, entry) => sum + _pointsFor(entry.difficulty));

  /// `switch` exaustivo: um nível novo no enum vira erro de compilação
  /// aqui, em vez de ficar sem pontuação em silêncio.
  static int _pointsFor(GameDifficulty difficulty) => switch (difficulty) {
    GameDifficulty.easy => 10,
    GameDifficulty.intermediate => 20,
    GameDifficulty.advanced => 30,
    GameDifficulty.hard => 40,
  };

  ProgressState copyWith({
    List<ProgressEntry>? entries,
    int? currentStreakDays,
    int? bestStreakDays,
    DateTime? lastSolvedDay,
  }) => ProgressState(
    entries: entries ?? this.entries,
    currentStreakDays: currentStreakDays ?? this.currentStreakDays,
    bestStreakDays: bestStreakDays ?? this.bestStreakDays,
    lastSolvedDay: lastSolvedDay ?? this.lastSolvedDay,
  );
}

class ProgressTrackerController extends Notifier<ProgressState> {
  @override
  ProgressState build() => const ProgressState();

  // NOTA SOBRE PERSISTÊNCIA: isso vive só na memória do app — fechou o app,
  // zera. Para manter entre sessões, dá pra serializar `entries` com
  // shared_preferences, hive, drift etc. Ao serializar a dificuldade, salve
  // `difficulty.name` e trate nomes desconhecidos (ex.: "medium" de versões
  // antigas) mapeando para `intermediate`.

  /// Chamado quando o jogador resolve um desafio corretamente. `leftSide` e
  /// `rightSide` são os dois lados da igualdade já montada pelo jogador.
  void recordSolved({
    required String leftSide,
    required String rightSide,
    required GameDifficulty difficulty,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final entry = ProgressEntry(
      leftSide: leftSide,
      rightSide: rightSide,
      difficulty: difficulty,
      solvedAt: now,
    );

    final streak = _nextStreak(today);

    state = state.copyWith(
      entries: [entry, ...state.entries],
      currentStreakDays: streak.current,
      bestStreakDays: streak.best,
      lastSolvedDay: today,
    );
  }

  /// Sequência de dias consecutivos com pelo menos um acerto.
  /// - Mesmo dia do último acerto → não conta de novo.
  /// - Dia seguinte → sequência continua.
  /// - Qualquer intervalo maior → sequência reinicia em 1.
  ({int current, int best}) _nextStreak(DateTime today) {
    final lastDay = state.lastSolvedDay;
    final int current;
    if (lastDay == null) {
      current = 1;
    } else {
      final daysSince = _calendarDaysBetween(lastDay, today);
      if (daysSince == 0) {
        current = state.currentStreakDays == 0 ? 1 : state.currentStreakDays;
      } else if (daysSince == 1) {
        current = state.currentStreakDays + 1;
      } else {
        current = 1;
      }
    }
    final best = current > state.bestStreakDays
        ? current
        : state.bestStreakDays;
    return (current: current, best: best);
  }
}
