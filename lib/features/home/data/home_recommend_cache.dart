/// 홈 추천 배너 문구 캐시 (Weather + Gemini/fallback 결과).
///
/// 홈 재진입 시 외부 API 호출을 줄이기 위해 1시간 동안 동일 문구를 재사용합니다.
class HomeRecommendCache {
  HomeRecommendCache._();

  static final HomeRecommendCache instance = HomeRecommendCache._();

  static const cacheTtl = Duration(hours: 1);

  String? _message;
  DateTime? _cachedAt;

  bool get hasValidCache =>
      _message != null &&
      _cachedAt != null &&
      DateTime.now().difference(_cachedAt!) < cacheTtl;

  String? get message => hasValidCache ? _message : null;

  void save(String message) {
    final trimmed = message.trim();
    if (trimmed.isEmpty) {
      return;
    }

    _message = trimmed;
    _cachedAt = DateTime.now();
  }

  void clear() {
    _message = null;
    _cachedAt = null;
  }
}
