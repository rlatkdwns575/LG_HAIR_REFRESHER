import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/model/routine.dart';

/// 월~일 요일을 다중 선택하는 원형 칩 그룹.
class RoutineWeekdayPicker extends StatelessWidget {
  const RoutineWeekdayPicker({
    required this.selected,
    required this.onToggle,
    super.key,
  });

  final Set<int> selected;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final weekday in RoutineWeekday.ordered)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: _WeekdayChip(
                label: RoutineWeekday.shortLabel(weekday),
                isSelected: selected.contains(weekday),
                onTap: () => onToggle(weekday),
              ),
            ),
          ),
      ],
    );
  }
}

class _WeekdayChip extends StatelessWidget {
  const _WeekdayChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary500 : AppColors.gray0,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? AppColors.primary500 : AppColors.gray200,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.bodyM2.copyWith(
              color: isSelected ? AppColors.gray0 : AppColors.gray600,
            ),
          ),
        ),
      ),
    );
  }
}
