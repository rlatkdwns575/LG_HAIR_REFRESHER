import '../../refresh/data/model/refresh_mode.dart';
import 'model/home_dashboard_data.dart';

/// 홈 즐겨찾기(리프레시 바로가기) 세션 store.
///
/// MVP 단계의 임시 저장소이며, 추후 `data/api` Supabase 연동으로 대체합니다.
class HomeShortcutStore {
  HomeShortcutStore._();

  static final HomeShortcutStore instance = HomeShortcutStore._();

  RefreshMode? _favoriteMode;

  RefreshMode? get favoriteMode => _favoriteMode;

  bool get hasFavorite => _favoriteMode != null;

  void setFavorite(RefreshMode mode) => _favoriteMode = mode;

  void clearFavorite() => _favoriteMode = null;

  HomeQuickRefreshMode? get favoriteQuickMode =>
      _favoriteMode?.toHomeQuickRefreshMode();
}

extension RefreshModeHomeShortcut on RefreshMode {
  HomeQuickRefreshMode toHomeQuickRefreshMode() {
    return HomeQuickRefreshMode(
      title: name,
      durationLabel: durationLabel,
      captionItems: tags.isNotEmpty ? tags : [category],
    );
  }
}
