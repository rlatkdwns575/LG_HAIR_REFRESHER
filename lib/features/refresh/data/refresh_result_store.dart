import 'model/refresh_mode.dart';
import 'model/refresh_result.dart';

/// 리프레시 진행 완료 → 결과 수집 → 결과 화면 사이에 결과 데이터를 전달합니다.
class RefreshResultStore {
  RefreshResultStore._();

  static final RefreshResultStore instance = RefreshResultStore._();

  RefreshResult? _pendingResult;
  RefreshMode? _pendingMode;

  void setPendingMode(RefreshMode mode) {
    _pendingMode = mode;
    _pendingResult = null;
  }

  void setPending(RefreshResult result, {RefreshMode? mode}) {
    _pendingResult = result;
    if (mode != null) {
      _pendingMode = mode;
    }
  }

  RefreshResult? peekPendingResult() => _pendingResult;

  RefreshMode? peekPendingMode() => _pendingMode;

  RefreshResult consume() {
    final result = _pendingResult ?? RefreshResult.sample;
    _pendingResult = null;
    _pendingMode = null;
    return result;
  }
}
