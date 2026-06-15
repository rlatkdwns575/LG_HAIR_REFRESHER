import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_badge.dart';

/// 진단 상세 분석 카드 배지 — 흰 배경 + 컬러 테두리, 글자 너비만큼만.
class MeasureResultDetailSectionBadge extends StatelessWidget {
  const MeasureResultDetailSectionBadge({
    required this.label,
    required this.variant,
    super.key,
  });

  final String label;
  final AppBadgeSmallVariant variant;

  @override
  Widget build(BuildContext context) {
    final colors = _outlineColors(variant);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.gray0,
        border: Border.all(color: colors.$1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelXs.copyWith(
          fontSize: 11,
          height: 1,
          color: colors.$2,
        ),
      ),
    );
  }

  (Color, Color) _outlineColors(AppBadgeSmallVariant variant) {
    return switch (variant) {
      AppBadgeSmallVariant.veryHigh => (AppColors.red800, AppColors.red900),
      AppBadgeSmallVariant.high => (AppColors.orange600, AppColors.orange700),
      AppBadgeSmallVariant.medium => (AppColors.green800, AppColors.green900),
      AppBadgeSmallVariant.low => (AppColors.blue800, AppColors.blue900),
      AppBadgeSmallVariant.primary => (
        AppColors.primary700,
        AppColors.primary700,
      ),
      AppBadgeSmallVariant.primaryLight => (
        AppColors.primary500,
        AppColors.primary700,
      ),
      AppBadgeSmallVariant.gray => (AppColors.gray400, AppColors.gray600),
    };
  }
}
