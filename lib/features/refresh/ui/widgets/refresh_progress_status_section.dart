import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_text.dart';
import '../../data/model/refresh_progress_session.dart';

/// 리프레시 진행 화면 — 현재 단계 상태 메시지 (Figma `Frame 4956` 하단).
class RefreshProgressStatusSection extends StatelessWidget {
  const RefreshProgressStatusSection({
    required this.isPaused,
    required this.step,
    required this.deviceGuide,
    required this.pausedHint,
    super.key,
  });

  final bool isPaused;
  final RefreshProgressStep step;
  final String deviceGuide;
  final String pausedHint;

  static const double _maxContentWidthPhone = 330;
  static const double _maxContentWidthTablet = 420;

  static double _maxContentWidthFor(BuildContext context) {
    if (MediaQuery.sizeOf(context).shortestSide >= 600) {
      return _maxContentWidthTablet;
    }
    return _maxContentWidthPhone;
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: _maxContentWidthFor(context)),
      child: SizedBox(
        width: double.infinity,
        child: isPaused ? _buildPausedContent() : _buildRunningContent(),
      ),
    );
  }

  Widget _buildPausedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText(
          '리프레시가 잠시 멈췄어요.',
          textAlign: TextAlign.center,
          softWrap: true,
          style: AppTextStyles.titleM.copyWith(color: AppColors.gray900),
        ),
        const SizedBox(height: AppSpacing.xs),
        AppText(
          pausedHint,
          textAlign: TextAlign.center,
          softWrap: true,
          breakLinesBySentence: true,
          style: AppTextStyles.bodyM1.copyWith(color: AppColors.gray700),
        ),
      ],
    );
  }

  Widget _buildRunningContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText(
          step.statusMessage,
          textAlign: TextAlign.center,
          softWrap: true,
          breakLinesBySentence: true,
          style: AppTextStyles.titleM.copyWith(color: AppColors.gray900),
        ),
        const SizedBox(height: AppSpacing.xs),
        AppText(
          deviceGuide,
          textAlign: TextAlign.center,
          softWrap: true,
          breakLinesBySentence: true,
          style: AppTextStyles.bodyM1.copyWith(color: AppColors.gray700),
        ),
      ],
    );
  }
}
