import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/model/refresh_mode.dart';
import '../../data/refresh_assets.dart';
import 'duration_badge.dart';

enum RefreshModeCardVariant { featured, compact, list }

class RefreshModeCard extends StatelessWidget {
  const RefreshModeCard({
    required this.mode,
    this.variant = RefreshModeCardVariant.list,
    this.badgeLabel,
    this.onTap,
    this.onAction,
    this.onDelete,
    super.key,
  });

  final RefreshMode mode;
  final RefreshModeCardVariant variant;
  final String? badgeLabel;
  final VoidCallback? onTap;
  final VoidCallback? onAction;
  final VoidCallback? onDelete;

  String get _badge => badgeLabel ?? mode.category.label;

  @override
  Widget build(BuildContext context) {
    return switch (variant) {
      RefreshModeCardVariant.featured => _buildFeatured(),
      RefreshModeCardVariant.compact => _buildCompact(),
      RefreshModeCardVariant.list => _buildList(),
    };
  }

  Widget _buildFeatured() {
    return _CardShell(
      backgroundColor: AppColors.primary100,
      borderColor: AppColors.primary200,
      boxShadow: AppShadows.soft,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  mode.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleS.copyWith(
                    color: AppColors.primary900,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              DurationBadge(minutes: mode.durationMinutes),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            mode.description,
            style: AppTextStyles.bodyS.copyWith(color: AppColors.gray700),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(child: _MetaRow(mode: mode)),
              _ArrowButton(onPressed: onAction ?? onTap),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompact() {
    return _CardShell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ModeAvatar(icon: mode.icon, size: 36),
              const Spacer(),
              _Badge(label: _badge),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            mode.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.titleXs.copyWith(color: AppColors.primary900),
          ),
          const SizedBox(height: AppSpacing.xs),
          _DurationLabel(label: mode.durationLabel),
        ],
      ),
    );
  }

  Widget _buildList() {
    return _ListCardShell(
      onTap: onTap,
      onDelete: onDelete,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DurationBadge(minutes: mode.durationMinutes),
          const SizedBox(height: AppSpacing.sm),
          Text(
            mode.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.titleS.copyWith(color: AppColors.primary900),
          ),
          const SizedBox(height: 6),
          Text(
            mode.description.replaceAll('\n', ' '),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyS.copyWith(color: AppColors.gray500),
          ),
        ],
      ),
    );
  }
}

/// 목록 카드 — 본문 탭(상세 이동)과 삭제 버튼 탭 영역을 분리합니다.
class _ListCardShell extends StatelessWidget {
  const _ListCardShell({required this.child, this.onTap, this.onDelete});

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Material(
        color: AppColors.gray0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.gray100),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(onTap: onTap, child: const SizedBox.expand()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: child),
                  if (onDelete != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    _DeleteButton(onPressed: onDelete!),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({
    required this.child,
    this.backgroundColor = AppColors.gray0,
    this.borderColor = AppColors.gray100,
    this.boxShadow,
    this.onTap,
  });

  final Widget child;
  final Color backgroundColor;
  final Color borderColor;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: boxShadow,
      ),
      child: Material(
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: borderColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: const EdgeInsets.all(15), child: child),
        ),
      ),
    );
  }
}

class _ModeAvatar extends StatelessWidget {
  const _ModeAvatar({required this.icon, required this.size});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary200,
        borderRadius: BorderRadius.circular(AppRadius.md + 2),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: size * 0.5, color: AppColors.primary500),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary100,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        child: Text(
          label,
          style: AppTextStyles.labelXs.copyWith(color: AppColors.primary700),
        ),
      ),
    );
  }
}

class _DurationLabel extends StatelessWidget {
  const _DurationLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.schedule_outlined, size: 14, color: AppColors.gray500),
        const SizedBox(width: 2),
        Text(
          label,
          style: AppTextStyles.labelS.copyWith(color: AppColors.gray500),
        ),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.mode});

  final RefreshMode mode;

  @override
  Widget build(BuildContext context) {
    return Text(
      mode.tags.join('  ・  '),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.labelS.copyWith(color: AppColors.gray600),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Image.asset(
            RefreshAssets.trashIcon,
            width: 20,
            height: 20,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary500,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Center(
            child: Image.asset(
              RefreshAssets.actionArrowIcon,
              width: 20,
              height: 20,
              fit: BoxFit.contain,
              color: AppColors.gray0,
              colorBlendMode: BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
