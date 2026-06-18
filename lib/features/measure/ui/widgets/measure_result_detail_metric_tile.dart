import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_text.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../data/model/measure_result_detail_metric.dart';
import '../../../../shared/widgets/app_metric_help_icon.dart';

/// Figma Card_small — 지표 행 (좌우 여백 + 라벨·뱃지 간격).
class MeasureResultDetailMetricTile extends StatelessWidget {
  const MeasureResultDetailMetricTile({required this.metric, super.key});

  final MeasureResultDetailMetric metric;

  static const double _horizontalInset = 15;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalInset),
      child: Row(
        children: [
          Expanded(
            child: metric.showHelpIcon && metric.helpMessage != null
                ? AppMetricHelpIcon(
                    label: metric.label,
                    labelStyle: AppTextStyles.titleXs.copyWith(
                      color: AppColors.gray800,
                    ),
                    tooltipMessage: metric.helpMessage!,
                    placement: AppMetricHelpTooltipPlacement.belowEnd,
                  )
                : AppText(
                    metric.label,
                    style: AppTextStyles.titleXs.copyWith(
                      color: AppColors.gray800,
                    ),
                  ),
          ),
          const SizedBox(width: AppSpacing.md),
          _BadgeGroup(metric: metric),
        ],
      ),
    );
  }
}

class _BadgeGroup extends StatelessWidget {
  const _BadgeGroup({required this.metric});

  final MeasureResultDetailMetric metric;

  @override
  Widget build(BuildContext context) {
    if (metric.tagLabels.isEmpty) {
      return AppBadge(
        label: metric.badgeLabel,
        smallVariant: metric.badgeVariant,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final tag in metric.tagLabels) ...[
          AppBadge(label: tag, smallVariant: AppBadgeSmallVariant.gray),
          const SizedBox(width: 4),
        ],
        AppBadge(label: metric.badgeLabel, smallVariant: metric.badgeVariant),
      ],
    );
  }
}
