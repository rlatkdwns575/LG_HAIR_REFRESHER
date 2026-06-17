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

  static const double _horizontalInset = 14;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalInset),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: AppText(
                    metric.label,
                    style: AppTextStyles.bodyS.copyWith(
                      color: AppColors.gray900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (metric.showHelpIcon && metric.helpMessage != null) ...[
                  const SizedBox(width: 2),
                  AppMetricHelpIcon(
                    tooltipMessage: metric.helpMessage!,
                    placement: AppMetricHelpTooltipPlacement.besideIcon,
                  ),
                ],
              ],
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
