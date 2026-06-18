import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_text_styles.dart';
import 'measure_result_detail_section_badge.dart';
import '../../../../shared/widgets/app_text.dart';
import '../../data/model/measure_result_detail_metric.dart';
import '../../data/model/measure_result_detail_section.dart';
import 'measure_result_detail_metric_tile.dart';

/// 냄새/먼지/모발 상태 섹션 (Figma 40000056:19078~19100).
class MeasureResultDetailSectionBlock extends StatelessWidget {
  const MeasureResultDetailSectionBlock({required this.section, super.key});

  final MeasureResultDetailSection section;

  static const _sectionVerticalPadding = 18.0;
  static const _titleToSubtitleGap = 4.0;
  static const _titleBlockToContentGap = 20.0;
  static const _cardToMetricsGap = 20.0;
  static const _analysisCardInnerGap = 8.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: _sectionVerticalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            section.title,
            style: AppTextStyles.titleM.copyWith(
              color: AppColors.gray900,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: _titleToSubtitleGap),
          AppText(
            section.subtitle,
            breakLinesBySentence: true,
            style: AppTextStyles.bodyS.copyWith(
              color: AppColors.gray500,
              height: 1.45,
            ),
          ),
          const SizedBox(height: _titleBlockToContentGap),
          _AnalysisCard(section: section),
          const SizedBox(height: _cardToMetricsGap),
          _MetricList(metrics: section.metrics),
        ],
      ),
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
      padding: const EdgeInsets.all(15),
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
          const SizedBox(
            height: MeasureResultDetailSectionBlock._analysisCardInnerGap,
          ),
          AppText(
            section.analysisDescription,
            breakLinesBySentence: true,
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
          if (i > 0) const SizedBox(height: 12),
          MeasureResultDetailMetricTile(metric: metrics[i]),
        ],
      ],
    );
  }
}
