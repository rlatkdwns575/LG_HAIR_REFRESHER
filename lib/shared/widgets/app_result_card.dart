import 'package:flutter/material.dart';

import '../../app/theme/app_component_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import 'app_badge.dart';
import 'app_text_link_button.dart';

class AppResultCardTag {
  const AppResultCardTag({
    required this.label,
    this.badgeLabel,
    this.badgeVariant = AppBadgeSmallVariant.high,
  });

  final String label;
  final String? badgeLabel;
  final AppBadgeSmallVariant badgeVariant;
}

enum AppResultCardVariant { defaultStyle, withAction }

/// Figma `card_result` — diagnosis / refresh result summary card.
class AppResultCard extends StatelessWidget {
  const AppResultCard({
    required this.title,
    this.image,
    this.tags = const [],
    this.actionLabel,
    this.onActionPressed,
    this.variant = AppResultCardVariant.defaultStyle,
    super.key,
  });

  final String title;
  final Widget? image;
  final List<AppResultCardTag> tags;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final AppResultCardVariant variant;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 330,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppComponentColors.resultCardBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleM.copyWith(
              color: AppComponentColors.resultCardTitle,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          image ??
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: AppComponentColors.fieldBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.image_outlined,
                  color: AppComponentColors.fieldPlaceholder,
                ),
              ),
          if (tags.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.xs,
              children: tags.map(_buildTag).toList(),
            ),
          ],
          if (variant == AppResultCardVariant.withAction &&
              actionLabel != null) ...[
            const SizedBox(height: AppSpacing.md),
            AppTextLinkButton(label: actionLabel!, onPressed: onActionPressed),
          ],
        ],
      ),
    );
  }

  Widget _buildTag(AppResultCardTag tag) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppComponentColors.resultCardTagDot,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          tag.label,
          style: AppTextStyles.bodyS.copyWith(
            color: AppComponentColors.resultCardTagText,
          ),
        ),
        if (tag.badgeLabel != null) ...[
          const SizedBox(width: 4),
          AppBadge(
            label: tag.badgeLabel!,
            smallVariant: tag.badgeVariant,
            style: AppBadgeStyle.text,
          ),
        ],
      ],
    );
  }
}
