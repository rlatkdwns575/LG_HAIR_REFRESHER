import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/image_assets.dart';
import '../../../../shared/models/scent_cartridge_status.dart';
import '../../../../shared/utils/scent_cartridge_mapper.dart';
import '../../data/model/settings_device_detail.dart';

class DeviceManageStatusPanel extends StatelessWidget {
  const DeviceManageStatusPanel({required this.device, super.key});

  final SettingsDeviceDetail device;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.gray0,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          Icon(Icons.dry_cleaning_outlined, size: 96, color: AppColors.gray300),
          const SizedBox(height: AppSpacing.sm),
          Text(
            device.modelName,
            style: AppTextStyles.titleM.copyWith(color: AppColors.gray900),
          ),
          const SizedBox(height: 6),
          _ConnectionBadge(isConnected: device.isConnected),
          const SizedBox(height: AppSpacing.lg),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '소모품 잔량',
              style: AppTextStyles.labelM.copyWith(color: AppColors.gray600),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ConsumableCapacityRow(
            label: '배터리',
            icon: Image.asset(
              ImageAssets.homeBatteryIconFor(device.batteryPercent),
              width: 24,
              height: 24,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.battery_5_bar,
                  size: 24,
                  color: AppColors.gray600,
                );
              },
            ),
            percent: device.batteryPercent,
            statusLabel: device.batteryPercent <= 10
                ? '충전 필요'
                : device.batteryPercent <= 30
                ? '부족'
                : null,
          ),
          const SizedBox(height: AppSpacing.sm),
          _ConsumableCapacityRow(
            label: '필터',
            icon: Image.asset(
              ImageAssets.homeFilterIcon,
              width: 24,
              height: 24,
            ),
            percent: device.filterRemainingPercent,
            statusLabel: device.filterStatusLabel,
          ),
          const SizedBox(height: AppSpacing.sm),
          _ScentCartridgeCapacityRow(cartridge: device.scentCartridge),
        ],
      ),
    );
  }
}

class _ScentCartridgeCapacityRow extends StatelessWidget {
  const _ScentCartridgeCapacityRow({required this.cartridge});

  final ScentCartridgeStatus cartridge;

  @override
  Widget build(BuildContext context) {
    if (!cartridge.isAttached) {
      return _ConsumableCapacityRow(
        label: '향 카트리지',
        icon: const Icon(
          Icons.spa_outlined,
          size: 24,
          color: AppColors.gray400,
        ),
        emptyMessage: '카트리지 없음',
      );
    }

    final percent = cartridge.remainingPercent ?? 0;
    final statusParts = <String>[
      if (cartridge.categoryLabel != null) cartridge.categoryLabel!,
      ScentCartridgeMapper.statusLabel(percent),
    ];

    return _ConsumableCapacityRow(
      label: '향 카트리지',
      icon: const Icon(Icons.spa_outlined, size: 24, color: AppColors.gray700),
      percent: percent,
      statusLabel: statusParts.join(' · '),
    );
  }
}

class _ConsumableCapacityRow extends StatelessWidget {
  const _ConsumableCapacityRow({
    required this.label,
    required this.icon,
    this.percent,
    this.statusLabel,
    this.emptyMessage,
  });

  final String label;
  final Widget icon;
  final int? percent;
  final String? statusLabel;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    final isEmpty = emptyMessage != null;
    final clamped = (percent ?? 0).clamp(0, 100);
    final valueColor = isEmpty ? AppColors.gray400 : _percentColor(clamped);
    final valueText = isEmpty ? emptyMessage! : '$clamped%';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(AppRadius.field),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              icon,
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodyM2.copyWith(
                    color: AppColors.gray800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                valueText,
                style: AppTextStyles.bodyM2.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (!isEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                value: clamped / 100,
                minHeight: 6,
                backgroundColor: AppColors.gray200,
                color: _percentColor(clamped),
              ),
            ),
            if (statusLabel != null) ...[
              const SizedBox(height: 6),
              Text(
                statusLabel!,
                style: AppTextStyles.labelS.copyWith(color: valueColor),
              ),
            ],
          ] else ...[
            const SizedBox(height: 6),
            Text(
              '탈부착형 카트리지가 장착되어 있지 않습니다.',
              style: AppTextStyles.labelS.copyWith(color: AppColors.gray500),
            ),
          ],
        ],
      ),
    );
  }

  static Color _percentColor(int percent) {
    if (percent <= 10) {
      return AppColors.red800;
    }
    if (percent <= 30) {
      return AppColors.orange700;
    }
    if (percent <= 70) {
      return AppColors.gray600;
    }
    return AppColors.safe500;
  }
}

class _ConnectionBadge extends StatelessWidget {
  const _ConnectionBadge({required this.isConnected});

  final bool isConnected;

  @override
  Widget build(BuildContext context) {
    final color = isConnected ? AppColors.safe500 : AppColors.gray400;
    final label = isConnected ? '연결됨' : '연결 안 됨';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isConnected ? AppColors.green100 : AppColors.gray50,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.labelS.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class DeviceManageInfoRow extends StatelessWidget {
  const DeviceManageInfoRow({
    required this.label,
    required this.value,
    super.key,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyM2.copyWith(color: AppColors.gray600),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyM2.copyWith(
              color: AppColors.gray900,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
