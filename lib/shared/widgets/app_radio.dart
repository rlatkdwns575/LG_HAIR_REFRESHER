import 'package:flutter/material.dart';

import '../../app/theme/app_component_colors.dart';

class AppRadio<T> extends StatelessWidget {
  const AppRadio({
    required this.value,
    required this.groupValue,
    required this.onChanged,
    super.key,
  });

  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    final enabled = onChanged != null;

    return SizedBox(
      width: 24,
      height: 24,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? () => onChanged!(value) : null,
          customBorder: const CircleBorder(),
          child: Center(
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? AppComponentColors.radioOnFill
                    : AppComponentColors.radioOffFill,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
