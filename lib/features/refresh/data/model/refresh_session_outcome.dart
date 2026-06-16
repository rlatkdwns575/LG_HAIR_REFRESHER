import 'refresh_result.dart';

/// `REFRESH_SESSIONS` INSERT에 사용하는 before/after 점수와 개선율.
class RefreshSessionScores {
  const RefreshSessionScores({
    this.odorBefore,
    this.odorAfter,
    this.dustBefore,
    this.dustAfter,
    this.pollutionBefore,
    this.pollutionAfter,
    this.odorRemovalPercent,
    this.dustRemovalPercent,
    required this.overallImprovementPercent,
  });

  final int? odorBefore;
  final int? odorAfter;
  final int? dustBefore;
  final int? dustAfter;

  /// `REFRESH_SESSIONS.pollution_score_before/after` (종합 오염 점수).
  final int? pollutionBefore;
  final int? pollutionAfter;

  /// 활성 축별 개선율(%). 소수점 1자리.
  final double? odorRemovalPercent;
  final double? dustRemovalPercent;
  final double overallImprovementPercent;
}

/// 생성기 출력: UI·DB·내역이 동일한 데이터를 공유합니다.
class RefreshSessionOutcome {
  const RefreshSessionOutcome({
    required this.result,
    required this.scores,
    this.measureId,
  });

  final RefreshResult result;
  final RefreshSessionScores scores;
  final String? measureId;
}
