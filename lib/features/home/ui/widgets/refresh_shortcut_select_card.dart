import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../refresh/data/model/refresh_mode.dart';
import '../../../refresh/ui/widgets/duration_badge.dart';

enum RefreshShortcutSelectState { normal, selected, dimmed }

/// Figma `card_refresh` — 리프레시 바로가기 선택용 카드.
class RefreshShortcutSelectCard extends StatelessWidget {
  const RefreshShortcutSelectCard({
    required this.mode,
    required this.state,
    required this.onTap,
    super.key,
  });

  final RefreshMode mode;
  final RefreshShortcutSelectState state;
  final VoidCallback onTap;

  bool get _isDimmed => state == RefreshShortcutSelectState.dimmed;
  bool get _isSelected => state == RefreshShortcutSelectState.selected;

  @override
  Widget build(BuildContext context) {
    final titleColor = _isDimmed ? AppColors.gray500 : AppColors.primary900;
    final bodyColor = _isDimmed ? AppColors.gray400 : AppColors.gray700;
    final borderColor = _isSelected ? AppColors.primary500 : AppColors.gray100;
    final badgeBackground = _isDimmed
        ? AppColors.gray200
        : AppColors.primary100;
    final badgeTextColor = _isDimmed ? AppColors.gray600 : AppColors.primary700;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Material(
        color: AppColors.gray0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: borderColor, width: _isSelected ? 1.5 : 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: badgeBackground,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      child: Text(
                        mode.category.label,
                        style: AppTextStyles.labelXs.copyWith(
                          color: badgeTextColor,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        mode.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.titleS.copyWith(color: titleColor),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    DurationBadge(minutes: mode.durationMinutes),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  mode.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyS.copyWith(color: bodyColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
