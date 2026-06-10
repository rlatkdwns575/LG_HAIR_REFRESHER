import 'package:flutter/material.dart';

import '../../../../app/theme/app_component_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_recommend_card.dart';

/// Figma `card_recommend` (710:17764) — 날씨·환경 안내 배너.
class HomeRecommendBanner extends StatelessWidget {
  const HomeRecommendBanner({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppComponentColors.recommendCardGradientStart.withValues(
              alpha: 0.6,
            ),
            AppComponentColors.recommendCardGradientEnd.withValues(alpha: 0.6),
          ],
        ),
        border: GradientBoxBorder(
          gradient: LinearGradient(
            begin: const Alignment(-0.2, 0.9),
            end: const Alignment(0.8, 0.1),
            colors: [
              AppComponentColors.recommendCardBorderStart,
              AppComponentColors.recommendCardBorderEnd,
            ],
          ),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 10,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppComponentColors.badgeSmallPrimaryLightBackground,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.nights_stay_outlined,
                size: 18,
                color: AppComponentColors.badgeSmallPrimaryText,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyXs.copyWith(
                  color: AppComponentColors.recommendCardText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
