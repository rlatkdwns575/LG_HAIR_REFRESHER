import 'package:flutter/material.dart';

import '../../core/constants/route_paths.dart';
import '../../features/auth/ui/widgets/auth_screen_styles.dart';
import '../theme/app_colors.dart';

/// 각 화면 Scaffold [backgroundColor]와 동일한 값.
///
/// ShellRoute 좌우 여백·페이지 배경을 맞출 때 사용합니다.
/// 화면 배경을 변경하면 이 파일의 해당 경로도 함께 수정하세요.
abstract final class AppPageBackgrounds {
  static Color forPath(String path) {
    return switch (path) {
      // auth — login_screen.dart
      AppRoutePaths.login => AuthScreenStyles.backgroundMuted,
      // auth — email_login / signup (Colors.white == surface)
      AppRoutePaths.emailLogin ||
      AppRoutePaths.signUp ||
      AppRoutePaths.signUpStepTwo => AppColors.surface,
      // measure — surface
      AppRoutePaths.measure ||
      AppRoutePaths.measurePrepare ||
      AppRoutePaths.measureRun ||
      AppRoutePaths.measureAnalyzing ||
      AppRoutePaths.measureResult ||
      AppRoutePaths.measureResultDetail => AppColors.surface,
      // refresh — refresh_result_page.dart only
      AppRoutePaths.refreshResult => AppColors.surface,
      // refresh — gray0
      AppRoutePaths.refresh ||
      AppRoutePaths.refreshDetail ||
      AppRoutePaths.refreshProgress ||
      AppRoutePaths.refreshResultCollecting ||
      AppRoutePaths.refreshResultDetail ||
      AppRoutePaths.refreshCustomCreate ||
      AppRoutePaths.refreshShortcutAdd => AppColors.gray0,
      // history — history_page.dart
      AppRoutePaths.history => AppColors.gray0,
      // settings — gray50
      AppRoutePaths.settings ||
      AppRoutePaths.settingsDevice ||
      AppRoutePaths.settingsLocalCalendar => AppColors.gray50,
      // home — home_page.dart (ShellRoute 밖, 참고용)
      AppRoutePaths.home => AppColors.homeBackground,
      _ => _forUnknownPath(path),
    };
  }

  static Color _forUnknownPath(String path) {
    if (path.startsWith('${AppRoutePaths.login}/')) {
      return AppColors.surface;
    }
    if (path.startsWith('${AppRoutePaths.measure}/') ||
        path == AppRoutePaths.measure) {
      return AppColors.surface;
    }
    if (path == AppRoutePaths.refreshResult) {
      return AppColors.surface;
    }
    if (path.startsWith('${AppRoutePaths.refresh}/') ||
        path == AppRoutePaths.refresh) {
      return AppColors.gray0;
    }
    if (path.startsWith('${AppRoutePaths.settings}/') ||
        path == AppRoutePaths.settings) {
      return AppColors.gray50;
    }
    return AppColors.background;
  }
}
