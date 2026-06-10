import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Figma `graph` + `Frame 4956` — 160px 링 · 진행률 · 잔여 시간.
class RefreshProgressRing extends StatelessWidget {
  const RefreshProgressRing({
    required this.progress,
    required this.percentLabel,
    required this.remainingLabel,
    this.dimmed = false,
    super.key,
  });

  final double progress;
  final String percentLabel;
  final String remainingLabel;
  final bool dimmed;

  static const _ringSize = 160.0;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: dimmed ? 0.45 : 1,
      child: SizedBox(
        width: _ringSize,
        height: _ringSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: _ringSize,
              height: _ringSize,
              child: CircularProgressIndicator(
                value: progress.clamp(0, 1),
                strokeWidth: 12,
                backgroundColor: AppColors.gray100,
                color: AppColors.primary400,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  percentLabel,
                  style: AppTextStyles.headlineL.copyWith(
                    color: AppColors.primary400,
                    fontSize: 32,
                    height: 32 / 32,
                    letterSpacing: -0.64,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  remainingLabel,
                  style: AppTextStyles.bodyXs.copyWith(
                    color: AppColors.gray700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
