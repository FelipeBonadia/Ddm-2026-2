import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:math_puzzle_app/app.dart';
import 'package:math_puzzle_app/features/game/application/game_session.dart';
import 'package:math_puzzle_app/features/game/presentation/game_page.dart';
import 'package:math_puzzle_app/providers/auth_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('game builds and validates an equality with four numbers', (
    tester,
  ) async {
    await _pumpApp(tester, const Size(1000, 1100));

    expect(tester.takeException(), isNull);
    expect(find.text('Olá, jogador'), findsOneWidget);
    expect(find.text('SEU PROGRESSO'), findsOneWidget);
    expect(find.text('Jogar agora'), findsOneWidget);

    await tester.tap(find.text('Jogar agora'));
    await tester.pumpAndSettle();

    final gameContext = tester.element(find.byType(GamePage));
    final container = ProviderScope.containerOf(gameContext);
    final controller = container.read(gameSessionProvider.notifier);
    expect(container.read(gameSessionProvider).challenge.numbers, hasLength(4));

    await tester.tap(find.byKey(const ValueKey('game-number-0')));
    await tester.tap(find.byKey(const ValueKey('game-operation-add')));
    await tester.tap(find.byKey(const ValueKey('game-number-1')));
    await tester.tap(find.byKey(const ValueKey('game-equality')));
    await tester.tap(find.byKey(const ValueKey('game-number-2')));
    await tester.tap(find.byKey(const ValueKey('game-operation-add')));
    await tester.tap(find.byKey(const ValueKey('game-number-3')));
    await tester.pumpAndSettle();

    final state = container.read(gameSessionProvider);
    expect(state.usedNumberIndexes, {0, 1, 2, 3});
    expect(controller.selectNumber(0), isFalse);
    expect(controller.checkAnswer()?.isValid, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'dragging onto equation board and tapping placed tile to remove it',
    (tester) async {
      await _pumpApp(tester, const Size(1000, 800));
      await tester.tap(find.text('Jogar agora'));
      await tester.pumpAndSettle();

      final gameContext = tester.element(find.byType(GamePage));
      final container = ProviderScope.containerOf(gameContext);
      final board = find.byKey(const ValueKey('game-equation-board'));

      final num0 = find.byKey(const ValueKey('game-number-0'));
      final gesture = await tester.startGesture(tester.getCenter(num0));
      await gesture.moveTo(tester.getCenter(board));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(container.read(gameSessionProvider).tokens, hasLength(1));
      expect(container.read(gameSessionProvider).usedNumberIndexes, {0});

      await tester.tap(find.byTooltip('Toque para remover'));
      await tester.pumpAndSettle();

      expect(container.read(gameSessionProvider).tokens, isEmpty);
      expect(container.read(gameSessionProvider).usedNumberIndexes, isEmpty);
    },
  );

  testWidgets('compact desktop navigation does not overflow', (tester) async {
    await _pumpApp(tester, const Size(1000, 400));

    expect(tester.takeException(), isNull);
    expect(find.text('Olá, jogador'), findsOneWidget);
    expect(find.byType(CurvedNavigationBar), findsOneWidget);
    expect(find.byIcon(Icons.tune_rounded), findsOneWidget);

    await tester.tap(find.byTooltip('Jogo'));
    await tester.pumpAndSettle();

    expect(find.text('Desafio'), findsOneWidget);
    expect(find.byType(CurvedNavigationBar), findsOneWidget);
  });

  testWidgets('help is presented as a dialog', (tester) async {
    await _pumpApp(tester, const Size(1000, 1100));

    await tester.tap(find.byTooltip('Ajuda'));
    await tester.pumpAndSettle();

    expect(find.text('Como jogar'), findsOneWidget);
    expect(find.text('Entendi'), findsOneWidget);

    await tester.tap(find.text('Entendi'));
    await tester.pumpAndSettle();
    expect(find.text('Como jogar'), findsNothing);
  });

  testWidgets('login does not show the main navigation', (tester) async {
    await _pumpApp(tester, const Size(1000, 1100));

    await tester.tap(find.byTooltip('Acessar conta'));
    await tester.pumpAndSettle();

    expect(find.text('Continuar com Google'), findsOneWidget);
    expect(find.text('INTEGRANTES DO GRUPO'), findsOneWidget);
    expect(find.text('Configurações'), findsNothing);
  });

  testWidgets('theme setting updates the active app theme', (tester) async {
    await _pumpApp(tester, const Size(1000, 1100));

    await tester.tap(find.byTooltip('Configurações'));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.text('Desativado'))).brightness,
      Brightness.light,
    );

    await tester.tap(find.widgetWithText(SwitchListTile, 'Tema escuro'));
    await tester.pumpAndSettle();

    expect(find.text('Ativado'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.text('Ativado'))).brightness,
      Brightness.dark,
    );
  });

  testWidgets('sound setting toggles and persists its preference', (
    tester,
  ) async {
    await _pumpApp(tester, const Size(1000, 1100));

    await tester.tap(find.byTooltip('Configurações'));
    await tester.pumpAndSettle();
    expect(find.text('Desativados'), findsOneWidget);

    await tester.tap(find.widgetWithText(SwitchListTile, 'Efeitos sonoros'));
    await tester.pumpAndSettle();

    expect(find.text('Ativados'), findsOneWidget);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool('sound_enabled'), isTrue);
  });

  testWidgets('font size slider updates the app text scale', (tester) async {
    await _pumpApp(tester, const Size(1000, 1100));

    await tester.tap(find.byTooltip('Configurações'));
    await tester.pumpAndSettle();
    final title = find.text('Configurações').last;
    final initialScale = MediaQuery.textScalerOf(tester.element(title))
        .scale(100);

    await tester.drag(find.byType(Slider), const Offset(500, 0));
    await tester.pumpAndSettle();

    // O tamanho não é mais mostrado em porcentagem.
    expect(find.text('150%'), findsNothing);
    expect(
      MediaQuery.textScalerOf(tester.element(title)).scale(100),
      greaterThan(initialScale),
    );
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getDouble('text_scale'), greaterThan(1));
  });

  testWidgets('language setting translates the progress screen', (
    tester,
  ) async {
    await _pumpApp(tester, const Size(1000, 1100));

    await tester.tap(find.byTooltip('Configurações'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('🇺🇸 English'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('selected_locale'), 'en');

    await tester.tap(find.byTooltip('Progress'));
    await tester.pumpAndSettle();

    expect(find.text('DEMONSTRATION DATA'), findsOneWidget);
    expect(find.text('Demo · Medium'), findsNWidgets(2));
    expect(find.text('Demo · Easy'), findsOneWidget);
    expect(find.text('3 days'), findsOneWidget);
    expect(find.text('DADOS DEMONSTRATIVOS'), findsNothing);
  });
}

Future<void> _pumpApp(WidgetTester tester, Size size) async {
  SharedPreferences.setMockInitialValues({
    'selected_locale': 'pt_BR',
    'theme_mode': 'light',
  });
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authStateProvider.overrideWith((ref) => Stream.value(null)),
        currentUserProvider.overrideWithValue(null),
        solvedChallengesProvider.overrideWith(
          (ref) => Future.value(<String>{}),
        ),
      ],
      child: const MathPuzzleApp(),
    ),
  );
  await tester.pumpAndSettle();
}
