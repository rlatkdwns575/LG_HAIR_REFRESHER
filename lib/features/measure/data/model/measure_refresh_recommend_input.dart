import '../../../refresh/data/model/refresh_mode.dart';
import 'schedule_category.dart';
import 'schedule_timing.dart';

/// 규칙 기반 리프레시 모드 추천 입력값.
class MeasureRefreshRecommendInput {
  const MeasureRefreshRecommendInput({
    required this.odorPollution,
    required this.dustPollution,
    required this.totalPollution,
    required this.temperatureCelsius,
    required this.humidityPercent,
    required this.isPrecipitating,
    required this.scheduleCategory,
    required this.scheduleTiming,
    required this.now,
    required this.candidates,
  });

  final double odorPollution;
  final double dustPollution;
  final double totalPollution;
  final double temperatureCelsius;
  final int humidityPercent;
  final bool isPrecipitating;
  final ScheduleCategory scheduleCategory;
  final ScheduleTiming scheduleTiming;
  final DateTime now;
  final List<RefreshMode> candidates;
}
