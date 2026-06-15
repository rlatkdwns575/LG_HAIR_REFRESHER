import 'model/measure_result.dart';

/// 진단 분석 완료 → 결과 화면 사이에 결과 데이터를 전달합니다.
class MeasureResultStore {
  MeasureResultStore._();

  static final MeasureResultStore instance = MeasureResultStore._();

  MeasureResult? _pending;

  void setPending(MeasureResult result) {
    _pending = result;
  }

  MeasureResult? peek() => _pending;

  MeasureResult consume({MeasureResult? fallback}) {
    final result = _pending ?? fallback ?? MeasureResult.sample;
    _pending = null;
    return result;
  }
}
