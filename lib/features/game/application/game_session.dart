import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/auth_providers.dart';
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

/// O '=' está sempre presente na equação: todo desafio começa com ele no
/// tabuleiro e ele não pode ser removido, movido nem adicionado de novo.
const _equalityToken = '=';
const _equalityPlacement = GameTokenPlacement(token: _equalityToken);

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
    this.allSolvedInLevel = false,
  });

  /// Estado de um desafio recém-começado: só o '=' no tabuleiro.
  factory GameSessionState.initial({
    required GameChallenge challenge,
    int attempts = 0,
    bool allSolvedInLevel = false,
  }) => GameSessionState(
    challenge: challenge,
    attempts: attempts,
    allSolvedInLevel: allSolvedInLevel,
    tokens: const [_equalityToken],
    placements: const [_equalityPlacement],
  );

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

  /// true quando o usuário já resolveu todos os desafios do nível atual: os
  /// desafios passam a se repetir (a UI avisa).
  final bool allSolvedInLevel;

  String get expression => tokens.join(' ');

  /// true quando há algo no tabuleiro além do '=' fixo.
  bool get hasContent => tokens.any((token) => token != _equalityToken);

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
    bool? allSolvedInLevel,
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
    allSolvedInLevel: allSolvedInLevel ?? this.allSolvedInLevel,
  );
}

class GameSessionController extends Notifier<GameSessionState> {
  static const _numberPool = [1, 2, 3, 4, 5, 6, 7, 8, 9];

  final ChallengeGenerator _generator = ChallengeGenerator(
    numberPool: _numberPool,
  );
  final Set<String> _seenChallengeKeys = {};
  final ExpressionEvaluator _evaluator = ExpressionEvaluator();

  /// Chaves dos desafios que o usuário atual já resolveu (vêm do Firestore
  /// em [loadSolvedChallenges] e crescem a cada acerto).
  final Set<String> _solvedKeys = {};
  String? _uid;

  @override
  GameSessionState build() {
    // Observa o usuário: ao trocar de conta o jogo recomeça do zero e não
    // herda os desafios resolvidos da conta anterior.
    _uid = ref.watch(currentUserProvider.select((user) => user?.uid));
    _solvedKeys.clear();
    _seenChallengeKeys.clear();
    return GameSessionState.initial(
      challenge: _generate(GameDifficulty.easy).challenge,
    );
  }

  /// Lê no Firestore os desafios já resolvidos e, se o desafio na tela for
  /// um deles (e o jogador ainda não mexeu nele), troca por um inédito.
  /// Em caso de falha de rede/regras, relança o erro para a tela mostrar o
  /// botão "Tentar novamente".
  Future<Set<String>> loadSolvedChallenges() async {
    final uid = _uid;
    if (uid == null) return <String>{};
    final solved = await ref
        .read(firestoreServiceProvider)
        .fetchSolvedChallenges(uid);
    // O usuário pode ter saído enquanto a leitura estava em andamento.
    if (uid != _uid) return <String>{};
    _solvedKeys
      ..clear()
      ..addAll(solved);
    final current = state.challenge;
    if (!state.hasContent && _solvedKeys.contains(current.key)) {
      final result = _generate(current.difficulty);
      state = GameSessionState.initial(
        challenge: result.challenge,
        allSolvedInLevel: result.allSolved,
      );
    }
    return Set.unmodifiable(_solvedKeys);
  }

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

  /// O '=' já vem posicionado no início do desafio, então nunca se adiciona
  /// outro (a equação tem exatamente uma igualdade).
  bool canAddEquality() => false;

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
    _insert(GameTokenPlacement(token: _tokenFor(operation)), insertAt);
    return true;
  }

  bool addParenthesis({required bool opening, int? insertAt}) {
    if (!canAddParenthesis()) return false;
    _insert(GameTokenPlacement(token: opening ? '(' : ')'), insertAt);
    return true;
  }

  /// Mantido por compatibilidade; sempre recusa (ver [canAddEquality]).
  bool addEquality([int? insertAt]) => false;

  /// Move um token já colocado. [to] é a posição final desejada na lista
  /// depois da remoção (0..length-1). O '=' é fixo e não pode ser movido.
  bool moveToken(int from, int to) {
    final length = state.placements.length;
    if (state.solved || from < 0 || from >= length) return false;
    if (state.placements[from].token == _equalityToken) return false;
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
    // O '=' é fixo.
    if (state.placements[index].token == _equalityToken) return;
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

  /// Desfaz o último token que não seja o '=' (que é fixo).
  void removeLast() {
    if (state.solved) return;
    final index = state.tokens.lastIndexWhere((t) => t != _equalityToken);
    if (index < 0) return;
    removeAt(index);
  }

  /// Limpa tudo, exceto o '=' fixo.
  void clearExpression() {
    if (state.solved) return;
    _commit(const [_equalityPlacement], const {}, const []);
  }

  // ── Wrappers de compatibilidade ───────────────────────────────────────────

  bool selectNumber(int index) => addNumber(index);
  bool selectOperation(GameOperation operation) => addOperation(operation);
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
            challengeKey: state.challenge.key,
          );
      _saveSolvedChallenge(state.challenge.key);
    }
    return evaluation;
  }

  void setDifficulty(GameDifficulty difficulty) => _startNew(difficulty);

  /// Pula o desafio atual (sem marcá-lo como resolvido).
  void skipChallenge() => _startNew(state.challenge.difficulty);

  void nextChallenge() {
    if (!state.solved) return;
    _startNew(state.challenge.difficulty);
  }

  void _startNew(GameDifficulty difficulty) {
    final result = _generate(difficulty);
    state = GameSessionState.initial(
      challenge: result.challenge,
      attempts: 0,
      allSolvedInLevel: result.allSolved,
    );
  }

  /// Grava o desafio resolvido no Firestore e atualiza a lista local, sem
  /// travar a interface esperando o servidor.
  void _saveSolvedChallenge(String key) {
    _solvedKeys.add(key);
    final uid = _uid;
    if (uid == null) return;
    ref
        .read(firestoreServiceProvider)
        .saveSolvedChallenge(uid, key)
        .then((_) {
          // O jogador pode ter saído da conta antes do servidor responder.
          if (ref.mounted) ref.invalidate(solvedChallengesProvider);
        })
        .catchError((Object error) {
          debugPrint('Erro ao salvar desafio resolvido: $error');
        });
  }

  /// Gera um desafio inédito: que não foi visto nesta sessão e que o usuário
  /// ainda não resolveu (lista vinda do Firestore). Com números de 1 a 9 há
  /// um conjunto finito de desafios por nível; se todos já foram resolvidos,
  /// repete os desafios (ignorando os resolvidos) e devolve `allSolved` =
  /// true para a tela avisar o jogador, em vez de travar o jogo.
  ({GameChallenge challenge, bool allSolved}) _generate(
    GameDifficulty difficulty,
  ) {
    final prefix = '${difficulty.name}:';

    GameChallenge? tryGenerate(Set<String> excluded) {
      try {
        return _generator.generate(
          difficulty: difficulty,
          excludedChallengeKeys: excluded,
        );
      } on StateError {
        return null;
      }
    }

    // 1) Inédito na sessão e ainda não resolvido.
    var challenge = tryGenerate({..._seenChallengeKeys, ..._solvedKeys});
    var allSolved = false;
    if (challenge == null) {
      // 2) Esgotou os não vistos: esquece os vistos DESTE nível, mas
      // continua evitando os já resolvidos.
      _seenChallengeKeys.removeWhere((key) => key.startsWith(prefix));
      challenge = tryGenerate({..._seenChallengeKeys, ..._solvedKeys});
    }
    if (challenge == null) {
      // 3) O usuário resolveu todos os desafios do nível: repete.
      allSolved = true;
      challenge = tryGenerate(_seenChallengeKeys);
      if (challenge == null) {
        _seenChallengeKeys.removeWhere((key) => key.startsWith(prefix));
        challenge = _generator.generate(difficulty: difficulty);
      }
    }
    _seenChallengeKeys.add(challenge.key);
    return (challenge: challenge, allSolved: allSolved);
  }

  // ── Internos ──────────────────────────────────────────────────────────────

  /// Texto do token de cada operação, no formato que o avaliador entende:
  /// binárias usam o símbolo infixo, funções (√ ∛ | ⌊ ⌈) usam o marcador
  /// prefixo e o fatorial usa '!'. (`symbol` lança erro fora das binárias.)
  static String _tokenFor(GameOperation operation) {
    if (operation.isBinaryInfix) return operation.symbol;
    if (operation.isPrefixFunction) return operation.prefixMarker;
    return '!'; // fatorial (pós-fixo)
  }

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
    final separator = tokens.indexOf(_equalityToken);
    if (side == EquationSide.left) {
      return separator < 0 ? tokens : tokens.take(separator).toList();
    }
    return separator < 0 ? const [] : tokens.skip(separator + 1).toList();
  }
}