import 'model/refresh_mode.dart';

/// 칩 탭 기준 리프레시 모드 필터.
List<RefreshMode> filterRefreshModes({
  required List<RefreshMode> allModes,
  required String selectedTab,
}) {
  if (selectedTab == RefreshModeTabs.allTab) {
    return allModes;
  }

  if (selectedTab == RefreshModeTabs.customMode) {
    return allModes
        .where((mode) => mode.isCustom || mode.createdByUser)
        .toList();
  }

  return allModes
      .where(
        (mode) =>
            !mode.isCustom &&
            !mode.createdByUser &&
            mode.category == selectedTab,
      )
      .toList();
}
