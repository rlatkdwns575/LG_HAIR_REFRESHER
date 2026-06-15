import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/app_badge.dart';

/// 요약 영역 Before/After % 막대 한 쌍.
class RefreshResultMetricPair {
  const RefreshResultMetricPair({
    required this.label,
    required this.beforePercent,
    required this.afterPercent,
    this.highlightAfter = true,
  });

  final String label;
  final double beforePercent;
  final double afterPercent;

  /// false 이면 After 막대를 회색(변화 없음)으로 표시합니다.
  final bool highlightAfter;
}

/// 상태 섹션 인사이트 카드.
class RefreshResultStatusInsight {
  const RefreshResultStatusInsight({
    required this.badgeLabel,
    required this.description,
    this.backgroundColor = AppColors.gray50,
    this.badgeBackgroundColor = AppColors.gray0,
    this.badgeTextColor = AppColors.primary500,
    this.badgeBorderColor = AppColors.primary500,
  });

  final String badgeLabel;
  final String description;
  final Color backgroundColor;
  final Color badgeBackgroundColor;
  final Color badgeTextColor;
  final Color badgeBorderColor;
}

/// Before → After 상태 변화 한 줄.
class RefreshResultStatusChange {
  const RefreshResultStatusChange({
    required this.label,
    required this.beforeLabel,
    required this.afterLabel,
    this.beforeVariant = AppBadgeSmallVariant.gray,
    this.afterVariant = AppBadgeSmallVariant.medium,
    this.beforeStyle = AppBadgeStyle.text,
    this.afterStyle = AppBadgeStyle.text,
    this.showHelpIcon = false,
    this.helpTooltipMessage,
  });

  final String label;
  final String beforeLabel;
  final String afterLabel;
  final AppBadgeSmallVariant beforeVariant;
  final AppBadgeSmallVariant afterVariant;
  final AppBadgeStyle beforeStyle;
  final AppBadgeStyle afterStyle;
  final bool showHelpIcon;
  final String? helpTooltipMessage;
}

/// 모발 상태 등 단일 배지 행.
class RefreshResultHairMetric {
  const RefreshResultHairMetric({
    required this.label,
    required this.valueLabel,
    this.variant = AppBadgeSmallVariant.gray,
    this.style = AppBadgeStyle.filled,
    this.showHelpIcon = false,
    this.helpTooltipMessage,
  });

  final String label;
  final String valueLabel;
  final AppBadgeSmallVariant variant;
  final AppBadgeStyle style;
  final bool showHelpIcon;
  final String? helpTooltipMessage;
}

/// 상태 섹션 (냄새 / 먼지 / 모발).
class RefreshResultStatusSection {
  const RefreshResultStatusSection({
    required this.title,
    required this.description,
    required this.insight,
    this.changes = const [],
    this.hairMetrics = const [],
  });

  final String title;
  final String description;
  final RefreshResultStatusInsight insight;
  final List<RefreshResultStatusChange> changes;
  final List<RefreshResultHairMetric> hairMetrics;
}

/// Figma 1170-16711 / 1182-20490 — 리프레시 결과 상세보기 데이터.
class RefreshResultDetail {
  const RefreshResultDetail({
    required this.modeName,
    required this.necessityReductionPercent,
    required this.currentCareNeedPercent,
    required this.metrics,
    required this.summaryMessage,
    required this.odorSection,
    required this.dustSection,
    required this.hairSection,
  });

  final String modeName;
  final double necessityReductionPercent;
  final double currentCareNeedPercent;
  final List<RefreshResultMetricPair> metrics;
  final String summaryMessage;
  final RefreshResultStatusSection odorSection;
  final RefreshResultStatusSection dustSection;
  final RefreshResultStatusSection hairSection;

  /// 냄새 상태 — 인지 가능도 ? 툴팁.
  static const odorPerceptionHelpTooltip =
      '잔여 냄새 반응을 기준으로, 가까운 거리에서 냄새가 '
      '얼마나 쉽게 인지될 수 있는지 분석한 값이에요.';

  /// 요약 그래프 — 리프레시 필요도 ? 툴팁.
  static const necessityHelpTooltip =
      '냄새, 먼지, 모발 컨디션을 종합해 리프레시가 '
      '얼마나 필요한지 보여줘요. 60% 이상이면 '
      '케어 권장 구간으로 표시돼요.';

  String get necessityReductionLabel {
    final value = necessityReductionPercent;
    if (value == value.roundToDouble()) {
      return '${value.toInt()}%';
    }
    return '${value.toStringAsFixed(1)}%';
  }

  String get currentCareNeedLabel {
    final value = currentCareNeedPercent;
    if (value == value.roundToDouble()) {
      return '${value.toInt()}%';
    }
    return '${value.toStringAsFixed(1)}%';
  }

  /// Figma 기준 mock.
  static const sample = RefreshResultDetail(
    modeName: '외출 후 집중 리프레시 모드',
    necessityReductionPercent: 40.9,
    currentCareNeedPercent: 35,
    metrics: [
      RefreshResultMetricPair(
        label: '냄새 케어 필요도',
        beforePercent: 66,
        afterPercent: 26,
      ),
      RefreshResultMetricPair(
        label: '먼지 케어 필요도',
        beforePercent: 76,
        afterPercent: 36,
      ),
      RefreshResultMetricPair(
        label: '모발 컨디션 영향도',
        beforePercent: 30,
        afterPercent: 30,
        highlightAfter: false,
      ),
    ],
    summaryMessage: '진단 시 권장 기준을 넘었던 냄새와 먼지 지표가\n리프레시 후 기준 아래로 내려갔어요.',
    odorSection: RefreshResultStatusSection(
      title: '냄새 상태',
      description: '냄새 제거 단계 후 머리카락에 남은 냄새 반응을 확인했어요.',
      insight: RefreshResultStatusInsight(
        badgeLabel: '권장 기준 아래',
        badgeBackgroundColor: AppColors.gray0,
        badgeTextColor: AppColors.primary500,
        badgeBorderColor: AppColors.primary300,
        description:
            '모발 사이에 머물던 냄새를 공기 흐름으로 덜어냈어요. '
            '리프레시 후 잔여 냄새 반응이 낮아져, 가까운 거리에서\n'
            '인지될 가능성도 줄었어요.',
      ),
      changes: [
        RefreshResultStatusChange(
          label: '잔여 냄새 수준',
          beforeLabel: '보통',
          beforeVariant: AppBadgeSmallVariant.gray,
          afterLabel: '낮음',
          afterVariant: AppBadgeSmallVariant.low,
        ),
        RefreshResultStatusChange(
          label: '인지 가능도',
          beforeLabel: '높음',
          beforeVariant: AppBadgeSmallVariant.gray,
          afterLabel: '낮음',
          afterVariant: AppBadgeSmallVariant.low,
          showHelpIcon: true,
          helpTooltipMessage: odorPerceptionHelpTooltip,
        ),
        RefreshResultStatusChange(
          label: '잔류 가능성',
          beforeLabel: '보통',
          beforeVariant: AppBadgeSmallVariant.gray,
          afterLabel: '낮음',
          afterVariant: AppBadgeSmallVariant.low,
        ),
      ],
    ),
    dustSection: RefreshResultStatusSection(
      title: '먼지 상태',
      description: '리프레시 후 모발 표면에 남은 먼지 반응을 확인했어요.',
      insight: RefreshResultStatusInsight(
        badgeLabel: '일부 잔여',
        description:
            '리프레시 중 모발 표면에 붙은 외부 먼지를 공기 흐름으로 분리하고, '
            '전체 모발을 가볍게 정리했어요.\n'
            '그 결과 넓게 퍼져 있던 미세 입자 흔적이 줄어, '
            '외출 후 남은 먼지 부담이 완화됐어요.',
        badgeTextColor: AppColors.green700,
        badgeBorderColor: AppColors.green700,
      ),
      changes: [
        RefreshResultStatusChange(
          label: '먼지량',
          beforeLabel: '높음',
          beforeVariant: AppBadgeSmallVariant.gray,
          afterLabel: '낮음',
          afterVariant: AppBadgeSmallVariant.low,
        ),
        RefreshResultStatusChange(
          label: '분포 범위',
          beforeLabel: '높음',
          beforeVariant: AppBadgeSmallVariant.gray,
          afterLabel: '낮음',
          afterVariant: AppBadgeSmallVariant.low,
        ),
      ],
    ),
    hairSection: RefreshResultStatusSection(
      title: '모발 상태',
      description: '모발 상태를 바탕으로 리프레시 강도와 마무리 방식을 조절했어요.',
      insight: RefreshResultStatusInsight(
        badgeLabel: '맞춤 조절 적용',
        badgeBackgroundColor: AppColors.gray0,
        badgeTextColor: AppColors.primary500,
        badgeBorderColor: AppColors.primary300,
        description:
            '모발 컨디션 영향이 낮아, 리프레시 강도를 과하게 높이지 않았어요.\n'
            '냄새와 먼지 제거는 집중적으로 진행했어요.',
      ),
      hairMetrics: [
        RefreshResultHairMetric(
          label: '오염 잔류 영향',
          valueLabel: '보통',
          variant: AppBadgeSmallVariant.medium,
          style: AppBadgeStyle.text,
          showHelpIcon: true,
          helpTooltipMessage:
              '손상도, 유분량, 수분감을 바탕으로 냄새와 먼지가 모발에 '
              '얼마나 오래 남기 쉬운지 분석한 값이에요.',
        ),
        RefreshResultHairMetric(
          label: '모발 손상도',
          valueLabel: '낮음',
          variant: AppBadgeSmallVariant.low,
          style: AppBadgeStyle.text,
        ),
        RefreshResultHairMetric(
          label: '모발 굵기',
          valueLabel: '얇음',
          variant: AppBadgeSmallVariant.gray,
          style: AppBadgeStyle.text,
        ),
      ],
    ),
  );
}
