import 'package:go_router/go_router.dart';

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

GoRouter createAppRouter() => GoRouter(
  initialLocation: AppRoutes.home,
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
