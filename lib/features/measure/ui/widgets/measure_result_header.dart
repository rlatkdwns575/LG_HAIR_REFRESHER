import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

/// 진단 결과 화면 상단 타이틀 + 안내 문구.
class MeasureResultHeader extends StatelessWidget {
  const MeasureResultHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '진단 결과',
          style: AppTextStyles.titleL.copyWith(
            color: AppColors.gray800,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          '진단 결과는 2시간 동안 볼 수 있으며, 이후 기록에서 확인할 수 있어요',
          style: AppTextStyles.bodyS.copyWith(color: AppColors.gray500),
        ),
      ],
    );
  }
}
