import 'package:flutter/material.dart';

import '../../app/theme/app_component_colors.dart';
import '../../app/theme/app_text_styles.dart';

/// Figma Item/Calendar — 월 네비게이션 바.
class AppCalendarItem extends StatelessWidget {
  const AppCalendarItem({
    required this.value,
    this.todayLabel = '오늘',
    this.onPrevious,
    this.onNext,
    this.onToday,
    this.onCalendar,
    super.key,
  });

  final String value;
  final String todayLabel;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onToday;
  final VoidCallback? onCalendar;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: Row(
        children: [
          TextButton(
            onPressed: onToday,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(45, 34),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              todayLabel,
              style: AppTextStyles.bodyM1.copyWith(
                color: AppComponentColors.calendarPrimaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _NavIconButton(icon: Icons.chevron_left, onPressed: onPrevious),
                const SizedBox(width: 8),
                Text(
                  value,
                  style: AppTextStyles.headlineM.copyWith(
                    color: AppComponentColors.calendarPrimaryText,
                  ),
                ),
                const SizedBox(width: 8),
                _NavIconButton(icon: Icons.chevron_right, onPressed: onNext),
              ],
            ),
          ),
          IconButton(
            onPressed: onCalendar,
            icon: const Icon(
              Icons.calendar_today_outlined,
              size: 24,
              color: AppComponentColors.calendarPrimaryText,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
        ],
      ),
    );
  }
}

class _NavIconButton extends StatelessWidget {
  const _NavIconButton({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 24, color: AppComponentColors.calendarPrimaryText),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
    );
  }
}
