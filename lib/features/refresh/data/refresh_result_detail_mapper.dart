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
      modeName: result.recommendedMode?.name ?? '리프레시',
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
    return RefreshResultStatusSection(
      title: RefreshResultDetail.sample.odorSection.title,
      description: RefreshResultDetail.sample.odorSection.description,
      insight: RefreshResultDetail.sample.odorSection.insight,
      changes: [
        _makeChange(
          label: '잔여 냄새 수준',
          beforeLabel: _odorRemainBeforeFromPollution(before),
          beforeVariant: AppBadgeSmallVariant.gray,
          afterLabel: _odorRemainAfterFromPollution(after),
          afterVariant: _afterVariantFromPollution(after),
        ),
        _makeChange(
          label: '인지 가능도',
          beforeLabel: _perceptionLabel(before),
          beforeVariant: AppBadgeSmallVariant.gray,
          afterLabel: _perceptionLabel(after),
          afterVariant: _afterVariantFromPollution(after),
          showHelpIcon: true,
          helpTooltipMessage: RefreshResultDetail.odorPerceptionHelpTooltip,
        ),
        _makeChange(
          label: '잔류 가능성',
          beforeLabel: _residualLabel(before),
          beforeVariant: AppBadgeSmallVariant.gray,
          afterLabel: _residualAfterFromPollution(after),
          afterVariant: AppBadgeSmallVariant.low,
        ),
      ],
    );
  }

  static RefreshResultStatusSection _odorSectionFromLabels({
    String? odorBeforeLabel,
    String? odorAfterLabel,
  }) {
    return RefreshResultStatusSection(
      title: RefreshResultDetail.sample.odorSection.title,
      description: RefreshResultDetail.sample.odorSection.description,
      insight: RefreshResultDetail.sample.odorSection.insight,
      changes: [
        _makeChange(
          label: '잔여 냄새 수준',
          beforeLabel: _odorRemainBeforeLabel(odorBeforeLabel),
          beforeVariant: AppBadgeSmallVariant.gray,
          afterLabel: _odorRemainAfterLabel(odorAfterLabel),
          afterVariant: _variantFromLabel(odorAfterLabel),
        ),
        _makeChange(
          label: '인지 가능도',
          beforeLabel: _perceptionFromLabel(odorBeforeLabel),
          beforeVariant: AppBadgeSmallVariant.gray,
          afterLabel: _perceptionFromLabel(odorAfterLabel),
          afterVariant: _variantFromLabel(odorAfterLabel),
          showHelpIcon: true,
          helpTooltipMessage: RefreshResultDetail.odorPerceptionHelpTooltip,
        ),
        _makeChange(
          label: '잔류 가능성',
          beforeLabel: _residualFromLabel(odorBeforeLabel),
          beforeVariant: AppBadgeSmallVariant.gray,
          afterLabel: _residualAfterFromLabel(odorAfterLabel),
          afterVariant: AppBadgeSmallVariant.low,
        ),
      ],
    );
  }

  static String _odorRemainBeforeFromPollution(RefreshPollutionLevel level) {
    return switch (level) {
      RefreshPollutionLevel.veryHigh || RefreshPollutionLevel.high => '높음',
      RefreshPollutionLevel.normal => '보통',
      RefreshPollutionLevel.good => '낮음',
    };
  }

  static String _odorRemainAfterFromPollution(RefreshPollutionLevel level) {
    return switch (level) {
      RefreshPollutionLevel.good || RefreshPollutionLevel.normal => '보통',
      _ => '높음',
    };
  }

  static String _residualAfterFromPollution(RefreshPollutionLevel level) {
    return switch (level) {
      RefreshPollutionLevel.good || RefreshPollutionLevel.normal => '낮음',
      _ => '보통',
    };
  }

  static String _odorRemainBeforeLabel(String? label) {
    return switch (label) {
      '집중필요' || '집중권장' || '권장' || '높음' || '매우높음' || '매우 높음' => '높음',
      '보통' => '보통',
      _ => '높음',
    };
  }

  static String _odorRemainAfterLabel(String? label) {
    return switch (label) {
      '좋음' || '낮음' || '불필요' || '보통' => '보통',
      _ => '보통',
    };
  }

  static String _residualAfterFromLabel(String? label) {
    return switch (label) {
      '좋음' || '낮음' || '불필요' || '보통' => '낮음',
      _ => '낮음',
    };
  }

  static RefreshResultStatusSection _dustSection({
    required RefreshPollutionLevel before,
    required RefreshPollutionLevel after,
  }) {
    return RefreshResultStatusSection(
      title: RefreshResultDetail.sample.dustSection.title,
      description: RefreshResultDetail.sample.dustSection.description,
      insight: RefreshResultDetail.sample.dustSection.insight,
      changes: [
        _makeChange(
          label: '먼지량',
          beforeLabel: _dustAmountFromPollution(before),
          beforeVariant: AppBadgeSmallVariant.gray,
          afterLabel: _dustAmountAfterFromPollution(after),
          afterVariant: _dustAfterVariant(_dustAmountAfterFromPollution(after)),
        ),
        _makeChange(
          label: '분포 범위',
          beforeLabel: _dustRangeBeforeFromPollution(before),
          beforeVariant: AppBadgeSmallVariant.gray,
          afterLabel: '낮음',
          afterVariant: AppBadgeSmallVariant.low,
        ),
      ],
    );
  }

  static RefreshResultStatusSection _dustSectionFromLabels({
    String? dustBeforeLabel,
    String? dustAfterLabel,
  }) {
    return RefreshResultStatusSection(
      title: RefreshResultDetail.sample.dustSection.title,
      description: RefreshResultDetail.sample.dustSection.description,
      insight: RefreshResultDetail.sample.dustSection.insight,
      changes: [
        _makeChange(
          label: '먼지량',
          beforeLabel: _dustAmountBeforeLabel(dustBeforeLabel),
          beforeVariant: AppBadgeSmallVariant.gray,
          afterLabel: _dustAmountAfterLabel(dustAfterLabel),
          afterVariant: _dustAfterVariant(
            _dustAmountAfterLabel(dustAfterLabel),
          ),
        ),
        _makeChange(
          label: '분포 범위',
          beforeLabel: '넓음',
          beforeVariant: AppBadgeSmallVariant.gray,
          afterLabel: '낮음',
          afterVariant: AppBadgeSmallVariant.low,
        ),
      ],
    );
  }

  static String _dustAmountFromPollution(RefreshPollutionLevel level) {
    return switch (level) {
      RefreshPollutionLevel.veryHigh || RefreshPollutionLevel.high => '높음',
      RefreshPollutionLevel.normal => '보통',
      RefreshPollutionLevel.good => '낮음',
    };
  }

  static String _dustAmountAfterFromPollution(RefreshPollutionLevel level) {
    return switch (level) {
      RefreshPollutionLevel.good || RefreshPollutionLevel.normal => '낮음',
      _ => '보통',
    };
  }

  static String _dustRangeBeforeFromPollution(RefreshPollutionLevel level) {
    return switch (level) {
      RefreshPollutionLevel.veryHigh || RefreshPollutionLevel.high => '넓음',
      _ => '보통',
    };
  }

  static String _dustAmountBeforeLabel(String? label) {
    return switch (label) {
      '집중필요' || '집중권장' || '권장' || '높음' || '매우높음' || '매우 높음' => '높음',
      '보통' || 'normal' => '보통',
      _ => '높음',
    };
  }

  static String _dustAmountAfterLabel(String? label) {
    return switch (label) {
      '좋음' || '낮음' || '불필요' => '낮음',
      _ => '낮음',
    };
  }

  static AppBadgeSmallVariant _dustAfterVariant(String afterLabel) {
    return afterLabel == '보통'
        ? AppBadgeSmallVariant.medium
        : AppBadgeSmallVariant.low;
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

  static AppBadgeSmallVariant _afterVariantFromPollution(
    RefreshPollutionLevel level, {
    bool preferLow = false,
  }) {
    if (preferLow && level == RefreshPollutionLevel.good) {
      return AppBadgeSmallVariant.low;
    }
    return switch (level) {
      RefreshPollutionLevel.normal => AppBadgeSmallVariant.medium,
      RefreshPollutionLevel.good => AppBadgeSmallVariant.low,
      _ => AppBadgeSmallVariant.medium,
    };
  }

  static AppBadgeSmallVariant _variantFromLabel(
    String? label, {
    bool preferLow = false,
  }) {
    if (label == null) {
      return AppBadgeSmallVariant.high;
    }
    if (preferLow && (label == '좋음' || label == '낮음')) {
      return AppBadgeSmallVariant.low;
    }
    return switch (label) {
      '좋음' || '낮음' => AppBadgeSmallVariant.low,
      '보통' || '권장' => AppBadgeSmallVariant.medium,
      '집중권장' || '높음' => AppBadgeSmallVariant.high,
      '집중필요' || '매우높음' || '매우 높음' => AppBadgeSmallVariant.veryHigh,
      '불필요' => AppBadgeSmallVariant.gray,
      _ => AppBadgeSmallVariant.high,
    };
  }

  static String _perceptionLabel(RefreshPollutionLevel level) {
    return switch (level) {
      RefreshPollutionLevel.veryHigh => '매우높음',
      RefreshPollutionLevel.high => '높음',
      RefreshPollutionLevel.normal => '보통',
      RefreshPollutionLevel.good => '낮음',
    };
  }

  static String _residualLabel(RefreshPollutionLevel level) {
    return switch (level) {
      RefreshPollutionLevel.veryHigh || RefreshPollutionLevel.high => '매우높음',
      RefreshPollutionLevel.normal => '보통',
      RefreshPollutionLevel.good => '낮음',
    };
  }

  static String _perceptionFromLabel(String? label) {
    return switch (label) {
      '집중필요' || '집중권장' => '매우높음',
      '권장' || '높음' => '높음',
      '보통' => '보통',
      '좋음' || '낮음' || '불필요' => '낮음',
      _ => '높음',
    };
  }

  static String _residualFromLabel(String? label, {bool preferLow = false}) {
    if (preferLow) {
      return switch (label) {
        '좋음' || '낮음' || '불필요' => '낮음',
        '보통' || '권장' => '보통',
        _ => '매우높음',
      };
    }
    return _perceptionFromLabel(label);
  }

  static RefreshResultStatusChange _makeChange({
    required String label,
    required String beforeLabel,
    required String afterLabel,
    AppBadgeSmallVariant? beforeVariant,
    AppBadgeSmallVariant? afterVariant,
    bool preferLowAfter = false,
    bool showHelpIcon = false,
    String? helpTooltipMessage,
  }) {
    return RefreshResultStatusChange(
      label: label,
      beforeLabel: beforeLabel,
      afterLabel: afterLabel,
      showHelpIcon: showHelpIcon,
      helpTooltipMessage: helpTooltipMessage,
      beforeVariant: beforeVariant ?? _beforeVariantFromLabel(beforeLabel),
      beforeStyle: AppBadgeStyle.text,
      afterStyle: AppBadgeStyle.text,
      afterVariant:
          afterVariant ??
          _variantFromLabel(afterLabel, preferLow: preferLowAfter),
    );
  }

  static AppBadgeSmallVariant _beforeVariantFromLabel(String label) {
    return switch (label) {
      '매우높음' || '매우 높음' => AppBadgeSmallVariant.veryHigh,
      '높음' || '집중필요' || '집중권장' => AppBadgeSmallVariant.high,
      '넓음' || '권장' || '보통' => AppBadgeSmallVariant.gray,
      '낮음' || '좋음' || '불필요' => AppBadgeSmallVariant.low,
      _ => AppBadgeSmallVariant.gray,
    };
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

  static double _average(List<double> values) {
    if (values.isEmpty) {
      return 0;
    }
    return values.reduce((a, b) => a + b) / values.length;
  }
}
