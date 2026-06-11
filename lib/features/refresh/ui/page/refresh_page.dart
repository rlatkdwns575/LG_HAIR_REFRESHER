import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_chip_tab_bar.dart';
import '../../../../shared/widgets/app_common_top_header.dart';
import '../../../../shared/widgets/app_confirm_dialog.dart';
import '../../data/custom_mode_store.dart';
import '../../data/model/refresh_mode.dart';
import '../../data/refresh_mode_catalog.dart';
import '../widgets/refresh_mode_card.dart';
import '../widgets/refresh_section_header.dart';

class RefreshPage extends StatefulWidget {
  const RefreshPage({super.key});

  @override
  State<RefreshPage> createState() => _RefreshPageState();
}

class _RefreshPageState extends State<RefreshPage> {
  static const List<RefreshMode> _modes = RefreshMode.samples;

  late final List<String> _chipTabs = [
    '전체',
    for (final category in RefreshModeCategory.values) category.label,
  ];

  int _selectedChipIndex = 0;

  RefreshMode get _recommended => _modes.first;

  /// 기본 샘플 모드 + [CustomModeStore] 커스텀 모드.
  List<RefreshMode> get _allModes => getAllRefreshModes();

  RefreshModeCategory? get _selectedCategory => _selectedChipIndex == 0
      ? null
      : RefreshModeCategory.values[_selectedChipIndex - 1];

  List<RefreshMode> get _filteredModes {
    final category = _selectedCategory;
    if (category == null) {
      return _allModes;
    }
    return _allModes.where((mode) => mode.category == category).toList();
  }

  Future<void> _openCustomCreate() async {
    final created = await context.pushRefreshCustomCreate();
    if (!mounted || created != true) {
      return;
    }
    setState(() {});
  }

  void _onModeTap(RefreshMode mode) {
    context.pushRefreshDetail(mode: mode);
  }

  Future<void> _confirmDeleteMode(RefreshMode mode) async {
    if (!mode.isDeletable) {
      return;
    }

    final confirmed = await AppConfirmDialog.show(
      context,
      title: '해당 모드를 삭제하시겠습니까?',
      message: '모드를 삭제하면\n더 이상 해당 모드를 사용할 수 없습니다.',
      primaryLabel: '삭제',
      secondaryLabel: '취소',
    );

    if (!mounted || confirmed != true) {
      return;
    }

    if (CustomModeStore.instance.delete(mode)) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray0,
      appBar: AppCommonTopHeader(
        variant: AppCommonTopHeaderVariant.gnb,
        title: '리프레시',
        onBack: () => context.pop(),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        children: [
          _buildRecommendedSection(),
          const SizedBox(height: AppSpacing.lg),
          _buildModeListSection(),
        ],
      ),
    );
  }

  Widget _buildRecommendedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const RefreshSectionHeader(
          title: '맞춤 리프레시',
          subtitle: '측정 결과를 바탕으로 추천한 모드예요',
        ),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: RefreshModeCard(
            mode: _recommended,
            variant: RefreshModeCardVariant.featured,
            badgeLabel: 'AI 추천',
            onTap: () => _onModeTap(_recommended),
          ),
        ),
      ],
    );
  }

  Widget _buildModeListSection() {
    final modes = _filteredModes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RefreshSectionHeader(
          title: '리프레시 모드',
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
                      RefreshModeCard(
                        mode: modes[i],
                        onTap: () => _onModeTap(modes[i]),
                        onDelete: modes[i].isDeletable
                            ? () => _confirmDeleteMode(modes[i])
                            : null,
                      ),
                    ],
                  ],
                ),
        ),
      ],
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
