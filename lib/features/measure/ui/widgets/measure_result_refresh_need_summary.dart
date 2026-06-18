import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_text.dart';

/// 진단 결과 간편보기 — 리프레시 필요도 % (Figma Body_M1 + Label_L).
class MeasureResultRefreshNeedSummary extends StatelessWidget {
  const MeasureResultRefreshNeedSummary({required this.percent, super.key});

  final int percent;

  static const _labelValueGap = 4.0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            '리프레시 필요도',
            style: AppTextStyles.bodyM1.copyWith(color: AppColors.gray900),
          ),
          const SizedBox(width: _labelValueGap),
          AppText(
            '$percent%',
            style: AppTextStyles.labelL.copyWith(color: AppColors.gray900),
          ),
        ],
      ),
    );
  }
}
