import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../data/model/measure_result_detail.dart';
import 'measure_result_detail_header.dart';
import 'measure_result_detail_section_block.dart';
import 'measure_result_detail_summary.dart';

/// 진단 결과 상세 본문.
class MeasureResultDetailContent extends StatelessWidget {
  const MeasureResultDetailContent({
    required this.detail,
    this.onRecommendTap,
    super.key,
  });

  final MeasureResultDetail detail;
  final VoidCallback? onRecommendTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const MeasureResultDetailHeader(),
        const SizedBox(height: AppSpacing.xl),
        MeasureResultDetailSummary(
          detail: detail,
          onRecommendTap: onRecommendTap,
        ),
        const SizedBox(height: 40),
        MeasureResultDetailSectionBlock(section: detail.odorSection),
        const SizedBox(height: 40),
        MeasureResultDetailSectionBlock(section: detail.dustSection),
        const SizedBox(height: 40),
        MeasureResultDetailSectionBlock(section: detail.hairSection),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}
