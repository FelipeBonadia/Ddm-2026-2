import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../progress/presentation/progress_tracker.dart';
import '../domain/game_engine.dart';

final gameSessionProvider =
    NotifierProvider<GameSessionController, GameSessionState>(
      GameSessionController.new,
    );

enum EquationSide { left, right }

class GameTokenPlacement {
  const GameTokenPlacement({
    this.side = EquationSide.left,
    required this.token,
    this.numberIndex,
  });

  final EquationSide side;
  final String token;

  /// Índice do número em `challenge.numbers` (null para operadores,
  /// parênteses e igualdade). É o que permite devolver a peça certa
  /// para a paleta ao remover, mesmo com números repetidos.
  final int? numberIndex;
}

class GameSessionState {
  const GameSessionState({
    required this.challenge,
    this.tokens = const [],
    this.usedNumberIndexes = const {},
    this.numberSelectionOrder = const [],
    this.placements = const [],
    this.evaluation,
    this.inputError,
    this.attempts = 0,
    this.solved = false,
  });

  final GameChallenge challenge;

  /// Sempre derivado de [placements] (ver `GameSessionController._commit`).
  final List<String> tokens;
  final Set<int> usedNumberIndexes;
  final List<int> numberSelectionOrder;

  /// Fonte da verdade da expressão: uma entrada por token, na mesma ordem.
  final List<GameTokenPlacement> placements;
  final EqualityEvaluation? evaluation;
  final GameExpressionError? inputError;
  final int attempts;
  final bool solved;

  String get expression => tokens.join(' ');

  List<String> tokensFor(EquationSide side) =>
      GameSessionController._sideTokens(tokens, side);

  GameSessionState copyWith({
    GameChallenge? challenge,
    List<String>? tokens,
    Set<int>? usedNumberIndexes,
    List<int>? numberSelectionOrder,
    List<GameTokenPlacement>? placements,
    EqualityEvaluation? evaluation,
    bool clearEvaluation = false,
    GameExpressionError? inputError,
    bool clearInputError = false,
    int? attempts,
    bool? solved,
  }) => GameSessionState(
    challenge: challenge ?? this.challenge,
    tokens: tokens ?? this.tokens,
    usedNumberIndexes: usedNumberIndexes ?? this.usedNumberIndexes,
    numberSelectionOrder: numberSelectionOrder ?? this.numberSelectionOrder,
    placements: placements ?? this.placements,
    evaluation: clearEvaluation ? null : evaluation ?? this.evaluation,
    inputError: clearInputError ? null : inputError ?? this.inputError,
    attempts: attempts ?? this.attempts,
    solved: solved ?? this.solved,
  );
}

class GameSessionController extends Notifier<GameSessionState> {
  static const _numberPool = [1, 2, 3, 4, 5, 6, 7, 8, 9];

  final ChallengeGenerator _generator = ChallengeGenerator(
    numberPool: _numberPool,
  );
  final Set<String> _seenChallengeKeys = {};
  final ExpressionEvaluator _evaluator = ExpressionEvaluator();

  @override
  GameSessionState build() =>
      GameSessionState(challenge: _generate(GameDifficulty.easy));

  // ── Validação (a UI usa isso para aceitar/recusar drops) ──────────────────

  bool canAddNumber(int index) {
    if (state.solved ||
        index < 0 ||
        index >= state.challenge.numbers.length ||
        state.usedNumberIndexes.contains(index)) {
      return false;
    }
    return true;
  }

  bool canAddOperation(GameOperation operation) =>
      !state.solved && state.challenge.allowedOperations.contains(operation);

  bool canAddParenthesis() => !state.solved;

  bool canAddEquality() => !state.solved && !state.tokens.contains('=');

  // ── Construção da equação ─────────────────────────────────────────────────
  // `insertAt` = posição na lista de tokens (0..length). Fora do intervalo ou
  // null → adiciona no final.

  bool addNumber(int index, [int? insertAt]) {
    if (!canAddNumber(index)) return false;
    _insert(
      GameTokenPlacement(
        token: '${state.challenge.numbers[index]}',
        numberIndex: index,
      ),
      insertAt,
    );
    return true;
  }

  bool addOperation(GameOperation operation, [int? insertAt]) {
    if (!canAddOperation(operation)) return false;
    _insert(GameTokenPlacement(token: operation.symbol), insertAt);
    return true;
  }

  bool addParenthesis({required bool opening, int? insertAt}) {
    if (!canAddParenthesis()) return false;
    _insert(GameTokenPlacement(token: opening ? '(' : ')'), insertAt);
    return true;
  }

  bool addEquality([int? insertAt]) {
    if (!canAddEquality()) return false;
    _insert(const GameTokenPlacement(token: '='), insertAt);
    return true;
  }

  /// Move um token já colocado. [to] é a posição final desejada na lista
  /// depois da remoção (0..length-1).
  bool moveToken(int from, int to) {
    final length = state.placements.length;
    if (state.solved || from < 0 || from >= length) return false;
    final target = to.clamp(0, length - 1);
    if (target == from) return false;
    final placements = [...state.placements];
    final moved = placements.removeAt(from);
    placements.insert(target, moved);
    _commit(placements, state.usedNumberIndexes, state.numberSelectionOrder);
    return true;
  }

  void removeAt(int index) {
    if (state.solved || index < 0 || index >= state.placements.length) return;
    final placements = [...state.placements];
    final removed = placements.removeAt(index);

    final used = {...state.usedNumberIndexes};
    final order = [...state.numberSelectionOrder];
    final numberIndex = removed.numberIndex;
    if (numberIndex != null) {
      // Usa o índice guardado no placement — antes procurava pelo VALOR e
      // liberava o número errado quando havia valores repetidos (ex.: 3 e 3).
      used.remove(numberIndex);
      order.remove(numberIndex);
    }

    _commit(placements, used, order);
  }

  void removeLast() {
    if (state.solved || state.tokens.isEmpty) return;
    removeAt(state.tokens.length - 1);
  }

  void clearExpression() {
    if (state.solved) return;
    _commit(const [], const {}, const []);
  }

  // ── Wrappers de compatibilidade ───────────────────────────────────────────

  bool selectNumber(int index) => addNumber(index);
  bool selectOperation(GameOperation operation) => addOperation(operation);
  bool addLeftParenthesis() => addParenthesis(opening: true);
  bool addRightParenthesis() => addParenthesis(opening: false);

  bool dropNumber(int index, [EquationSide? side]) => addNumber(index);
  bool dropOperation(GameOperation operation, [EquationSide? side]) =>
      addOperation(operation);
  bool dropParenthesis({required bool opening, EquationSide? side}) =>
      addParenthesis(opening: opening);

  bool canDropNumber(int index, [EquationSide? side]) => canAddNumber(index);
  bool canDropOperation(GameOperation operation, [EquationSide? side]) =>
      canAddOperation(operation);
  bool canDropParenthesis({required bool opening, EquationSide? side}) =>
      canAddParenthesis();
  bool canDropEquality([EquationSide? side]) => canAddEquality();
  void removeLastFromSide(EquationSide side) => removeLast();

  // ── Verificação / desafios ────────────────────────────────────────────────

  EqualityEvaluation? checkAnswer() {
    if (state.solved) return state.evaluation;
    final evaluation = _evaluator.evaluate(state.expression, state.challenge);
    state = state.copyWith(
      evaluation: evaluation,
      inputError: evaluation.error,
      attempts: state.attempts + 1,
      solved: evaluation.isCorrect,
    );
    if (evaluation.isCorrect) {
      // Grava o desafio resolvido de verdade; é daqui que a página de
      // progresso passa a tirar os números, em vez de valores fixos.
      ref
          .read(progressTrackerProvider.notifier)
          .recordSolved(
            leftSide: state.tokensFor(EquationSide.left).join(' '),
            rightSide: state.tokensFor(EquationSide.right).join(' '),
            difficulty: state.challenge.difficulty,
          );
    }
    return evaluation;
  }

  void setDifficulty(GameDifficulty difficulty) {
    state = GameSessionState(
      challenge: _generate(difficulty),
      attempts: state.attempts,
    );
  }

  void skipChallenge() {
    state = GameSessionState(
      challenge: _generate(state.challenge.difficulty),
      attempts: state.attempts,
    );
  }

  void nextChallenge() {
    if (!state.solved) return;
    state = GameSessionState(
      challenge: _generate(state.challenge.difficulty),
      attempts: state.attempts,
    );
  }

  GameChallenge _generate(GameDifficulty difficulty) {
    final challenge = _generator.generate(
      difficulty: difficulty,
      excludedChallengeKeys: _seenChallengeKeys,
    );
    _seenChallengeKeys.add(challenge.key);
    return challenge;
  }

  // ── Internos ──────────────────────────────────────────────────────────────

  /// Insere um placement mantendo tokens/placements/usados em sincronia.
  /// (Antes o placement era sempre adicionado no FIM mesmo quando o token era
  /// inserido no meio, e os dois ficavam fora de ordem.)
  void _insert(GameTokenPlacement placement, int? insertAt) {
    final placements = [...state.placements];
    final index = (insertAt ?? placements.length).clamp(0, placements.length);
    placements.insert(index, placement);

    final used = {...state.usedNumberIndexes};
    final order = [...state.numberSelectionOrder];
    final numberIndex = placement.numberIndex;
    if (numberIndex != null) {
      used.add(numberIndex);
      order.add(numberIndex);
    }

    _commit(placements, used, order);
  }

  /// Único ponto que escreve a expressão no estado; `tokens` é sempre
  /// derivado de `placements`, então nunca divergem.
  void _commit(
    List<GameTokenPlacement> placements,
    Set<int> usedIndexes,
    List<int> numberOrder,
  ) {
    state = state.copyWith(
      tokens: List.unmodifiable(placements.map((p) => p.token)),
      usedNumberIndexes: Set.unmodifiable(usedIndexes),
      numberSelectionOrder: List.unmodifiable(numberOrder),
      placements: List.unmodifiable(placements),
      clearEvaluation: true,
      clearInputError: true,
    );
  }

  static List<String> _sideTokens(List<String> tokens, EquationSide side) {
    final separator = tokens.indexOf('=');
    if (side == EquationSide.left) {
      return separator < 0 ? tokens : tokens.take(separator).toList();
    }
    return separator < 0 ? const [] : tokens.skip(separator + 1).toList();
  }
}
