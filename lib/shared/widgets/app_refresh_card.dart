import 'package:flutter/material.dart';

import '../../app/theme/app_component_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import 'app_badge.dart';
import 'app_capsule_icon_button.dart';

enum AppRefreshCardVariant { defaultStyle, compact, small }

/// Figma `card_refresh` — refresh mode summary card.
class AppRefreshCard extends StatelessWidget {
  const AppRefreshCard({
    required this.title,
    this.description,
    this.captionItems = const [],
    this.badgeLabel,
    this.badgeVariant = AppBadgeSmallVariant.primary,
    this.variant = AppRefreshCardVariant.defaultStyle,
    this.trailing,
    this.onTrailingPressed,
    this.onTap,
    super.key,
  });

  final String title;
  final String? description;
  final List<String> captionItems;
  final String? badgeLabel;
  final AppBadgeSmallVariant badgeVariant;
  final AppRefreshCardVariant variant;
  final Widget? trailing;
  final VoidCallback? onTrailingPressed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDefault = variant == AppRefreshCardVariant.defaultStyle;
    final isSmall = variant == AppRefreshCardVariant.small;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Ink(
          width: isSmall ? 180 : null,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDefault
                ? AppComponentColors.refreshCardDefaultBackground
                : AppComponentColors.refreshCardCompactBackground,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isDefault
                  ? AppComponentColors.refreshCardDefaultBorder
                  : AppComponentColors.refreshCardCompactBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildTitleRow(isDefault)),
                  if (trailing != null)
                    trailing!
                  else if (onTrailingPressed != null)
                    AppCapsuleIconButton(
                      onPressed: onTrailingPressed,
                      variant: isDefault
                          ? AppCapsuleIconButtonVariant.active
                          : AppCapsuleIconButtonVariant.secondary,
                    ),
                ],
              ),
              if (description != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description!,
                  style: AppTextStyles.bodyS.copyWith(
                    color: AppComponentColors.refreshCardBody,
                    height: isSmall ? 16 / 12 : 18 / 13,
                    fontSize: isSmall ? 12 : 13,
                  ),
                ),
              ],
              if (captionItems.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                _buildCaptions(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleRow(bool isDefault) {
    if (variant == AppRefreshCardVariant.compact && badgeLabel != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppBadge(
            label: badgeLabel!,
            smallVariant: badgeVariant,
            style: AppBadgeStyle.text,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: AppTextStyles.titleXs.copyWith(
              color: AppComponentColors.refreshCardTitle,
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            title,
            style: (isDefault ? AppTextStyles.titleS : AppTextStyles.titleXs)
                .copyWith(color: AppComponentColors.refreshCardTitle),
          ),
        ),
        if (badgeLabel != null) ...[
          const SizedBox(width: AppSpacing.xs),
          AppBadge(
            label: badgeLabel!,
            smallVariant: badgeVariant,
            style: AppBadgeStyle.text,
          ),
        ],
      ],
    );
  }

  Widget _buildCaptions() {
    return Wrap(
      spacing: 0,
      runSpacing: 0,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var i = 0; i < captionItems.length; i++) ...[
          if (i > 0)
            Text(
              '・',
              style: AppTextStyles.labelS.copyWith(
                color: AppComponentColors.refreshCardCaption,
              ),
            ),
          Text(
            captionItems[i],
            style: AppTextStyles.labelS.copyWith(
              color: AppComponentColors.refreshCardCaption,
            ),
          ),
        ],
      ],
    );
  }
}
