/// 앱 전역 route path·name 상수.
///
/// path는 [GoRouter] 등록과 [context.go]/[context.push]에 사용하고,
/// name은 [context.goNamed] / [context.pushNamed]에 사용합니다.
class AppRoutePaths {
  const AppRoutePaths._();

  /// 홈 허브 (하단 탭 없음 — 홈에서 버튼/리스트로 이동)
  static const home = '/';
  static const measure = '/measure';
  static const measureRun = '/measure/run';
  static const measureResult = '/measure/result';

  static const refresh = '/refresh';
  static const refreshProgress = '/refresh/progress';
  static const refreshResult = '/refresh/result';
  static const refreshCustomCreate = '/refresh/custom/new';
  static const history = '/history';
  static const settings = '/settings';

  static const widgetGallery = '/dev/widgets';
}

class AppRouteNames {
  const AppRouteNames._();

  static const home = 'home';
  static const measure = 'measure';
  static const measureRun = 'measureRun';
  static const measureResult = 'measureResult';

  static const refresh = 'refresh';
  static const refreshProgress = 'refreshProgress';
  static const refreshResult = 'refreshResult';
  static const refreshCustomCreate = 'refreshCustomCreate';
  static const history = 'history';
  static const settings = 'settings';
  static const widgetGallery = 'widgetGallery';
}
