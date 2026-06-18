import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/constants/image_assets.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_text.dart';
import '../../data/model/refresh_history_record.dart';
import '../../data/model/refresh_history_report.dart';
import 'history_care_badge.dart';
import 'history_common.dart';

/// Section 1 — 오늘의 리프레시 요약 + 루틴 추천.
class HistoryTodaySection extends StatelessWidget {
  const HistoryTodaySection({
    required this.report,
    this.onRecordDetailTap,
    this.onRoutineRegisterTap,
    super.key,
  });

  final RefreshHistoryReport report;
  final ValueChanged<RefreshHistoryRecord>? onRecordDetailTap;
  final VoidCallback? onRoutineRegisterTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (report.hasTodayRecords)
          _TodaySummaryCard(
            title: report.todaySummaryTitle,
            subtitle: report.todaySummarySubtitle,
            records: report.todayRecords,
            onRecordDetailTap: onRecordDetailTap,
          )
        else
          _buildEmptyCard(),
        if (report.routineSuggestion != null) ...[
          const SizedBox(height: AppSpacing.md),
          _RoutineCard(
            suggestion: report.routineSuggestion!,
            onRegisterTap: onRoutineRegisterTap,
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyCard() {
    return HistoryWhiteCard(
      backgroundColor: AppColors.gray50,
      borderColor: null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            '오늘의 리프레시 내역이 없어요.',
            style: AppTextStyles.titleS.copyWith(color: AppColors.gray900),
          ),
          const SizedBox(height: 6),
          AppText(
            '리프레시를 통해 외출 후 컨디션을 가볍게 정리해보세요.',
            style: AppTextStyles.bodyS.copyWith(color: AppColors.gray600),
          ),
        ],
      ),
    );
  }
}

class _TodaySummaryCard extends StatefulWidget {
  const _TodaySummaryCard({
    required this.title,
    required this.subtitle,
    required this.records,
    this.onRecordDetailTap,
  });

  final String title;
  final String subtitle;
  final List<RefreshHistoryRecord> records;
  final ValueChanged<RefreshHistoryRecord>? onRecordDetailTap;

  @override
  State<_TodaySummaryCard> createState() => _TodaySummaryCardState();
}

class _TodaySummaryCardState extends State<_TodaySummaryCard> {
  bool _showAllRecords = false;

  @override
  void didUpdateWidget(covariant _TodaySummaryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.records.length != widget.records.length ||
        !_hasSameRecordOrder(oldWidget.records, widget.records)) {
      _showAllRecords = false;
    }
  }

  bool _hasSameRecordOrder(
    List<RefreshHistoryRecord> previous,
    List<RefreshHistoryRecord> current,
  ) {
    if (previous.length != current.length) {
      return false;
    }
    for (var i = 0; i < previous.length; i++) {
      if (previous[i].dateTime != current[i].dateTime ||
          previous[i].modeName != current[i].modeName) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final records = widget.records;
    final hasHiddenRecords = records.length > historyMaxVisibleDayRecords;
    final visibleRecords = _showAllRecords || !hasHiddenRecords
        ? records
        : records.take(historyMaxVisibleDayRecords).toList();

    return HistoryWhiteCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            widget.title,
            style: AppTextStyles.titleS.copyWith(color: AppColors.gray900),
          ),
          const SizedBox(height: 4),
          AppText(
            widget.subtitle,
            style: AppTextStyles.bodyS.copyWith(color: AppColors.gray600),
          ),
          for (var i = 0; i < visibleRecords.length; i++) ...[
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1, color: AppColors.gray100),
            const SizedBox(height: AppSpacing.md),
            _TodayRecordTile(
              record: visibleRecords[i],
              onDetailTap: widget.onRecordDetailTap == null
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

class _TodayRecordTile extends StatelessWidget {
  const _TodayRecordTile({required this.record, this.onDetailTap});

  final RefreshHistoryRecord record;
  final VoidCallback? onDetailTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: AppText(
                      record.modeName,
                      style: AppTextStyles.bodyM2.copyWith(
                        color: AppColors.gray900,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppText(
                    formatKoreanTime(record.dateTime),
                    style: AppTextStyles.bodyS.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ),
            HistoryDetailLink(label: '상세보기', onTap: onDetailTap),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _buildMetricsRow(),
      ],
    );
  }

  Widget _buildMetricsRow() {
    final careItems = <HistoryCareStatusItem>[
      if (record.odorBeforeStatus != null)
        HistoryCareStatusItem(
          label: '냄새 관리',
          before: record.odorBeforeStatus!,
          after: record.odorAfterStatus,
        ),
      if (record.dustBeforeStatus != null)
        HistoryCareStatusItem(
          label: '먼지 관리',
          before: record.dustBeforeStatus!,
          after: record.dustAfterStatus,
        ),
    ];
    final hasCareItems = careItems.isNotEmpty;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (record.hasNecessityReduction)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  '청결도',
                  style: AppTextStyles.bodyS.copyWith(color: AppColors.gray500),
                ),
                const SizedBox(height: 2),
                AppText(
                  record.cleanlinessIncreaseLabel!,
                  style: AppTextStyles.titleM.copyWith(
                    color: AppColors.gray900,
                  ),
                ),
              ],
            ),
          const Spacer(),
          if (hasCareItems)
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (record.hasNecessityReduction) ...[
                  Container(width: 1, color: AppColors.gray100),
                  const SizedBox(width: AppSpacing.md),
                ],
                HistoryCareStatusGroup(labelWidth: 58, items: careItems),
              ],
            ),
        ],
      ),
    );
  }
}

class _RoutineCard extends StatelessWidget {
  const _RoutineCard({required this.suggestion, this.onRegisterTap});

  final RoutineSuggestion suggestion;
  final VoidCallback? onRegisterTap;

  static const _tagStyle = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    fontSize: 10,
    height: 1,
    fontWeight: FontWeight.w500,
    color: AppColors.primary700,
  );

  @override
  Widget build(BuildContext context) {
    return HistoryWhiteCard(
      padding: const EdgeInsets.all(20),
      backgroundColor: AppColors.primary100,
      borderColor: null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                ImageAssets.homeRecommendSparkleIcon,
                width: 44,
                height: 44,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      suggestion.title,
                      style: AppTextStyles.bodyM2.copyWith(
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    AppText(
                      suggestion.subtitle,
                      style: AppTextStyles.titleXs.copyWith(
                        color: AppColors.gray900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              for (final tag in suggestion.tags) AppText(tag, style: _tagStyle),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 30,
            width: double.infinity,
            child: TextButton(
              onPressed: onRegisterTap,
              style: TextButton.styleFrom(
                backgroundColor: onRegisterTap == null
                    ? AppColors.gray300
                    : AppColors.primary500,
                disabledBackgroundColor: AppColors.gray300,
                foregroundColor: AppColors.gray0,
                disabledForegroundColor: AppColors.gray0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: AppText(
                '루틴 등록하기',
                style: AppTextStyles.labelL.copyWith(
                  fontSize: 12,
                  height: 16 / 12,
                  color: AppColors.gray0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
