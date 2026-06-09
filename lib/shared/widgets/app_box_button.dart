import 'package:flutter/material.dart';

import '../../app/theme/app_component_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_text_styles.dart';

enum AppBoxButtonSize { large, medium, small }

enum AppBoxButtonVariant { active, line, text, disabled }

class AppBoxButton extends StatelessWidget {
  const AppBoxButton({
    required this.label,
    required this.onPressed,
    this.size = AppBoxButtonSize.large,
    this.variant = AppBoxButtonVariant.active,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppBoxButtonSize size;
  final AppBoxButtonVariant variant;

  static const double _height = 48;

  bool get _isDisabled =>
      variant == AppBoxButtonVariant.disabled || onPressed == null;

  @override
  Widget build(BuildContext context) {
    final resolvedVariant = _isDisabled
        ? AppBoxButtonVariant.disabled
        : variant;

    return SizedBox(
      width: _widthForSize(size),
      height: _height,
      child: TextButton(
        onPressed: _isDisabled ? null : onPressed,
        style: _styleFor(resolvedVariant),
        child: Text(
          label,
          style: AppTextStyles.labelL.copyWith(
            color: _textColorFor(resolvedVariant),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  double? _widthForSize(AppBoxButtonSize buttonSize) {
    return switch (buttonSize) {
      AppBoxButtonSize.large => double.infinity,
      AppBoxButtonSize.medium => 276,
      AppBoxButtonSize.small => 144,
    };
  }

  ButtonStyle _styleFor(AppBoxButtonVariant buttonVariant) {
    return switch (buttonVariant) {
      AppBoxButtonVariant.active => TextButton.styleFrom(
        backgroundColor: AppComponentColors.buttonActiveBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      AppBoxButtonVariant.line => TextButton.styleFrom(
        backgroundColor: AppComponentColors.buttonLineBackground,
        foregroundColor: AppComponentColors.buttonLineText,
        side: const BorderSide(color: AppComponentColors.buttonLineBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      AppBoxButtonVariant.text => TextButton.styleFrom(
        backgroundColor: AppComponentColors.buttonTextBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      AppBoxButtonVariant.disabled => TextButton.styleFrom(
        backgroundColor: AppComponentColors.buttonDisabledBackground,
        disabledBackgroundColor: AppComponentColors.buttonDisabledBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    };
  }

  Color _textColorFor(AppBoxButtonVariant buttonVariant) {
    return switch (buttonVariant) {
      AppBoxButtonVariant.active => AppComponentColors.buttonActiveText,
      AppBoxButtonVariant.line => AppComponentColors.buttonLineText,
      AppBoxButtonVariant.text => AppComponentColors.buttonTextText,
      AppBoxButtonVariant.disabled => AppComponentColors.buttonDisabledText,
    };
  }
}
