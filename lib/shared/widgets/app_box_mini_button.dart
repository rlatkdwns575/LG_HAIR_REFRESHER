import 'package:flutter/material.dart';

import '../../app/theme/app_component_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_text_styles.dart';

/// Figma `Button_Box_mini` — 42×32 mini toggle chip button.
class AppBoxMiniButton extends StatelessWidget {
  const AppBoxMiniButton({
    required this.label,
    required this.selected,
    required this.onPressed,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 32,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: selected
              ? AppComponentColors.boxMiniOnBackground
              : AppComponentColors.boxMiniOffBackground,
          foregroundColor: selected
              ? AppComponentColors.boxMiniOnText
              : AppComponentColors.boxMiniOffText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.field),
            side: selected
                ? const BorderSide(color: AppComponentColors.boxMiniOnBorder)
                : BorderSide.none,
          ),
        ),
        child: Text(label, style: AppTextStyles.labelM),
      ),
    );
  }
}
