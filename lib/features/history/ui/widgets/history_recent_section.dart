import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_section_title.dart';
import '../../data/history_assets.dart';
import '../../data/model/refresh_history_record.dart';
import '../../data/model/refresh_history_report.dart';
import 'history_care_badge.dart';
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
    this.onDayResultDetailTap,
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
  final VoidCallback? onDayResultDetailTap;

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
            onDetailTap: onDayResultDetailTap,
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
        Text(
          _label,
          style: AppTextStyles.titleS.copyWith(color: AppColors.gray900),
        ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${summary.month.month}월 간 총 ${summary.totalCount}회 리프레시 했어요.',
            style: AppTextStyles.titleS.copyWith(color: AppColors.gray900),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '지난 $_previousMonthLabel보다 ',
                style: AppTextStyles.bodyS.copyWith(color: AppColors.gray900),
              ),
              Text(
                '↑${summary.vsLastMonthDelta}회',
                style: AppTextStyles.bodyS.copyWith(
                  color: AppColors.primary500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          HistoryKeyValueRow(
            label: '리프레시 개선도',
            value: _formatPercent(summary.improvementPercent),
            valueColor: AppColors.gray900,
            trailingDelta:
                '↑${_formatPercent(summary.improvementDeltaPercent)}',
          ),
          const SizedBox(height: 8),
          HistoryKeyValueRow(
            label: '가장 많이 사용한 모드',
            value: summary.mostUsedMode,
          ),
          const SizedBox(height: 8),
          HistoryKeyValueRow(
            label: '가장 자주 사용한 시간',
            value: summary.mostUsedTimeRange,
          ),
        ],
      ),
    );
  }
}

class _SelectedDayCard extends StatelessWidget {
  const _SelectedDayCard({required this.group, this.onDetailTap});

  final RefreshDayGroup group;
  final VoidCallback? onDetailTap;

  @override
  Widget build(BuildContext context) {
    return HistoryWhiteCard(
      backgroundColor: AppColors.gray50,
      borderColor: null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  formatKoreanDateWithWeekday(group.date),
                  style: AppTextStyles.bodyM2.copyWith(
                    color: AppColors.gray900,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onDetailTap,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    Text(
                      '결과 상세보기',
                      style: AppTextStyles.labelM.copyWith(
                        color: AppColors.gray500,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      size: 14,
                      color: AppColors.gray400,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '총 ${group.count}번 리프레시했어요.',
            style: AppTextStyles.bodyM2.copyWith(color: AppColors.gray900),
          ),
          const SizedBox(height: 2),
          Text(
            group.summaryMessage,
            style: AppTextStyles.bodyS.copyWith(color: AppColors.gray600),
          ),
          const SizedBox(height: AppSpacing.md),
          for (var i = 0; i < group.records.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.sm),
            _DayRecordTile(record: group.records[i]),
          ],
        ],
      ),
    );
  }
}

class _DayRecordTile extends StatelessWidget {
  const _DayRecordTile({required this.record});

  final RefreshHistoryRecord record;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.gray0,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                formatKoreanTime(record.dateTime),
                style: AppTextStyles.bodyM2.copyWith(color: AppColors.gray900),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  record.modeName,
                  style: AppTextStyles.bodyS.copyWith(color: AppColors.gray600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (record.odorBeforeStatus != null)
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: HistoryCareStatusRow(
                      label: '냄새관리',
                      before: record.odorBeforeStatus!,
                      after: record.odorAfterStatus,
                      compact: true,
                    ),
                  ),
                ),
              if (record.odorBeforeStatus != null &&
                  record.dustBeforeStatus != null)
                const SizedBox(width: 6),
              if (record.dustBeforeStatus != null)
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: HistoryCareStatusRow(
                      label: '먼지관리',
                      before: record.dustBeforeStatus!,
                      after: record.dustAfterStatus,
                      compact: true,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
