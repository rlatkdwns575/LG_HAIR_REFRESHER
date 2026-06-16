import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/models/scent_cartridge_status.dart';
import '../../../../shared/models/scent_category.dart';
import '../../../../shared/utils/scent_cartridge_mapper.dart';

/// 디바이스 관리 · 소모품 안내 — 향 카트리지 설명.
class DeviceManageScentCartridgeGuide extends StatelessWidget {
  const DeviceManageScentCartridgeGuide({required this.cartridge, super.key});

  final ScentCartridgeStatus cartridge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '향 카트리지',
            style: AppTextStyles.labelM.copyWith(
              color: AppColors.gray800,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _currentStatusText(),
            style: AppTextStyles.bodyS.copyWith(
              color: AppColors.gray700,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '향 종류',
            style: AppTextStyles.labelS.copyWith(
              color: AppColors.gray600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '카트리지마다 아래 향 중 하나가 장착됩니다.',
            style: AppTextStyles.labelS.copyWith(color: AppColors.gray500),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final category in ScentCategory.values)
                _ScentCategoryChip(
                  label: category.label,
                  isActive: cartridge.category == category,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _tipText(),
            style: AppTextStyles.bodyS.copyWith(
              color: AppColors.gray600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  String _currentStatusText() {
    if (!cartridge.isAttached) {
      return '현재 카트리지가 장착되어 있지 않습니다. 향기 케어 모드는 카트리지 장착 후 사용할 수 있습니다.';
    }

    final percent = cartridge.remainingPercent ?? 0;
    final statusLabel = ScentCartridgeMapper.statusLabel(percent);
    final categoryText = cartridge.categoryLabel ?? '향 종류 미등록';

    return '현재 장착: $categoryText · 잔량 $percent% ($statusLabel)';
  }

  String _tipText() {
    if (!cartridge.isAttached) {
      return '코튼, 플로럴, 시트러스, 우디, 머스크, 프루티 중 원하는 향 카트리지를 장착해 주세요.';
    }

    if (cartridge.remainingPercent != null &&
        cartridge.remainingPercent! <= 10) {
      return '향 카트리지 잔량이 거의 없습니다. 동일 향 또는 다른 향으로 교체해 주세요.';
    }

    if (cartridge.category == null) {
      return '향 종류 정보를 확인할 수 없습니다. 카트리지를 다시 장착해 주세요.';
    }

    return '${cartridge.categoryLabel} 향이 장착되어 있습니다. 교체 시 같은 향 또는 다른 향 종류를 선택할 수 있습니다.';
  }
}

class _ScentCategoryChip extends StatelessWidget {
  const _ScentCategoryChip({required this.label, required this.isActive});

  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary100 : AppColors.gray50,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isActive ? AppColors.primary500 : AppColors.gray200,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelS.copyWith(
          color: isActive ? AppColors.primary700 : AppColors.gray600,
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}
