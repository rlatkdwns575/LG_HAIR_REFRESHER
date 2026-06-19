import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../refresh/data/refresh_mode_availability.dart';
import '../../../refresh/ui/widgets/refresh_mode_card.dart';
import '../../../../shared/widgets/app_metric_help_icon.dart';
import '../../../../shared/widgets/app_text.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/api/measure_result_mapper.dart';
import '../../data/model/measure_result_detail.dart';
import 'measure_result_detail_need_bars.dart';

/// 리프레시 필요도 요약 블록 (Figma 40000056:19039~19076).
class MeasureResultDetailSummary extends StatelessWidget {
  const MeasureResultDetailSummary({
    required this.detail,
    this.onRecommendTap,
    this.isRecommendEnabled = true,
    super.key,
  });

  final MeasureResultDetail detail;
  final VoidCallback? onRecommendTap;
  final bool isRecommendEnabled;

  /// Figma 40000056:19040 — 헤드라인 ↔ 막대 그래프.
  static const double _headlineToBarsGap = 60;

  /// Figma 40000056:19039 — 막대 ↔ 도움말.
  static const double _barsToHelpGap = 20;

  /// Figma 40000056:19038 — 도움말 ↔ 추천 카드.
  static const double _helpToRecommendGap = 28;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Headline(detail: detail),
        const SizedBox(height: _headlineToBarsGap),
        MeasureResultDetailNeedBars(
          odorPercent: detail.odorNeedPercent,
          dustPercent: detail.dustNeedPercent,
          hairPercent: detail.hairImpactPercent,
          thresholdPercent: detail.recommendedThresholdPercent,
        ),
        const SizedBox(height: _barsToHelpGap),
        const _RefreshNeedHelpRow(),
        const SizedBox(height: _helpToRecommendGap),
        RefreshModeCard(
          mode: detail.recommendedMode,
          variant: RefreshModeCardVariant.featured,
          badgeLabel: '추천',
          descriptionOverride: detail.recommendReason,
          enabled: isRecommendEnabled,
          disabledReason: isRecommendEnabled
              ? null
              : RefreshModeAvailability.unavailableReason,
          onTap: onRecommendTap,
          onAction: onRecommendTap,
        ),
      ],
    );
  }
}

class _Headline extends StatelessWidget {
  const _Headline({required this.detail});

  final MeasureResultDetail detail;

  static const _horizontalInset = 15.0;

  TextStyle get _headlineLineStyle => AppTextStyles.titleS.copyWith(
    color: AppColors.gray800,
    fontWeight: FontWeight.w600,
  );

  @override
  Widget build(BuildContext context) {
    final suffix = detail.exceedsThreshold ? '로 권장 기준을 넘었어요.' : '로 안정 범위예요.';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText('리프레시 필요도가', style: _headlineLineStyle),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppText(
                '${detail.refreshNeedPercent}%',
                style: AppTextStyles.headlineL.copyWith(
                  fontSize: 48,
                  height: 1,
                  color: AppColors.gray900,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 2),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: AppText(suffix, style: _headlineLineStyle),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              AppText(
                detail.refreshFocusLabel,
                style: _headlineLineStyle.copyWith(color: AppColors.orange700),
              ),
              AppText('가 필요해요.', style: _headlineLineStyle),
            ],
          ),
        ],
      ),
    );
  }
}

class _RefreshNeedHelpRow extends StatelessWidget {
  const _RefreshNeedHelpRow();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: AppMetricHelpIcon(
        label: '리프레시 필요도',
        labelStyle: AppTextStyles.labelS.copyWith(
          color: AppColors.gray500,
          fontWeight: FontWeight.w400,
        ),
        tooltipMessage: MeasureResultMapper.refreshNeedHelpMessage,
        placement: AppMetricHelpTooltipPlacement.belowEnd,
        tooltipMaxWidth: 240,
        labelIconGap: 2,
      ),
    );
  }
}
