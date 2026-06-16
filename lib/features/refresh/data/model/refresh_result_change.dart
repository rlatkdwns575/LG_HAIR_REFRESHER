import 'refresh_pollution_level.dart';

/// 리프레시 전후 단일 항목(먼지/냄새)의 상태 변화.
class RefreshResultChange {
  const RefreshResultChange({
    required this.label,
    required this.beforeLevel,
    required this.afterLevel,
    this.beforeScore,
    this.afterScore,
  });

  final String label;
  final RefreshPollutionLevel beforeLevel;
  final RefreshPollutionLevel afterLevel;
  final int? beforeScore;
  final int? afterScore;

  double get beforeAxisFraction => beforeScore != null
      ? RefreshPollutionLevel.axisFractionFromScore(beforeScore!)
      : beforeLevel.axisFraction;

  double get afterAxisFraction => afterScore != null
      ? RefreshPollutionLevel.axisFractionFromScore(afterScore!)
      : afterLevel.axisFraction;
}
