import 'package:flutter/material.dart';

import '../../app/theme/app_component_colors.dart';
import '../../app/theme/app_radius.dart';

enum AppCapsuleIconButtonVariant { active, secondary }

/// Figma `Button_Capsule_IconOnly` — 24×24 gradient icon button.
class AppCapsuleIconButton extends StatelessWidget {
  const AppCapsuleIconButton({
    required this.onPressed,
    this.icon = Icons.arrow_forward_ios,
    this.variant = AppCapsuleIconButtonVariant.active,
    this.enabled = true,
    super.key,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final AppCapsuleIconButtonVariant variant;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final isDisabled = !enabled || onPressed == null;
    final useGradient =
        !isDisabled && variant == AppCapsuleIconButtonVariant.active;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onPressed,
        borderRadius: BorderRadius.circular(AppRadius.chip),
        child: Ink(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.chip),
            color: isDisabled
                ? AppComponentColors.capsuleDisabledBackground
                : (useGradient
                      ? null
                      : AppComponentColors.capsuleIconOnlySecondary),
            gradient: useGradient ? AppComponentColors.capsuleGradient : null,
          ),
          child: Icon(
            icon,
            size: 12,
            color: isDisabled
                ? AppComponentColors.capsuleDisabledText
                : AppComponentColors.capsuleActiveText,
          ),
        ),
      ),
    );
  }
}
