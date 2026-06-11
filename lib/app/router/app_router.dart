import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/route_paths.dart';
import '../../features/auth/data/model/sign_up_draft.dart';
import '../../features/auth/ui/page/email_login_screen.dart';
import '../../features/auth/ui/page/login_screen.dart';
import '../../features/auth/ui/page/signup_step_one_screen.dart';
import '../../features/auth/ui/page/signup_step_two_screen.dart';
import '../../features/history/ui/page/history_page.dart';
import '../../features/home/ui/page/home_page.dart';
import '../../features/home/ui/page/home_refresh_shortcut_add_page.dart';
import '../../features/measure/ui/page/measure_page.dart';
import '../../features/measure/ui/page/measure_analyzing_page.dart';
import '../../features/measure/ui/page/measure_result_page.dart';
import '../../features/measure/ui/page/measure_run_page.dart';
import '../../features/refresh/data/refresh_route_extra.dart';
import '../../features/refresh/ui/page/refresh_custom_create_page.dart';
import '../../features/refresh/ui/page/refresh_detail_page.dart';
import '../../features/refresh/ui/page/refresh_page.dart';
import '../../features/refresh/ui/page/refresh_progress_page.dart';
import '../../features/refresh/ui/page/refresh_result_collecting_page.dart';
import '../../features/refresh/ui/page/refresh_result_page.dart';
import '../../features/settings/ui/page/settings_page.dart';
import '../../shared/widgets/shared_widget_gallery_page.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutePaths.login,
  debugLogDiagnostics: false,
  errorBuilder: (context, state) => _RouteErrorPage(error: state.error),
  routes: [
    GoRoute(
      name: AppRouteNames.login,
      path: AppRoutePaths.login,
      builder: (context, state) => const LoginScreen(),
      routes: [
        GoRoute(
          name: AppRouteNames.emailLogin,
          path: 'email',
          builder: (context, state) => const EmailLoginScreen(),
        ),
        GoRoute(
          name: AppRouteNames.signUp,
          path: 'signup',
          builder: (context, state) => const SignUpStepOneScreen(),
          routes: [
            GoRoute(
              name: AppRouteNames.signUpStepTwo,
              path: 'step-two',
              builder: (context, state) {
                final draft = state.extra;
                if (draft is! SignUpDraft) {
                  return const SignUpStepOneScreen();
                }
                return SignUpStepTwoScreen(draft: draft);
              },
            ),
          ],
        ),
      ],
    ),
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
          name: AppRouteNames.measureAnalyzing,
          path: 'analyzing',
          builder: (context, state) => const MeasureAnalyzingPage(),
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
          name: AppRouteNames.refreshDetail,
          path: 'detail',
          builder: (context, state) {
            final mode = resolveRefreshMode(state.extra);
            if (mode == null) {
              return const RefreshDetailPageFallback();
            }
            return RefreshDetailPage(mode: mode);
          },
        ),
        GoRoute(
          name: AppRouteNames.refreshProgress,
          path: 'progress',
          builder: (context, state) =>
              RefreshProgressPage(mode: resolveRefreshMode(state.extra)),
        ),
        GoRoute(
          name: AppRouteNames.refreshResultCollecting,
          path: 'result/collecting',
          builder: (context, state) => const RefreshResultCollectingPage(),
        ),
        GoRoute(
          name: AppRouteNames.refreshResult,
          path: 'result',
          builder: (context, state) => const RefreshResultPage(),
        ),
      ],
    ),
    GoRoute(
      name: AppRouteNames.refreshCustomCreate,
      path: AppRoutePaths.refreshCustomCreate,
      builder: (context, state) => const RefreshCustomCreatePage(),
    ),
    GoRoute(
      name: AppRouteNames.refreshShortcutAdd,
      path: AppRoutePaths.refreshShortcutAdd,
      builder: (context, state) => const HomeRefreshShortcutAddPage(),
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
