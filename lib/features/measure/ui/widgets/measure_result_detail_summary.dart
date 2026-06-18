import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/model/measure_result_detail.dart';
import '../../../refresh/data/refresh_mode_availability.dart';
import '../../../refresh/ui/widgets/refresh_mode_card.dart';
import '../../../../shared/widgets/app_text.dart';
import 'measure_result_detail_need_bars.dart';
import '../../../../shared/widgets/app_metric_help_icon.dart';
import '../../data/api/measure_result_mapper.dart';

/// 리프레시 필요도 요약 블록 (Figma Frame 2085668905~8906).
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Headline(detail: detail),
        const SizedBox(height: AppSpacing.xl),
        MeasureResultDetailNeedBars(
          odorPercent: detail.odorNeedPercent,
          dustPercent: detail.dustNeedPercent,
          hairPercent: detail.hairImpactPercent,
          thresholdPercent: detail.recommendedThresholdPercent,
        ),
        const SizedBox(height: 12),
        const _RefreshNeedHelpRow(),
        const SizedBox(height: AppSpacing.xl),
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

  @override
  Widget build(BuildContext context) {
    final suffix = detail.exceedsThreshold ? '로 권장 기준을 넘었어요.' : '로 안정 범위예요.';

    return Padding(
      padding: const EdgeInsets.only(left: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            '리프레시 필요도가',
            style: AppTextStyles.titleM.copyWith(
              color: AppColors.gray900,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppText(
                '${detail.refreshNeedPercent}%',
                style: AppTextStyles.headlineL.copyWith(
                  fontSize: 44,
                  height: 1.1,
                  color: AppColors.gray900,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 2, bottom: 2),
                child: AppText(
                  suffix,
                  style: AppTextStyles.titleM.copyWith(
                    color: AppColors.gray900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              AppText(
                detail.refreshFocusLabel,
                style: AppTextStyles.titleM.copyWith(
                  color: AppColors.orange700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              AppText(
                '가 필요해요.',
                style: AppTextStyles.titleM.copyWith(
                  color: AppColors.gray600,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
        labelStyle: AppTextStyles.bodyS.copyWith(
          color: AppColors.gray600,
          fontWeight: FontWeight.w500,
        ),
        tooltipMessage: MeasureResultMapper.refreshNeedHelpMessage,
        size: 16,
        placement: AppMetricHelpTooltipPlacement.belowStart,
        tooltipMaxWidth: 240,
        labelIconGap: 3,
      ),
    );
  }
}
