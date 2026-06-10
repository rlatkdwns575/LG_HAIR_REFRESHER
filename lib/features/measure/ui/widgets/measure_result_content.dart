import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/app_text_link_button.dart';
import '../../../refresh/ui/widgets/refresh_mode_card.dart';
import '../../data/model/measure_result.dart';
import 'measure_result_headline.dart';
import 'measure_result_header.dart';
import 'measure_result_status_row.dart';

/// 진단 결과 본문 — 안정형/경고형 공통 레이아웃.
class MeasureResultContent extends StatelessWidget {
  const MeasureResultContent({
    required this.result,
    required this.onDetailTap,
    required this.onRecommendTap,
    super.key,
  });

  /// 중앙 비주얼 영역 높이 (이미지 확정 전 빈 공간 유지).
  static const double visualAreaHeight = 200;

  final MeasureResult result;
  final VoidCallback onDetailTap;
  final VoidCallback onRecommendTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const MeasureResultHeader(),
        const SizedBox(height: 36),
        MeasureResultHeadline(headline: result.headline),
        const SizedBox(height: 40),
        const SizedBox(height: visualAreaHeight),
        const SizedBox(height: 36),
        MeasureResultStatusRow(items: result.statusItems),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: AppTextLinkButton(
            label: result.detailLinkLabel,
            onPressed: onDetailTap,
          ),
        ),
        const SizedBox(height: 40),
        RefreshModeCard(
          mode: result.recommendedMode,
          variant: RefreshModeCardVariant.featured,
          onTap: onRecommendTap,
          onAction: onRecommendTap,
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}
