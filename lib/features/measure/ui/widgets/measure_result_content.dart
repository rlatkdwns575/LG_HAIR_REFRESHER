import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_text_link_button.dart';
import '../../../refresh/data/refresh_mode_availability.dart';
import '../../../refresh/ui/widgets/refresh_mode_card.dart';
import '../../data/model/measure_result.dart';
import 'measure_result_headline.dart';
import 'measure_result_header.dart';
import 'measure_result_refresh_need_summary.dart';
import 'measure_result_status_row.dart';

/// 진단 결과 본문 — 안정형/경고형 공통 레이아웃.
class MeasureResultContent extends StatelessWidget {
  const MeasureResultContent({
    required this.result,
    required this.onDetailTap,
    required this.onRecommendTap,
    this.isRecommendEnabled = true,
    super.key,
  });

  /// Figma 40000056:18420 — img area 160×160.
  static const double visualAreaHeight = 160;

  /// Figma 40000056:18411 — Title ↔ card_result, card_result ↔ card_refresh.
  static const double _sectionGap = 20;

  /// Figma 40000056:18417 — 헤드라인 ↔ 이미지, 이미지 ↔ 지표 블록.
  static const double _cardInnerGap = 24;

  /// Figma 40000056:18421 — 리프레시 필요도 ↔ 냄새·먼지.
  static const double _metricsInnerGap = 6;

  final MeasureResult result;
  final VoidCallback onDetailTap;
  final VoidCallback onRecommendTap;
  final bool isRecommendEnabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const MeasureResultHeader(),
        const SizedBox(height: _sectionGap),
        MeasureResultHeadline(headline: result.headline),
        const SizedBox(height: _cardInnerGap),
        const SizedBox(height: visualAreaHeight),
        const SizedBox(height: _cardInnerGap),
        Column(
          children: [
            MeasureResultRefreshNeedSummary(percent: result.refreshNeedPercent),
            const SizedBox(height: _metricsInnerGap),
            MeasureResultStatusRow(items: result.statusItems),
          ],
        ),
        const SizedBox(height: _cardInnerGap),
        Center(
          child: AppTextLinkButton(
            label: result.detailLinkLabel,
            onPressed: onDetailTap,
          ),
        ),
        const SizedBox(height: _sectionGap),
        RefreshModeCard(
          mode: result.recommendedMode,
          variant: RefreshModeCardVariant.featured,
          badgeLabel: '추천',
          descriptionOverride: result.recommendReason,
          enabled: isRecommendEnabled,
          disabledReason: isRecommendEnabled
              ? null
              : RefreshModeAvailability.unavailableReason,
          onTap: onRecommendTap,
          onAction: onRecommendTap,
        ),
      ],
    );
  }
}
