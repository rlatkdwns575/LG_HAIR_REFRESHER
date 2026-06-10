import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_bottom_button_bar.dart';
import '../../../../shared/widgets/app_chip_tab_bar.dart';
import '../../../../shared/widgets/app_common_top_header.dart';
import '../../../refresh/data/model/refresh_mode.dart';
import '../../../refresh/data/refresh_mode_catalog.dart';
import '../../../refresh/ui/widgets/refresh_section_header.dart';
import '../widgets/refresh_shortcut_select_card.dart';

/// Figma `리프레시 바로가기 추가` — 홈 즐겨찾기 모드 선택 화면.
class HomeRefreshShortcutAddPage extends StatefulWidget {
  const HomeRefreshShortcutAddPage({super.key});

  @override
  State<HomeRefreshShortcutAddPage> createState() =>
      _HomeRefreshShortcutAddPageState();
}

class _HomeRefreshShortcutAddPageState
    extends State<HomeRefreshShortcutAddPage> {
  late final List<String> _chipTabs = [
    '전체',
    for (final category in RefreshModeCategory.values) category.label,
  ];

  int _selectedChipIndex = 0;
  String? _selectedModeId;

  RefreshModeCategory? get _selectedCategory => _selectedChipIndex == 0
      ? null
      : RefreshModeCategory.values[_selectedChipIndex - 1];

  List<RefreshMode> get _filteredModes {
    final category = _selectedCategory;
    final modes = getAllRefreshModes();
    if (category == null) {
      return modes;
    }
    return modes.where((mode) => mode.category == category).toList();
  }

  RefreshShortcutSelectState _stateFor(RefreshMode mode) {
    if (_selectedModeId == null) {
      return RefreshShortcutSelectState.normal;
    }
    return mode.id == _selectedModeId
        ? RefreshShortcutSelectState.selected
        : RefreshShortcutSelectState.dimmed;
  }

  Future<void> _openCustomCreate() async {
    final created = await context.pushRefreshCustomCreate();
    if (!mounted || created != true) {
      return;
    }
    setState(() {});
  }

  void _confirmSelection() {
    RefreshMode? selected;
    for (final mode in getAllRefreshModes()) {
      if (mode.id == _selectedModeId) {
        selected = mode;
        break;
      }
    }

    if (selected == null) {
      return;
    }

    context.pop(selected);
  }

  @override
  Widget build(BuildContext context) {
    final modes = _filteredModes;

    return Scaffold(
      backgroundColor: AppColors.gray0,
      appBar: AppCommonTopHeader(
        variant: AppCommonTopHeaderVariant.gnb,
        title: '리프레시 추가',
        onBack: () => context.pop(),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              children: [
                RefreshSectionHeader(
                  title: '리프레시 모드',
                  subtitle: '홈 바로가기에 추가할 모드를 선택하세요',
                  trailingLabel: '커스텀하기',
                  onTrailingTap: _openCustomCreate,
                ),
                _buildChipTabBar(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, AppSpacing.lg, 15, 0),
                  child: modes.isEmpty
                      ? _buildEmptyState()
                      : Column(
                          children: [
                            for (var i = 0; i < modes.length; i++) ...[
                              if (i > 0) const SizedBox(height: AppSpacing.md),
                              RefreshShortcutSelectCard(
                                mode: modes[i],
                                state: _stateFor(modes[i]),
                                onTap: () => setState(
                                  () => _selectedModeId = modes[i].id,
                                ),
                              ),
                            ],
                          ],
                        ),
                ),
              ],
            ),
          ),
          AppBottomButtonBar(
            primaryLabel: '추가하기',
            onPrimaryPressed: _selectedModeId == null
                ? null
                : _confirmSelection,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final isCustom = _selectedCategory == RefreshModeCategory.customMode;
    final message = isCustom ? '아직 제작된 커스텀 모드가 없어요' : '해당 분류의 모드가 아직 없어요';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 56),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyS.copyWith(color: AppColors.gray500),
        ),
      ),
    );
  }

  Widget _buildChipTabBar() {
    return SizedBox(
      height: 52,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 18, left: 15, right: 15),
            child: AppChipTabBar(
              tabs: _chipTabs,
              selectedIndex: _selectedChipIndex,
              onChanged: (index) => setState(() => _selectedChipIndex = index),
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
