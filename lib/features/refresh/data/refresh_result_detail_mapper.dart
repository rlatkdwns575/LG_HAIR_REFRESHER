import '../../../../shared/utils/metric_badge_mapper.dart';
import '../../../../shared/widgets/app_badge.dart';
import 'model/refresh_pollution_level.dart';
import 'model/refresh_result.dart';
import 'model/refresh_result_detail.dart';

/// [RefreshResult] / 기록 요약 필드 → [RefreshResultDetail] 변환.
class RefreshResultDetailMapper {
  const RefreshResultDetailMapper._();

  static RefreshResultDetail fromRefreshResult(RefreshResult result) {
    final odorBefore = _percentFromPollution(result.odorChange.beforeLevel);
    final odorAfter = _percentFromPollution(result.odorChange.afterLevel);
    final dustBefore = _percentFromPollution(result.dustChange.beforeLevel);
    final dustAfter = _percentFromPollution(result.dustChange.afterLevel);

    return RefreshResultDetail(
      modeName: _modeNameFromResult(result),
      necessityReductionPercent: result.overallImprovementPercent,
      currentCareNeedPercent: _average([odorAfter, dustAfter]),
      metrics: [
        RefreshResultMetricPair(
          label: '냄새 케어 필요도',
          beforePercent: odorBefore,
          afterPercent: odorAfter,
        ),
        RefreshResultMetricPair(
          label: '먼지 케어 필요도',
          beforePercent: dustBefore,
          afterPercent: dustAfter,
        ),
        const RefreshResultMetricPair(
          label: '모발 컨디션 영향도',
          beforePercent: 30,
          afterPercent: 30,
          highlightAfter: false,
        ),
      ],
      summaryMessage: RefreshResultDetail.sample.summaryMessage,
      odorSection: _odorSection(
        before: result.odorChange.beforeLevel,
        after: result.odorChange.afterLevel,
      ),
      dustSection: _dustSection(
        before: result.dustChange.beforeLevel,
        after: result.dustChange.afterLevel,
      ),
      hairSection: RefreshResultDetail.sample.hairSection,
    );
  }

  static RefreshResultDetail fromRecordSummary({
    required String modeName,
    double? necessityReductionPercent,
    String? odorBeforeLabel,
    String? odorAfterLabel,
    String? dustBeforeLabel,
    String? dustAfterLabel,
  }) {
    final odorBefore = _percentFromLabel(odorBeforeLabel) ?? 66;
    final odorAfter = _percentFromLabel(odorAfterLabel) ?? 26;
    final dustBefore = _percentFromLabel(dustBeforeLabel) ?? 76;
    final dustAfter = _percentFromLabel(dustAfterLabel) ?? 36;

    return RefreshResultDetail(
      modeName: modeName,
      necessityReductionPercent: necessityReductionPercent ?? 40.9,
      currentCareNeedPercent: _average([odorAfter, dustAfter]),
      metrics: [
        RefreshResultMetricPair(
          label: '냄새 케어 필요도',
          beforePercent: odorBefore,
          afterPercent: odorAfter,
        ),
        RefreshResultMetricPair(
          label: '먼지 케어 필요도',
          beforePercent: dustBefore,
          afterPercent: dustAfter,
        ),
        const RefreshResultMetricPair(
          label: '모발 컨디션 영향도',
          beforePercent: 30,
          afterPercent: 30,
          highlightAfter: false,
        ),
      ],
      summaryMessage: RefreshResultDetail.sample.summaryMessage,
      odorSection: _odorSectionFromLabels(
        odorBeforeLabel: odorBeforeLabel,
        odorAfterLabel: odorAfterLabel,
      ),
      dustSection: _dustSectionFromLabels(
        dustBeforeLabel: dustBeforeLabel,
        dustAfterLabel: dustAfterLabel,
      ),
      hairSection: RefreshResultDetail.sample.hairSection,
    );
  }

  static RefreshResultStatusSection _odorSection({
    required RefreshPollutionLevel before,
    required RefreshPollutionLevel after,
  }) {
    final beforeScore = _scoreFromPollution(before);
    final afterScore = _scoreFromPollution(after);

    return RefreshResultStatusSection(
      title: RefreshResultDetail.sample.odorSection.title,
      description: RefreshResultDetail.sample.odorSection.description,
      insight: RefreshResultDetail.sample.odorSection.insight,
      changes: [
        _makeScoreChange(
          label: '잔여 냄새 수준',
          beforeScore: beforeScore,
          afterScore: afterScore,
        ),
        _makeScoreChange(
          label: '인지 가능도',
          beforeScore: beforeScore,
          afterScore: afterScore,
          usePerceptionScore: true,
          showHelpIcon: true,
          helpTooltipMessage: RefreshResultDetail.odorPerceptionHelpTooltip,
        ),
        _makeScoreChange(
          label: '잔류 가능성',
          beforeScore: beforeScore,
          afterScore: afterScore,
        ),
      ],
    );
  }

  static RefreshResultStatusSection _odorSectionFromLabels({
    String? odorBeforeLabel,
    String? odorAfterLabel,
  }) {
    final beforeScore = _scoreFromLabel(odorBeforeLabel) ?? 66;
    final afterScore = _scoreFromLabel(odorAfterLabel) ?? 26;

    return RefreshResultStatusSection(
      title: RefreshResultDetail.sample.odorSection.title,
      description: RefreshResultDetail.sample.odorSection.description,
      insight: RefreshResultDetail.sample.odorSection.insight,
      changes: [
        _makeScoreChange(
          label: '잔여 냄새 수준',
          beforeScore: beforeScore,
          afterScore: afterScore,
        ),
        _makeScoreChange(
          label: '인지 가능도',
          beforeScore: beforeScore,
          afterScore: afterScore,
          usePerceptionScore: true,
          showHelpIcon: true,
          helpTooltipMessage: RefreshResultDetail.odorPerceptionHelpTooltip,
        ),
        _makeScoreChange(
          label: '잔류 가능성',
          beforeScore: beforeScore,
          afterScore: afterScore,
        ),
      ],
    );
  }

  static RefreshResultStatusSection _dustSection({
    required RefreshPollutionLevel before,
    required RefreshPollutionLevel after,
  }) {
    final beforeScore = _scoreFromPollution(before);
    final afterScore = _scoreFromPollution(after);

    return RefreshResultStatusSection(
      title: RefreshResultDetail.sample.dustSection.title,
      description: RefreshResultDetail.sample.dustSection.description,
      insight: RefreshResultDetail.sample.dustSection.insight,
      changes: [
        _makeScoreChange(
          label: '먼지량',
          beforeScore: beforeScore,
          afterScore: afterScore,
        ),
        _makeScoreChange(
          label: '분포 범위',
          beforeScore: beforeScore,
          afterScore: afterScore,
        ),
      ],
    );
  }

  static RefreshResultStatusSection _dustSectionFromLabels({
    String? dustBeforeLabel,
    String? dustAfterLabel,
  }) {
    final beforeScore = _scoreFromLabel(dustBeforeLabel) ?? 76;
    final afterScore = _scoreFromLabel(dustAfterLabel) ?? 36;

    return RefreshResultStatusSection(
      title: RefreshResultDetail.sample.dustSection.title,
      description: RefreshResultDetail.sample.dustSection.description,
      insight: RefreshResultDetail.sample.dustSection.insight,
      changes: [
        _makeScoreChange(
          label: '먼지량',
          beforeScore: beforeScore,
          afterScore: afterScore,
        ),
        _makeScoreChange(
          label: '분포 범위',
          beforeScore: beforeScore,
          afterScore: afterScore,
        ),
      ],
    );
  }

  static RefreshResultStatusChange _makeScoreChange({
    required String label,
    required int beforeScore,
    required int afterScore,
    bool usePerceptionScore = false,
    bool showHelpIcon = false,
    String? helpTooltipMessage,
  }) {
    final resolvedBeforeScore = usePerceptionScore
        ? MetricBadgeMapper.pollutionScoreStepUp(beforeScore)
        : beforeScore;
    final resolvedAfterScore = usePerceptionScore
        ? MetricBadgeMapper.pollutionScoreStepUp(afterScore)
        : afterScore;

    return RefreshResultStatusChange(
      label: label,
      beforeLabel: MetricBadgeMapper.pollutionScoreLabel(resolvedBeforeScore),
      afterLabel: MetricBadgeMapper.pollutionScoreLabel(resolvedAfterScore),
      showHelpIcon: showHelpIcon,
      helpTooltipMessage: helpTooltipMessage,
      beforeVariant: AppBadgeSmallVariant.gray,
      beforeStyle: AppBadgeStyle.text,
      afterStyle: AppBadgeStyle.text,
      afterVariant: MetricBadgeMapper.pollutionScoreVariant(resolvedAfterScore),
    );
  }

  static String _modeNameFromResult(RefreshResult result) {
    final modeName = result.recommendedMode?.name;
    if (modeName != null && modeName.isNotEmpty) {
      return modeName;
    }
    if (result.isScentCareResult) {
      return '향기 케어';
    }
    return '리프레시 모드';
  }

  static int _scoreFromPollution(RefreshPollutionLevel level) {
    return _percentFromPollution(level).round();
  }

  static int? _scoreFromLabel(String? label) {
    return _percentFromLabel(label)?.round();
  }

  static double _percentFromPollution(RefreshPollutionLevel level) {
    return switch (level) {
      RefreshPollutionLevel.veryHigh => 90,
      RefreshPollutionLevel.high => 76,
      RefreshPollutionLevel.normal => 45,
      RefreshPollutionLevel.good => 26,
    };
  }

  static double? _percentFromLabel(String? label) {
    return switch (label) {
      '좋음' => 26,
      '보통' => 45,
      '권장' => 60,
      '집중권장' => 80,
      '집중필요' => 92,
      '불필요' => 15,
      '높음' => 76,
      '매우높음' || '매우 높음' => 90,
      '낮음' => 26,
      _ => null,
    };
  }

  static double _average(List<double> values) {
    if (values.isEmpty) {
      return 0;
    }
    return values.reduce((a, b) => a + b) / values.length;
  }
}
