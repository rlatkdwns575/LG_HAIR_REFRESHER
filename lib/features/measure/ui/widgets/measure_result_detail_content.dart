import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/app_section_divider.dart';
import '../../data/model/measure_result_detail.dart';
import 'measure_result_detail_header.dart';
import 'measure_result_detail_section_block.dart';
import 'measure_result_detail_summary.dart';

/// 진단 결과 상세 본문 (Figma 40000026:23547).
class MeasureResultDetailContent extends StatelessWidget {
  const MeasureResultDetailContent({
    required this.detail,
    this.onRecommendTap,
    this.isRecommendEnabled = true,
    super.key,
  });

  /// Figma 40000056:19034 — Title ↔ 요약 블록.
  static const double _headerToSummaryGap = 40;

  /// Figma divider — 섹션 구분 상·하 여백.
  static const double _sectionDividerSpacing = 12;

  /// 냄새/먼지/모발 섹션과 동일한 상·하 패딩.
  static const double _sectionVerticalPadding = 18;

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
              const SizedBox(height: _headerToSummaryGap),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: _sectionVerticalPadding,
                ),
                child: MeasureResultDetailSummary(
                  detail: detail,
                  onRecommendTap: onRecommendTap,
                  isRecommendEnabled: isRecommendEnabled,
                ),
              ),
            ],
          ),
        ),
        const AppSectionDivider(verticalSpacing: _sectionDividerSpacing),
        DetailPageHorizontalPadding(
          child: MeasureResultDetailSectionBlock(section: detail.odorSection),
        ),
        const AppSectionDivider(verticalSpacing: _sectionDividerSpacing),
        DetailPageHorizontalPadding(
          child: MeasureResultDetailSectionBlock(section: detail.dustSection),
        ),
        const AppSectionDivider(verticalSpacing: _sectionDividerSpacing),
        DetailPageHorizontalPadding(
          child: MeasureResultDetailSectionBlock(section: detail.hairSection),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}
