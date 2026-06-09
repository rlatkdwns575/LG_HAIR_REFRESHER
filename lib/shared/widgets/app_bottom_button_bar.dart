import 'package:flutter/material.dart';

import '../../app/theme/app_component_colors.dart';
import '../../app/theme/app_spacing.dart';
import 'app_box_button.dart';

enum AppBottomButtonBarType { oneButton, twoButtons }

/// Figma `button_bottom` — fixed bottom action bar with 1 or 2 box buttons.
class AppBottomButtonBar extends StatelessWidget {
  const AppBottomButtonBar({
    required this.primaryLabel,
    required this.onPrimaryPressed,
    this.type = AppBottomButtonBarType.oneButton,
    this.secondaryLabel,
    this.onSecondaryPressed,
    super.key,
  });

  final AppBottomButtonBarType type;
  final String primaryLabel;
  final VoidCallback? onPrimaryPressed;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppComponentColors.bottomBarBackground,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: type == AppBottomButtonBarType.oneButton
              ? AppBoxButton(
                  label: primaryLabel,
                  onPressed: onPrimaryPressed,
                  size: AppBoxButtonSize.large,
                )
              : Row(
                  children: [
                    Expanded(
                      child: AppBoxButton(
                        label: secondaryLabel ?? '버튼명',
                        onPressed: onSecondaryPressed,
                        size: AppBoxButtonSize.medium,
                        variant: AppBoxButtonVariant.disabled,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppBoxButton(
                        label: primaryLabel,
                        onPressed: onPrimaryPressed,
                        size: AppBoxButtonSize.medium,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
