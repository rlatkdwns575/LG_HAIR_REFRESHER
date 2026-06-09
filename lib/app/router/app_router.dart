import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/route_paths.dart';
import '../../features/history/ui/page/history_page.dart';
import '../../features/home/ui/page/home_page.dart';
import '../../features/measure/ui/page/measure_page.dart';
import '../../features/measure/ui/page/measure_result_page.dart';
import '../../features/measure/ui/page/measure_run_page.dart';
import '../../features/refresh/ui/page/refresh_page.dart';
import '../../features/refresh/ui/page/refresh_progress_page.dart';
import '../../features/refresh/ui/page/refresh_result_page.dart';
import '../../features/settings/ui/page/settings_page.dart';
import '../../shared/widgets/shared_widget_gallery_page.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutePaths.home,
  debugLogDiagnostics: false,
  errorBuilder: (context, state) => _RouteErrorPage(error: state.error),
  routes: [
    GoRoute(
      name: AppRouteNames.home,
      path: AppRoutePaths.home,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      name: AppRouteNames.measure,
      path: AppRoutePaths.measure,
      builder: (context, state) => const MeasurePage(),
      routes: [
        GoRoute(
          name: AppRouteNames.measureRun,
          path: 'run',
          builder: (context, state) => const MeasureRunPage(),
        ),
        GoRoute(
          name: AppRouteNames.measureResult,
          path: 'result',
          builder: (context, state) => const MeasureResultPage(),
        ),
      ],
    ),
    GoRoute(
      name: AppRouteNames.refresh,
      path: AppRoutePaths.refresh,
      builder: (context, state) => const RefreshPage(),
      routes: [
        GoRoute(
          name: AppRouteNames.refreshProgress,
          path: 'progress',
          builder: (context, state) => const RefreshProgressPage(),
        ),
        GoRoute(
          name: AppRouteNames.refreshResult,
          path: 'result',
          builder: (context, state) => const RefreshResultPage(),
        ),
      ],
    ),
    GoRoute(
      name: AppRouteNames.history,
      path: AppRoutePaths.history,
      builder: (context, state) => const HistoryPage(),
    ),
    GoRoute(
      name: AppRouteNames.settings,
      path: AppRoutePaths.settings,
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      name: AppRouteNames.widgetGallery,
      path: AppRoutePaths.widgetGallery,
      builder: (context, state) => const SharedWidgetGalleryPage(),
    ),
  ],
);

class _RouteErrorPage extends StatelessWidget {
  const _RouteErrorPage({this.error});

  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('페이지를 찾을 수 없습니다')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('요청한 경로가 존재하지 않습니다.'),
              if (error != null) ...[
                const SizedBox(height: 12),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go(AppRoutePaths.home),
                child: const Text('홈으로'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
