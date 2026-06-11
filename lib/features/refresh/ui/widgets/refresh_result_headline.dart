import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/model/refresh_result.dart';

/// 리프레시 결과 상단 개선율 메시지.
class RefreshResultHeadline extends StatelessWidget {
  const RefreshResultHeadline({required this.result, super.key});

  final RefreshResult result;

  static final TextStyle _messageStyle = AppTextStyles.titleL.copyWith(
    color: AppColors.gray800,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle _percentStyle = AppTextStyles.headlineL.copyWith(
    color: AppColors.primary500,
    fontWeight: FontWeight.w700,
    height: 1.1,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          result.headlineBefore,
          textAlign: TextAlign.center,
          style: _messageStyle,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text.rich(
          TextSpan(
            style: _messageStyle,
            children: [
              TextSpan(
                text: result.overallImprovementLabel,
                style: _percentStyle,
              ),
              TextSpan(text: ' ${result.headlineAfter}'),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          result.disclaimer,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyS.copyWith(color: AppColors.gray500),
        ),
      ],
    );
  }
}
