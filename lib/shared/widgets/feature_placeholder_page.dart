import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

class FeaturePlaceholderPage extends StatelessWidget {
  const FeaturePlaceholderPage({
    required this.title,
    required this.description,
    required this.items,
    super.key,
  });

  final String title;
  final String description;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacingExtension>()!;

    return ListView(
      padding: spacing.pagePadding,
      children: [
        Text(title, style: AppTextStyles.headlineMedium),
        const SizedBox(height: AppSpacing.sm),
        Text(description, style: AppTextStyles.bodyMedium),
        const SizedBox(height: AppSpacing.lg),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: Text(item),
              ),
            ),
          ),
      ],
    );
  }
}
