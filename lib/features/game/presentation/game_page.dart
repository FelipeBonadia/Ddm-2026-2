import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:math_puzzle_app/l10n/generated/app_localizations.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/app_providers.dart';
import '../application/game_session.dart';
import '../domain/game_engine.dart';

class GamePage extends ConsumerStatefulWidget {
  const GamePage({super.key});

  @override
  ConsumerState<GamePage> createState() => _GamePageState();
}

class _GamePageState extends ConsumerState<GamePage> {
  /// true enquanto alguma peça está sendo arrastada (usado só para dar
  /// destaque visual no tabuleiro).
  bool _isDragging = false;

  /// Incrementado sempre que as peças devem "voltar à paleta" com animação.
  /// Cada _AnimatedReturnTile observa este valor e dispara sua animação quando
  /// ele muda — padrão barato sem coordenador externo.
  int _returnTick = 0;

  void _setDragging(bool value) {
    if (!mounted || _isDragging == value) return;
    setState(() => _isDragging = value);
  }

  /// Dispara a animação de retorno em todos os tiles da paleta.
  void _animateReturn() {
    if (!mounted) return;
    setState(() => _returnTick++);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final game = ref.watch(gameSessionProvider);
    final controller = ref.read(gameSessionProvider.notifier);
    final soundService = ref.read(appSoundServiceProvider);
    final soundEnabled = ref.watch(soundEnabledProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final feedback = _feedbackText(l10n, game);

    // O '=' é sempre presente (o jogo começa com ele no tabuleiro), então só
    // há o que pré-visualizar quando existe algo além dele. Os tokens são
    // unidos com espaço para dois números vizinhos não virarem um só ("2 3").
    final hasContent = game.tokens.any((t) => t != '=');
    final draftText = game.tokens.join(' ');
    // Modo parcial: a fórmula é renderizada em LaTeX durante toda a montagem
    // (partes que faltam aparecem como □), não só quando está completa.
    final latex = expressionToLatex(draftText, partial: true);

    void playSelection() => soundService.playSelection(enabled: soundEnabled);

    // ── Lógica única de "pode essa peça entrar agora?" ──────────────────────
    // Delega ao controller: a regra vive num lugar só.
    bool canAccept(_GamePiece piece) => switch (piece.kind) {
      _GamePieceKind.number => controller.canAddNumber(piece.numberIndex!),
      _GamePieceKind.operation => controller.canAddOperation(piece.operation!),
      _GamePieceKind.leftParenthesis ||
      _GamePieceKind.rightParenthesis => controller.canAddParenthesis(),
      _GamePieceKind.equality => controller.canAddEquality(),
    };

    // insertAt == null → adiciona no final; com valor → insere na
    // posição onde a peça foi solta.
    void addPiece(_GamePiece piece, [int? insertAt]) {
      final added = switch (piece.kind) {
        _GamePieceKind.number => controller.addNumber(
          piece.numberIndex!,
          insertAt,
        ),
        _GamePieceKind.operation => controller.addOperation(
          piece.operation!,
          insertAt,
        ),
        _GamePieceKind.leftParenthesis => controller.addParenthesis(
          opening: true,
          insertAt: insertAt,
        ),
        _GamePieceKind.rightParenthesis => controller.addParenthesis(
          opening: false,
          insertAt: insertAt,
        ),
        _GamePieceKind.equality => controller.addEquality(insertAt),
      };
      if (added) playSelection();
    }

    void removeTokenAt(int index) {
      // O '=' é fixo: não pode ser removido.
      if (game.tokens[index] == '=') return;
      controller.removeAt(index);
      playSelection();
    }

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppConstants.contentMaxWidth,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final totalH = constraints.maxHeight;
              final totalW = constraints.maxWidth;

              // ── Tamanhos: só dois tokens, nada de porcentagem por seção ───
              final compact = totalH < 600 || totalW < 360;
              // Com zoom do navegador ou telas baixas a área útil encolhe:
              // abaixo disso a página inteira rola em vez de estourar o layout.
              final scrollable = totalH < 820;
              final metrics = _TileMetrics(
                height: compact ? 38 : 46,
                minWidth: compact ? 38 : 46,
                fontSize: compact ? 17 : 20,
                hPad: 10,
              );
              final gap = compact ? 8.0 : 12.0;
              final hPad = (totalW * 0.04).clamp(12.0, 20.0);

              Widget paletteTile({
                required Key tileKey,
                required _GamePiece piece,
                required _TileStyle style,
                bool isUsed = false,
                int delay = 0,
              }) {
                return _AnimatedReturnTile(
                  key: tileKey,
                  returnTick: _returnTick,
                  delay: delay,
                  child: _DraggableTile(
                    piece: piece,
                    style: style,
                    metrics: metrics,
                    enabled: canAccept(piece),
                    isUsed: isUsed,
                    onDragStarted: () => _setDragging(true),
                    onDragEnded: () => _setDragging(false),
                  ),
                );
              }

              final boardParts = <Widget>[
                _EquationBoard(
                  key: const ValueKey('game-equation-board'),
                  tokens: game.tokens,
                  metrics: metrics,
                  dragging: _isDragging,
                  canAccept: canAccept,
                  onDropPiece: addPiece,
                  onTokenTapped: removeTokenAt,
                ),
                SizedBox(height: gap),
                _LatexPreview(
                  key: const ValueKey('game-latex-preview'),
                  latex: latex,
                  draft: draftText,
                ),
              ];

              final body = Column(
                mainAxisSize: scrollable ? MainAxisSize.min : MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Header ───────────────────────────────────────────────
                  SizedBox(
                    height: 44,
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: l10n.gameBack,
                          iconSize: 22,
                          onPressed: () {
                            soundService.playBack(enabled: soundEnabled);
                            ref
                                .read(selectedSectionProvider.notifier)
                                .select(AppSection.home);
                            context.go(AppRoutes.home);
                          },
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        Expanded(
                          child: Text(
                            l10n.gameTitle,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        Flexible(
                          child: _DifficultyPicker(
                            value: game.challenge.difficulty,
                            enabled: !game.solved,
                            onChanged: (difficulty) {
                              playSelection();
                              controller.setDifficulty(difficulty);
                            },
                          ),
                        ),
                        SizedBox(width: gap / 2),
                        _AttemptsBadge(attempts: game.attempts),
                        IconButton(
                          tooltip: l10n.gameSkip,
                          iconSize: 22,
                          onPressed: game.solved
                              ? null
                              : () {
                                  controller.skipChallenge();
                                  soundService.playNavigation(
                                    enabled: soundEnabled,
                                  );
                                },
                          icon: const Icon(Icons.skip_next_rounded),
                        ),
                      ],
                    ),
                  ),

                  // 2. Instrução de arrastar + Tagline ───────────────────────
                  Padding(
                    padding: EdgeInsets.only(top: gap / 2),
                    child: Text(
                      l10n.gameDragHint,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: gap / 2),
                    child: Text(
                      l10n.gameRuleHint,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  // 3. Tabuleiro + LaTeX logo abaixo, juntos e centralizados ─
                  // ListView(shrinkWrap) mantém o preview colado no tabuleiro
                  // e ainda rola se a tela for muito baixa.
                  if (scrollable)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: gap),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: boardParts,
                      ),
                    )
                  else
                    Expanded(
                      child: Center(
                        child: ListView(shrinkWrap: true, children: boardParts),
                      ),
                    ),

                  // 4. Feedback: espaço sempre reservado (sem "pulo") ───────
                  SizedBox(
                    height: 40,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: gap / 3),
                      child: feedback == null
                          ? const SizedBox.shrink()
                          : _FeedbackMessage(
                              text: feedback,
                              success: game.evaluation?.isCorrect == true,
                            ),
                    ),
                  ),

                  // 5. Números ──────────────────────────────────────────────
                  _SectionLabel(l10n.gameNumbers),
                  SizedBox(height: gap / 2),
                  Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    alignment: WrapAlignment.center,
                    children: [
                      for (var i = 0; i < game.challenge.numbers.length; i++)
                        paletteTile(
                          tileKey: ValueKey('game-number-$i'),
                          piece: _GamePiece.number(
                            i,
                            '${game.challenge.numbers[i]}',
                          ),
                          style: _TileStyle.number,
                          isUsed: game.usedNumberIndexes.contains(i),
                          delay: i * 35,
                        ),
                    ],
                  ),

                  SizedBox(height: gap * 1.2),

                  // 6. Operações ────────────────────────────────────────────
                  // Só aparecem as operações permitidas no nível atual.
                  _SectionLabel(l10n.gameOperations),
                  SizedBox(height: gap / 2),
                  Builder(
                    builder: (context) {
                      var opIndex = game.challenge.numbers.length;
                      return Wrap(
                        spacing: gap,
                        runSpacing: gap,
                        alignment: WrapAlignment.center,
                        children: [
                          for (final op in GameOperation.values)
                            if (game.challenge.allowedOperations.contains(op))
                              paletteTile(
                                tileKey: ValueKey('game-operation-${op.name}'),
                                piece: _GamePiece.operation(op, _opLabel(op)),
                                style: _TileStyle.operation,
                                delay: (opIndex++) * 30,
                              ),
                          paletteTile(
                            tileKey: const ValueKey('game-open-parenthesis'),
                            piece: const _GamePiece.leftParenthesis(),
                            style: _TileStyle.parenthesis,
                            delay: (opIndex++) * 30,
                          ),
                          paletteTile(
                            tileKey: const ValueKey('game-close-parenthesis'),
                            piece: const _GamePiece.rightParenthesis(),
                            style: _TileStyle.parenthesis,
                            delay: (opIndex++) * 30,
                          ),
                          // O '=' já vem posicionado no tabuleiro; a peça só
                          // aparece na paleta se ele não estiver lá.
                          if (!game.tokens.contains('='))
                            paletteTile(
                              tileKey: const ValueKey('game-equality'),
                              piece: const _GamePiece.equality(),
                              style: _TileStyle.equality,
                              delay: (opIndex++) * 30,
                            ),
                        ],
                      );
                    },
                  ),

                  SizedBox(height: gap * 1.2),

                  // 7. Barra de ações ───────────────────────────────────────
                  Row(
                    children: [
                      _ActionBtn(
                        icon: Icons.undo_rounded,
                        label: l10n.gameUndo,
                        enabled: !game.solved && hasContent,
                        onPressed: () {
                          controller.removeLast();
                          playSelection();
                        },
                      ),
                      SizedBox(width: gap),
                      _ActionBtn(
                        icon: Icons.delete_sweep_outlined,
                        label: l10n.gameClear,
                        enabled: !game.solved && hasContent,
                        onPressed: () {
                          _animateReturn();
                          controller.clearExpression();
                          soundService.playControl(enabled: soundEnabled);
                        },
                      ),
                      const Spacer(),
                      _ActionBtn(
                        icon: game.solved
                            ? Icons.arrow_forward_rounded
                            : Icons.check_circle_outline_rounded,
                        label: game.solved
                            ? l10n.gameContinue
                            : l10n.gameVerify,
                        enabled: true,
                        filled: true,
                        onPressed: game.solved
                            ? () {
                                _animateReturn();
                                controller.nextChallenge();
                                soundService.playPrimaryAction(
                                  enabled: soundEnabled,
                                );
                              }
                            : () {
                                final result = controller.checkAnswer();
                                if (result?.isCorrect == true) {
                                  soundService.playSuccess(
                                    enabled: soundEnabled,
                                  );
                                  _animateReturn();
                                } else {
                                  soundService.playWarning(
                                    enabled: soundEnabled,
                                  );
                                }
                              },
                      ),
                    ],
                  ),
                ],
              );

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad, vertical: gap),
                child: scrollable ? SingleChildScrollView(child: body) : body,
              );
            },
          ),
        ),
      ),
    );
  }

  /// Rótulo de cada operação na paleta. `switch` exaustivo sobre todas as
  /// operações do enum — antes só cobria as 4 básicas e não compilava.
  String _opLabel(GameOperation op) => switch (op) {
    GameOperation.add => '+',
    GameOperation.subtract => '−',
    GameOperation.multiply => '×',
    GameOperation.divide => '÷',
    GameOperation.power => '**',
    GameOperation.sqrt => '√',
    GameOperation.cbrt => '∛',
    GameOperation.factorial => '!',
    GameOperation.modulus => '|',
    GameOperation.floor => '⌊',
    GameOperation.ceil => '⌈',
  };

  String? _feedbackText(AppLocalizations l10n, GameSessionState game) {
    final evaluation = game.evaluation;
    if (evaluation == null) return null;
    if (evaluation.isCorrect) return l10n.gameFeedbackCorrect;
    if (evaluation.error == null) return l10n.gameFeedbackIncorrect;
    return switch (evaluation.error!) {
      GameExpressionError.missingEquality => l10n.gameFeedbackMissingEquality,
      GameExpressionError.incomplete => l10n.gameFeedbackIncomplete,
      GameExpressionError.wrongNumbers => l10n.gameFeedbackWrongNumbers,
      GameExpressionError.operationNotAllowed =>
        l10n.gameFeedbackOperationNotAllowed,
      GameExpressionError.divisionByZero => l10n.gameFeedbackDivisionByZero,
      GameExpressionError.divisionNotExact => l10n.gameFeedbackDivisionNotExact,
      GameExpressionError.domainError => l10n.gameFeedbackDomainError,
      GameExpressionError.invalidCharacter ||
      GameExpressionError.invalidSyntax ||
      GameExpressionError.unbalancedParentheses =>
        l10n.gameFeedbackInvalidSyntax,
    };
  }
}

// ─── Header widgets ───────────────────────────────────────────────────────────

class _DifficultyPicker extends StatelessWidget {
  const _DifficultyPicker({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final GameDifficulty value;
  final bool enabled;
  final ValueChanged<GameDifficulty> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    String labelFor(GameDifficulty difficulty) => switch (difficulty) {
      GameDifficulty.easy => l10n.gameEasy,
      GameDifficulty.intermediate => l10n.gameIntermediate,
      GameDifficulty.advanced => l10n.gameAdvanced,
      GameDifficulty.hard => l10n.gameHard,
    };

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 140),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: DropdownButton<GameDifficulty>(
          value: value,
          isDense: true,
          isExpanded: true,
          underline: const SizedBox.shrink(),
          style: TextStyle(
            color: scheme.onSurface,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          // Um item por nível, na ordem do enum (do mais fácil ao mais difícil).
          items: [
            for (final difficulty in GameDifficulty.values)
              DropdownMenuItem(
                value: difficulty,
                child: Text(
                  labelFor(difficulty),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: enabled
              ? (d) {
                  if (d != null) onChanged(d);
                }
              : null,
        ),
      ),
    );
  }
}

class _AttemptsBadge extends StatelessWidget {
  const _AttemptsBadge({required this.attempts});
  final int attempts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    // Não é um botão: é só o contador de tentativas. Por isso:
    // - ícone sem cara de "ação" (nada de replay/undo, que parecem clicáveis)
    // - rótulo ao lado do número, não só o número sozinho
    // - Tooltip + Semantics, pra quem passar o mouse ou usar leitor de tela
    return Tooltip(
      message: l10n.gameAttemptsTooltip,
      child: Semantics(
        label: l10n.gameAttemptsTooltip,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.pin_outlined,
                size: 13,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                l10n.gameAttemptsBadge(attempts),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    textAlign: TextAlign.center,
    style: const TextStyle(
      color: AppColors.cyan,
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
    ),
  );
}

// ─── Action Button ────────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onPressed,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.symmetric(horizontal: 14, vertical: 10);
    final text = Text(label, style: const TextStyle(fontSize: 14));
    if (filled) {
      return FilledButton.icon(
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(padding: padding),
        icon: Icon(icon, size: 18),
        label: text,
      );
    }
    return OutlinedButton.icon(
      onPressed: enabled ? onPressed : null,
      style: OutlinedButton.styleFrom(padding: padding),
      icon: Icon(icon, size: 18),
      label: text,
    );
  }
}

// ─── Game Piece Model ─────────────────────────────────────────────────────────

enum _GamePieceKind {
  number,
  operation,
  leftParenthesis,
  rightParenthesis,
  equality,
}

class _GamePiece {
  const _GamePiece.number(this.numberIndex, this.label)
    : kind = _GamePieceKind.number,
      operation = null;

  const _GamePiece.operation(this.operation, this.label)
    : kind = _GamePieceKind.operation,
      numberIndex = null;

  const _GamePiece.leftParenthesis()
    : kind = _GamePieceKind.leftParenthesis,
      numberIndex = null,
      operation = null,
      label = '(';

  const _GamePiece.rightParenthesis()
    : kind = _GamePieceKind.rightParenthesis,
      numberIndex = null,
      operation = null,
      label = ')';

  const _GamePiece.equality()
    : kind = _GamePieceKind.equality,
      numberIndex = null,
      operation = null,
      label = '=';

  final _GamePieceKind kind;
  final int? numberIndex;
  final GameOperation? operation;
  final String label;
}

// ─── Tile (visual) ────────────────────────────────────────────────────────────

enum _TileStyle { number, operation, parenthesis, equality }

class _TileMetrics {
  const _TileMetrics({
    required this.height,
    required this.minWidth,
    required this.fontSize,
    required this.hPad,
  });

  final double height;
  final double minWidth;
  final double fontSize;
  final double hPad;
}

/// A "caixinha" de uma peça.
///
/// IMPORTANTE: não usa `Container(alignment: ...)`. Um Container com
/// `alignment` se expande até o máximo permitido pelo pai (dentro de Wrap ou
/// Row isso vira largura/altura total) — era esse o bug das caixas gigantes.
/// Aqui o `Center(widthFactor: 1, heightFactor: 1)` faz a caixa abraçar o texto,
/// respeitando só o tamanho mínimo.
class _TileFace extends StatelessWidget {
  const _TileFace({
    required this.label,
    required this.style,
    required this.metrics,
    this.enabled = true,
    this.isUsed = false,
    this.onTap,
  });

  final String label;
  final _TileStyle style;
  final _TileMetrics metrics;
  final bool enabled;
  final bool isUsed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Color bg;
    Color fg;
    Color border;

    if (isUsed) {
      bg = scheme.surfaceContainerLow.withValues(alpha: 0.3);
      fg = scheme.onSurface.withValues(alpha: 0.25);
      border = scheme.outlineVariant.withValues(alpha: 0.25);
    } else {
      switch (style) {
        case _TileStyle.equality:
          bg = Colors.amber.withValues(alpha: 0.2);
          fg = Colors.amber.shade300;
          border = Colors.amber.shade600;
        case _TileStyle.number:
          bg = scheme.primaryContainer;
          fg = scheme.onPrimaryContainer;
          border = scheme.primary.withValues(alpha: 0.8);
        case _TileStyle.operation:
          bg = Color.alphaBlend(
            AppColors.cyan.withValues(alpha: 0.14),
            scheme.surface,
          );
          fg = AppColors.cyan;
          border = AppColors.cyan.withValues(alpha: 0.6);
        case _TileStyle.parenthesis:
          bg = scheme.surfaceContainerHighest;
          fg = scheme.onSurface;
          border = scheme.outlineVariant;
      }
    }

    return Opacity(
      opacity: (enabled || isUsed) ? 1.0 : 0.45,
      child: Material(
        color: bg,
        elevation: (enabled && !isUsed) ? 1.5 : 0,
        shadowColor: Colors.black,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: border, width: 1.2),
        ),
        child: InkWell(
          onTap: (enabled && !isUsed) ? onTap : null,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: metrics.minWidth,
              minHeight: metrics.height,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: metrics.hPad),
              child: Center(
                widthFactor: 1,
                heightFactor: 1,
                child: Text(
                  label,
                  style: TextStyle(
                    color: fg,
                    fontSize: metrics.fontSize,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Draggable Tile (paleta) ──────────────────────────────────────────────────

class _DraggableTile extends StatelessWidget {
  const _DraggableTile({
    required this.piece,
    required this.style,
    required this.metrics,
    required this.enabled,
    required this.isUsed,
    required this.onDragStarted,
    required this.onDragEnded,
  });

  final _GamePiece piece;
  final _TileStyle style;
  final _TileMetrics metrics;
  final bool enabled;
  final bool isUsed;
  final VoidCallback onDragStarted;
  final VoidCallback onDragEnded;

  @override
  Widget build(BuildContext context) {
    final face = _TileFace(
      label: piece.label,
      style: style,
      metrics: metrics,
      enabled: enabled,
      isUsed: isUsed,
    );

    if (!enabled) {
      return MouseRegion(cursor: SystemMouseCursors.basic, child: face);
    }

    return Draggable<_GamePiece>(
      data: piece,
      // O ícone fica CENTRADO no ponteiro. O Flutter decide o drop pela posição
      // do ponteiro, então o que você vê é exatamente onde vai cair.
      dragAnchorStrategy: (draggable, context, position) {
        final box = context.findRenderObject() as RenderBox;
        return box.size.center(Offset.zero);
      },
      onDragStarted: onDragStarted,
      // Cobre drop aceito, drop recusado e cancelamento.
      onDragEnd: (_) => onDragEnded(),
      feedback: Transform.scale(
        scale: 1.12,
        child: _TileFace(label: piece.label, style: style, metrics: metrics),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _TileFace(
          label: piece.label,
          style: style,
          metrics: metrics,
          enabled: false,
        ),
      ),
      child: MouseRegion(cursor: SystemMouseCursors.grab, child: face),
    );
  }
}

// ─── Animação de Retorno das Peças à Paleta ──────────────────────────────────

/// Anima a volta das peças para a paleta com um efeito de deslize e escala suave
/// (como sugerido no enunciado do trabalho: "os operadores voltam aos seus
/// lugares após a finalização de uma escolha").
class _AnimatedReturnTile extends StatefulWidget {
  const _AnimatedReturnTile({
    super.key,
    required this.returnTick,
    this.delay = 0,
    required this.child,
  });

  final int returnTick;
  final int delay;
  final Widget child;

  @override
  State<_AnimatedReturnTile> createState() => _AnimatedReturnTileState();
}

class _AnimatedReturnTileState extends State<_AnimatedReturnTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );
    _scaleAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );
    // Começa já na posição final de descanso (sem animação no primeiro build).
    _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant _AnimatedReturnTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.returnTick != oldWidget.returnTick && widget.returnTick > 0) {
      _triggerAnimation();
    }
  }

  void _triggerAnimation() {
    _controller.reset();
    if (widget.delay > 0) {
      Future.delayed(Duration(milliseconds: widget.delay), () {
        if (mounted) {
          _controller.forward();
        }
      });
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

// ─── Equation Board (alvo do drop) ────────────────────────────────────────────

class _EquationBoard extends StatefulWidget {
  const _EquationBoard({
    super.key,
    required this.tokens,
    required this.metrics,
    required this.dragging,
    required this.canAccept,
    required this.onDropPiece,
    required this.onTokenTapped,
  });

  final List<String> tokens;
  final _TileMetrics metrics;
  final bool dragging;
  final bool Function(_GamePiece piece) canAccept;
  final void Function(_GamePiece piece, int? insertAt) onDropPiece;
  final ValueChanged<int> onTokenTapped;

  @override
  State<_EquationBoard> createState() => _EquationBoardState();
}

class _EquationBoardState extends State<_EquationBoard> {
  final List<GlobalKey> _keys = [];

  /// Posição (0..tokens.length) onde a peça entraria se fosse solta agora.
  int? _insertIndex;

  void _syncKeys() {
    while (_keys.length < widget.tokens.length) {
      _keys.add(GlobalKey());
    }
    if (_keys.length > widget.tokens.length) {
      _keys.removeRange(widget.tokens.length, _keys.length);
    }
  }

  /// Posição do ponteiro: o feedback é ancorado pelo centro, e o `offset` do
  /// drag é o canto superior esquerdo dele.
  Offset _centerOf(Offset dragOffset) =>
      dragOffset +
      Offset(widget.metrics.minWidth / 2, widget.metrics.height / 2);

  /// Descobre entre quais tokens o ponto caiu, lendo as posições reais na
  /// tela — funciona mesmo quando o Wrap quebra em várias linhas.
  int _insertIndexFor(Offset global) {
    for (var i = 0; i < widget.tokens.length && i < _keys.length; i++) {
      final box = _keys[i].currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) continue;
      final rect = box.localToGlobal(Offset.zero) & box.size;
      // Token numa linha abaixo do ponto → insere antes dele.
      if (global.dy < rect.top) return i;
      // Mesma linha e o ponto está à esquerda do centro → insere antes.
      if (global.dy <= rect.bottom && global.dx < rect.center.dx) return i;
    }
    return widget.tokens.length;
  }

  void _setInsertIndex(int? value) {
    if (_insertIndex == value) return;
    setState(() => _insertIndex = value);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    _syncKeys();

    return DragTarget<_GamePiece>(
      // Opaco: toda a área reservada ao tabuleiro recebe o drop.
      hitTestBehavior: HitTestBehavior.opaque,
      onWillAcceptWithDetails: (details) => widget.canAccept(details.data),
      onMove: (details) =>
          _setInsertIndex(_insertIndexFor(_centerOf(details.offset))),
      onLeave: (_) => _setInsertIndex(null),
      onAcceptWithDetails: (details) {
        final index = _insertIndexFor(_centerOf(details.offset));
        _setInsertIndex(null);
        widget.onDropPiece(details.data, index);
      },
      builder: (context, candidates, rejected) {
        final hovering = candidates.isNotEmpty;
        final rejecting = rejected.isNotEmpty;
        final tokens = widget.tokens;

        final Color borderColor;
        if (hovering) {
          borderColor = scheme.primary;
        } else if (rejecting) {
          borderColor = scheme.error;
        } else if (widget.dragging) {
          borderColor = scheme.primary.withValues(alpha: 0.6);
        } else if (tokens.isEmpty) {
          borderColor = scheme.outlineVariant;
        } else {
          borderColor = scheme.primary.withValues(alpha: 0.45);
        }

        final bgColor = hovering
            ? scheme.primaryContainer.withValues(alpha: 0.3)
            : scheme.surfaceContainerLow;

        Widget marker() => Container(
          width: 3,
          height: widget.metrics.height - 6,
          decoration: BoxDecoration(
            color: scheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        );

        final showMarker = hovering && _insertIndex != null;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 96),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: borderColor,
                  width: (hovering || widget.dragging) ? 2.0 : 1.2,
                ),
              ),
              child: tokens.isEmpty
                  ? Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.drag_indicator_rounded,
                            color: scheme.onSurfaceVariant.withValues(
                              alpha: 0.5,
                            ),
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              AppLocalizations.of(context)!.gameBoardEmptyHint,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: scheme.onSurfaceVariant.withValues(
                                  alpha: 0.7,
                                ),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Center(
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            for (var i = 0; i < tokens.length; i++) ...[
                              if (showMarker && _insertIndex == i) marker(),
                              _BoardTile(
                                key: _keys[i],
                                token: tokens[i],
                                metrics: widget.metrics,
                                onTap: tokens[i] == '='
                                    ? null
                                    : () => widget.onTokenTapped(i),
                              ),
                            ],
                            if (showMarker && _insertIndex == tokens.length)
                              marker(),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Peça já colocada no tabuleiro ───────────────────────────────────────────

class _BoardTile extends StatelessWidget {
  const _BoardTile({
    super.key,
    required this.token,
    required this.metrics,
    this.onTap,
  });

  final String token;
  final _TileMetrics metrics;
  final VoidCallback? onTap; // null = peça fixa (o '=')

  @override
  Widget build(BuildContext context) {
    // Qualquer símbolo reconhecido pelo motor (+ − × ÷ ** √ ∛ ! | ⌊ ⌈) é
    // operação; antes só os 4 básicos eram, e √, !, ⌊ etc. ficavam com a
    // cor de parêntese.
    final style = switch (token) {
      '=' => _TileStyle.equality,
      '(' || ')' => _TileStyle.parenthesis,
      _ =>
        int.tryParse(token) != null
            ? _TileStyle.number
            : GameOperationSymbol.fromSymbol(token) != null
            ? _TileStyle.operation
            : _TileStyle.parenthesis,
    };

    final label = switch (token) {
      '*' => '×',
      '/' => '÷',
      '-' => '−',
      _ => token,
    };

    final face = _TileFace(
      label: label,
      style: style,
      metrics: _TileMetrics(
        height: metrics.height - 6,
        minWidth: metrics.minWidth - 6,
        fontSize: metrics.fontSize - 1,
        hPad: metrics.hPad - 2,
      ),
      onTap: onTap,
    );
    if (onTap == null) return face;
    return Tooltip(
      message: AppLocalizations.of(context)!.gameRemoveTokenHint,
      child: face,
    );
  }
}

// ─── Pré-visualização LaTeX ──────────────────────────────────────────────────

/// Renderiza a fórmula montada em LaTeX, logo abaixo do tabuleiro.
/// - [latex] != null → fórmula completa e renderizável.
/// - [latex] == null e [draft] != null → ainda incompleta (ex.: "3 + ="):
///   mostra o rascunho em texto simples, esmaecido, em vez de sumir.
/// A altura mínima é fixa para o layout não "pular" ao montar a fórmula.
class _LatexPreview extends StatelessWidget {
  const _LatexPreview({super.key, required this.latex, required this.draft});

  final String? latex;
  final String? draft;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // FittedBox(scaleDown): fórmulas longas ou com zoom alto encolhem para
    // caber inteiras na largura, em vez de cortar ou exigir rolagem lateral.
    Widget content;
    if (latex != null) {
      content = FittedBox(
        fit: BoxFit.scaleDown,
        child: Math.tex(
          latex!,
          textStyle: TextStyle(fontSize: 28, color: scheme.onSurface),
          onErrorFallback: (_) => Text(
            latex!,
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 16),
          ),
        ),
      );
    } else if (draft != null) {
      content = Text(
        draft!,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
          fontSize: 16,
        ),
      );
    } else {
      content = const SizedBox.shrink();
    }

    return Container(
      key: const ValueKey('game-latex-box'),
      constraints: const BoxConstraints(minHeight: 64),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Semantics(label: latex ?? draft ?? '', child: content),
    );
  }
}

// ─── Feedback Message ─────────────────────────────────────────────────────────

class _FeedbackMessage extends StatelessWidget {
  const _FeedbackMessage({required this.text, required this.success});

  final String text;
  final bool success;

  @override
  Widget build(BuildContext context) {
    final color = success
        ? AppColors.success
        : Theme.of(context).colorScheme.error;
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Icon(
              success ? Icons.check_circle_rounded : Icons.info_outline_rounded,
              color: color,
              size: 16,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}