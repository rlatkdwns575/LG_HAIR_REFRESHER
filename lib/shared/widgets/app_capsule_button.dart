import 'package:flutter/material.dart';

import '../../app/theme/app_component_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_text_styles.dart';

enum AppCapsuleButtonIconPosition { left, right }

class AppCapsuleButton extends StatelessWidget {
  const AppCapsuleButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.iconPosition = AppCapsuleButtonIconPosition.left,
    this.enabled = true,
    this.useGradient = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppCapsuleButtonIconPosition iconPosition;
  final bool enabled;
  final bool useGradient;

  @override
  Widget build(BuildContext context) {
    final isDisabled = !enabled || onPressed == null;
    final textStyle = AppTextStyles.labelM.copyWith(
      color: isDisabled
          ? AppComponentColors.capsuleDisabledText
          : AppComponentColors.capsuleActiveText,
    );

    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null &&
            iconPosition == AppCapsuleButtonIconPosition.left) ...[
          Icon(icon, size: 16, color: textStyle.color),
          const SizedBox(width: 4),
        ],
        Text(label, style: textStyle),
        if (icon != null &&
            iconPosition == AppCapsuleButtonIconPosition.right) ...[
          const SizedBox(width: 4),
          Icon(icon, size: 16, color: textStyle.color),
        ],
      ],
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onPressed,
        borderRadius: BorderRadius.circular(AppRadius.chip),
        child: Ink(
          height: icon == null ? 32 : 36,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.chip),
            color: isDisabled
                ? AppComponentColors.capsuleDisabledBackground
                : (useGradient
                      ? null
                      : AppComponentColors.capsuleGradientStart),
            gradient: isDisabled || !useGradient
                ? null
                : AppComponentColors.capsuleGradient,
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}
