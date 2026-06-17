import 'package:flutter/material.dart';
import 'app_text.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_component_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_text_styles.dart';

class AppChipTabBar extends StatefulWidget {
  const AppChipTabBar({
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
    this.dividerAfterIndex,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  /// 해당 인덱스 칩 오른쪽에 세로 구분선을 넣습니다.
  final int? dividerAfterIndex;
  final EdgeInsetsGeometry padding;

  @override
  State<AppChipTabBar> createState() => _AppChipTabBarState();
}

class _AppChipTabBarState extends State<AppChipTabBar> {
  final _scrollController = ScrollController();
  late List<GlobalKey> _chipKeys;

  @override
  void initState() {
    super.initState();
    _chipKeys = _createChipKeys();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelected(animate: false);
    });
  }

  @override
  void didUpdateWidget(AppChipTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabs.length != widget.tabs.length) {
      _chipKeys = _createChipKeys();
    }
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelected();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<GlobalKey> _createChipKeys() {
    return List.generate(widget.tabs.length, (_) => GlobalKey());
  }

  void _scrollToSelected({bool animate = true}) {
    final index = widget.selectedIndex;
    if (index < 0 || index >= _chipKeys.length) {
      return;
    }

    final chipContext = _chipKeys[index].currentContext;
    if (chipContext == null) {
      return;
    }

    Scrollable.ensureVisible(
      chipContext,
      alignment: 0.5,
      duration: animate ? const Duration(milliseconds: 200) : Duration.zero,
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: widget.padding,
        primary: false,
        clipBehavior: Clip.none,
        itemCount: widget.tabs.length,
        separatorBuilder: (context, index) {
          if (widget.dividerAfterIndex == index) {
            return const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 8),
                _ChipDivider(),
                SizedBox(width: 8),
              ],
            );
          }
          return const SizedBox(width: 8);
        },
        itemBuilder: (context, index) {
          final selected = index == widget.selectedIndex;
          return KeyedSubtree(
            key: _chipKeys[index],
            child: GestureDetector(
              onTap: () => widget.onChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 34,
                decoration: BoxDecoration(
                  color: selected
                      ? AppComponentColors.chipSelectedBackground
                      : AppComponentColors.chipNormalBackground,
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                ),
                alignment: Alignment.center,
                child: AppText(
                  widget.tabs[index],
                  style: AppTextStyles.labelM.copyWith(
                    color: selected
                        ? AppComponentColors.chipSelectedText
                        : AppComponentColors.chipNormalText,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 칩 탭 바를 감싸 우측 페이드와 상단 여백을 적용합니다.
class AppChipTabBarShell extends StatelessWidget {
  const AppChipTabBarShell({
    required this.child,
    this.horizontalPadding = 15,
    super.key,
  });

  final Widget child;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 18, left: horizontalPadding),
            child: Padding(
              padding: const EdgeInsets.only(right: 30),
              child: child,
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 52,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0x00FFFFFF), AppColors.gray0],
                      ),
                    ),
                  ),
                  const ColoredBox(
                    color: AppColors.gray0,
                    child: SizedBox(width: 10, height: 52),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipDivider extends StatelessWidget {
  const _ChipDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 28, color: AppColors.gray100);
  }
}
