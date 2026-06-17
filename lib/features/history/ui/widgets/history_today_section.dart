import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
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
        if (report.hasTodayRecords) _buildSummaryCard() else _buildEmptyCard(),
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

  Widget _buildSummaryCard() {
    final records = report.todayRecords;
    return HistoryWhiteCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            report.todaySummaryTitle,
            style: AppTextStyles.titleS.copyWith(color: AppColors.gray900),
          ),
          const SizedBox(height: 4),
          AppText(
            report.todaySummarySubtitle,
            style: AppTextStyles.bodyS.copyWith(color: AppColors.gray600),
          ),
          for (var i = 0; i < records.length; i++) ...[
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1, color: AppColors.gray100),
            const SizedBox(height: AppSpacing.md),
            _TodayRecordTile(
              record: records[i],
              onDetailTap: onRecordDetailTap == null
                  ? null
                  : () => onRecordDetailTap!(records[i]),
            ),
          ],
        ],
      ),
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
                  '리프레시 필요성',
                  style: AppTextStyles.bodyS.copyWith(color: AppColors.gray500),
                ),
                const SizedBox(height: 2),
                AppText(
                  record.necessityReductionLabel!,
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRegisterTap,
      behavior: HitTestBehavior.opaque,
      child: HistoryWhiteCard(
        padding: const EdgeInsets.all(20),
        backgroundColor: AppColors.primary100,
        borderColor: null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.gray200,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
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
                for (final tag in suggestion.tags)
                  AppText(
                    tag,
                    style: AppTextStyles.bodyS.copyWith(
                      color: AppColors.primary500,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
