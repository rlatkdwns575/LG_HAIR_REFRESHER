import 'package:flutter/material.dart';

import '../../app/theme/app_component_colors.dart';
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
              padding: const EdgeInsets.symmetric(horizontal: 15),
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
              Text(
                featureName ?? '기능명',
                style: AppTextStyles.titleM.copyWith(
                  color: AppComponentColors.headerTitle,
                ),
              ),
              const SizedBox(width: 17),
              Flexible(
                child: Text(
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
              _HeaderIconButton(
                icon: Icons.ios_share_outlined,
                onPressed: onShare,
              ),
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
          child: Text(
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
              if (onBack != null)
                _HeaderIconButton(
                  icon: Icons.arrow_back,
                  onPressed: onBack,
                  size: 20,
                ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
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
          _HeaderIconButton(icon: Icons.arrow_back, onPressed: onBack),
          const SizedBox(width: 8),
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

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, this.onPressed, this.size = 24});

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: size, color: AppComponentColors.headerTitle),
      padding: const EdgeInsets.all(4),
      constraints: BoxConstraints(minWidth: size, minHeight: size),
    );
  }
}
