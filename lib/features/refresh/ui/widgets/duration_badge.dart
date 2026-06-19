import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_text.dart';

import '../../../../app/theme/app_component_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/care_duration_split.dart';

/// 소요시간 배지 (Figma `badge_small` primary light).
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
        color: AppComponentColors.badgeSmallPrimaryLightBackground,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: AppText(
          '$prefix ${CareDurationSplit.formatKoreanTime(totalSeconds)}',
          style: AppTextStyles.labelS.copyWith(
            color: AppComponentColors.badgeSmallPrimaryLightText,
          ),
        ),
      ),
    );
  }
}
