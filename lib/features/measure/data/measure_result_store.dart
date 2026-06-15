import 'model/measure_result.dart';

/// 진단 분석 완료 → 결과 화면 사이에 결과 데이터를 전달합니다.
class MeasureResultStore {
  MeasureResultStore._();

  static final MeasureResultStore instance = MeasureResultStore._();

  MeasureResult? _pending;
  String? _loadError;

  void setPending(MeasureResult result) {
    _pending = result;
    _loadError = null;
  }

  void setLoadError(String message) {
    _loadError = message;
    _pending = null;
  }

  MeasureResult? peek() => _pending;

  String? consumeLoadError() {
    final error = _loadError;
    _loadError = null;
    return error;
  }

  MeasureResult? consume({MeasureResult? fallback}) {
    final result = _pending ?? fallback;
    _pending = null;
    return result;
  }
}
