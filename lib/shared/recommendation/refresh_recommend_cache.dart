import 'refresh_recommend_result.dart';

/// 통합 추천 결과 캐시 (모드 + 문구 + basis).
class RefreshRecommendCache {
  RefreshRecommendCache._();

  static final RefreshRecommendCache instance = RefreshRecommendCache._();

  static const cacheTtl = Duration(hours: 1);

  RefreshRecommendResult? _result;
  DateTime? _cachedAt;
  int _calendarSyncToken = 0;

  /// 캘린더 동기화 후 UI가 추천을 다시 불러올 때 비교합니다.
  int get calendarSyncToken => _calendarSyncToken;

  bool get hasValidCache =>
      _result != null &&
      _cachedAt != null &&
      DateTime.now().difference(_cachedAt!) < cacheTtl;

  RefreshRecommendResult? get result => hasValidCache ? _result : null;

  RefreshRecommendResult? getIfValidFor(String signature) {
    final cached = result;
    if (cached == null || cached.signature != signature) {
      return null;
    }
    return cached;
  }

  void save(RefreshRecommendResult result) {
    _result = result;
    _cachedAt = DateTime.now();
  }

  void invalidate() {
    _result = null;
    _cachedAt = null;
  }

  void markCalendarSynced() {
    invalidate();
    _calendarSyncToken++;
  }
}
