import 'dart:math';

import '../../../measure/data/model/measure_result_record.dart';
import '../api/refresh_session_result_generator.dart';
import '../refresh_mode_catalog.dart';
import 'refresh_mode.dart';
import 'refresh_pollution_level.dart';
import 'refresh_progress_session.dart';
import 'refresh_result_change.dart';

/// 리프레시 완료 후 최종 결과 화면 데이터.
///
/// [dustRemovalPercent], [odorRemovalPercent], [overallImprovementPercent] 는
/// 추후 API 응답으로 교체할 수 있도록 분리되어 있습니다.
class RefreshResult {
  const RefreshResult({
    required this.dustRemovalPercent,
    required this.odorRemovalPercent,
    required this.overallImprovementPercent,
    required this.headlineBefore,
    required this.headlineAfter,
    required this.disclaimer,
    required this.dustChange,
    required this.odorChange,
    this.odorBeforeScore,
    this.odorAfterScore,
    this.dustBeforeScore,
    this.dustAfterScore,
    this.recommendedMode,
    this.detailLinkLabel = '리프레시 결과 자세히 보기',
    this.showChangeChart = true,
    this.isScentCareResult = false,
    this.showImprovementPercent = true,
  });

  final double dustRemovalPercent;
  final double odorRemovalPercent;
  final double overallImprovementPercent;
  final String headlineBefore;
  final String headlineAfter;
  final String disclaimer;
  final RefreshResultChange dustChange;
  final RefreshResultChange odorChange;
  final int? odorBeforeScore;
  final int? odorAfterScore;
  final int? dustBeforeScore;
  final int? dustAfterScore;
  final RefreshMode? recommendedMode;
  final String detailLinkLabel;
  final bool showChangeChart;
  final bool isScentCareResult;
  final bool showImprovementPercent;

  /// 향기 케어 모드 추천 카드 노출 여부.
  bool get showScentCareRecommendation => recommendedMode != null;

  String get overallImprovementLabel {
    final value = overallImprovementPercent;
    if (value == value.roundToDouble()) {
      return '${value.toInt()}%';
    }
    return '${value.toStringAsFixed(1)}%';
  }

  /// 진행 세션 완료 시 [RefreshSessionResultGenerator]로 결과를 생성합니다.
  factory RefreshResult.fromProgressSession({
    required RefreshProgressSession session,
    RefreshMode? mode,
    MeasureResultRecord? baseline,
    Random? random,
  }) {
    if (mode == null) {
      return RefreshResult.sample;
    }

    return RefreshSessionResultGenerator()
        .generate(mode: mode, baseline: baseline, random: random)
        .result;
  }

  /// 실행 모드에 향기 케어가 이미 포함되면 추천하지 않습니다.
  static bool shouldRecommendScentCare(RefreshMode? mode) {
    if (mode == null) {
      return true;
    }
    return !mode.scentYn;
  }

  /// Figma 622-13066 기준 mock.
  static RefreshResult get sample {
    return RefreshResult(
      dustRemovalPercent: 87,
      odorRemovalPercent: 92,
      overallImprovementPercent: 40.9,
      headlineBefore: '외출 후 집중 리프레시 모드로 남아 있던 냄새와 먼지가',
      headlineAfter: '줄어들었어요.',
      disclaimer: '',
      dustChange: const RefreshResultChange(
        label: '먼지',
        beforeLevel: RefreshPollutionLevel.high,
        afterLevel: RefreshPollutionLevel.good,
      ),
      odorChange: const RefreshResultChange(
        label: '냄새',
        beforeLevel: RefreshPollutionLevel.veryHigh,
        afterLevel: RefreshPollutionLevel.normal,
      ),
      recommendedMode: resolveScentCareMode(),
    );
  }
}
