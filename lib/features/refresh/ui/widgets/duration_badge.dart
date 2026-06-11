import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/care_duration_split.dart';

/// 소요시간을 파란색 계열 배지로 표시하는 재사용 위젯.
///
/// 예: `소요시간 3분` · `소요시간 2분 30초`
class DurationBadge extends StatelessWidget {
  const DurationBadge({
    required this.totalSeconds,
    this.prefix = '소요시간',
    super.key,
  });

  final int totalSeconds;
  final String prefix;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary200,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          '$prefix ${CareDurationSplit.formatKoreanTime(totalSeconds)}',
          style: AppTextStyles.labelS.copyWith(color: AppColors.primary700),
        ),
      ),
    );
  }
}
