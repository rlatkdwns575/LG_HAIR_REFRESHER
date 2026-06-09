import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_component_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

class FeaturePlaceholderPage extends StatelessWidget {
  const FeaturePlaceholderPage({
    required this.title,
    required this.description,
    required this.items,
    this.footer,
    super.key,
  });

  final String title;
  final String description;
  final List<String> items;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacingExtension>()!;

    return ListView(
      padding: spacing.pagePadding,
      children: [
        Text(
          title,
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.gray900,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          description,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray600),
        ),
        const SizedBox(height: AppSpacing.lg),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.gray0,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gray200),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.primary500,
                ),
                title: Text(
                  item,
                  style: AppTextStyles.titleS.copyWith(
                    color: AppComponentColors.listTitle,
                  ),
                ),
              ),
            ),
          ),
        if (footer != null) ...[const SizedBox(height: AppSpacing.md), footer!],
      ],
    );
  }
}
