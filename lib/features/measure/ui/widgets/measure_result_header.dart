import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_text.dart';

/// 진단 결과 화면 상단 타이틀 + 안내 문구.
class MeasureResultHeader extends StatelessWidget {
  const MeasureResultHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          '진단 결과',
          style: AppTextStyles.titleL.copyWith(
            color: AppColors.gray800,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        AppText(
          '진단 결과는 리프레시 기록에서 확인할 수 있어요.',
          style: AppTextStyles.bodyXs.copyWith(color: AppColors.gray500),
        ),
      ],
    );
  }
}
