import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/app_box_button.dart';
import '../../../../shared/widgets/app_fixed_bottom_button_area.dart';

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

  @override
  Widget build(BuildContext context) {
    return AppFixedBottomButtonArea(
      backgroundColor: AppColors.surface,
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
    );
  }
}
