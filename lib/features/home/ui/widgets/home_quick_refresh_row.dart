import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

import '../../../../app/theme/app_radius.dart';

import '../../../../app/theme/app_spacing.dart';

import '../../../../app/theme/app_text_styles.dart';

import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/app_refresh_card.dart';

import '../../data/model/home_dashboard_data.dart';

/// Figma 간편 헤어 리프레시 — 즐겨찾기·자주 사용한 모드 행.

class HomeQuickRefreshRow extends StatelessWidget {
  const HomeQuickRefreshRow({
    required this.slots,

    this.onFavoriteAddPressed,

    this.onModePressed,

    super.key,
  });

  final List<HomeQuickRefreshSlot> slots;

  final VoidCallback? onFavoriteAddPressed;

  final ValueChanged<HomeQuickRefreshMode>? onModePressed;

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        for (var i = 0; i < slots.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.sm),

          Expanded(child: _buildSlot(slots[i])),
        ],
      ],
    );
  }

  Widget _buildSlot(HomeQuickRefreshSlot slot) {
    switch (slot.type) {
      case HomeQuickSlotType.favoriteAdd:
        return _FavoriteAddCard(onPressed: onFavoriteAddPressed);

      case HomeQuickSlotType.favoriteMode:
      case HomeQuickSlotType.frequentMode:
        final mode = slot.mode!;

        final badgeLabel = slot.type == HomeQuickSlotType.favoriteMode
            ? '즐겨찾기'
            : '자주 사용한 모드';

        return AppRefreshCard(
          title: mode.title,
          captionItems: [mode.durationLabel, ...mode.captionItems],
          badgeLabel: badgeLabel,
          badgeVariant: AppBadgeSmallVariant.primaryLight,
          variant: AppRefreshCardVariant.compact,
          onTap: () => onModePressed?.call(mode),
          onTrailingPressed: () => onModePressed?.call(mode),
        );
    }
  }
}

class _FavoriteAddCard extends StatelessWidget {
  const _FavoriteAddCard({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onPressed,

        borderRadius: BorderRadius.circular(AppRadius.lg),

        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.md),

          decoration: BoxDecoration(
            color: AppColors.gray0,

            borderRadius: BorderRadius.circular(AppRadius.lg),

            border: Border.all(
              color: AppColors.gray200,
              style: BorderStyle.solid,
            ),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Container(
                width: 28,

                height: 28,

                decoration: BoxDecoration(
                  color: AppColors.gray100,

                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),

                alignment: Alignment.center,

                child: const Icon(
                  Icons.add,

                  size: 18,

                  color: AppColors.gray600,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              Text(
                '즐겨찾기 추천\n추가하기',

                style: AppTextStyles.titleXs.copyWith(color: AppColors.gray700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
