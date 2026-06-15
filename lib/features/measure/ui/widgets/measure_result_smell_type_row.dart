import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_badge.dart';

/// 진단 결과 요약 화면의 냄새 유형 행.
class MeasureResultSmellTypeRow extends StatelessWidget {
  const MeasureResultSmellTypeRow({required this.types, super.key});

  final List<String> types;

  @override
  Widget build(BuildContext context) {
    if (types.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '냄새 유형',
          style: AppTextStyles.bodyM2.copyWith(color: AppColors.gray800),
        ),
        const SizedBox(width: AppSpacing.sm),
        for (var i = 0; i < types.length; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          AppBadge(label: types[i], smallVariant: AppBadgeSmallVariant.gray),
        ],
      ],
    );
  }
}
