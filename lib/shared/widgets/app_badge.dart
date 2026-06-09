import 'package:flutter/material.dart';

import '../../app/theme/app_component_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_text_styles.dart';

enum AppBadgeSize { small, large }

enum AppBadgeSmallVariant {
  gray,
  primary,
  primaryLight,
  low,
  medium,
  high,
  veryHigh,
}

enum AppBadgeLargeVariant {
  refreshNotNeeded,
  refreshSelected,
  focusedRecommend,
  focusedRequired,
  refreshRecommend,
}

enum AppBadgeStyle { text, filled }

class AppBadge extends StatelessWidget {
  const AppBadge({
    required this.label,
    this.size = AppBadgeSize.small,
    this.smallVariant = AppBadgeSmallVariant.gray,
    this.largeVariant = AppBadgeLargeVariant.refreshNotNeeded,
    this.style = AppBadgeStyle.text,
    super.key,
  });

  final String label;
  final AppBadgeSize size;
  final AppBadgeSmallVariant smallVariant;
  final AppBadgeLargeVariant largeVariant;
  final AppBadgeStyle style;

  @override
  Widget build(BuildContext context) {
    if (size == AppBadgeSize.large) {
      return _buildLarge();
    }
    return _buildSmall();
  }

  Widget _buildSmall() {
    final colors = _smallColors();
    final fontSize =
        smallVariant == AppBadgeSmallVariant.primaryLight &&
            style == AppBadgeStyle.text
        ? 10.0
        : 11.0;

    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: AppTextStyles.labelXs.copyWith(
          fontSize: fontSize,
          height: 1,
          color: colors.$2,
        ),
      ),
    );
  }

  Widget _buildLarge() {
    final colors = _largeColors();

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: AppTextStyles.labelM.copyWith(color: colors.$2),
      ),
    );
  }

  (Color, Color) _smallColors() {
    if (style == AppBadgeStyle.filled) {
      return switch (smallVariant) {
        AppBadgeSmallVariant.gray => (
          AppComponentColors.badgeSmallGrayFilledBackground,
          AppComponentColors.badgeSmallGrayFilledText,
        ),
        AppBadgeSmallVariant.primary => (
          AppComponentColors.badgeSmallPrimaryFilledBackground,
          AppComponentColors.badgeSmallPrimaryFilledText,
        ),
        AppBadgeSmallVariant.primaryLight => (
          AppComponentColors.badgeSmallPrimaryFilledBackground,
          AppComponentColors.badgeSmallPrimaryFilledText,
        ),
        AppBadgeSmallVariant.low => (
          AppComponentColors.badgeSmallLowFilledBackground,
          AppComponentColors.badgeSmallLowFilledText,
        ),
        AppBadgeSmallVariant.medium => (
          AppComponentColors.badgeSmallMediumFilledBackground,
          AppComponentColors.badgeSmallMediumFilledText,
        ),
        AppBadgeSmallVariant.high => (
          AppComponentColors.badgeSmallHighFilledBackground,
          AppComponentColors.badgeSmallHighFilledText,
        ),
        AppBadgeSmallVariant.veryHigh => (
          AppComponentColors.badgeSmallVeryHighFilledBackground,
          AppComponentColors.badgeSmallVeryHighFilledText,
        ),
      };
    }

    return switch (smallVariant) {
      AppBadgeSmallVariant.gray => (
        AppComponentColors.badgeSmallGrayBackground,
        AppComponentColors.badgeSmallGrayText,
      ),
      AppBadgeSmallVariant.primary => (
        AppComponentColors.badgeSmallPrimaryBackground,
        AppComponentColors.badgeSmallPrimaryText,
      ),
      AppBadgeSmallVariant.primaryLight => (
        AppComponentColors.badgeSmallPrimaryLightBackground,
        AppComponentColors.badgeSmallPrimaryLightText,
      ),
      AppBadgeSmallVariant.low => (
        AppComponentColors.badgeSmallLowBackground,
        AppComponentColors.badgeSmallLowText,
      ),
      AppBadgeSmallVariant.medium => (
        AppComponentColors.badgeSmallMediumBackground,
        AppComponentColors.badgeSmallMediumText,
      ),
      AppBadgeSmallVariant.high => (
        AppComponentColors.badgeSmallHighBackground,
        AppComponentColors.badgeSmallHighText,
      ),
      AppBadgeSmallVariant.veryHigh => (
        AppComponentColors.badgeSmallVeryHighBackground,
        AppComponentColors.badgeSmallVeryHighText,
      ),
    };
  }

  (Color, Color) _largeColors() {
    return switch (largeVariant) {
      AppBadgeLargeVariant.refreshNotNeeded => (
        AppComponentColors.badgeLargeRefreshNotNeeded,
        AppComponentColors.badgeLargeText,
      ),
      AppBadgeLargeVariant.refreshSelected => (
        AppComponentColors.badgeLargeRefreshSelected,
        AppComponentColors.badgeLargeText,
      ),
      AppBadgeLargeVariant.focusedRecommend => (
        AppComponentColors.badgeLargeFocusedRecommend,
        AppComponentColors.badgeLargeText,
      ),
      AppBadgeLargeVariant.focusedRequired => (
        AppComponentColors.badgeLargeFocusedRequired,
        AppComponentColors.badgeLargeText,
      ),
      AppBadgeLargeVariant.refreshRecommend => (
        AppComponentColors.badgeLargeRefreshRecommend,
        AppComponentColors.badgeLargeRefreshRecommendText,
      ),
    };
  }
}
