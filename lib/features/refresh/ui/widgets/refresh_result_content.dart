import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/app_text_link_button.dart';
import '../../data/model/refresh_result.dart';
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
    super.key,
  });

  final RefreshResult result;
  final VoidCallback onDetailTap;
  final VoidCallback onRecommendTap;

  /// 헤더(리프레시 결과 / 2시간) 아래 콘텐츠를 내리기 위한 여백.
  static const _headerToHeadlineGap = 64.0;
  static const _headlineToGraphGap = 32.0;
  static const _graphToDetailGap = 44.0;
  static const _detailToCardGap = 52.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const RefreshResultHeader(),
        const SizedBox(height: _headerToHeadlineGap),
        RefreshResultHeadline(result: result),
        const SizedBox(height: _headlineToGraphGap),
        RefreshResultChangeChart(
          dustChange: result.dustChange,
          odorChange: result.odorChange,
        ),
        const SizedBox(height: _graphToDetailGap),
        Center(
          child: AppTextLinkButton(
            label: result.detailLinkLabel,
            onPressed: onDetailTap,
          ),
        ),
        const SizedBox(height: _detailToCardGap),
        RefreshModeCard(
          mode: result.recommendedMode,
          variant: RefreshModeCardVariant.featured,
          onTap: onRecommendTap,
          onAction: onRecommendTap,
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
