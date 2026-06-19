import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_text.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

/// 리프레시 결과 화면 상단 타이틀 + 안내 문구.
class RefreshResultHeader extends StatelessWidget {
  const RefreshResultHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          '리프레시 결과',
          style: AppTextStyles.titleL.copyWith(
            color: AppColors.gray800,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppText(
          '리프레시 결과는 리프레시 기록에서 확인할 수 있습니다.',
          style: AppTextStyles.bodyS.copyWith(color: AppColors.gray500),
        ),
      ],
    );
  }
}
