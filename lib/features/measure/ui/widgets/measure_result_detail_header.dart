import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_text.dart';

/// 진단 상세 화면 상단 타이틀 + 안내 문구 (Figma Title).
class MeasureResultDetailHeader extends StatelessWidget {
  const MeasureResultDetailHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          '헤어 상태 진단 결과',
          style: AppTextStyles.titleL.copyWith(color: AppColors.gray800),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppText(
          '진단 결과는 2시간 동안 유지되며, 이후 기록에서 확인할 수 있어요.',
          style: AppTextStyles.bodyXs.copyWith(color: AppColors.gray500),
        ),
      ],
    );
  }
}
