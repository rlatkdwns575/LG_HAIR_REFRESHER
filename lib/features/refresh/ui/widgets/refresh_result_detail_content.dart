import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_section_divider.dart';
import '../../data/model/refresh_result_detail.dart';
import 'refresh_result_detail_metric_bars.dart';
import 'refresh_result_detail_status_section.dart';

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
              const SizedBox(height: 20),
              _buildHeadline(),
              const SizedBox(height: 20),
              RefreshResultDetailMetricBars(metrics: detail.metrics),
              const SizedBox(height: 8),
              _SummaryMessageCard(message: detail.summaryMessage),
              const SizedBox(height: 6),
              const _NecessityHelpRow(),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '리프레시 결과',
          style: AppTextStyles.titleL.copyWith(
            color: AppColors.gray900,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '결과는 2시간 동안 유지되며, 이후 기록에서 확인할 수 있어요.',
          style: AppTextStyles.bodyS.copyWith(
            color: AppColors.gray500,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _buildHeadline() {
    final (modeBlueText, modeBlackSuffix) = _modeHeadlineParts;
    final modeLineStyle = AppTextStyles.bodyM2.copyWith(
      fontWeight: FontWeight.w600,
      height: 1.4,
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
                  text: modeBlueText,
                  style: modeLineStyle.copyWith(color: AppColors.primary500),
                ),
                TextSpan(
                  text: modeBlackSuffix,
                  style: modeLineStyle.copyWith(color: AppColors.gray900),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '리프레시 필요도가',
            style: AppTextStyles.titleM.copyWith(
              color: AppColors.gray900,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: detail.necessityReductionLabel,
                  style: AppTextStyles.headlineL.copyWith(
                    color: AppColors.gray900,
                    fontWeight: FontWeight.w800,
                    fontSize: 44,
                    height: 1.1,
                  ),
                ),
                TextSpan(
                  text: ' 낮아졌어요.',
                  style: AppTextStyles.titleM.copyWith(
                    color: AppColors.gray900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '현재 케어 필요도 ${detail.currentCareNeedLabel}',
            style: AppTextStyles.bodyS.copyWith(
              color: AppColors.gray600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryMessageCard extends StatelessWidget {
  const _SummaryMessageCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: AppTextStyles.bodyXs.copyWith(
          color: AppColors.gray900,
          height: 1.55,
        ),
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '리프레시 필요도',
            style: AppTextStyles.bodyS.copyWith(
              color: AppColors.gray600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 3),
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gray400),
            ),
            alignment: Alignment.center,
            child: Text(
              '?',
              style: AppTextStyles.labelXs.copyWith(
                color: AppColors.gray500,
                fontSize: 10,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
