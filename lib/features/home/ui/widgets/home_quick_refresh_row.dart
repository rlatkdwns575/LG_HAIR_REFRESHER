import 'package:flutter/material.dart';

import '../../../../app/theme/app_component_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/model/home_dashboard_data.dart';

/// Figma `631:18545` Frame 4943 — `card_refresh` 162×130 × 2, gap 6.
class HomeQuickRefreshRow extends StatelessWidget {
  const HomeQuickRefreshRow({
    required this.slots,
    this.onFavoriteAddPressed,
    this.onModePressed,
    super.key,
  });

  static const cardHeight = 130.0;
  static const cardGap = 6.0;
  static const cardPadding = 15.0;

  final List<HomeQuickRefreshSlot> slots;
  final VoidCallback? onFavoriteAddPressed;
  final ValueChanged<HomeQuickRefreshMode>? onModePressed;

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: cardHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < slots.length; i++) ...[
            if (i > 0) const SizedBox(width: cardGap),
            Expanded(child: _buildSlot(slots[i])),
          ],
        ],
      ),
    );
  }

  Widget _buildSlot(HomeQuickRefreshSlot slot) {
    switch (slot.type) {
      case HomeQuickSlotType.favoriteAdd:
        return _RefreshModeAddCard(onPressed: onFavoriteAddPressed);
      case HomeQuickSlotType.favoriteMode:
      case HomeQuickSlotType.frequentMode:
        final mode = slot.mode!;
        final isFavorite = slot.type == HomeQuickSlotType.favoriteMode;
        return _RefreshModeQuickCard(
          mode: mode,
          secondaryBadgeLabel: isFavorite ? '즐겨찾기' : '자주 사용',
          onPressed: () => onModePressed?.call(mode),
        );
    }
  }
}

class _RefreshModeAddCard extends StatelessWidget {
  const _RefreshModeAddCard({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: HomeQuickRefreshRow.cardHeight,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Ink(
            padding: const EdgeInsets.all(HomeQuickRefreshRow.cardPadding),
            decoration: BoxDecoration(
              color: AppComponentColors.refreshCardAddBackground,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: AppComponentColors.refreshCardAddBorder,
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    '리프레시 모드 추가하기',
                    style: AppTextStyles.titleXs.copyWith(
                      color: AppComponentColors.refreshCardAddTitle,
                      fontWeight: FontWeight.w600,
                      height: 20 / 14,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: _NeutralCapsuleIconButton(
                    icon: Icons.add,
                    onPressed: onPressed,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RefreshModeQuickCard extends StatelessWidget {
  const _RefreshModeQuickCard({
    required this.mode,
    required this.onPressed,
    required this.secondaryBadgeLabel,
  });

  final HomeQuickRefreshMode mode;
  final VoidCallback? onPressed;
  final String secondaryBadgeLabel;

  @override
  Widget build(BuildContext context) {
    final captionLabels = [secondaryBadgeLabel];

    return SizedBox(
      height: HomeQuickRefreshRow.cardHeight,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Ink(
            padding: const EdgeInsets.all(HomeQuickRefreshRow.cardPadding),
            decoration: BoxDecoration(
              color: AppComponentColors.refreshCardCompactBackground,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: AppComponentColors.refreshCardCompactBorder,
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BadgeRow(
                      durationLabel: mode.durationLabel,
                      captionLabels: captionLabels,
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        mode.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.titleXs.copyWith(
                          color: AppComponentColors.refreshCardTitle,
                          fontWeight: FontWeight.w600,
                          height: 20 / 14,
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: _ActionCapsuleIconButton(onPressed: onPressed),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Figma Frame 4955 — `소요시간 N분` 60×20 + caption 배지 한 줄.
class _BadgeRow extends StatelessWidget {
  const _BadgeRow({required this.durationLabel, required this.captionLabels});

  static const badgeGap = 4.0;

  final String durationLabel;
  final List<String> captionLabels;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _DurationBadge.height,
      child: Row(
        children: [
          _DurationBadge(durationLabel: durationLabel),
          for (final label in captionLabels) ...[
            const SizedBox(width: badgeGap),
            Flexible(child: _OutlineBadge(label: label)),
          ],
        ],
      ),
    );
  }
}

/// Figma `badge_small` · 소요시간 — 60×20.
class _DurationBadge extends StatelessWidget {
  const _DurationBadge({required this.durationLabel});

  static const width = 60.0;
  static const height = 20.0;

  final String durationLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppComponentColors.badgeSmallPrimaryLightBackground,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Center(
          child: Text(
            '소요시간 $durationLabel',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelXs.copyWith(
              fontSize: 10,
              height: 1,
              color: AppComponentColors.badgeSmallPrimaryLightText,
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlineBadge extends StatelessWidget {
  const _OutlineBadge({required this.label});

  static const height = 20.0;

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppComponentColors.refreshCardCompactBackground,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: AppComponentColors.refreshCardOutlineBadgeBorder,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.labelXs.copyWith(
          fontSize: 10,
          height: 1,
          color: AppComponentColors.refreshCardCaption,
        ),
      ),
    );
  }
}

class _ActionCapsuleIconButton extends StatelessWidget {
  const _ActionCapsuleIconButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppComponentColors.capsuleIconOnlySecondary,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.chevron_right,
            size: 16,
            color: AppComponentColors.capsuleActiveText,
          ),
        ),
      ),
    );
  }
}

class _NeutralCapsuleIconButton extends StatelessWidget {
  const _NeutralCapsuleIconButton({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppComponentColors.capsuleIconOnlyNeutral,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            icon,
            size: 16,
            color: AppComponentColors.capsuleIconOnlyNeutralIcon,
          ),
        ),
      ),
    );
  }
}
