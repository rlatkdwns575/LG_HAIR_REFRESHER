import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/app_box_button.dart';

class MeasurePrepareBottomBar extends StatelessWidget {
  const MeasurePrepareBottomBar({
    required this.label,
    required this.enabled,
    this.onPressed,
    super.key,
  });

  final String label;
  final bool enabled;
  final VoidCallback? onPressed;

  static const double _horizontalPadding = 15;
  static const double _topPadding = 10;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            _horizontalPadding,
            _topPadding,
            _horizontalPadding,
            AppSpacing.sm,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: SizedBox(
              key: ValueKey(enabled),
              width: double.infinity,
              child: AppBoxButton(
                label: label,
                onPressed: enabled ? onPressed : null,
                variant: enabled
                    ? AppBoxButtonVariant.active
                    : AppBoxButtonVariant.disabled,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
