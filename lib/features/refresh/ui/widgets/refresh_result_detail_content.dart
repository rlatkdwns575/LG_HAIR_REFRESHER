import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_text.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_section_divider.dart';
import '../../../../core/utils/korean_date_time_format.dart';
import '../../data/model/refresh_result_detail.dart';
import 'refresh_result_detail_metric_bars.dart';
import 'refresh_result_detail_status_section.dart';
import '../../../../shared/widgets/app_metric_help_icon.dart';

/// Figma 1170-16711 — 리프레시 결과 상세보기 본문.
class RefreshResultDetailContent extends StatelessWidget {
  const RefreshResultDetailContent({required this.detail, super.key});

  final RefreshResultDetail detail;

  static const _headlineLeftInset = 12.0;

  (String, String) get _modeHeadlineParts {
    final name = detail.modeName.trim();
    if (name.endsWith(' 후')) {
      return (name.substring(0, name.length - 2), ' 후');
    }
    if (name.endsWith('후')) {
      return (name.substring(0, name.length - 1), '후');
    }
    return (name, ' 후');
  }

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
              _buildSummaryHeader(),
              const SizedBox(height: 40),
              _buildHeadline(),
              const SizedBox(height: 40),
              RefreshResultDetailMetricBars(metrics: detail.metrics),
              const SizedBox(height: 20),
              const _NecessityHelpRow(),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const AppSectionDivider(),
        DetailPageHorizontalPadding(
          child: RefreshResultDetailStatusSection(section: detail.odorSection),
        ),
        const AppSectionDivider(),
        DetailPageHorizontalPadding(
          child: RefreshResultDetailStatusSection(section: detail.dustSection),
        ),
        const AppSectionDivider(),
        DetailPageHorizontalPadding(
          child: RefreshResultDetailStatusSection(section: detail.hairSection),
        ),
      ],
    );
  }

  Widget _buildSummaryHeader() {
    final completedAt = detail.historyCompletedAt;
    final subtitle = completedAt != null
        ? formatKoreanCompletionLabel(completedAt)
        : '리프레시 결과는 리프레시 기록에서 확인할 수 있어요.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          '리프레시 결과',
          style: AppTextStyles.titleL.copyWith(
            color: AppColors.gray900,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        AppText(
          subtitle,
          style: AppTextStyles.labelM.copyWith(
            color: AppColors.gray500,
            height: 16 / 12,
          ),
        ),
      ],
    );
  }

  Widget _buildHeadline() {
    final (modeBlueText, modeBlackSuffix) = _modeHeadlineParts;
    final modeLineStyle = AppTextStyles.titleS.copyWith(
      fontWeight: FontWeight.w600,
      height: 22 / 16,
    );

    return Padding(
      padding: const EdgeInsets.only(left: _headlineLeftInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: modeBlueText.softWrapWords(),
                  style: modeLineStyle.copyWith(color: AppColors.primary500),
                ),
                TextSpan(
                  text: modeBlackSuffix.softWrapWords(),
                  style: modeLineStyle.copyWith(color: AppColors.gray900),
                ),
              ],
            ),
          ),
          const SizedBox(height: 0),
          AppText(
            '헤어 청결도가',
            style: AppTextStyles.titleS.copyWith(
              color: AppColors.gray900,
              fontWeight: FontWeight.w600,
              height: 22 / 16,
            ),
          ),
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: detail.necessityReductionLabel.softWrapWords(),
                  style: AppTextStyles.headlineL.copyWith(
                    color: AppColors.gray900,
                    fontWeight: FontWeight.w700,
                    fontSize: 48,
                    height: 40 / 48,
                  ),
                ),
                TextSpan(
                  text: ' 높아졌어요.'.softWrapWords(),
                  style: AppTextStyles.titleS.copyWith(
                    color: AppColors.gray900,
                    fontWeight: FontWeight.w600,
                    height: 22 / 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '리프레시 필요도 ',
                  style: AppTextStyles.bodyM1.copyWith(
                    color: AppColors.gray600,
                    height: 20 / 14,
                  ),
                ),
                TextSpan(
                  text: detail.currentCareNeedLabel,
                  style: AppTextStyles.bodyM1.copyWith(
                    color: AppColors.gray600,
                    fontWeight: FontWeight.w600,
                    height: 20 / 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NecessityHelpRow extends StatelessWidget {
  const _NecessityHelpRow();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: AppMetricHelpIcon(
        label: '리프레시 필요도',
        labelStyle: AppTextStyles.labelS.copyWith(color: AppColors.gray500),
        tooltipMessage: RefreshResultDetail.necessityHelpTooltip,
        placement: AppMetricHelpTooltipPlacement.belowEnd,
        tooltipMaxWidth: 240,
      ),
    );
  }
}
