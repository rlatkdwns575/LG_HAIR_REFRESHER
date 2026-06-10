import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/model/measure_result_status_item.dart';

/// 냄새/먼지 관리 상태 행 (점 + 라벨 + 배지).
class MeasureResultStatusRow extends StatelessWidget {
  const MeasureResultStatusRow({required this.items, super.key});

  final List<MeasureResultStatusItem> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.sm,
      children: [for (final item in items) _StatusItem(item: item)],
    );
  }
}

class _StatusItem extends StatelessWidget {
  const _StatusItem({required this.item});

  final MeasureResultStatusItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: item.dotColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          item.categoryLabel,
          style: AppTextStyles.bodyM2.copyWith(color: AppColors.gray800),
        ),
        const SizedBox(width: 6),
        DecoratedBox(
          decoration: BoxDecoration(
            color: item.badgeBackgroundColor,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              item.badgeLabel,
              style: AppTextStyles.labelS.copyWith(color: item.badgeTextColor),
            ),
          ),
        ),
      ],
    );
  }
}
