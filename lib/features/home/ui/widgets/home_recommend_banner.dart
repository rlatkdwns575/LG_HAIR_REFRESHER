import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_component_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/home_assets.dart';
import '../../../../shared/widgets/app_recommend_card.dart';
import '../../../../shared/widgets/app_text.dart';

/// Figma `card_recommend` (1244:25476) — 330×62, sparkle + 추천 문구.
class HomeRecommendBanner extends StatelessWidget {
  const HomeRecommendBanner({required this.message, this.onTap, super.key});

  static const bannerHeight = 62.0;
  static const _sparkleSize = 24.0;
  static const _borderWidth = 1.5;

  final String message;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: bannerHeight,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.gray0,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: GradientBoxBorder(
                gradient: LinearGradient(
                  begin: const Alignment(-0.2, 0.9),
                  end: const Alignment(0.8, 0.1),
                  colors: [
                    AppComponentColors.recommendCardBorderStart,
                    AppComponentColors.recommendCardBorderEnd,
                  ],
                ),
                width: _borderWidth,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
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
        ),
      ),
    );
  }
}
