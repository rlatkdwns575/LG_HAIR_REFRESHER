import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/korean_date_time_format.dart';
import '../../../../shared/widgets/app_text.dart';

/// 진단 상세 화면 상단 타이틀 + 안내 문구 (Figma 40000056:19035).
class MeasureResultDetailHeader extends StatelessWidget {
  const MeasureResultDetailHeader({this.historyCompletedAt, super.key});

  final DateTime? historyCompletedAt;

  String get _subtitle {
    final completedAt = historyCompletedAt;
    if (completedAt != null) {
      return formatKoreanCompletionLabel(completedAt);
    }
    return '진단 결과는 리프레시 기록에서 확인할 수 있어요.';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          '진단 결과',
          style: AppTextStyles.titleL.copyWith(color: AppColors.gray900),
        ),
        const SizedBox(height: 6),
        AppText(
          _subtitle,
          style: AppTextStyles.labelM.copyWith(color: AppColors.gray500),
        ),
      ],
    );
  }
}
