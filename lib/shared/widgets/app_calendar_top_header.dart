import 'package:flutter/material.dart';

import '../../app/theme/app_component_colors.dart';
import 'app_calendar_day_strip.dart';
import 'app_calendar_item.dart';
import 'app_calendar_week_strip.dart';

enum AppCalendarTopHeaderVariant { none, weekly, daily }

/// Figma Top_Header_Calendar (Variants > Calendar).
class AppCalendarTopHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const AppCalendarTopHeader({
    required this.variant,
    required this.monthValue,
    this.todayLabel = '오늘',
    this.weeks = const [],
    this.days = const [],
    this.onPreviousMonth,
    this.onNextMonth,
    this.onToday,
    this.onCalendar,
    this.onWeekSelected,
    this.onDaySelected,
    super.key,
  });

  final AppCalendarTopHeaderVariant variant;
  final String monthValue;
  final String todayLabel;
  final List<AppCalendarWeekCell> weeks;
  final List<AppCalendarDayCell> days;
  final VoidCallback? onPreviousMonth;
  final VoidCallback? onNextMonth;
  final VoidCallback? onToday;
  final VoidCallback? onCalendar;
  final ValueChanged<int>? onWeekSelected;
  final ValueChanged<int>? onDaySelected;

  @override
  Size get preferredSize {
    return switch (variant) {
      AppCalendarTopHeaderVariant.none => const Size.fromHeight(49),
      AppCalendarTopHeaderVariant.weekly => const Size.fromHeight(85),
      AppCalendarTopHeaderVariant.daily => const Size.fromHeight(106),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppComponentColors.headerBackground,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: preferredSize.height,
          child: Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppCalendarItem(
                  value: monthValue,
                  todayLabel: todayLabel,
                  onPrevious: onPreviousMonth,
                  onNext: onNextMonth,
                  onToday: onToday,
                  onCalendar: onCalendar,
                ),
                if (variant == AppCalendarTopHeaderVariant.weekly) ...[
                  const SizedBox(height: 12),
                  AppCalendarWeekStrip(
                    weeks: weeks,
                    onWeekSelected: onWeekSelected,
                  ),
                ],
                if (variant == AppCalendarTopHeaderVariant.daily) ...[
                  const SizedBox(height: 11),
                  AppCalendarDayStrip(days: days, onDaySelected: onDaySelected),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
