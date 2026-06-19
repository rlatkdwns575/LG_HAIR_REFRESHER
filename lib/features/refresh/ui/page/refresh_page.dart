import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_text.dart';

import '../../../../app/navigation/app_system_insets.dart';
import '../../../../app/router/app_navigation.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_chip_tab_bar.dart';
import '../../../../shared/widgets/app_common_top_header.dart';
import '../../../../core/services/auth_session_service.dart';
import '../../../../core/services/device_consumable_service.dart';
import '../../../../shared/models/scent_cartridge_status.dart';
import '../../../../shared/recommendation/refresh_recommend_basis.dart';
import '../../../../shared/recommendation/refresh_recommend_cache.dart';
import '../../../../shared/recommendation/refresh_recommend_service.dart';
import '../../data/api/custom_mode_api.dart';
import '../../data/api/refresh_api.dart';
import '../../data/custom_mode_cache.dart';
import '../../data/model/refresh_mode.dart';
import '../../data/refresh_mode_availability.dart';
import '../../data/refresh_mode_catalog.dart';
import '../../data/refresh_mode_filter.dart';
import '../refresh_scent_unavailable.dart';
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
  final _recommendService = RefreshRecommendService.instance;
  final _deviceConsumableService = const DeviceConsumableService();

  List<RefreshMode> _presetModes = const [];
  RefreshMode? _recommendedMode;
  String? _recommendMessage;
  RefreshRecommendBasis? _recommendBasis;
  ScentCartridgeStatus _scentCartridge = ScentCartridgeStatus.notAttached;
  bool _isLoading = true;
  int _selectedChipIndex = 0;
  int _lastCalendarSyncToken = 0;

  List<RefreshMode> get _allModes => [
    ..._presetModes,
    ...CustomModeCache.instance.modes,
  ];

  List<RefreshMode> get _filteredModes {
    final selectedTab = RefreshModeTabs.all[_selectedChipIndex];
    final filtered = filterRefreshModes(
      allModes: _allModes,
      selectedTab: selectedTab,
    );
    return RefreshModeAvailability.orderSelectableFirst(
      modes: filtered,
      cartridge: _scentCartridge,
    );
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

  @override
  void activate() {
    super.activate();
    _refreshRecommendationIfCalendarSynced();
  }

  void _refreshRecommendationIfCalendarSynced() {
    final token = RefreshRecommendCache.instance.calendarSyncToken;
    if (token == _lastCalendarSyncToken) {
      return;
    }
    _lastCalendarSyncToken = token;
    unawaited(_refreshRecommendation(forceRefresh: true));
  }

  Future<void> _refreshRecommendation({bool forceRefresh = false}) async {
    try {
      final recommendation = await _recommendService.resolve(
        forceRefresh: forceRefresh,
      );
      if (!mounted || recommendation == null) {
        return;
      }
      setState(() {
        _recommendedMode = recommendation.mode;
        _recommendMessage = recommendation.message;
        _recommendBasis = recommendation.basis;
      });
    } catch (_) {}
  }

  Future<void> _loadModes() async {
    final userId = AuthSessionService.resolveUserId();
    final presets = await _refreshApi.fetchPresetModes();
    final customModes = await _customModeApi.fetchForUser(userId);
    final cartridge = await _deviceConsumableService
        .fetchScentCartridgeStatus();
    RefreshPresetModeStore.instance.setPresets(presets);
    CustomModeCache.instance.setModes(customModes);

    RefreshMode? recommended;
    String? recommendMessage;
    RefreshRecommendBasis? recommendBasis;
    try {
      final recommendation = await _recommendService.resolve();
      if (recommendation != null) {
        recommended = recommendation.mode;
        recommendMessage = recommendation.message;
        recommendBasis = recommendation.basis;
      }
    } catch (_) {}

    if (!mounted) {
      return;
    }

    setState(() {
      _presetModes = presets;
      _recommendedMode = recommended;
      _recommendMessage = recommendMessage;
      _recommendBasis = recommendBasis;
      _scentCartridge = cartridge;
      _isLoading = false;
      _lastCalendarSyncToken = RefreshRecommendCache.instance.calendarSyncToken;
    });
  }

  Future<void> _openCustomCreate() async {
    final created = await context.pushRefreshCustomCreate();
    if (!mounted || created != true) {
      return;
    }
    setState(() {
      _selectedChipIndex = RefreshModeTabs.customTabIndex;
    });
  }

  bool _isModeEnabled(RefreshMode mode) {
    return RefreshModeAvailability.isEnabled(mode, _scentCartridge);
  }

  Future<void> _onModeTap(RefreshMode mode) async {
    if (!_isModeEnabled(mode)) {
      showRefreshScentUnavailableSnackBar(context);
      return;
    }
    final deleted = await context.pushRefreshDetailForResult(mode: mode);
    if (deleted == true && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray0,
      appBar: AppCommonTopHeader(
        variant: AppCommonTopHeaderVariant.gnb,
        title: '리프레시하기',
        onBack: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.goHome();
          }
        },
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: AppSystemInsets.onlyBottom(
                context,
                extra: AppSpacing.xl,
              ),
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
    final subtitle =
        _recommendBasis?.refreshSectionSubtitle ??
        RefreshRecommendBasis.weatherOnly.refreshSectionSubtitle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RefreshSectionHeader(title: '맞춤 리프레시', subtitle: subtitle),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: RefreshModeCard(
            mode: mode,
            variant: RefreshModeCardVariant.featured,
            badgeLabel: 'AI 추천',
            descriptionOverride: _recommendMessage,
            enabled: _isModeEnabled(mode),
            disabledReason: _isModeEnabled(mode)
                ? null
                : RefreshModeAvailability.unavailableReason,
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
          trailingLabel: '커스텀 모드 생성',
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
                        enabled: _isModeEnabled(modes[i]),
                        disabledReason: _isModeEnabled(modes[i])
                            ? null
                            : RefreshModeAvailability.unavailableReason,
                        onTap: () => _onModeTap(modes[i]),
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
    final isCustom = selectedTab == RefreshModeTabs.customModeTab;
    final message = isCustom ? '아직 제작된 커스텀 모드가 없어요' : '해당 분류의 모드가 아직 없어요';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 56),
      child: Center(
        child: AppText(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyS.copyWith(color: AppColors.gray500),
        ),
      ),
    );
  }

  Widget _buildChipTabBar() {
    return AppChipTabBarShell(
      child: AppChipTabBar(
        tabs: RefreshModeTabs.all,
        selectedIndex: _selectedChipIndex,
        onChanged: (index) => setState(() => _selectedChipIndex = index),
        dividerAfterIndex: 1,
      ),
    );
  }
}
