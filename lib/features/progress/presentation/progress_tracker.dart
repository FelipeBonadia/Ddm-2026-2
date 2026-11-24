import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/auth_providers.dart';
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
    this.challengeKey,
  });

  final String leftSide;
  final String rightSide;
  final GameDifficulty difficulty;
  final DateTime solvedAt;

  /// Chave estável do desafio no formato `"nivel:n1,n2,n3,n4:intDiv"`.
  /// Usada para derivar os números mostrados no painel "Números Resolvidos".
  /// Pode ser null em entradas antigas gravadas antes deste campo existir.
  final String? challengeKey;

  Map<String, dynamic> toMap() => {
    'leftSide': leftSide,
    'rightSide': rightSide,
    // Salva o `name` do enum, nunca o índice: reordenar o enum não corrompe
    // dados antigos.
    'difficulty': difficulty.name,
    'solvedAt': Timestamp.fromDate(solvedAt),
    if (challengeKey != null) 'challengeKey': challengeKey,
  };

  /// Retorna null se o documento estiver malformado (em vez de derrubar a
  /// tela inteira por causa de um registro ruim).
  static ProgressEntry? tryFromMap(Map<String, dynamic> map) {
    final left = map['leftSide'];
    final right = map['rightSide'];
    final solvedAt = map['solvedAt'];
    if (left is! String || right is! String || solvedAt is! Timestamp) {
      return null;
    }
    return ProgressEntry(
      leftSide: left,
      rightSide: right,
      difficulty: _difficultyFromName(map['difficulty']),
      solvedAt: solvedAt.toDate(),
      challengeKey: map['challengeKey'] as String?,
    );
  }

  /// Nomes desconhecidos (ex.: "medium" de versões antigas) viram
  /// `intermediate`.
  static GameDifficulty _difficultyFromName(Object? name) {
    for (final value in GameDifficulty.values) {
      if (value.name == name) return value;
    }
    return GameDifficulty.intermediate;
  }
}

class ProgressState {
  const ProgressState({
    this.entries = const [],
    this.currentStreakDays = 0,
    this.bestStreakDays = 0,
    this.lastSolvedDay,
    this.isLoading = false,
    this.hasError = false,
  });

  /// Monta o estado a partir dos desafios salvos no Firestore. Sequências e
  /// pontuação são sempre DERIVADAS dos registros, então não existe número
  /// guardado que possa ficar fora de sincronia com o histórico.
  factory ProgressState.fromEntries(List<ProgressEntry> entries) {
    final sorted = [...entries]
      ..sort((a, b) => b.solvedAt.compareTo(a.solvedAt));
    if (sorted.isEmpty) return const ProgressState();

    // Dias distintos (calendário local), do mais antigo ao mais recente.
    final days = {
      for (final e in sorted)
        DateTime(e.solvedAt.year, e.solvedAt.month, e.solvedAt.day),
    }.toList()..sort();

    var best = 1;
    var run = 1;
    for (var i = 1; i < days.length; i++) {
      run = _calendarDaysBetween(days[i - 1], days[i]) == 1 ? run + 1 : 1;
      if (run > best) best = run;
    }

    return ProgressState(
      entries: List.unmodifiable(sorted),
      currentStreakDays: run, // sequência que termina no último dia jogado
      bestStreakDays: best,
      lastSolvedDay: days.last,
    );
  }

  /// true até o primeiro snapshot do Firestore chegar.
  final bool isLoading;

  /// true se o stream do Firestore falhou (ex.: regras de segurança).
  final bool hasError;

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
      entries.fold(0, (total, entry) => total + _pointsFor(entry.difficulty));

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
    bool? isLoading,
    bool? hasError,
  }) => ProgressState(
    entries: entries ?? this.entries,
    currentStreakDays: currentStreakDays ?? this.currentStreakDays,
    bestStreakDays: bestStreakDays ?? this.bestStreakDays,
    lastSolvedDay: lastSolvedDay ?? this.lastSolvedDay,
    isLoading: isLoading ?? this.isLoading,
    hasError: hasError ?? this.hasError,
  );
}

class ProgressTrackerController extends Notifier<ProgressState> {
  String? _uid;

  @override
  ProgressState build() {
    // Reconstrói (e troca a assinatura do Firestore) quando o usuário muda:
    // logout/login não herda o progresso de outra conta.
    final uid = ref.watch(currentUserProvider.select((user) => user?.uid));
    _uid = uid;
    if (uid == null) return const ProgressState();

    final subscription = ref
        .watch(firestoreServiceProvider)
        .watchProgressEntries(uid)
        .listen(
          (docs) {
            final entries = [
              for (final doc in docs) ?ProgressEntry.tryFromMap(doc),
            ];
            state = ProgressState.fromEntries(entries);
          },
          onError: (Object error, StackTrace stack) {
            debugPrint('Erro ao carregar progresso: $error');
            state = state.copyWith(isLoading: false, hasError: true);
          },
        );
    ref.onDispose(subscription.cancel);

    return const ProgressState(isLoading: true);
  }

  /// Chamado quando o jogador resolve um desafio corretamente. `leftSide` e
  /// `rightSide` são os dois lados da igualdade já montada pelo jogador.
  ///
  /// Só grava no Firestore; o estado da tela é atualizado pelo stream (o
  /// Firestore emite imediatamente a escrita local, mesmo offline).
  void recordSolved({
    required String leftSide,
    required String rightSide,
    required GameDifficulty difficulty,
    String? challengeKey,
  }) {
    final uid = _uid;
    if (uid == null) return; // sem usuário logado não há onde gravar

    final entry = ProgressEntry(
      leftSide: leftSide,
      rightSide: rightSide,
      difficulty: difficulty,
      solvedAt: DateTime.now(),
      challengeKey: challengeKey,
    );

    unawaited(
      ref
          .read(firestoreServiceProvider)
          .addProgressEntry(uid, entry.toMap())
          .catchError((Object error) {
            debugPrint('Erro ao salvar progresso: $error');
          }),
    );
  }
}
