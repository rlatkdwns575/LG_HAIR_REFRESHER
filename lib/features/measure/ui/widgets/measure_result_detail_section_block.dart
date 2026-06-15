import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import 'measure_result_detail_section_badge.dart';
import '../../../../shared/widgets/app_text.dart';
import '../../data/model/measure_result_detail_metric.dart';
import '../../data/model/measure_result_detail_section.dart';
import 'measure_result_detail_metric_tile.dart';

/// 냄새/먼지/모발 상태 섹션 (Figma Title + 분석 카드 + 지표 목록).
class MeasureResultDetailSectionBlock extends StatelessWidget {
  const MeasureResultDetailSectionBlock({required this.section, super.key});

  final MeasureResultDetailSection section;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.title,
          style: AppTextStyles.titleM.copyWith(color: AppColors.gray800),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppText(
          section.subtitle,
          style: AppTextStyles.bodyS.copyWith(color: AppColors.gray500),
        ),
        const SizedBox(height: AppSpacing.md),
        _AnalysisCard(section: section),
        const SizedBox(height: AppSpacing.lg),
        _MetricList(metrics: section.metrics),
      ],
    );
  }
}

class _AnalysisCard extends StatelessWidget {
  const _AnalysisCard({required this.section});

  final MeasureResultDetailSection section;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 12, 15, 16),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MeasureResultDetailSectionBadge(
            label: section.analysisBadgeLabel,
            variant: section.analysisBadgeVariant,
          ),
          const SizedBox(height: 10),
          AppText(
            section.analysisDescription,
            style: AppTextStyles.bodyM2.copyWith(
              color: AppColors.gray800,
              height: 20 / 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricList extends StatelessWidget {
  const _MetricList({required this.metrics});

  final List<MeasureResultDetailMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < metrics.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.md),
          MeasureResultDetailMetricTile(metric: metrics[i]),
        ],
      ],
    );
  }
}
