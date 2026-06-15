import 'model/refresh_mode.dart';

const _presetCategoryOrder = [
  RefreshModeTabs.beforeOuting,
  RefreshModeTabs.afterOuting,
  RefreshModeTabs.weather,
  RefreshModeTabs.etc,
];

bool _isCustomMode(RefreshMode mode) => mode.isCustom || mode.createdByUser;

int _categoryOrderIndex(String category) {
  final index = _presetCategoryOrder.indexOf(category);
  return index >= 0 ? index : _presetCategoryOrder.length;
}

int _compareByDuration(RefreshMode a, RefreshMode b) =>
    a.durationSeconds.compareTo(b.durationSeconds);

int _compareByCategoryThenDuration(RefreshMode a, RefreshMode b) {
  final categoryCompare = _categoryOrderIndex(
    a.category,
  ).compareTo(_categoryOrderIndex(b.category));
  if (categoryCompare != 0) {
    return categoryCompare;
  }
  return _compareByDuration(a, b);
}

int _compareByCreatedAtDesc(RefreshMode a, RefreshMode b) {
  final aTime = a.createdAt;
  final bTime = b.createdAt;
  if (aTime == null && bTime == null) {
    return 0;
  }
  if (aTime == null) {
    return 1;
  }
  if (bTime == null) {
    return -1;
  }
  return bTime.compareTo(aTime);
}

/// 칩 탭 기준 리프레시 모드 필터·정렬.
List<RefreshMode> filterRefreshModes({
  required List<RefreshMode> allModes,
  required String selectedTab,
}) {
  if (selectedTab == RefreshModeTabs.allTab) {
    return allModes.where((mode) => !_isCustomMode(mode)).toList()
      ..sort(_compareByCategoryThenDuration);
  }

  if (selectedTab == RefreshModeTabs.customModeTab) {
    return allModes.where(_isCustomMode).toList()
      ..sort(_compareByCreatedAtDesc);
  }

  return allModes.where((mode) => mode.category == selectedTab).toList()
    ..sort(_compareByDuration);
}
