import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/app_text_link_button.dart';
import '../../data/model/refresh_result.dart';
import '../../data/refresh_mode_availability.dart';
import 'refresh_mode_card.dart';
import 'refresh_result_change_chart.dart';
import 'refresh_result_headline.dart';
import 'refresh_result_header.dart';

/// 리프레시 결과 본문.
class RefreshResultContent extends StatelessWidget {
  const RefreshResultContent({
    required this.result,
    required this.onDetailTap,
    required this.onRecommendTap,
    this.isScentRecommendEnabled = true,
    super.key,
  });

  final RefreshResult result;
  final VoidCallback onDetailTap;
  final VoidCallback onRecommendTap;
  final bool isScentRecommendEnabled;

  /// 헤더(리프레시 결과 / 기록 안내) 아래 콘텐츠를 내리기 위한 여백.
  static const _headerToHeadlineGap = 64.0;
  static const _headlineToGraphGap = 44.0;
  static const _graphToDetailGap = 52.0;
  static const _detailToCardGap = 52.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const RefreshResultHeader(),
        const SizedBox(height: _headerToHeadlineGap),
        RefreshResultHeadline(result: result),
        if (result.showChangeChart) ...[
          const SizedBox(height: _headlineToGraphGap),
          RefreshResultChangeChart(
            dustChange: result.dustChange,
            odorChange: result.odorChange,
          ),
          const SizedBox(height: _graphToDetailGap),
        ] else
          const SizedBox(height: _headlineToGraphGap),
        Center(
          child: AppTextLinkButton(
            label: result.detailLinkLabel,
            onPressed: onDetailTap,
          ),
        ),
        if (result.showScentCareRecommendation) ...[
          const SizedBox(height: _detailToCardGap),
          RefreshModeCard(
            mode: result.recommendedMode!,
            variant: RefreshModeCardVariant.featured,
            enabled: isScentRecommendEnabled,
            disabledReason: isScentRecommendEnabled
                ? null
                : RefreshModeAvailability.unavailableReason,
            onTap: onRecommendTap,
            onAction: onRecommendTap,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ],
    );
  }
}
