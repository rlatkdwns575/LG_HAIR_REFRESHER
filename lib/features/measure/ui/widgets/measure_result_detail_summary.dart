import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/model/measure_result_detail.dart';
import '../../../refresh/data/refresh_mode_availability.dart';
import '../../../refresh/ui/widgets/refresh_mode_card.dart';
import '../../../../shared/widgets/app_text.dart';
import 'measure_result_detail_need_bars.dart';
import 'measure_result_metric_help_icon.dart';
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
        const SizedBox(height: AppSpacing.xl),
        _AnalysisSummary(detail: detail),
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
                style: AppTextStyles.bodyS.copyWith(
                  color: AppColors.orange700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              AppText(
                '가 필요해요.',
                style: AppTextStyles.bodyS.copyWith(
                  color: AppColors.gray600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnalysisSummary extends StatelessWidget {
  const _AnalysisSummary({required this.detail});

  final MeasureResultDetail detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.gray50,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: AppText(
            detail.analysisSummary,
            textAlign: TextAlign.center,
            breakLinesBySentence: true,
            style: AppTextStyles.bodyXs.copyWith(
              color: AppColors.gray900,
              height: 1.55,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText(
                '리프레시 필요도',
                style: AppTextStyles.bodyS.copyWith(
                  color: AppColors.gray600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              MeasureResultMetricHelpIcon(
                message: MeasureResultMapper.refreshNeedHelpMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
