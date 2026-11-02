# Math Puzzle App

Base Flutter para um jogo de desafios matemáticos. O nome `math_puzzle_app` e as telas são provisórios; autenticação, motor matemático e persistência não foram implementados.

## Executar

```powershell
flutter pub get
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 5173
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