import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_component_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/model/home_dashboard_data.dart';

/// Figma `1244:25476` Frame 4943 — `card_refresh` 162×110 × 2, gap 6.
class HomeQuickRefreshRow extends StatelessWidget {
  const HomeQuickRefreshRow({
    required this.slots,
    this.isScentCartridgeAttached = true,
    this.onFavoriteAddPressed,
    this.onModePressed,
    this.onScentUnavailable,
    super.key,
  });

  static const cardHeight = 110.0;
  static const cardGap = 6.0;
  static const cardPadding = 15.0;

  final List<HomeQuickRefreshSlot> slots;
  final bool isScentCartridgeAttached;
  final VoidCallback? onFavoriteAddPressed;
  final ValueChanged<HomeQuickRefreshMode>? onModePressed;
  final VoidCallback? onScentUnavailable;

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
      case HomeQuickSlotType.recommendedMode:
        return _RefreshModeQuickCard(
          mode: slot.mode ?? homeRecommendedModeFallback,
          leadingBadgeLabel: '추천',
          enabled: _isModeEnabled(slot.mode ?? homeRecommendedModeFallback),
          onPressed: () =>
              _handleModePressed(slot.mode ?? homeRecommendedModeFallback),
        );
      case HomeQuickSlotType.favoriteAdd:
        return _RefreshModeAddCard(onPressed: onFavoriteAddPressed);
      case HomeQuickSlotType.favoriteMode:
      case HomeQuickSlotType.frequentMode:
        final mode = slot.mode!;
        final isFavorite = slot.type == HomeQuickSlotType.favoriteMode;
        return _RefreshModeQuickCard(
          mode: mode,
          leadingBadgeLabel: isFavorite ? '즐겨찾기' : '자주쓰는',
          enabled: _isModeEnabled(mode),
          onPressed: () => _handleModePressed(mode),
        );
    }
  }

  bool _isModeEnabled(HomeQuickRefreshMode mode) {
    return !mode.requiresScentCartridge || isScentCartridgeAttached;
  }

  void _handleModePressed(HomeQuickRefreshMode mode) {
    if (!_isModeEnabled(mode)) {
      onScentUnavailable?.call();
      return;
    }
    onModePressed?.call(mode);
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
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.gray300),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    '자주 쓰는 리프레시를\n홈에 등록해보세요.',
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
    this.leadingBadgeLabel,
    this.enabled = true,
  });

  final HomeQuickRefreshMode mode;
  final VoidCallback? onPressed;
  final String? leadingBadgeLabel;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: HomeQuickRefreshRow.cardHeight,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
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
                  color: enabled
                      ? AppComponentColors.refreshCardCompactBorder
                      : AppColors.gray200,
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
                        leadingBadgeLabel: leadingBadgeLabel,
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(
                          mode.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.titleXs.copyWith(
                            color: enabled
                                ? AppColors.gray800
                                : AppColors.gray500,
                            fontWeight: FontWeight.w600,
                            height: 20 / 14,
                          ),
                        ),
                      ),
                      if (!enabled) ...[
                        Text(
                          '카트리지 없음',
                          style: AppTextStyles.labelXs.copyWith(
                            color: AppColors.gray500,
                          ),
                        ),
                      ],
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
      ),
    );
  }
}

/// Figma Frame 4955 — caption 배지 + `소요시간 N분` 한 줄.
class _BadgeRow extends StatelessWidget {
  const _BadgeRow({required this.durationLabel, this.leadingBadgeLabel});

  static const badgeGap = 4.0;

  final String durationLabel;
  final String? leadingBadgeLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _DurationBadge.height,
      child: Row(
        children: [
          if (leadingBadgeLabel != null) ...[
            _FilledBadge(label: leadingBadgeLabel!),
            const SizedBox(width: badgeGap),
          ],
          _DurationBadge(durationLabel: durationLabel),
        ],
      ),
    );
  }
}

class _FilledBadge extends StatelessWidget {
  const _FilledBadge({required this.label});

  static const height = 20.0;

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.primary500,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.labelXs.copyWith(
          fontSize: 10,
          height: 1,
          color: AppColors.primary100,
        ),
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
            color: AppColors.gray300,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(icon, size: 16, color: AppColors.gray500),
        ),
      ),
    );
  }
}
