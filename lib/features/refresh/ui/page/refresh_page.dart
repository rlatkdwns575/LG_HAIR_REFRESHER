import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_component_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_common_top_header.dart';
import '../../../../shared/widgets/app_confirm_dialog.dart';
import '../../../../core/services/auth_session_service.dart';
import '../../../home/data/api/weather_api.dart';
import '../../data/api/custom_mode_api.dart';
import '../../data/api/refresh_api.dart';
import '../../data/api/refresh_recommend_api.dart';
import '../../data/api/refresh_recommend_fallback.dart';
import '../../data/custom_mode_cache.dart';
import '../../data/model/refresh_mode.dart';
import '../../data/refresh_mode_catalog.dart';
import '../../data/model/refresh_mode_filter.dart';
import '../widgets/refresh_mode_card.dart';
import '../widgets/refresh_section_header.dart';

class RefreshPage extends StatefulWidget {
  const RefreshPage({super.key});

  @override
  State<RefreshPage> createState() => _RefreshPageState();
}

class _RefreshPageState extends State<RefreshPage> {
  final _refreshApi = const RefreshApi();
  final _customModeApi = const CustomModeApi();
  final _weatherApi = const WeatherApi();
  final _refreshRecommendApi = const RefreshRecommendApi();

  List<RefreshMode> _presetModes = const [];
  RefreshMode? _recommendedMode;
  bool _isLoading = true;
  int _selectedChipIndex = 0;

  List<RefreshMode> get _allModes => [
    ..._presetModes,
    ...CustomModeCache.instance.modes,
  ];

  List<RefreshMode> get _filteredModes {
    final selectedTab = RefreshModeTabs.all[_selectedChipIndex];
    return filterRefreshModes(allModes: _allModes, selectedTab: selectedTab);
  }

  RefreshMode? get _featuredMode {
    if (_recommendedMode != null) {
      return _recommendedMode;
    }
    if (_presetModes.isNotEmpty) {
      return _presetModes.first;
    }
    return _allModes.isNotEmpty ? _allModes.first : null;
  }

  @override
  void initState() {
    super.initState();
    _loadModes();
  }

  Future<void> _loadModes() async {
    final userId = AuthSessionService.resolveUserId();
    final presets = await _refreshApi.fetchPresetModes();
    final customModes = await _customModeApi.fetchForUser(userId);
    RefreshPresetModeStore.instance.setPresets(presets);
    CustomModeCache.instance.setModes(customModes);

    RefreshMode? recommended;
    try {
      final environment = await _weatherApi.fetchSnapshot();
      recommended = await _refreshRecommendApi.recommendMode(
        candidates: presets,
        environment: environment,
      );
      recommended ??= RefreshRecommendFallback.pickMode(
        candidates: presets,
        environment: environment,
      );
    } catch (error, stackTrace) {
      debugPrint('RefreshPage recommend failed: $error\n$stackTrace');
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _presetModes = presets;
      _recommendedMode = recommended;
      _isLoading = false;
    });
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

    final userId = AuthSessionService.resolveUserId();
    final deleted = await _customModeApi.delete(
      userId: userId,
      modeId: mode.id,
    );

    if (!mounted) {
      return;
    }

    if (deleted && CustomModeCache.instance.removeById(mode.id)) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray0,
      appBar: AppCommonTopHeader(
        variant: AppCommonTopHeaderVariant.gnb,
        title: '헤어 리프레시',
        onBack: () => context.pop(),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              children: [
                if (_featuredMode != null) ...[
                  _buildRecommendedSection(_featuredMode!),
                  const SizedBox(height: AppSpacing.lg),
                ],
                _buildModeListSection(),
              ],
            ),
    );
  }

  Widget _buildRecommendedSection(RefreshMode mode) {
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
            mode: mode,
            variant: RefreshModeCardVariant.featured,
            badgeLabel: 'AI 추천',
            onTap: () => _onModeTap(mode),
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
    final selectedTab = RefreshModeTabs.all[_selectedChipIndex];
    final isCustom = selectedTab == RefreshModeTabs.customMode;
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
            padding: const EdgeInsets.only(top: 18),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: List.generate(RefreshModeTabs.all.length, (index) {
                  final tab = RefreshModeTabs.all[index];
                  final selected = index == _selectedChipIndex;

                  final chipWidget = GestureDetector(
                    onTap: () => setState(() => _selectedChipIndex = index),
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
                      child: Text(
                        tab,
                        style: AppTextStyles.labelM.copyWith(
                          color: selected
                              ? AppComponentColors.chipSelectedText
                              : AppComponentColors.chipNormalText,
                        ),
                      ),
                    ),
                  );

                  if (index == 1) {
                    // '커스텀 모드'와 '외출 전' 사이
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        chipWidget,
                        const SizedBox(width: 8),
                        Container(
                          width: 1,
                          height: 28,
                          color: const Color(0xFFEFF1F4),
                        ),
                        const SizedBox(width: 8),
                      ],
                    );
                  }

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      chipWidget,
                      if (index < RefreshModeTabs.all.length - 1)
                        const SizedBox(width: 8),
                    ],
                  );
                }),
              ),
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
