import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../../screens/login_screen.dart';

class AppRoutes {
  // já existentes
  static const home = '/home';
  static const game = '/game';
  static const progress = '/progress';
  static const settings = '/settings';

  // NOVO
  static const login = '/login';
}

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.home,
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final atLogin = state.matchedLocation == AppRoutes.login;

      if (user == null && !atLogin) return AppRoutes.login;
      if (user != null && atLogin) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      // ... demais rotas existentes ...
    ],
  );
}