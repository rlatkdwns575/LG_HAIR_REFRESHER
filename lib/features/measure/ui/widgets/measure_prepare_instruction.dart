import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_text.dart';

class MeasurePrepareInstruction extends StatelessWidget {
  const MeasurePrepareInstruction({
    required this.title,
    this.subtitle,
    super.key,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppText(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.titleL.copyWith(color: AppColors.textPrimary),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.xs),
          AppText(
            subtitle!,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyM1.copyWith(color: AppColors.gray500),
          ),
        ],
      ],
    );
  }
}
