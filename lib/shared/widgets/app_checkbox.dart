import 'package:flutter/material.dart';

import '../../app/theme/app_component_colors.dart';

enum AppCheckboxSize { small, large }

class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    required this.value,
    required this.onChanged,
    this.size = AppCheckboxSize.large,
    super.key,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final AppCheckboxSize size;

  double get _boxSize => size == AppCheckboxSize.small ? 16 : 24;
  double get _innerSize => size == AppCheckboxSize.small ? 16 : 20;

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;

    return SizedBox(
      width: _boxSize,
      height: _boxSize,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? () => onChanged!(!value) : null,
          borderRadius: BorderRadius.circular(2),
          child: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: value
                    ? AppComponentColors.checkboxOnFill
                    : AppComponentColors.checkboxOffBackground,
                borderRadius: BorderRadius.circular(2),
                border: Border.all(
                  color: value
                      ? AppComponentColors.checkboxOnFill
                      : AppComponentColors.checkboxOffBorder,
                ),
              ),
              child: SizedBox(
                width: _innerSize,
                height: _innerSize,
                child: value
                    ? Icon(
                        Icons.check,
                        size: _innerSize - 4,
                        color: AppComponentColors.checkboxOnCheck,
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
