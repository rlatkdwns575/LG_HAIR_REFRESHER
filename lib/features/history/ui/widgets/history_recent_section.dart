import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/app_section_title.dart';
import '../../../../shared/widgets/app_text.dart';
import '../../data/history_assets.dart';
import '../../data/model/refresh_history_record.dart';
import '../../data/model/refresh_history_report.dart';
import 'history_common.dart';
import 'history_month_calendar.dart';

/// Section 2 — 최근 리프레시 기록 (월 이동 + 캘린더 + 선택 날짜 상세).
class HistoryRecentSection extends StatelessWidget {
  const HistoryRecentSection({
    required this.asOfDate,
    required this.visibleMonth,
    required this.monthData,
    required this.selectedDate,
    required this.calendarExpanded,
    required this.canGoPreviousMonth,
    required this.canGoNextMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onCalendarIconTap,
    required this.onDateSelected,
    required this.onToggleExpanded,
    this.onRecordDetailTap,
    super.key,
  });

  final DateTime asOfDate;
  final DateTime visibleMonth;
  final RefreshHistoryMonthData monthData;
  final DateTime? selectedDate;
  final bool calendarExpanded;
  final bool canGoPreviousMonth;
  final bool canGoNextMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onCalendarIconTap;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onToggleExpanded;
  final ValueChanged<RefreshHistoryRecord>? onRecordDetailTap;

  @override
  Widget build(BuildContext context) {
    final summary = monthData.monthlySummary;
    final selectedGroup = selectedDate == null
        ? null
        : monthData.groupForDate(selectedDate!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppSectionTitle(
          title: '최근 리프레시 기록',
          subtitle: '파란 점이 있는 날짜를 선택해 기록을 확인해보세요.',
        ),
        const SizedBox(height: AppSpacing.md),
        _MonthNavRow(
          month: visibleMonth,
          canGoPrevious: canGoPreviousMonth,
          canGoNext: canGoNextMonth,
          onPrevious: onPreviousMonth,
          onNext: onNextMonth,
          onCalendarIconTap: onCalendarIconTap,
        ),
        const SizedBox(height: AppSpacing.md),
        _MonthlySummaryCard(summary: summary),
        const SizedBox(height: AppSpacing.md),
        HistoryWhiteCard(
          borderColor: null,
          backgroundColor: AppColors.gray0,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: HistoryMonthCalendar(
            month: visibleMonth,
            countByDate: monthData.countByDate,
            selectedDate: selectedDate,
            asOfDate: asOfDate,
            expanded: calendarExpanded,
            onDateSelected: onDateSelected,
            onToggleExpanded: onToggleExpanded,
          ),
        ),
        if (selectedGroup != null) ...[
          const SizedBox(height: AppSpacing.md),
          _SelectedDayCard(
            group: selectedGroup,
            onRecordDetailTap: onRecordDetailTap,
          ),
        ],
      ],
    );
  }
}

class _MonthNavRow extends StatelessWidget {
  const _MonthNavRow({
    required this.month,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
    required this.onCalendarIconTap,
  });

  final DateTime month;
  final bool canGoPrevious;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onCalendarIconTap;

  String get _label {
    final monthStr = month.month.toString().padLeft(2, '0');
    return '${month.year}.$monthStr';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _NavIconButton(
          icon: Icons.chevron_left,
          enabled: canGoPrevious,
          onTap: onPrevious,
        ),
        const SizedBox(width: 4),
        AppText(_label, style: HistoryTextStyles.cardTitle),
        const SizedBox(width: 4),
        _NavIconButton(
          icon: Icons.chevron_right,
          enabled: canGoNext,
          onTap: onNext,
        ),
        const Spacer(),
        GestureDetector(
          onTap: onCalendarIconTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Image.asset(
              HistoryAssets.calendarIcon,
              width: 20,
              height: 20,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}

class _NavIconButton extends StatelessWidget {
  const _NavIconButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Icon(
        icon,
        size: 22,
        color: enabled ? AppColors.gray700 : AppColors.gray300,
      ),
    );
  }
}

class _MonthlySummaryCard extends StatelessWidget {
  const _MonthlySummaryCard({required this.summary});

  final RefreshMonthlySummary summary;

  String get _previousMonthLabel {
    final prevMonth = summary.month.month == 1 ? 12 : summary.month.month - 1;
    return '$prevMonth월';
  }

  String _formatPercent(double value) {
    if (value == value.roundToDouble()) {
      return '${value.toInt()}%';
    }
    return '${value.toStringAsFixed(1)}%';
  }

  @override
  Widget build(BuildContext context) {
    return HistoryWhiteCard(
      backgroundColor: AppColors.gray50,
      borderColor: null,
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            '${summary.month.month}월 간 총 ${summary.totalCount}회 리프레시 했어요.',
            style: HistoryTextStyles.cardTitle,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppText(
                '지난 $_previousMonthLabel보다 ',
                style: HistoryTextStyles.labelSecondary,
              ),
              HistoryDeltaText(delta: '${summary.vsLastMonthDelta}회'),
            ],
          ),
          const SizedBox(height: 20),
          HistoryKeyValueRow(
            label: '헤어 청결 개선율',
            value: _formatPercent(summary.improvementPercent),
            trailingDelta: _formatPercent(summary.improvementDeltaPercent),
            isPercentValue: true,
          ),
          const SizedBox(height: 6),
          HistoryKeyValueRow(
            label: '가장 많이 사용한 모드',
            value: summary.mostUsedMode,
          ),
          const SizedBox(height: 6),
          HistoryKeyValueRow(
            label: '가장 자주 사용한 시간',
            value: summary.mostUsedTimeRange,
          ),
        ],
      ),
    );
  }
}

class _SelectedDayCard extends StatefulWidget {
  const _SelectedDayCard({required this.group, this.onRecordDetailTap});

  final RefreshDayGroup group;
  final ValueChanged<RefreshHistoryRecord>? onRecordDetailTap;

  @override
  State<_SelectedDayCard> createState() => _SelectedDayCardState();
}

class _SelectedDayCardState extends State<_SelectedDayCard> {
  bool _showAllRecords = false;

  @override
  void didUpdateWidget(covariant _SelectedDayCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isSameDay(oldWidget.group.date, widget.group.date)) {
      _showAllRecords = false;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    final records = group.records;
    final hasHiddenRecords = records.length > historyMaxVisibleDayRecords;
    final visibleRecords = _showAllRecords || !hasHiddenRecords
        ? records
        : records.take(historyMaxVisibleDayRecords).toList();

    return HistoryWhiteCard(
      backgroundColor: AppColors.gray50,
      borderColor: null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(
            formatKoreanDateWithWeekday(group.date),
            style: HistoryTextStyles.labelPrimary,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (group.refreshCount > 0)
            AppText(
              '리프레시를 총 ${group.refreshCount}번 완료했어요.',
              style: HistoryTextStyles.labelPrimary,
            ),
          if (group.diagnosisCount > 0) ...[
            if (group.refreshCount > 0) const SizedBox(height: 2),
            AppText(
              '헤어 상태 진단을 총 ${group.diagnosisCount}번 완료했어요.',
              style: HistoryTextStyles.labelPrimary,
            ),
          ],
          const SizedBox(height: 2),
          AppText(
            group.summaryMessage,
            style: HistoryTextStyles.insightCaption,
          ),
          const SizedBox(height: AppSpacing.md),
          for (var i = 0; i < visibleRecords.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.sm),
            _DayRecordTile(
              record: visibleRecords[i],
              onTap: widget.onRecordDetailTap == null
                  ? null
                  : () => widget.onRecordDetailTap!(visibleRecords[i]),
            ),
          ],
          if (hasHiddenRecords) ...[
            const SizedBox(height: AppSpacing.sm),
            HistoryRecordsExpandToggle(
              expanded: _showAllRecords,
              onTap: () => setState(() => _showAllRecords = !_showAllRecords),
            ),
          ],
        ],
      ),
    );
  }
}

class _DayRecordTile extends StatelessWidget {
  const _DayRecordTile({required this.record, this.onTap});

  final RefreshHistoryRecord record;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          AppText(
            formatKoreanTime(record.dateTime),
            style: HistoryTextStyles.labelPrimary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AppText(
              record.modeName,
              style: HistoryTextStyles.labelSecondary,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.gray400),
          ],
        ],
      ),
    );

    return Material(
      color: AppColors.gray0,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: content),
    );
  }
}
