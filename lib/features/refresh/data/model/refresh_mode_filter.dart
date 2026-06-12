import 'refresh_mode.dart';

/// 칩 탭 기준 리프레시 모드 필터 및 정렬.
List<RefreshMode> filterRefreshModes({
  required List<RefreshMode> allModes,
  required String selectedTab,
}) {
  if (selectedTab == RefreshModeTabs.allTab) {
    // "전체" 탭인 경우 커스텀 모드를 제외하고 카테고리별 정렬 적용
    final sortedModes = allModes
        .where((mode) => !mode.isCustom && !mode.createdByUser)
        .toList();
    sortedModes.sort((a, b) {
      int getCategoryWeight(String category) {
        switch (category) {
          case RefreshModeTabs.beforeOuting:
            return 1;
          case RefreshModeTabs.afterOuting:
            return 2;
          case RefreshModeTabs.weather:
            return 3;
          default:
            return 4;
        }
      }

      final weightA = getCategoryWeight(a.category);
      final weightB = getCategoryWeight(b.category);

      return weightA.compareTo(weightB);
    });
    return sortedModes;
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
