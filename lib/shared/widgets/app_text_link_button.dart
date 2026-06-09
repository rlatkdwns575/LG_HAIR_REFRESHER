import 'package:flutter/material.dart';

import '../../app/theme/app_component_colors.dart';
import '../../app/theme/app_text_styles.dart';

/// Figma `Button_text` — text link with trailing chevron.
class AppTextLinkButton extends StatelessWidget {
  const AppTextLinkButton({
    required this.label,
    required this.onPressed,
    this.showChevron = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
