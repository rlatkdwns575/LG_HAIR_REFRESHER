import 'package:flutter/material.dart';

import '../../../../app/theme/app_component_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/home_assets.dart';
import '../../../../shared/widgets/app_recommend_card.dart';
import '../../../../shared/widgets/app_text.dart';

/// Figma `card_recommend` (631:18545) — 330×52, sparkle + 추천 문구.
class HomeRecommendBanner extends StatelessWidget {
  const HomeRecommendBanner({required this.message, super.key});

  static const bannerHeight = 52.0;
  static const _sparkleSize = 16.0;

  final String message;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: bannerHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppComponentColors.recommendCardGradientStart.withValues(
                alpha: 0.6,
              ),
              AppComponentColors.recommendCardGradientEnd.withValues(
                alpha: 0.6,
              ),
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
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                HomeAssets.recommendSparkleIcon,
                width: _sparkleSize,
                height: _sparkleSize,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppText(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyXs.copyWith(
                    color: AppComponentColors.recommendCardText,
                    height: 16 / 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
