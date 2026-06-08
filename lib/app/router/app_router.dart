import 'package:go_router/go_router.dart';

import '../../features/history/presentation/pages/history_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/measure/presentation/pages/measure_page.dart';
import '../../features/refresh/presentation/pages/refresh_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../navigation/bottom_nav_shell.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutePaths.home,
  routes: [
    ShellRoute(
      builder: (context, state, child) => BottomNavShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutePaths.home,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: HomePage()),
        ),
        GoRoute(
          path: AppRoutePaths.measure,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: MeasurePage()),
        ),
        GoRoute(
          path: AppRoutePaths.refresh,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: RefreshPage()),
        ),
        GoRoute(
          path: AppRoutePaths.history,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: HistoryPage()),
        ),
        GoRoute(
          path: AppRoutePaths.settings,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: SettingsPage()),
        ),
      ],
    ),
  ],
);

class AppRoutePaths {
  const AppRoutePaths._();

  static const home = '/';
  static const measure = '/measure';
  static const refresh = '/refresh';
  static const history = '/history';
  static const settings = '/settings';
}
