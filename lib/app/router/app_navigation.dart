import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/route_paths.dart';

/// 화면에서 route path 문자열을 직접 쓰지 않고 이동할 때 사용합니다.
///
/// 홈 허브에서 하위 화면으로 갈 때는 [push] 계열을 사용해 뒤로가기가 동작하게 합니다.
extension AppNavigation on BuildContext {
  void goHome() => go(AppRoutePaths.home);

  void pushMeasure() => push(AppRoutePaths.measure);

  void pushRefresh() => push(AppRoutePaths.refresh);

  void pushHistory() => push(AppRoutePaths.history);

  void pushSettings() => push(AppRoutePaths.settings);

  void pushWidgetGallery() => push(AppRoutePaths.widgetGallery);

  void goHomeNamed() => goNamed(AppRouteNames.home);

  void pushMeasureNamed() => pushNamed(AppRouteNames.measure);

  void pushRefreshNamed() => pushNamed(AppRouteNames.refresh);

  void pushHistoryNamed() => pushNamed(AppRouteNames.history);

  void pushSettingsNamed() => pushNamed(AppRouteNames.settings);

  void pushWidgetGalleryNamed() => pushNamed(AppRouteNames.widgetGallery);
}
