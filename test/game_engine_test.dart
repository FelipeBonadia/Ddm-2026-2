import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:math_puzzle_app/features/game/domain/game_engine.dart';

void main() {
  final evaluator = ExpressionEvaluator();

  test('rational arithmetic stays exact', () {
    expect(Rational(1, 2) + Rational(1, 3), Rational(5, 6));
  });

  test('evaluates Emplake equality with operation precedence', () {
    final challenge = GameChallenge(
      numbers: [3, 2, 3, 3],
      difficulty: GameDifficulty.hard,
    );

    final result = evaluator.evaluate('3 * 2 = 3 + 3', challenge);

    expect(result.isCorrect, isTrue);
    expect(result.left, Rational(6));
    expect(result.right, Rational(6));
  });

  test('supports parentheses and visible mathematical symbols', () {
    final challenge = GameChallenge(
      numbers: [1, 2, 3, 4],
      difficulty: GameDifficulty.easy,
    );

    final result = evaluator.evaluate('(2 + 3) = 4 + 1', challenge);

    expect(result.isCorrect, isTrue);
  });

  test('rejects reusing a number and omitting another', () {
    final challenge = GameChallenge(
      numbers: [3, 2, 3, 3],
      difficulty: GameDifficulty.hard,
    );

    final result = evaluator.evaluate('3 * 2 = 3 + 2', challenge);

    expect(result.error, GameExpressionError.wrongNumbers);
  });

  test('advanced difficulty rejects power', () {
    final challenge = GameChallenge(
      numbers: [2, 3, 7, 1],
      difficulty: GameDifficulty.advanced,
    );

    final result = evaluator.evaluate('2 ** 3 = 7 + 1', challenge);

    expect(result.error, GameExpressionError.operationNotAllowed);
  });

  test('rejects division by zero', () {
    final challenge = GameChallenge(
      numbers: [3, 0, 2, 1],
      difficulty: GameDifficulty.hard,
    );

    final result = evaluator.evaluate('3 / 0 = 2 + 1', challenge);

    expect(result.error, GameExpressionError.divisionByZero);
  });

  test('requires exact division by default', () {
    final challenge = GameChallenge(
      numbers: [1, 2, 3, 4],
      difficulty: GameDifficulty.hard,
    );

    final result = evaluator.evaluate('1 / 2 = 3 / 4', challenge);

    expect(result.error, GameExpressionError.divisionNotExact);
  });

  test('generator only publishes challenges with a valid equality', () {
    final generator = ChallengeGenerator(
      numberPool: [1, 2, 3, 4, 5, 6, 7, 8, 9],
      random: Random(19),
    );

    for (final difficulty in GameDifficulty.values) {
      final challenge = generator.generate(difficulty: difficulty);
      expect(challenge.numbers, hasLength(4));
      expect(ChallengeGenerator.hasSolution(challenge), isTrue);
      final solution = ChallengeGenerator.findEqualitySolution(challenge)!;
      expect(evaluator.evaluate(solution, challenge).isCorrect, isTrue);
    }
  });

  test('generator avoids excluded challenges', () {
    final generator = ChallengeGenerator(numberPool: [1], random: Random(1));
    final challenge = generator.generate(difficulty: GameDifficulty.easy);

    expect(
      () => generator.generate(
        difficulty: GameDifficulty.easy,
        excludedChallengeKeys: {challenge.key},
        maxAttempts: 10,
      ),
      throwsStateError,
    );
  });
}
