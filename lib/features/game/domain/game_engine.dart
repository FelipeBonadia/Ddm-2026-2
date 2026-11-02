import 'dart:math';

/// Quatro níveis, do enunciado: Fácil (easy) tem o conjunto MAIOR de
/// operadores (mais ferramentas = mais fácil achar uma solução) e é o
/// único que permite divisão não inteira. Difícil (hard) tem o conjunto
/// MENOR — só o básico + módulo.
enum GameDifficulty { easy, intermediate, advanced, hard }

enum GameOperation {
  add,
  subtract,
  multiply,
  divide,
  power, // **
  sqrt, // √
  cbrt, // ∛
  factorial, // !
  modulus, // |x| (valor absoluto)
  floor, // ⌊x⌋
  ceil, // ⌈x⌉
}

extension GameDifficultyRules on GameDifficulty {
  Set<GameOperation> get operations => switch (this) {
    GameDifficulty.easy => GameOperation.values.toSet(),
    GameDifficulty.intermediate => const {
      GameOperation.add,
      GameOperation.subtract,
      GameOperation.multiply,
      GameOperation.divide,
      GameOperation.sqrt,
      GameOperation.cbrt,
      GameOperation.factorial,
      GameOperation.power,
      GameOperation.modulus,
    },
    GameDifficulty.advanced => const {
      GameOperation.add,
      GameOperation.subtract,
      GameOperation.multiply,
      GameOperation.divide,
      GameOperation.sqrt,
      GameOperation.factorial,
      GameOperation.modulus,
    },
    GameDifficulty.hard => const {
      GameOperation.add,
      GameOperation.subtract,
      GameOperation.multiply,
      GameOperation.divide,
      GameOperation.modulus,
    },
  };

  /// Só o nível Fácil permite divisão com resultado não inteiro.
  bool get allowsNonIntegerDivision => this == GameDifficulty.easy;
}

extension GameOperationSymbol on GameOperation {
  /// Símbolo infixo — só os binários (+, -, *, /, **).
  String get symbol => switch (this) {
    GameOperation.add => '+',
    GameOperation.subtract => '-',
    GameOperation.multiply => '*',
    GameOperation.divide => '/',
    GameOperation.power => '**',
    _ => throw UnsupportedError('$this não é um operador infixo binário.'),
  };

  /// Marcador de função prefixa — √, ∛, |, ⌊, ⌈. Recebem um grupo entre
  /// parênteses, √(8 + 1), ou um único operando, √7.
  /// Não há marcador de fechamento: o grupo termina no ')'.
  String get prefixMarker => switch (this) {
    GameOperation.sqrt => '√',
    GameOperation.cbrt => '∛',
    GameOperation.modulus => '|',
    GameOperation.floor => '⌊',
    GameOperation.ceil => '⌈',
    _ => throw UnsupportedError('$this não é uma função prefixa.'),
  };

  bool get isBinaryInfix => const {
    GameOperation.add,
    GameOperation.subtract,
    GameOperation.multiply,
    GameOperation.divide,
    GameOperation.power,
  }.contains(this);

  bool get isPrefixFunction => const {
    GameOperation.sqrt,
    GameOperation.cbrt,
    GameOperation.modulus,
    GameOperation.floor,
    GameOperation.ceil,
  }.contains(this);

  bool get isPostfix => this == GameOperation.factorial;

  static GameOperation? fromSymbol(String symbol) => switch (symbol) {
    '+' => GameOperation.add,
    '-' || '−' => GameOperation.subtract,
    '*' || '×' => GameOperation.multiply,
    '/' || '÷' => GameOperation.divide,
    '**' => GameOperation.power,
    '!' => GameOperation.factorial,
    '√' => GameOperation.sqrt,
    '∛' => GameOperation.cbrt,
    '|' => GameOperation.modulus,
    '⌊' => GameOperation.floor,
    '⌈' => GameOperation.ceil,
    _ => null,
  };
}

/// Limites de segurança. A build web usa inteiros seguros de até 2^53, e
/// as operações racionais multiplicam numeradores por denominadores. Por
/// isso TODO numerador/denominador armazenado é limitado a [_maxMagnitude]:
/// assim qualquer produto fica abaixo de 2.5e15 e qualquer soma de produtos
/// abaixo de 5e15, sempre dentro da faixa exata. Passou disso, é overflow
/// (tratado como erro de domínio / combinação descartada no solver).
const _maxMagnitude = 50000000;

/// 11! = 39.916.800 ainda cabe em [_maxMagnitude]; 12! não.
const _maxFactorialArgument = 11;
const _maxPowerExponent = 20;

class _RationalOverflow implements Exception {
  const _RationalOverflow();
}

class Rational implements Comparable<Rational> {
  factory Rational(int numerator, [int denominator = 1]) {
    if (denominator == 0) throw ArgumentError.value(denominator, 'denominator');
    final sign = denominator < 0 ? -1 : 1;
    final divisor = _gcd(numerator.abs(), denominator.abs());
    final reducedNumerator = sign * numerator ~/ divisor;
    final reducedDenominator = denominator.abs() ~/ divisor;
    if (reducedNumerator.abs() > _maxMagnitude ||
        reducedDenominator > _maxMagnitude) {
      throw const _RationalOverflow();
    }
    return Rational._(reducedNumerator, reducedDenominator);
  }

  const Rational._(this.numerator, this.denominator);

  final int numerator;
  final int denominator;

  bool get isInteger => denominator == 1;

  Rational operator +(Rational other) => Rational(
    numerator * other.denominator + other.numerator * denominator,
    denominator * other.denominator,
  );
  Rational operator -(Rational other) => Rational(
    numerator * other.denominator - other.numerator * denominator,
    denominator * other.denominator,
  );
  Rational operator *(Rational other) =>
      Rational(numerator * other.numerator, denominator * other.denominator);
  Rational operator /(Rational other) =>
      Rational(numerator * other.denominator, denominator * other.numerator);

  /// Negação (menos unário).
  Rational get negated => Rational(-numerator, denominator);

  /// Módulo/valor absoluto: sempre exato, nunca falha.
  Rational get absolute =>
      numerator < 0 ? Rational(-numerator, denominator) : this;

  /// Maior inteiro ≤ este valor. Sempre exato, nunca falha.
  Rational get floorValue {
    if (isInteger) return this;
    final truncated = numerator ~/ denominator; // trunca em direção a zero
    return Rational(numerator < 0 ? truncated - 1 : truncated);
  }

  /// Menor inteiro ≥ este valor. Sempre exato, nunca falha.
  Rational get ceilValue {
    if (isInteger) return this;
    final truncated = numerator ~/ denominator;
    return Rational(numerator < 0 ? truncated : truncated + 1);
  }

  /// Potência com expoente racional. Retorna null se o expoente não for
  /// inteiro (resultado geralmente irracional), se for grande demais, se o
  /// resultado estourar o limite seguro, ou se for 0**0 / base 0 com
  /// expoente negativo (indefinidos).
  Rational? powOrNull(Rational exponent) {
    if (!exponent.isInteger) return null;
    final e = exponent.numerator;
    if (e.abs() > _maxPowerExponent) return null;
    if (e == 0) {
      if (numerator == 0) return null; // 0**0 indefinido
      return const Rational._(1, 1);
    }
    if (numerator == 0) {
      return e < 0 ? null : const Rational._(0, 1); // 0 elevado a negativo
    }
    try {
      final base = e < 0 ? Rational(denominator, numerator) : this;
      var result = const Rational._(1, 1);
      for (var i = 0; i < e.abs(); i++) {
        result = result * base;
      }
      return result;
    } on _RationalOverflow {
      return null;
    }
  }

  /// Raiz quadrada exata, se existir (numerador e denominador quadrados
  /// perfeitos); senão null — nunca aproxima.
  Rational? get exactSquareRoot {
    if (numerator < 0) return null;
    final n = _exactIntegerRoot(numerator, 2);
    final d = _exactIntegerRoot(denominator, 2);
    if (n == null || d == null) return null;
    return Rational(n, d);
  }

  /// Raiz cúbica exata, se existir (aceita numerador negativo); senão null.
  Rational? get exactCubeRoot {
    final n = _exactIntegerRoot(numerator, 3);
    final d = _exactIntegerRoot(denominator, 3);
    if (n == null || d == null) return null;
    return Rational(n, d);
  }

  /// Fatorial, exigindo inteiro não negativo dentro do limite seguro;
  /// senão null.
  Rational? get exactFactorial {
    if (!isInteger || numerator < 0 || numerator > _maxFactorialArgument) {
      return null;
    }
    var result = 1;
    for (var i = 2; i <= numerator; i++) {
      result *= i;
    }
    if (result > _maxMagnitude) return null;
    return Rational(result);
  }

  @override
  int compareTo(Rational other) =>
      (numerator * other.denominator).compareTo(other.numerator * denominator);

  @override
  bool operator ==(Object other) =>
      other is Rational &&
      numerator == other.numerator &&
      denominator == other.denominator;

  @override
  int get hashCode => Object.hash(numerator, denominator);

  @override
  String toString() => isInteger ? '$numerator' : '$numerator/$denominator';
}

int _gcd(int first, int second) {
  var a = first;
  var b = second;
  while (b != 0) {
    final remainder = a % b;
    a = b;
    b = remainder;
  }
  return a == 0 ? 1 : a;
}

/// Raiz [degree]-ésima exata de [value] (2 = quadrada, 3 = cúbica), ou null
/// se não for exata. Aceita [value] negativo só quando [degree] é ímpar
/// (raiz cúbica de negativo é real; raiz quadrada não).
int? _exactIntegerRoot(int value, int degree) {
  if (value < 0 && degree.isEven) return null;
  final sign = value < 0 ? -1 : 1;
  final absValue = value.abs();
  final estimate = pow(absValue, 1 / degree).round();
  // Confere os vizinhos pra cobrir erro de arredondamento do ponto flutuante
  // usado só pra estimar — a confirmação final é com inteiros exatos.
  for (final candidate in [estimate - 1, estimate, estimate + 1]) {
    if (candidate >= 0 && pow(candidate, degree) == absValue) {
      return sign * candidate;
    }
  }
  return null;
}

class GameChallenge {
  GameChallenge({
    required List<int> numbers,
    required this.difficulty,
    bool? requireIntegerDivision,
  }) : numbers = List.unmodifiable(numbers),
       requireIntegerDivision =
           requireIntegerDivision ?? !difficulty.allowsNonIntegerDivision {
    if (numbers.length != 4) {
      throw ArgumentError.value(
        numbers,
        'numbers',
        'Exactly four numbers required.',
      );
    }
  }

  final List<int> numbers;
  final GameDifficulty difficulty;
  final bool requireIntegerDivision;

  Set<GameOperation> get allowedOperations => difficulty.operations;

  String get key {
    final sorted = [...numbers]..sort();
    return '${difficulty.name}:${sorted.join(',')}:$requireIntegerDivision';
  }
}

enum GameExpressionError {
  missingEquality,
  invalidCharacter,
  wrongNumbers,
  operationNotAllowed,
  incomplete,
  invalidSyntax,
  unbalancedParentheses,
  divisionByZero,
  divisionNotExact,

  /// Operação matematicamente indefinida ou cujo resultado não seria
  /// exato: raiz de algo que não é potência perfeita, fatorial de
  /// negativo/não inteiro, expoente não inteiro, resultado grande demais,
  /// etc.
  domainError,
}

class EqualityEvaluation {
  const EqualityEvaluation._({this.left, this.right, this.error});
  const EqualityEvaluation.success(Rational left, Rational right)
    : this._(left: left, right: right);
  const EqualityEvaluation.failure(GameExpressionError error)
    : this._(error: error);

  final Rational? left;
  final Rational? right;
  final GameExpressionError? error;

  bool get isValid => error == null;
  bool get isCorrect => isValid && left == right;
}

class ExpressionEvaluator {
  EqualityEvaluation evaluate(String expression, GameChallenge challenge) {
    final parts = expression.split('=');
    if (parts.length != 2) {
      return const EqualityEvaluation.failure(
        GameExpressionError.missingEquality,
      );
    }

    final left = _tokenize(parts[0]);
    final right = _tokenize(parts[1]);
    if (left.error != null) return EqualityEvaluation.failure(left.error!);
    if (right.error != null) return EqualityEvaluation.failure(right.error!);
    if (left.tokens.isEmpty || right.tokens.isEmpty) {
      return const EqualityEvaluation.failure(GameExpressionError.incomplete);
    }

    final usedNumbers = [...left.numbers, ...right.numbers]..sort();
    final availableNumbers = [...challenge.numbers]..sort();
    if (!_sameList(usedNumbers, availableNumbers)) {
      return const EqualityEvaluation.failure(GameExpressionError.wrongNumbers);
    }
    final usedOperations = {...left.operations, ...right.operations};
    if (!challenge.allowedOperations.containsAll(usedOperations)) {
      return const EqualityEvaluation.failure(
        GameExpressionError.operationNotAllowed,
      );
    }

    try {
      final leftValue = _ExpressionParser(
        left.tokens,
        challenge.requireIntegerDivision,
      ).parse();
      final rightValue = _ExpressionParser(
        right.tokens,
        challenge.requireIntegerDivision,
      ).parse();
      return EqualityEvaluation.success(leftValue, rightValue);
    } on _EvaluationFailure catch (failure) {
      return EqualityEvaluation.failure(failure.error);
    } on _RationalOverflow {
      return const EqualityEvaluation.failure(GameExpressionError.domainError);
    }
  }

  _Tokenization _tokenize(String expression) {
    final tokens = <_Token>[];
    final numbers = <int>[];
    final operations = <GameOperation>{};
    for (var index = 0; index < expression.length;) {
      final character = expression[index];
      if (character.trim().isEmpty) {
        index++;
        continue;
      }
      if (_isDigit(character)) {
        final start = index;
        while (index < expression.length && _isDigit(expression[index])) {
          index++;
        }
        final number = int.tryParse(expression.substring(start, index));
        if (number == null) {
          return const _Tokenization.failure(
            GameExpressionError.invalidCharacter,
          );
        }
        numbers.add(number);
        tokens.add(_Token.number(number));
        continue;
      }
      if (character == '(') {
        tokens.add(const _Token.leftParenthesis());
        index++;
        continue;
      }
      if (character == ')') {
        tokens.add(const _Token.rightParenthesis());
        index++;
        continue;
      }
      // '**' precisa do lookahead de 2 caracteres antes de cair no '*'
      // simples (multiplicação).
      if (character == '*' &&
          index + 1 < expression.length &&
          expression[index + 1] == '*') {
        final operation = GameOperationSymbol.fromSymbol('**')!;
        operations.add(operation);
        tokens.add(_Token.operation(operation));
        index += 2;
        continue;
      }
      final operation = GameOperationSymbol.fromSymbol(character);
      if (operation == null) {
        return const _Tokenization.failure(
          GameExpressionError.invalidCharacter,
        );
      }
      operations.add(operation);
      tokens.add(_Token.operation(operation));
      index++;
    }
    return _Tokenization.success(tokens, numbers, operations);
  }

  static bool _sameList(List<int> first, List<int> second) {
    if (first.length != second.length) return false;
    for (var index = 0; index < first.length; index++) {
      if (first[index] != second[index]) return false;
    }
    return true;
  }

  static bool _isDigit(String character) {
    final code = character.codeUnitAt(0);
    return code >= 48 && code <= 57;
  }
}

/// Converte o mesmo texto que [ExpressionEvaluator] entende em LaTeX, pra
/// mostrar embaixo da equação que o jogador está montando. Não valida a
/// igualdade (não é isso que faz); só não sabe renderizar partes
/// incompletas ou inválidas e devolve null nesses casos — quem chama
/// decide o que mostrar (normalmente nada, ou o texto de rascunho).
///
/// Suporta preview parcial: se ainda não houver '=', renderiza só o lado
/// esquerdo já montado. Com [partial] = true, a fórmula ainda em construção
/// também é renderizada: operandos que faltam viram um quadrado (□),
/// parênteses abertos são fechados automaticamente e lados vazios aparecem
/// como □. Assim o jogador vê a fórmula em LaTeX durante toda a montagem.
String? expressionToLatex(String expression, {bool partial = false}) {
  final parts = expression.split('=');
  if (parts.isEmpty || parts.length > 2) return null;

  final evaluator = ExpressionEvaluator();
  String? renderSide(String raw) {
    final tokenized = evaluator._tokenize(raw);
    if (tokenized.error != null) return null;
    if (tokenized.tokens.isEmpty) return partial ? '\\square' : null;
    try {
      return _LatexBuilder(tokenized.tokens, partial: partial).build();
    } on _EvaluationFailure {
      return null;
    }
  }

  if (parts.length == 1) {
    return renderSide(parts[0]);
  }
  final left = renderSide(parts[0]);
  final right = renderSide(parts[1]);
  if (left == null || right == null) return null;
  return '$left = $right';
}

/// Espelha a mesma gramática/precedência de [_ExpressionParser], só que em
/// vez de calcular um [Rational] monta uma string LaTeX. Por isso as duas
/// classes têm estrutura quase idêntica — é proposital: garante que o
/// preview sempre reflete exatamente como a expressão seria avaliada.
class _LatexBuilder {
  _LatexBuilder(this.tokens, {this.partial = false});
  final List<_Token> tokens;

  /// Modo tolerante, para pré-visualizar fórmulas incompletas.
  final bool partial;
  int _position = 0;

  String build() {
    var result = _buildExpression();
    if (!partial) {
      if (_position != tokens.length) {
        throw const _EvaluationFailure(GameExpressionError.invalidSyntax);
      }
      return result;
    }
    // Sobras (')' perdido, dois números seguidos...): ignora o ')' e mostra
    // o resto ao lado, em vez de desistir de renderizar.
    while (_position < tokens.length) {
      if (tokens[_position].kind == _TokenKind.rightParenthesis) {
        _position++;
        continue;
      }
      result = '$result \\; ${_buildExpression()}';
    }
    return result;
  }

  String _buildExpression() {
    var value = _buildTerm();
    while (_matches(GameOperation.add) || _matches(GameOperation.subtract)) {
      final operation = tokens[_position++].operation!;
      final right = _buildTerm();
      value = operation == GameOperation.add
          ? '$value + $right'
          : '$value - $right';
    }
    return value;
  }

  String _buildTerm() {
    var value = _buildUnary();
    while (_matches(GameOperation.multiply) || _matches(GameOperation.divide)) {
      final operation = tokens[_position++].operation!;
      final right = _buildUnary();
      value = operation == GameOperation.multiply
          ? '$value \\cdot $right'
          : '\\frac{$value}{$right}';
    }
    return value;
  }

  /// Menos unário, ex.: -(2 - 5). Fica abaixo de * e / e acima de **,
  /// como na matemática usual (-2**2 = -(2**2)).
  String _buildUnary() {
    if (_matches(GameOperation.subtract)) {
      _position++;
      final inner = _buildUnary();
      return inner.startsWith('-') ? '-\\left($inner\\right)' : '-$inner';
    }
    return _buildPower();
  }

  String _buildPower() {
    final base = _buildPostfix();
    if (_matches(GameOperation.power)) {
      _position++;
      final exponent = _buildUnary(); // associativo à direita
      return '{$base}^{$exponent}';
    }
    return base;
  }

  String _buildPostfix() {
    var value = _buildPrimary();
    while (_matches(GameOperation.factorial)) {
      _position++;
      value = '$value!';
    }
    return value;
  }

  /// Lê o conteúdo de um grupo "( ... )". No modo parcial aceita grupo sem
  /// '(' (vira □) e sem ')' (fecha sozinho).
  String _buildGroup() {
    if (_matchesKind(_TokenKind.leftParenthesis)) {
      _position++;
      final inner = _buildExpression();
      if (_matchesKind(_TokenKind.rightParenthesis)) {
        _position++;
      } else if (!partial) {
        throw const _EvaluationFailure(
          GameExpressionError.unbalancedParentheses,
        );
      }
      return inner;
    }
    // Forma curta, sem parênteses: √7, ∛27, |3, √√16
    if (_startsOperand(tokens, _position)) return _buildPrimary();
    if (partial) return '\\square';
    throw const _EvaluationFailure(GameExpressionError.invalidSyntax);
  }

  String _buildPrimary() {
    if (_position >= tokens.length) {
      if (partial) return '\\square';
      throw const _EvaluationFailure(GameExpressionError.incomplete);
    }
    final token = tokens[_position];

    if (token.kind == _TokenKind.operation &&
        token.operation!.isPrefixFunction) {
      final function = token.operation!;
      _position++;
      final inner = _buildGroup();
      return switch (function) {
        GameOperation.sqrt => '\\sqrt{$inner}',
        GameOperation.cbrt => '\\sqrt[3]{$inner}',
        GameOperation.modulus => '\\left|$inner\\right|',
        GameOperation.floor => '\\lfloor $inner \\rfloor',
        GameOperation.ceil => '\\lceil $inner \\rceil',
        _ => inner,
      };
    }

    if (token.kind == _TokenKind.number) {
      _position++;
      return '${token.number}';
    }

    if (token.kind == _TokenKind.leftParenthesis) {
      final inner = _buildGroup();
      return '\\left($inner\\right)';
    }

    // Operador ou ')' onde era esperado um operando: no modo parcial vira □
    // sem consumir o token (quem chamou o consome).
    if (partial) return '\\square';
    throw const _EvaluationFailure(GameExpressionError.incomplete);
  }

  bool _matches(GameOperation operation) =>
      _position < tokens.length &&
      tokens[_position].kind == _TokenKind.operation &&
      tokens[_position].operation == operation;

  bool _matchesKind(_TokenKind kind) =>
      _position < tokens.length && tokens[_position].kind == kind;
}

class ChallengeGenerator {
  ChallengeGenerator({required List<int> numberPool, Random? random})
    : numberPool = List.unmodifiable(numberPool),
      _random = random ?? Random() {
    if (numberPool.isEmpty) {
      throw ArgumentError.value(numberPool, 'numberPool', 'Must not be empty.');
    }
    if (numberPool.any((number) => number < 0)) {
      throw ArgumentError.value(
        numberPool,
        'numberPool',
        'Use non-negative numbers.',
      );
    }
  }

  final List<int> numberPool;
  final Random _random;

  /// Quantas operações unárias (raiz, fatorial, módulo, base, teto) o
  /// solver pode empilhar ao procurar uma solução. 2 já cobre casos como
  /// "⌊7/2⌋" (uma divisão não exata seguida de um arredondamento) sem
  /// deixar a busca combinatória explodir. Se ficar lento na prática,
  /// baixe pra 1 primeiro.
  static const _maxUnaryChainPerSearch = 2;

  GameChallenge generate({
    required GameDifficulty difficulty,
    bool? requireIntegerDivision,
    Set<String> excludedChallengeKeys = const {},
    int maxAttempts = 500,
  }) {
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final challenge = GameChallenge(
        numbers: List.generate(
          4,
          (_) => numberPool[_random.nextInt(numberPool.length)],
        ),
        difficulty: difficulty,
        requireIntegerDivision: requireIntegerDivision,
      );
      if (excludedChallengeKeys.contains(challenge.key)) continue;
      if (findEqualitySolution(challenge) != null) return challenge;
    }
    throw StateError(
      'No new solvable challenge found after $maxAttempts attempts.',
    );
  }

  static bool hasSolution(GameChallenge challenge) =>
      findEqualitySolution(challenge) != null;

  /// Devolve uma solução no MESMO formato que [ExpressionEvaluator] aceita
  /// (funções prefixas sem marcador de fechamento: `|(x)`, `⌊(x)`, `⌈(x)`).
  static String? findEqualitySolution(GameChallenge challenge) {
    final count = challenge.numbers.length;
    for (var mask = 1; mask < (1 << count) - 1; mask++) {
      if ((mask & 1) == 0) continue;
      final leftNumbers = <int>[];
      final rightNumbers = <int>[];
      for (var index = 0; index < count; index++) {
        (mask & (1 << index) != 0 ? leftNumbers : rightNumbers).add(
          challenge.numbers[index],
        );
      }
      final leftValues = _possibleValues(
        leftNumbers,
        challenge.allowedOperations,
        challenge.requireIntegerDivision,
      );
      final rightValues = _possibleValues(
        rightNumbers,
        challenge.allowedOperations,
        challenge.requireIntegerDivision,
      );
      for (final value in leftValues.keys) {
        final rightExpression = rightValues[value];
        if (rightExpression != null) {
          return '${leftValues[value]}=$rightExpression';
        }
      }
    }
    return null;
  }

  static Map<Rational, String> _possibleValues(
    List<int> numbers,
    Set<GameOperation> operations,
    bool requireIntegerDivision,
  ) => _searchValues(
    numbers
        .map((number) => _ExpressionValue(Rational(number), '$number'))
        .toList(),
    operations,
    requireIntegerDivision,
    _maxUnaryChainPerSearch,
  );

  static Map<Rational, String> _searchValues(
    List<_ExpressionValue> values,
    Set<GameOperation> operations,
    bool requireIntegerDivision,
    int unaryBudget,
  ) {
    final results = <Rational, String>{};

    if (values.length == 1) {
      results[values.single.value] = values.single.expression;
    }

    // Tenta aplicar uma função unária (raiz, fatorial, módulo, base, teto)
    // a UM valor da lista, mantendo os demais, e continua a busca a
    // partir daí — é o que permite soluções como "⌊9/2⌋ + 1".
    if (unaryBudget > 0) {
      for (var index = 0; index < values.length; index++) {
        for (final variant in _applyUnary(
          values[index],
          operations,
          requireIntegerDivision,
        )) {
          final next = [...values];
          next[index] = variant;
          results.addAll(
            _searchValues(
              next,
              operations,
              requireIntegerDivision,
              unaryBudget - 1,
            ),
          );
        }
      }
    }

    if (values.length >= 2) {
      for (var firstIndex = 0; firstIndex < values.length; firstIndex++) {
        for (
          var secondIndex = firstIndex + 1;
          secondIndex < values.length;
          secondIndex++
        ) {
          final first = values[firstIndex];
          final second = values[secondIndex];
          final remaining = [
            for (var index = 0; index < values.length; index++)
              if (index != firstIndex && index != secondIndex) values[index],
          ];
          for (final combination in _combineValues(
            first,
            second,
            operations,
            requireIntegerDivision,
          )) {
            results.addAll(
              _searchValues(
                [...remaining, combination],
                operations,
                requireIntegerDivision,
                unaryBudget,
              ),
            );
          }
        }
      }
    }
    return results;
  }

  /// Aplica uma função unária ao valor. Variantes que não mudam o valor
  /// (|x| de x ≥ 0, ⌊x⌋ ou ⌈x⌉ de inteiro, √0, √1, 1!, ...) são descartadas:
  /// só multiplicariam a busca sem produzir nada novo.
  static List<_ExpressionValue> _applyUnary(
    _ExpressionValue value,
    Set<GameOperation> operations,
    bool requireIntegerDivision,
  ) {
    final variants = <_ExpressionValue>[];

    void addIfNew(Rational? result, String Function(String) wrap) {
      if (result == null || result == value.value) return;
      variants.add(_ExpressionValue(result, wrap(value.expression)));
    }

    if (operations.contains(GameOperation.sqrt)) {
      addIfNew(value.value.exactSquareRoot, (e) => '√($e)');
    }
    if (operations.contains(GameOperation.cbrt)) {
      addIfNew(value.value.exactCubeRoot, (e) => '∛($e)');
    }
    if (operations.contains(GameOperation.factorial)) {
      addIfNew(value.value.exactFactorial, (e) => '($e)!');
    }
    if (operations.contains(GameOperation.modulus)) {
      addIfNew(value.value.absolute, (e) => '|($e)');
    }
    if (operations.contains(GameOperation.floor)) {
      addIfNew(value.value.floorValue, (e) => '⌊($e)');
    }
    if (operations.contains(GameOperation.ceil)) {
      addIfNew(value.value.ceilValue, (e) => '⌈($e)');
    }

    return variants;
  }

  /// Executa [compute] e devolve null se algum numerador/denominador
  /// estourar o limite seguro.
  static Rational? _safe(Rational Function() compute) {
    try {
      return compute();
    } on _RationalOverflow {
      return null;
    }
  }

  static List<_ExpressionValue> _combineValues(
    _ExpressionValue first,
    _ExpressionValue second,
    Set<GameOperation> operations,
    bool requireIntegerDivision,
  ) {
    final combinations = <_ExpressionValue>[];
    final a = first.expression;
    final b = second.expression;

    void add(String expression, Rational? value) {
      if (value == null) return;
      combinations.add(_ExpressionValue(value, expression));
    }

    if (operations.contains(GameOperation.add)) {
      add('($a+$b)', _safe(() => first.value + second.value));
    }
    if (operations.contains(GameOperation.subtract)) {
      add('($a-$b)', _safe(() => first.value - second.value));
      add('($b-$a)', _safe(() => second.value - first.value));
    }
    if (operations.contains(GameOperation.multiply)) {
      add('($a*$b)', _safe(() => first.value * second.value));
    }
    if (operations.contains(GameOperation.divide)) {
      if (second.value.numerator != 0) {
        final result = _safe(() => first.value / second.value);
        if (result != null && (!requireIntegerDivision || result.isInteger)) {
          add('($a/$b)', result);
        }
      }
      if (first.value.numerator != 0) {
        final result = _safe(() => second.value / first.value);
        if (result != null && (!requireIntegerDivision || result.isInteger)) {
          add('($b/$a)', result);
        }
      }
    }
    if (operations.contains(GameOperation.power)) {
      add('($a**$b)', first.value.powOrNull(second.value));
      add('($b**$a)', second.value.powOrNull(first.value));
    }
    return combinations;
  }
}

/// true se na posição [position] começa um operando "simples" que uma função
/// prefixa pode receber sem parênteses: um número ou outra função prefixa.
bool _startsOperand(List<_Token> tokens, int position) {
  if (position >= tokens.length) return false;
  final token = tokens[position];
  return token.kind == _TokenKind.number ||
      (token.kind == _TokenKind.operation && token.operation!.isPrefixFunction);
}

class _Tokenization {
  const _Tokenization.success(this.tokens, this.numbers, this.operations)
    : error = null;
  const _Tokenization.failure(this.error)
    : tokens = const [],
      numbers = const [],
      operations = const {};

  final List<_Token> tokens;
  final List<int> numbers;
  final Set<GameOperation> operations;
  final GameExpressionError? error;
}

class _Token {
  const _Token.number(this.number) : operation = null, kind = _TokenKind.number;
  const _Token.operation(this.operation)
    : number = null,
      kind = _TokenKind.operation;
  const _Token.leftParenthesis()
    : number = null,
      operation = null,
      kind = _TokenKind.leftParenthesis;
  const _Token.rightParenthesis()
    : number = null,
      operation = null,
      kind = _TokenKind.rightParenthesis;

  final int? number;
  final GameOperation? operation;
  final _TokenKind kind;
}

enum _TokenKind { number, operation, leftParenthesis, rightParenthesis }

class _EvaluationFailure implements Exception {
  const _EvaluationFailure(this.error);
  final GameExpressionError error;
}

/// Precedência, da mais solta pra mais apertada:
/// expressão (+ -) → termo (* /) → menos unário → potência (** , assoc. à
/// direita) → pós-fixo (!) → primário (número, parênteses, função prefixa).
class _ExpressionParser {
  _ExpressionParser(this.tokens, this.requireIntegerDivision);

  final List<_Token> tokens;
  final bool requireIntegerDivision;
  int _position = 0;

  Rational parse() {
    final value = _parseExpression();
    if (_position != tokens.length) {
      throw _EvaluationFailure(
        tokens[_position].kind == _TokenKind.rightParenthesis
            ? GameExpressionError.unbalancedParentheses
            : GameExpressionError.invalidSyntax,
      );
    }
    return value;
  }

  Rational _parseExpression() {
    var value = _parseTerm();
    while (_matches(GameOperation.add) || _matches(GameOperation.subtract)) {
      final operation = tokens[_position++].operation!;
      final right = _parseTerm();
      value = operation == GameOperation.add ? value + right : value - right;
    }
    return value;
  }

  Rational _parseTerm() {
    var value = _parseUnary();
    while (_matches(GameOperation.multiply) || _matches(GameOperation.divide)) {
      final operation = tokens[_position++].operation!;
      final right = _parseUnary();
      if (operation == GameOperation.multiply) {
        value = value * right;
      } else {
        if (right.numerator == 0) {
          throw const _EvaluationFailure(GameExpressionError.divisionByZero);
        }
        final result = value / right;
        if (requireIntegerDivision && !result.isInteger) {
          throw const _EvaluationFailure(GameExpressionError.divisionNotExact);
        }
        value = result;
      }
    }
    return value;
  }

  /// Menos unário, ex.: -(2 - 5) = 3.
  Rational _parseUnary() {
    if (_matches(GameOperation.subtract)) {
      _position++;
      return _parseUnary().negated;
    }
    return _parsePower();
  }

  Rational _parsePower() {
    final base = _parsePostfix();
    if (_matches(GameOperation.power)) {
      _position++;
      final exponent = _parseUnary(); // associativo à direita
      final result = base.powOrNull(exponent);
      if (result == null) {
        throw const _EvaluationFailure(GameExpressionError.domainError);
      }
      return result;
    }
    return base;
  }

  Rational _parsePostfix() {
    var value = _parsePrimary();
    while (_matches(GameOperation.factorial)) {
      _position++;
      final result = value.exactFactorial;
      if (result == null) {
        throw const _EvaluationFailure(GameExpressionError.domainError);
      }
      value = result;
    }
    return value;
  }

  Rational _parsePrimary() {
    if (_position >= tokens.length) {
      throw const _EvaluationFailure(GameExpressionError.incomplete);
    }
    final token = tokens[_position];

    if (token.kind == _TokenKind.operation &&
        token.operation!.isPrefixFunction) {
      final function = token.operation!;
      _position++;
      final Rational inner;
      if (_matchesKind(_TokenKind.leftParenthesis)) {
        // Forma com grupo: √(8 + 1)
        _position++; // consome '('
        inner = _parseExpression();
        if (!_matchesKind(_TokenKind.rightParenthesis)) {
          throw const _EvaluationFailure(
            GameExpressionError.unbalancedParentheses,
          );
        }
        _position++; // consome ')'
      } else if (_startsOperand(tokens, _position)) {
        // Forma curta, com um único operando: √7, ∛27, |3, √√16
        inner = _parsePrimary();
      } else {
        throw _EvaluationFailure(
          _position >= tokens.length
              ? GameExpressionError.incomplete
              : GameExpressionError.invalidSyntax,
        );
      }
      final Rational? result = switch (function) {
        GameOperation.sqrt => inner.exactSquareRoot,
        GameOperation.cbrt => inner.exactCubeRoot,
        GameOperation.modulus => inner.absolute,
        GameOperation.floor => inner.floorValue,
        GameOperation.ceil => inner.ceilValue,
        _ => throw StateError('$function não é uma função prefixa.'),
      };
      if (result == null) {
        throw const _EvaluationFailure(GameExpressionError.domainError);
      }
      return result;
    }

    if (token.kind == _TokenKind.number) {
      _position++;
      return Rational(token.number!);
    }

    if (token.kind == _TokenKind.leftParenthesis) {
      _position++;
      if (_matchesKind(_TokenKind.rightParenthesis)) {
        throw const _EvaluationFailure(GameExpressionError.incomplete);
      }
      final value = _parseExpression();
      if (!_matchesKind(_TokenKind.rightParenthesis)) {
        throw const _EvaluationFailure(
          GameExpressionError.unbalancedParentheses,
        );
      }
      _position++;
      return value;
    }

    throw const _EvaluationFailure(GameExpressionError.incomplete);
  }

  bool _matches(GameOperation operation) =>
      _position < tokens.length &&
      tokens[_position].kind == _TokenKind.operation &&
      tokens[_position].operation == operation;

  bool _matchesKind(_TokenKind kind) =>
      _position < tokens.length && tokens[_position].kind == kind;
}

class _ExpressionValue {
  const _ExpressionValue(this.value, this.expression);
  final Rational value;
  final String expression;
}
