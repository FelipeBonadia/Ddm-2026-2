# Math Puzzle App

Feito por Felipe Bonadia e Rick Robert

Base Flutter para um jogo de desafios matemáticos.

## Executar

```powershell
flutter pub get
flutter run -d chrome  // de preferencia pelo chrome ao edge
```

## Validar

```powershell
flutter analyze
flutter test
```

## Organização

- `lib/app.dart`: configuração, localização e tema.
- `lib/core/`: cores, tema, constantes e rotas.
- `lib/features/`: páginas por funcionalidade.
- `lib/models/`: preferências da interface.
- `lib/providers/`: estado global Riverpod.
- `lib/widgets/`: navegação e layout responsivos.
- `test/`: testes de widget.
