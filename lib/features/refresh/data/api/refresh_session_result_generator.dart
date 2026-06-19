import 'dart:math';

import '../../../measure/data/model/measure_result_record.dart';
import '../model/refresh_mode.dart';
import '../model/refresh_pollution_level.dart';
import '../model/refresh_result.dart';
import '../model/refresh_result_change.dart';
import '../model/refresh_session_outcome.dart';
import '../refresh_result_headline_builder.dart';
import '../refresh_mode_catalog.dart';

/// 리프레시 완료 시 before/after 점수와 개선율을 생성합니다.
class RefreshSessionResultGenerator {
  const RefreshSessionResultGenerator();

  static const int minRemovalTenths = 300;
  static const int maxRemovalTenths = 400;
  static const int minAfterScore = 18;
  static const int odorBeforeMin = 60;
  static const int odorBeforeMax = 80;
  static const int dustBeforeMin = 55;
  static const int dustBeforeMax = 75;
  static const int defaultScentPollutionScore = 20;

  RefreshSessionOutcome generate({
    required RefreshMode mode,
    MeasureResultRecord? baseline,
    Random? random,
  }) {
    final rng = random ?? Random.secure();

    if (mode.isScentOnlyCare) {
      final pollutionScore =
          baseline?.totalPollutionScore ??
          RefreshSessionResultGenerator.defaultScentPollutionScore;
      final headline = RefreshResultHeadlineBuilder.forMode(mode);
      return RefreshSessionOutcome(
        result: _buildScentOnlyResult(headline),
        scores: RefreshSessionScores(
          pollutionBefore: pollutionScore,
          pollutionAfter: pollutionScore,
          overallImprovementPercent: 0,
        ),
        measureId: baseline?.measureId,
      );
    }

    int? odorBefore;
    int? odorAfter;
    double? odorRemoval;
    int? dustBefore;
    int? dustAfter;
    double? dustRemoval;

    if (mode.odorYn) {
      odorBefore = _resolveBeforeScore(
        measureScore: baseline?.hairOdorScore,
        min: odorBeforeMin,
        max: odorBeforeMax,
        random: rng,
      );
      odorRemoval = sampleRemoval(rng);
      odorAfter = computeAfterScore(
        before: odorBefore,
        removalPercent: odorRemoval,
      );
    }

    if (mode.dustYn) {
      dustBefore = _resolveBeforeScore(
        measureScore: baseline?.hairDustScore,
        min: dustBeforeMin,
        max: dustBeforeMax,
        random: rng,
      );
      dustRemoval = sampleRemoval(rng);
      dustAfter = computeAfterScore(
        before: dustBefore,
        removalPercent: dustRemoval,
      );
    }

    final overall = computeOverallImprovement(
      odorRemoval: odorRemoval,
      dustRemoval: dustRemoval,
    );
    final pollutionBefore = computePollutionScore(
      odor: odorBefore,
      dust: dustBefore,
      fallback: baseline?.totalPollutionScore,
    );
    final pollutionAfter = computePollutionScore(
      odor: odorAfter,
      dust: dustAfter,
      fallback: pollutionBefore,
    );

    final headline = RefreshResultHeadlineBuilder.forMode(mode);

    final result = RefreshResult(
      dustRemovalPercent: dustRemoval ?? 0,
      odorRemovalPercent: odorRemoval ?? 0,
      overallImprovementPercent: overall,
      headlineBefore: headline.before,
      headlineAfter: headline.after,
      disclaimer: '',
      dustChange: RefreshResultChange(
        label: '먼지',
        beforeLevel: pollutionLevelFromScore(dustBefore ?? dustBeforeMin),
        afterLevel: pollutionLevelFromScore(dustAfter ?? minAfterScore),
        beforeScore: dustBefore,
        afterScore: dustAfter,
      ),
      odorChange: RefreshResultChange(
        label: '냄새',
        beforeLevel: pollutionLevelFromScore(odorBefore ?? odorBeforeMin),
        afterLevel: pollutionLevelFromScore(odorAfter ?? minAfterScore),
        beforeScore: odorBefore,
        afterScore: odorAfter,
      ),
      odorBeforeScore: odorBefore,
      odorAfterScore: odorAfter,
      dustBeforeScore: dustBefore,
      dustAfterScore: dustAfter,
      recommendedMode: RefreshResult.shouldRecommendScentCare(mode)
          ? resolveScentCareMode()
          : null,
    );

    return RefreshSessionOutcome(
      result: result,
      scores: RefreshSessionScores(
        odorBefore: odorBefore,
        odorAfter: odorAfter,
        dustBefore: dustBefore,
        dustAfter: dustAfter,
        pollutionBefore: pollutionBefore,
        pollutionAfter: pollutionAfter,
        odorRemovalPercent: odorRemoval,
        dustRemovalPercent: dustRemoval,
        overallImprovementPercent: overall,
      ),
      measureId: baseline?.measureId,
    );
  }

  static double sampleRemoval(Random random) {
    final tenths =
        minRemovalTenths +
        random.nextInt(maxRemovalTenths - minRemovalTenths + 1);
    return tenths / 10.0;
  }

  static double roundImprovement(double value) =>
      (value * 10).roundToDouble() / 10.0;

  static int computeAfterScore({
    required int before,
    required double removalPercent,
  }) {
    return (before * (1 - removalPercent / 100)).round().clamp(
      minAfterScore,
      100,
    );
  }

  static double computeOverallImprovement({
    required double? odorRemoval,
    required double? dustRemoval,
  }) {
    final values = <double>[?odorRemoval, ?dustRemoval];
    if (values.isEmpty) {
      return 0;
    }
    return roundImprovement(values.reduce((a, b) => a + b) / values.length);
  }

  /// `MEASURE_RESULTS.total_pollution_score`와 동일하게 활성 축 중 최대값.
  static int computePollutionScore({int? odor, int? dust, int? fallback}) {
    final values = <int>[?odor, ?dust];
    if (values.isNotEmpty) {
      return values.reduce(max);
    }
    return (fallback ?? defaultScentPollutionScore).clamp(0, 100);
  }

  static RefreshPollutionLevel pollutionLevelFromScore(int score) {
    if (score <= 25) {
      return RefreshPollutionLevel.good;
    }
    if (score <= 45) {
      return RefreshPollutionLevel.normal;
    }
    if (score <= 85) {
      return RefreshPollutionLevel.high;
    }
    return RefreshPollutionLevel.veryHigh;
  }

  static int _resolveBeforeScore({
    required int? measureScore,
    required int min,
    required int max,
    required Random random,
  }) {
    if (measureScore != null) {
      return measureScore.clamp(0, 100);
    }
    return min + random.nextInt(max - min + 1);
  }

  static RefreshResult _buildScentOnlyResult(
    ({String before, String after}) headline,
  ) {
    return RefreshResult(
      dustRemovalPercent: 0,
      odorRemovalPercent: 0,
      overallImprovementPercent: 100,
      headlineBefore: headline.before,
      headlineAfter: headline.after,
      disclaimer: '',
      dustChange: const RefreshResultChange(
        label: '먼지',
        beforeLevel: RefreshPollutionLevel.good,
        afterLevel: RefreshPollutionLevel.good,
      ),
      odorChange: const RefreshResultChange(
        label: '냄새',
        beforeLevel: RefreshPollutionLevel.good,
        afterLevel: RefreshPollutionLevel.good,
      ),
      showChangeChart: false,
      isScentCareResult: true,
      showImprovementPercent: false,
    );
  }
}
