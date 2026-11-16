import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/authentication/presentation/login_page.dart';
import '../../features/game/presentation/game_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/progress/presentation/progress_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../widgets/responsive_layout.dart';

abstract final class AppRoutes {
  static const home = '/home';
  static const game = '/game';
  static const progress = '/progress';
  static const settings = '/settings';
  static const login = '/login';
}

/// Quando `true`, o redirect abaixo não mexe na navegação.
///
/// Criar uma conta no Firebase já deixa o usuário logado. Na tela de
/// cadastro queremos mostrar o pop-up de sucesso e voltar para o login (e
/// não cair direto na home), então a tela pausa o redirect enquanto cria a
/// conta, mostra o aviso e faz o signOut.
final ValueNotifier<bool> authRedirectPaused = ValueNotifier<bool>(false);

const _lastRouteKey = 'last_route';
String? _cachedInitialRoute;

Future<void> loadPersistedRoute() async {
  final prefs = await SharedPreferences.getInstance();
  _cachedInitialRoute = prefs.getString(_lastRouteKey);
}

class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

class _RoutePersistenceObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _save(route.settings.name);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _save(newRoute?.settings.name);
  }

  void _save(String? name) {
    if (name == null || name.isEmpty) return;
    if (name == AppRoutes.login) return;
    if (name == '/') return;
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setString(_lastRouteKey, name),
    );
  }
}

GoRouter createAppRouter({FirebaseAuth? auth}) {
  Stream<User?>? authChanges;
  User? Function()? currentUserGetter;
  try {
    final firebaseAuth = auth ?? FirebaseAuth.instance;
    authChanges = firebaseAuth.authStateChanges();
    currentUserGetter = () => firebaseAuth.currentUser;
  } catch (_) {
    // Ambiente de teste sem Firebase inicializado.
  }

  return GoRouter(
    initialLocation: _cachedInitialRoute ?? AppRoutes.home,
    refreshListenable: authChanges != null
        ? _RouterRefreshNotifier(authChanges)
        : null,
    observers: [_RoutePersistenceObserver()],
    redirect: (context, state) {
      if (authRedirectPaused.value) return null;
      if (currentUserGetter == null) return null;
      final user = currentUserGetter();
      final atLogin = state.matchedLocation == AppRoutes.login;
      if (user == null) return atLogin ? null : AppRoutes.login;
      return atLogin ? AppRoutes.home : null;
    },
    routes: [
      GoRoute(path: '/', redirect: (context, state) => AppRoutes.home),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => ResponsiveLayout(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: AppRoutes.game,
            builder: (context, state) => const GamePage(),
          ),
          GoRoute(
            path: AppRoutes.progress,
            builder: (context, state) => const ProgressPage(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
  );
}
