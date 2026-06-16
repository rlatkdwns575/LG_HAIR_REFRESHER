import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/app_section_divider.dart';
import '../../data/model/measure_result_detail.dart';
import 'measure_result_detail_header.dart';
import 'measure_result_detail_section_block.dart';
import 'measure_result_detail_summary.dart';

/// 진단 결과 상세 본문.
class MeasureResultDetailContent extends StatelessWidget {
  const MeasureResultDetailContent({
    required this.detail,
    this.onRecommendTap,
    this.isRecommendEnabled = true,
    super.key,
  });

  final MeasureResultDetail detail;
  final VoidCallback? onRecommendTap;
  final bool isRecommendEnabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DetailPageHorizontalPadding(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const MeasureResultDetailHeader(),
              const SizedBox(height: AppSpacing.xl),
              MeasureResultDetailSummary(
                detail: detail,
                onRecommendTap: onRecommendTap,
                isRecommendEnabled: isRecommendEnabled,
              ),
            ],
          ),
        ),
        const AppSectionDivider(),
        DetailPageHorizontalPadding(
          child: MeasureResultDetailSectionBlock(section: detail.odorSection),
        ),
        const AppSectionDivider(),
        DetailPageHorizontalPadding(
          child: MeasureResultDetailSectionBlock(section: detail.dustSection),
        ),
        const AppSectionDivider(),
        DetailPageHorizontalPadding(
          child: MeasureResultDetailSectionBlock(section: detail.hairSection),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}
