import 'package:flutter/material.dart';

import '../../app/theme/app_component_colors.dart';

enum AppToggleSize { small, large }

class AppToggle extends StatelessWidget {
  const AppToggle({
    required this.value,
    required this.onChanged,
    this.size = AppToggleSize.small,
    super.key,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final AppToggleSize size;

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    final trackWidth = size == AppToggleSize.small ? 34.0 : 48.0;
    final trackHeight = size == AppToggleSize.small ? 18.0 : 30.0;
    final thumbSize = size == AppToggleSize.small ? 14.0 : 24.0;
    final thumbPadding = size == AppToggleSize.small ? 2.0 : 3.0;

    return GestureDetector(
      onTap: enabled ? () => onChanged!(!value) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: trackWidth,
        height: trackHeight,
        padding: EdgeInsets.all(thumbPadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(trackHeight / 2),
          color: value
              ? AppComponentColors.toggleTrackOn
              : AppComponentColors.toggleTrackOff,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: thumbSize,
            height: thumbSize,
            decoration: const BoxDecoration(
              color: AppComponentColors.toggleThumb,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
