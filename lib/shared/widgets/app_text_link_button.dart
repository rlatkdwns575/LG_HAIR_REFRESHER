import 'package:flutter/material.dart';

import '../../app/theme/app_component_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

/// Figma `Button_text` — text link with trailing chevron.
class AppTextLinkButton extends StatelessWidget {
  const AppTextLinkButton({
    required this.label,
    required this.onPressed,
    this.showChevron = true,
    this.contentPadding,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool showChevron;
  final EdgeInsetsGeometry? contentPadding;

  static const _defaultContentPadding = EdgeInsets.fromLTRB(
    AppSpacing.md,
    AppSpacing.xs,
    AppSpacing.xs,
    AppSpacing.xs,
  );

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: contentPadding ?? _defaultContentPadding,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.padded,
        foregroundColor: AppComponentColors.textLinkButton,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTextStyles.labelM),
          if (showChevron) ...[
            const SizedBox(width: 2),
            const Icon(Icons.chevron_right, size: 20),
          ],
        ],
      ),
    );
  }
}
