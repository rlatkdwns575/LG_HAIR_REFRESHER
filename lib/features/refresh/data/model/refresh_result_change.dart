import 'refresh_pollution_level.dart';

/// 리프레시 전후 단일 항목(먼지/냄새)의 상태 변화.
class RefreshResultChange {
  const RefreshResultChange({
    required this.label,
    required this.beforeLevel,
    required this.afterLevel,
  });

  final String label;
  final RefreshPollutionLevel beforeLevel;
  final RefreshPollutionLevel afterLevel;
}
