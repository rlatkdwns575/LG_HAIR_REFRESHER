import 'package:flutter/material.dart';

import '../../app/theme/app_component_colors.dart';
import '../../app/theme/app_text_styles.dart';

class AppCalendarDayCell {
  const AppCalendarDayCell({
    required this.weekdayLabel,
    required this.dayLabel,
    this.isSelected = false,
  });

  final String weekdayLabel;
  final String dayLabel;
  final bool isSelected;
}

/// Figma Top_Header_Calendar Type=Daily > Down 일자 스트립.
class AppCalendarDayStrip extends StatelessWidget {
  const AppCalendarDayStrip({
    required this.days,
    this.onDaySelected,
    super.key,
  });

  final List<AppCalendarDayCell> days;
  final ValueChanged<int>? onDaySelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var i = 0; i < days.length; i++)
            GestureDetector(
              onTap: onDaySelected == null ? null : () => onDaySelected!(i),
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 24,
                child: Column(
                  children: [
                    Text(
                      days[i].weekdayLabel,
                      style: AppTextStyles.labelS.copyWith(
                        color: days[i].isSelected
                            ? AppComponentColors.calendarAccent
                            : AppComponentColors.calendarPrimaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      days[i].dayLabel,
                      style: AppTextStyles.titleS.copyWith(
                        color: days[i].isSelected
                            ? AppComponentColors.calendarAccent
                            : AppComponentColors.calendarPrimaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
