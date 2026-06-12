import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// 월간 캘린더 그리드.
///
/// - 기록이 있는 날짜: 파란 점 + 횟수
/// - 선택된 날짜: 파란 라운드 테두리
/// - 미래/타월 날짜: 옅은 회색, 선택 불가
/// - 접힘 시 2주, 펼침 시 한 달 전체 표시
class HistoryMonthCalendar extends StatelessWidget {
  const HistoryMonthCalendar({
    required this.month,
    required this.countByDate,
    required this.selectedDate,
    required this.asOfDate,
    required this.expanded,
    required this.onDateSelected,
    required this.onToggleExpanded,
    super.key,
  });

  final DateTime month;
  final Map<DateTime, int> countByDate;
  final DateTime? selectedDate;
  final DateTime asOfDate;
  final bool expanded;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onToggleExpanded;

  static const _weekdayLabels = ['일', '월', '화', '수', '목', '금', '토'];

  @override
  Widget build(BuildContext context) {
    final rows = _buildRows();
    final visibleRows = expanded ? rows : _collapsedRows(rows);

    return Column(
      children: [
        Row(
          children: [
            for (final label in _weekdayLabels)
              Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: AppTextStyles.labelM.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        for (final row in visibleRows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                for (final cell in row) Expanded(child: _buildCell(cell)),
              ],
            ),
          ),
        const SizedBox(height: 4),
        _ExpandToggle(expanded: expanded, onTap: onToggleExpanded),
      ],
    );
  }

  List<List<_DayCell>> _buildRows() {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leading = firstDay.weekday % 7; // 일요일 시작

    final cells = <_DayCell>[];
    for (var i = 0; i < leading; i++) {
      final date = firstDay.subtract(Duration(days: leading - i));
      cells.add(_DayCell(date: date, inMonth: false));
    }
    for (var day = 1; day <= daysInMonth; day++) {
      cells.add(_DayCell(date: DateTime(month.year, month.month, day)));
    }
    while (cells.length % 7 != 0) {
      final last = cells.last.date;
      cells.add(
        _DayCell(date: last.add(const Duration(days: 1)), inMonth: false),
      );
    }

    final rows = <List<_DayCell>>[];
    for (var i = 0; i < cells.length; i += 7) {
      rows.add(cells.sublist(i, i + 7));
    }
    return rows;
  }

  /// 선택된 날짜가 포함된 주와 그 위 주를 보여줍니다(없으면 처음 2주).
  List<List<_DayCell>> _collapsedRows(List<List<_DayCell>> rows) {
    if (rows.length <= 2) {
      return rows;
    }
    var selectedRow = 0;
    if (selectedDate != null) {
      for (var i = 0; i < rows.length; i++) {
        final match = rows[i].any(
          (cell) => cell.inMonth && _isSameDay(cell.date, selectedDate!),
        );
        if (match) {
          selectedRow = i;
          break;
        }
      }
    }
    final start = (selectedRow - 1).clamp(0, rows.length - 2);
    return rows.sublist(start, start + 2);
  }

  Widget _buildCell(_DayCell cell) {
    final date = cell.date;
    final isFuture = date.isAfter(asOfDate);
    final isSelectable = cell.inMonth && !isFuture;
    final count = cell.inMonth ? countByDate[_dateKey(date)] : null;
    final isSelected =
        selectedDate != null && _isSameDay(date, selectedDate!) && cell.inMonth;

    final Color textColor;
    if (!cell.inMonth || isFuture) {
      textColor = AppColors.gray300;
    } else if (isSelected) {
      textColor = AppColors.primary500;
    } else {
      textColor = AppColors.gray800;
    }

    return GestureDetector(
      onTap: isSelectable ? () => onDateSelected(date) : null,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 44,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: isSelected
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary500),
                    )
                  : null,
              child: Text(
                '${date.day}',
                style: AppTextStyles.bodyS.copyWith(color: textColor),
              ),
            ),
            const SizedBox(height: 2),
            SizedBox(
              height: 10,
              child: count != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: AppColors.primary500,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '$count',
                          style: AppTextStyles.labelS.copyWith(
                            color: AppColors.primary500,
                            fontSize: 9,
                            height: 1,
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  static DateTime _dateKey(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DayCell {
  const _DayCell({required this.date, this.inMonth = true});

  final DateTime date;
  final bool inMonth;
}

class _ExpandToggle extends StatelessWidget {
  const _ExpandToggle({required this.expanded, required this.onTap});

  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 28,
        child: Center(
          child: Icon(
            expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            size: 22,
            color: AppColors.gray400,
          ),
        ),
      ),
    );
  }
}
