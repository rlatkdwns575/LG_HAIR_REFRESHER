import 'package:flutter/material.dart';

import '../../app/theme/app_component_colors.dart';

/// Figma `indicator` + `item/indicator` — page dot indicator.
class AppPageIndicator extends StatelessWidget {
  const AppPageIndicator({
    required this.count,
    required this.selectedIndex,
    this.onDotTap,
    super.key,
  });

  final int count;
  final int selectedIndex;
  final ValueChanged<int>? onDotTap;

  static const double _dotSize = 6;
  static const double _dotSpacing = 8;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 43,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (index) {
          final isActive = index == selectedIndex;
          final dot = Container(
            width: _dotSize,
            height: _dotSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? AppComponentColors.indicatorActive
                  : AppComponentColors.indicatorInactive,
            ),
          );

          if (onDotTap == null) {
            return Padding(
              padding: EdgeInsets.only(left: index == 0 ? 0 : _dotSpacing),
              child: dot,
            );
          }

          return Padding(
            padding: EdgeInsets.only(left: index == 0 ? 0 : _dotSpacing),
            child: GestureDetector(
              onTap: () => onDotTap!(index),
              behavior: HitTestBehavior.opaque,
              child: dot,
            ),
          );
        }),
      ),
    );
  }
}
