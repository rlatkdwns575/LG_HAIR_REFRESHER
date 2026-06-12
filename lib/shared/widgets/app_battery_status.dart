import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

/// `battery_remaining_percent` 기반 배터리 상태 표시.
///
/// Figma `951:20433` (`icon_battery_24`) — 상태별 아이콘 + 라벨 + 잔량(%).
class AppBatteryStatus extends StatelessWidget {
  const AppBatteryStatus({
    required this.percent,
    this.iconAsset,
    this.showTitle = true,
    super.key,
  });

  final int percent;
  final String? iconAsset;
  final bool showTitle;

  static const _batteryIconDir = 'lib/features/home/assets/battery';
  static const _iconStates = [0, 10, 30, 40, 50, 60, 80, 100];
  static const _iconSize = 24.0;
  static const _labelColor = AppColors.gray700;

  /// Figma `icon_battery_24` variant 중 가장 가까운 상태값.
  static int resolveIconState(int batteryRemainingPercent) {
    final clamped = batteryRemainingPercent.clamp(0, 100);

    return _iconStates.reduce(
      (best, candidate) => (candidate - clamped).abs() < (best - clamped).abs()
          ? candidate
          : best,
    );
  }

  static String iconAssetFor(int batteryRemainingPercent) {
    final state = resolveIconState(batteryRemainingPercent);
    return '$_batteryIconDir/icon_battery_24_state_$state.png';
  }

  @override
  Widget build(BuildContext context) {
    final clamped = percent.clamp(0, 100);
    final asset = iconAsset ?? iconAssetFor(clamped);

    return SizedBox(
      height: 32,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              asset,
              width: _iconSize,
              height: _iconSize,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.battery_5_bar,
                  size: _iconSize,
                  color: _labelColor,
                );
              },
            ),
            if (showTitle) ...[
              const SizedBox(width: AppSpacing.xs),
              Text(
                '배터리',
                style: AppTextStyles.bodyS.copyWith(color: _labelColor),
              ),
            ],
            const SizedBox(width: AppSpacing.xs),
            Text(
              '$clamped%',
              style: AppTextStyles.bodyS.copyWith(color: _labelColor),
            ),
          ],
        ),
      ),
    );
  }
}
