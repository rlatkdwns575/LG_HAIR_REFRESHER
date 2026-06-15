import '../../../refresh/data/model/refresh_mode.dart';

/// 규칙 기반 리프레시 모드 추천 결과.
class MeasureRefreshRecommendResult {
  const MeasureRefreshRecommendResult({
    required this.recommendedMode,
    required this.reason,
    required this.scores,
  });

  final RefreshMode recommendedMode;
  final String reason;
  final Map<String, double> scores;
}
