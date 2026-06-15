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

  /// 진행 세션 기반 mock 결과. 실제 API 연동 시 이 factory를 교체합니다.
  factory RefreshResult.fromProgressSession({
    required RefreshProgressSession session,
    RefreshMode? mode,
  }) {
    if (mode != null && mode.isScentOnlyCare) {
      return RefreshResult(
        dustRemovalPercent: 0,
        odorRemovalPercent: 0,
        overallImprovementPercent: 100,
        headlineBefore: '은은한 향기 케어가',
        headlineAfter: '완료되었어요.',
        disclaimer: '향기는 시간이 지나면 희미해질 수 있어요.',
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

    return RefreshResult(
      dustRemovalPercent: 87,
      odorRemovalPercent: 92,
      overallImprovementPercent: 40.9,
      headlineBefore: '외출 후 남아 있던 냄새와 먼지가',
      headlineAfter: '개선되었어요.',
      disclaimer: '외부 활동이 이어지면 냄새와 먼지가 다시 남을 수 있어요.',
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
      recommendedMode: _shouldRecommendScentCare(mode)
          ? resolveScentCareMode()
          : null,
    );
  }

  /// 실행 모드에 향기 케어가 이미 포함되면 추천하지 않습니다.
  static bool _shouldRecommendScentCare(RefreshMode? mode) {
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
      headlineBefore: '외출 후 남아 있던 냄새와 먼지가',
      headlineAfter: '개선되었어요.',
      disclaimer: '외부 활동이 이어지면 냄새와 먼지가 다시 남을 수 있어요.',
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
