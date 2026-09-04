import '../../features/home/data/model/environment_snapshot.dart';
import '../../features/measure/data/model/measure_result_record.dart';
import 'refresh_recommend_basis.dart';
import 'refresh_recommend_schedule_snapshot.dart';

/// Gemini user prompt용 통합 입력 컨텍스트.
class RefreshRecommendInput {
  const RefreshRecommendInput({
    required this.basis,
    required this.environment,
    this.measure,
    this.schedule,
  });

  final RefreshRecommendBasis basis;
  final EnvironmentSnapshot environment;
  final MeasureResultRecord? measure;
  final RefreshRecommendScheduleSnapshot? schedule;

  bool get includesMeasure => measure != null;

  bool get includesSchedule => schedule != null && schedule!.hasEventsToday;

  String buildSignature() {
    final measurePart = includesMeasure ? measure!.measureId : '';
    final env = environment.toPromptJson();
    final envPart =
        '${env['temperature_celsius']}|${env['humidity_percent']}|'
        '${env['is_raining']}|${env['is_snowing']}';
    final schedulePart = includesSchedule ? schedule!.fingerprint : '';
    return '${basis.name}|$measurePart|$envPart|$schedulePart';
  }
}
