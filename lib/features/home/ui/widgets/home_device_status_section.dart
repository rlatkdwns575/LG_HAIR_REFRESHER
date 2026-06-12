import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/app_battery_status.dart';
import '../../../../shared/widgets/app_text_link_button.dart';
import '../../data/home_assets.dart';
import '../../data/model/home_dashboard_data.dart';
import '../../data/model/home_filter_status.dart';

/// Figma `홈_첫진입 시` (710:17738) — img area 360×356 · 배터리/필터 · 디바이스 관리.
class HomeDeviceStatusSection extends StatelessWidget {
  const HomeDeviceStatusSection({
    required this.data,
    this.onDeviceManagePressed,
    super.key,
  });

  final HomeDashboardData data;
  final VoidCallback? onDeviceManagePressed;

  static const _heroHeight = 356.0;
  static const _statusLabelColor = AppColors.gray700;
  static const _statusIconSize = 24.0;
  static const _statusAreaBottomPadding = 16.0;
  static const _deviceManageButtonPadding = EdgeInsets.fromLTRB(
    16,
    AppSpacing.xs,
    9,
    AppSpacing.xs,
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: _heroHeight,
      child: DecoratedBox(
        decoration: const BoxDecoration(color: AppColors.gray100),
        child: Column(
          children: [
            Expanded(
              child: Align(
                alignment: const Alignment(0, -0.1),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.dry_cleaning_outlined,
                      size: 120,
                      color: AppColors.gray300,
                    ),
                    if (data.modelName != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        data.modelName!,
                        style: AppTextStyles.bodyS.copyWith(
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: _statusAreaBottomPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 240,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 120,
                          child: Center(
                            child: AppBatteryStatus(
                              percent: data.batteryPercent,
                              iconAsset: HomeAssets.batteryIconFor(
                                data.batteryPercent,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 120,
                          child: Center(
                            child: _FilterStatus(status: data.filterStatus),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Center(
                    child: AppTextLinkButton(
                      label: '디바이스 관리',
                      onPressed: onDeviceManagePressed,
                      contentPadding: _deviceManageButtonPadding,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterStatus extends StatelessWidget {
  const _FilterStatus({required this.status});

  final HomeFilterStatus status;

  static AppBadgeSmallVariant _badgeVariant(HomeFilterStatusTier tier) {
    return switch (tier) {
      HomeFilterStatusTier.replaceSoon => AppBadgeSmallVariant.veryHigh,
      HomeFilterStatusTier.replaceRecommended => AppBadgeSmallVariant.high,
      HomeFilterStatusTier.normal => AppBadgeSmallVariant.gray,
      HomeFilterStatusTier.fresh => AppBadgeSmallVariant.medium,
    };
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              HomeAssets.filterIcon,
              width: HomeDeviceStatusSection._statusIconSize,
              height: HomeDeviceStatusSection._statusIconSize,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '필터 상태',
              style: AppTextStyles.bodyS.copyWith(
                color: HomeDeviceStatusSection._statusLabelColor,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            AppBadge(
              label: status.label,
              smallVariant: _badgeVariant(status.tier),
              style: AppBadgeStyle.text,
            ),
          ],
        ),
      ),
    );
  }
}
