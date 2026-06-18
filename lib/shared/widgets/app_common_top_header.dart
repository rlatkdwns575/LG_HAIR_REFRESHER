import 'package:flutter/material.dart';
import 'app_text.dart';

import '../../app/theme/app_component_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import 'app_search_text_field.dart';

enum AppCommonTopHeaderVariant { game, home, gnb, search }

/// Figma Top_Header_Common (Variants > Common).
class AppCommonTopHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const AppCommonTopHeader({
    required this.variant,
    this.featureName,
    this.pageName,
    this.title,
    this.searchController,
    this.searchHintText,
    this.onBack,
    this.onSearch,
    this.onMenu,
    this.onSettings,
    this.onClose,
    this.onAlarm,
    this.onShare,
    this.actions = const [],
    super.key,
  });

  /// 본문 [AppSystemInsets.pageHorizontal] 좌우 inset과 동일.
  static const pageHorizontalInset = 15.0;

  /// GNB 뒤로가기 아이콘(20) + 타이틀 사이 — Figma 8dp.
  static const backToTitleGap = AppSpacing.sm;

  /// GNB 뒤로가기 터치 영역 너비. 아이콘은 좌측 정렬해 본문 15dp와 맞춥니다.
  static const backIconSlotWidth = 24.0;

  final AppCommonTopHeaderVariant variant;
  final String? featureName;
  final String? pageName;
  final String? title;
  final TextEditingController? searchController;
  final String? searchHintText;
  final VoidCallback? onBack;
  final VoidCallback? onSearch;
  final VoidCallback? onMenu;
  final VoidCallback? onSettings;
  final VoidCallback? onClose;
  final VoidCallback? onAlarm;
  final VoidCallback? onShare;
  final List<Widget> actions;

  @override
  Size get preferredSize {
    return switch (variant) {
      AppCommonTopHeaderVariant.game => const Size.fromHeight(49),
      AppCommonTopHeaderVariant.home => const Size.fromHeight(44),
      AppCommonTopHeaderVariant.gnb => const Size.fromHeight(52),
      AppCommonTopHeaderVariant.search => const Size.fromHeight(52),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppComponentColors.headerBackground,
      child: SafeArea(
        bottom: false,
        child: DecoratedBox(
          decoration: variant == AppCommonTopHeaderVariant.game
              ? const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppComponentColors.headerGameBorder,
                    ),
                  ),
                )
              : const BoxDecoration(),
          child: SizedBox(
            height: preferredSize.height,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: pageHorizontalInset,
              ),
              child: switch (variant) {
                AppCommonTopHeaderVariant.game => _buildGame(),
                AppCommonTopHeaderVariant.home => _buildHome(),
                AppCommonTopHeaderVariant.gnb => _buildGnb(),
                AppCommonTopHeaderVariant.search => _buildSearch(),
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGame() {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              AppText(
                featureName ?? '기능명',
                style: AppTextStyles.titleM.copyWith(
                  color: AppComponentColors.headerTitle,
                ),
              ),
              const SizedBox(width: 17),
              Flexible(
                child: AppText(
                  pageName ?? '페이지명',
                  style: AppTextStyles.titleS.copyWith(
                    color: AppComponentColors.headerSubtitle,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onAlarm != null)
              _HeaderIconButton(
                icon: Icons.alarm_add_outlined,
                onPressed: onAlarm,
              ),
            if (onShare != null)
              _HeaderIconButton(icon: Icons.share_outlined, onPressed: onShare),
            if (onClose != null)
              _HeaderIconButton(icon: Icons.close, onPressed: onClose),
            ...actions,
          ],
        ),
      ],
    );
  }

  Widget _buildHome() {
    return Row(
      children: [
        Expanded(
          child: AppText(
            title ?? 'LG ThinQ',
            style: AppTextStyles.headlineM.copyWith(
              color: AppComponentColors.headerTitle,
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onSearch != null)
              _HeaderIconButton(icon: Icons.search, onPressed: onSearch),
            if (onMenu != null)
              _HeaderIconButton(icon: Icons.menu, onPressed: onMenu),
            ...actions,
          ],
        ),
      ],
    );
  }

  Widget _buildGnb() {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              if (onBack != null) ...[
                _HeaderBackButton(onPressed: onBack!),
                const SizedBox(width: backToTitleGap),
              ],
              Expanded(
                child: AppText(
                  title ?? '타이틀',
                  style: AppTextStyles.titleM.copyWith(
                    color: AppComponentColors.headerTitle,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onShare != null)
              _HeaderIconButton(icon: Icons.share_outlined, onPressed: onShare),
            if (onSettings != null)
              _HeaderIconButton(
                icon: Icons.settings_outlined,
                onPressed: onSettings,
              ),
            if (onClose != null)
              _HeaderIconButton(icon: Icons.close, onPressed: onClose),
            ...actions,
          ],
        ),
      ],
    );
  }

  Widget _buildSearch() {
    assert(
      searchController != null,
      'searchController is required for AppCommonTopHeaderVariant.search',
    );

    return Row(
      children: [
        if (onBack != null) ...[
          _HeaderBackButton(onPressed: onBack!, iconSize: 24),
          const SizedBox(width: backToTitleGap),
        ],
        Expanded(
          child: AppSearchTextField(
            controller: searchController!,
            hintText: searchHintText ?? '검색어를 입력하세요.',
          ),
        ),
      ],
    );
  }
}

/// GNB/Search 뒤로가기 — 아이콘 좌측을 본문 inset(15dp)에 맞추고, 타이틀과 8dp 간격.
class _HeaderBackButton extends StatelessWidget {
  const _HeaderBackButton({required this.onPressed, this.iconSize = 20});

  final VoidCallback onPressed;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppCommonTopHeader.backIconSlotWidth,
      height: iconSize,
      child: Align(
        alignment: Alignment.centerLeft,
        child: _HeaderIconButton(
          icon: Icons.arrow_back,
          onPressed: onPressed,
          size: iconSize,
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    this.icon,
    this.assetPath,
    this.onPressed,
    this.size = 24,
  }) : assert(icon != null || assetPath != null);

  final IconData? icon;
  final String? assetPath;
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    final iconWidget = assetPath != null
        ? Image.asset(
            assetPath!,
            width: size,
            height: size,
            fit: BoxFit.contain,
          )
        : Icon(icon, size: size, color: AppComponentColors.headerTitle);

    return IconButton(
      onPressed: onPressed,
      icon: iconWidget,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(minWidth: size, minHeight: size),
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
