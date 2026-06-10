import 'package:flutter/material.dart';

import '../../app/theme/app_component_colors.dart';
import '../../app/theme/app_text_styles.dart';

class AppCalendarWeekCell {
  const AppCalendarWeekCell({required this.label, this.isSelected = false});

  final String label;
  final bool isSelected;
}

/// Figma Top_Header_Calendar Type=Weekly > Down 주차 스트립.
class AppCalendarWeekStrip extends StatelessWidget {
  const AppCalendarWeekStrip({
    required this.weeks,
    this.onWeekSelected,
    super.key,
  });

  final List<AppCalendarWeekCell> weeks;
  final ValueChanged<int>? onWeekSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 22,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        child: Row(
          children: [
            for (var i = 0; i < weeks.length; i++) ...[
              if (i > 0) const SizedBox(width: 16),
              GestureDetector(
                onTap: onWeekSelected == null ? null : () => onWeekSelected!(i),
                child: Text(
                  weeks[i].label,
                  style: AppTextStyles.titleS.copyWith(
                    color: weeks[i].isSelected
                        ? AppComponentColors.calendarAccent
                        : AppComponentColors.calendarPrimaryText,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
