import '../../../core/services/auth_session_service.dart';
import '../../refresh/data/model/refresh_mode.dart';
import '../../refresh/data/refresh_mode_catalog.dart';
import 'api/home_shortcut_local_store.dart';
import 'model/home_dashboard_data.dart';
import 'model/home_favorite_mode_snapshot.dart';

/// 홈 즐겨찾기(리프레시 바로가기) 저장소.
///
/// 로그인 사용자별로 [HomeShortcutLocalStore]에 영속화합니다.
class HomeShortcutStore {
  HomeShortcutStore._();

  static final HomeShortcutStore instance = HomeShortcutStore._();

  final HomeShortcutLocalStore _localStore = const HomeShortcutLocalStore();

  RefreshMode? _favoriteMode;

  RefreshMode? get favoriteMode => _favoriteMode;

  bool get hasFavorite => _favoriteMode != null;

  HomeQuickRefreshMode? get favoriteQuickMode =>
      _favoriteMode?.toHomeQuickRefreshMode();

  /// 현재 로그인 사용자의 즐겨찾기를 로컬에서 불러옵니다.
  Future<void> loadForCurrentUser() async {
    final userId = AuthSessionService.currentUserId;
    if (userId == null) {
      _favoriteMode = null;
      return;
    }

    await loadForUser(userId);
  }

  Future<void> loadForUser(String userId) async {
    final snapshot = await _localStore.load(userId);
    if (snapshot == null) {
      _favoriteMode = null;
      return;
    }

    _favoriteMode = _resolveMode(snapshot);
  }

  Future<void> setFavorite(RefreshMode mode) async {
    _favoriteMode = mode;

    final userId = AuthSessionService.currentUserId;
    if (userId == null) {
      return;
    }

    await _localStore.save(
      userId,
      HomeFavoriteModeSnapshot.fromRefreshMode(mode),
    );
  }

  Future<void> clearFavorite() async {
    final userId = AuthSessionService.currentUserId;
    _favoriteMode = null;
    if (userId != null) {
      await _localStore.clear(userId);
    }
  }

  /// 로그아웃 시 메모리 캐시만 비웁니다. 로컬 데이터는 사용자별로 유지됩니다.
  void resetSessionCache() {
    _favoriteMode = null;
  }

  RefreshMode _resolveMode(HomeFavoriteModeSnapshot snapshot) {
    for (final mode in getAllRefreshModes()) {
      if (mode.id == snapshot.id) {
        return mode;
      }
    }
    return snapshot.toRefreshMode();
  }
}

extension RefreshModeHomeShortcut on RefreshMode {
  HomeQuickRefreshMode toHomeQuickRefreshMode() {
    return HomeQuickRefreshMode(
      title: name,
      durationLabel: durationLabel,
      captionItems: tags.isNotEmpty ? tags : [category],
      requiresScentCartridge: scentYn,
    );
  }
}
