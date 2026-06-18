import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_text.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/models/scent_cartridge_status.dart';
import '../../../../shared/models/scent_category.dart';
import '../../../../shared/utils/scent_cartridge_mapper.dart';

/// 디바이스 관리 · 소모품 안내 — 향 카트리지 안내.
class DeviceManageScentCartridgeGuide extends StatefulWidget {
  const DeviceManageScentCartridgeGuide({
    required this.cartridge,
    this.onPurchaseTap,
    super.key,
  });

  final ScentCartridgeStatus cartridge;
  final VoidCallback? onPurchaseTap;

  @override
  State<DeviceManageScentCartridgeGuide> createState() =>
      _DeviceManageScentCartridgeGuideState();
}

class _DeviceManageScentCartridgeGuideState
    extends State<DeviceManageScentCartridgeGuide> {
  late ScentCategory _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.cartridge.category ?? ScentCategory.values.first;
  }

  @override
  void didUpdateWidget(covariant DeviceManageScentCartridgeGuide oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cartridge.category != null &&
        widget.cartridge.category != oldWidget.cartridge.category) {
      _selectedCategory = widget.cartridge.category!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CartridgeStatusSection(cartridge: widget.cartridge),
        const SettingsInlineDivider(),
        _ScentTypeSection(
          selectedCategory: _selectedCategory,
          installedCategory: widget.cartridge.category,
          onCategorySelected: (category) {
            setState(() => _selectedCategory = category);
          },
        ),
        const SettingsInlineDivider(),
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                ScentCategoryDescriptions.forCategory(_selectedCategory),
                style: AppTextStyles.bodyS.copyWith(
                  color: AppColors.gray600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _PurchaseButton(onTap: widget.onPurchaseTap),
            ],
          ),
        ),
      ],
    );
  }
}

class _CartridgeStatusSection extends StatelessWidget {
  const _CartridgeStatusSection({required this.cartridge});

  final ScentCartridgeStatus cartridge;

  static TextStyle get _sectionTitleStyle => AppTextStyles.labelM.copyWith(
    color: AppColors.gray800,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get _captionStyle =>
      AppTextStyles.bodyS.copyWith(color: AppColors.gray600, height: 1.5);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText('향 카트리지', style: _sectionTitleStyle),
          const SizedBox(height: AppSpacing.sm),
          if (!cartridge.isAttached) ...[
            AppText('현재 카트리지가 장착되어 있지 않습니다.', style: _captionStyle),
            const SizedBox(height: 4),
            AppText(
              '향기 케어 모드는 카트리지 장착 후 사용할 수 있습니다.',
              style: AppTextStyles.labelS.copyWith(
                color: AppColors.gray500,
                height: 1.5,
              ),
            ),
          ] else
            _CartridgeStatusRow(cartridge: cartridge),
        ],
      ),
    );
  }
}

class _CartridgeStatusRow extends StatelessWidget {
  const _CartridgeStatusRow({required this.cartridge});

  final ScentCartridgeStatus cartridge;

  @override
  Widget build(BuildContext context) {
    final percent = (cartridge.remainingPercent ?? 0).clamp(0, 100);
    final statusLabel = ScentCartridgeMapper.statusLabel(percent);
    final categoryText = cartridge.categoryLabel ?? '향 종류 미등록';
    final barColor = _percentColor(percent);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: AppText(
            '현재 장착: $categoryText · 잔량 $percent% ($statusLabel)',
            style: AppTextStyles.bodyS.copyWith(
              color: AppColors.gray700,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Icon(Icons.water_drop_outlined, size: 16, color: barColor),
        const SizedBox(width: 4),
        AppText(
          '$percent% ($statusLabel)',
          style: AppTextStyles.labelS.copyWith(
            color: barColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        SizedBox(
          width: 72,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 6,
              backgroundColor: AppColors.gray200,
              color: barColor,
            ),
          ),
        ),
      ],
    );
  }

  static Color _percentColor(int value) {
    if (value <= 10) {
      return AppColors.red800;
    }
    if (value <= 30) {
      return AppColors.orange700;
    }
    return AppColors.blue700;
  }
}

class _ScentTypeSection extends StatelessWidget {
  const _ScentTypeSection({
    required this.selectedCategory,
    required this.installedCategory,
    required this.onCategorySelected,
  });

  final ScentCategory selectedCategory;
  final ScentCategory? installedCategory;
  final ValueChanged<ScentCategory> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            '향 종류',
            style: AppTextStyles.labelM.copyWith(
              color: AppColors.gray800,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          AppText(
            '다양한 향을 만나보세요. 교체 및 구매는 별도로 가능합니다.',
            style: AppTextStyles.labelS.copyWith(
              color: AppColors.gray500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < ScentCategory.values.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.xs),
                  _ScentCategoryChip(
                    category: ScentCategory.values[i],
                    isSelected: selectedCategory == ScentCategory.values[i],
                    isInstalled: installedCategory == ScentCategory.values[i],
                    onTap: () => onCategorySelected(ScentCategory.values[i]),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScentCategoryChip extends StatelessWidget {
  const _ScentCategoryChip({
    required this.category,
    required this.isSelected,
    required this.isInstalled,
    required this.onTap,
  });

  final ScentCategory category;
  final bool isSelected;
  final bool isInstalled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected ? AppColors.primary500 : AppColors.gray200;
    final backgroundColor = isSelected ? AppColors.primary100 : AppColors.gray0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Ink(
          width: 72,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ScentCategoryDescriptions.iconEmoji(category),
                style: const TextStyle(fontSize: 20, height: 1.1),
              ),
              const SizedBox(height: 6),
              AppText(
                category.label,
                textAlign: TextAlign.center,
                style: AppTextStyles.labelS.copyWith(
                  color: isSelected ? AppColors.primary700 : AppColors.gray700,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              if (isInstalled) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary500,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: AppText(
                    '장착 중',
                    style: AppTextStyles.labelXs.copyWith(
                      color: AppColors.gray0,
                      fontWeight: FontWeight.w600,
                      fontSize: 9,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PurchaseButton extends StatelessWidget {
  const _PurchaseButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary500,
      borderRadius: BorderRadius.circular(AppRadius.button),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.button),
        child: Container(
          width: double.infinity,
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.shopping_bag_outlined,
                size: 18,
                color: AppColors.gray0,
              ),
              const SizedBox(width: 8),
              AppText(
                'LGE.com 구매 페이지로 이동',
                style: AppTextStyles.labelM.copyWith(
                  color: AppColors.gray0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.open_in_new, size: 16, color: AppColors.gray0),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsInlineDivider extends StatelessWidget {
  const SettingsInlineDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: AppColors.gray100);
  }
}

/// 향 종류별 아이콘·설명 문구.
class ScentCategoryDescriptions {
  const ScentCategoryDescriptions._();

  static String iconEmoji(ScentCategory category) {
    return switch (category) {
      ScentCategory.cotton => '☁️',
      ScentCategory.floral => '🌸',
      ScentCategory.citrus => '🍊',
      ScentCategory.woody => '🌲',
      ScentCategory.musk => '💜',
      ScentCategory.fruity => '🍑',
    };
  }

  static String forCategory(ScentCategory category) {
    return switch (category) {
      ScentCategory.cotton => '부드럽고 포근한 코튼 향으로, 일상적인 리프레시에 잘 어울립니다.',
      ScentCategory.floral => '은은한 플로럴 향으로, 상쾌하고 여성스러운 무드를 더해 줍니다.',
      ScentCategory.citrus => '상큼한 시트러스 향으로, 기분 전환과 활력이 필요할 때 추천해요.',
      ScentCategory.woody => '깊고 따뜻한 우디 향으로, 차분하고 고급스러운 잔향을 남겨요.',
      ScentCategory.musk => '포근한 머스크 향으로, 은은하고 지속력 있는 향기를 제공합니다.',
      ScentCategory.fruity => '달콤한 프루티 향으로, 생기 있고 경쾌한 분위기를 연출해요.',
    };
  }
}
