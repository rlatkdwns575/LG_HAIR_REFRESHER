import 'model/refresh_result.dart';

/// 리프레시 진행 완료 → 결과 수집 → 결과 화면 사이에 결과 데이터를 전달합니다.
///
/// 추후 API 응답 또는 [GoRouter] extra 로 대체할 수 있습니다.
class RefreshResultStore {
  RefreshResultStore._();

  static final RefreshResultStore instance = RefreshResultStore._();

  RefreshResult? _pending;

  void setPending(RefreshResult result) {
    _pending = result;
  }

  RefreshResult consume() {
    final result = _pending ?? RefreshResult.sample;
    _pending = null;
    return result;
  }
}
