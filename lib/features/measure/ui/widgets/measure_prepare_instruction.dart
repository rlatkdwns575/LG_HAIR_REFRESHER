import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import 'measure_skeleton_box.dart';

class MeasurePrepareInstruction extends StatelessWidget {
  const MeasurePrepareInstruction({
    required this.title,
    this.subtitle,
    this.isLoading = false,
    super.key,
  });

  final String title;
  final String? subtitle;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: MeasureSkeletonBox(width: double.infinity, height: 26),
          ),
          SizedBox(height: AppSpacing.xs),
          MeasureSkeletonBox(width: 240, height: 20),
        ],
      );
    }

    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.titleL.copyWith(color: AppColors.textPrimary),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyM1.copyWith(color: AppColors.gray500),
          ),
        ],
      ],
    );
  }
}
