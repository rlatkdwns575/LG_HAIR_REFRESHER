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
import '../../../../shared/widgets/app_confirm_dialog.dart';
import '../../../../shared/widgets/app_recommend_featured_card.dart';
import '../../../../core/services/auth_session_service.dart';
import '../../../../core/services/local_calendar_service.dart';
import '../../../../core/services/device_consumable_service.dart';
import '../../../../shared/models/scent_cartridge_status.dart';
import '../../../../features/home/data/model/environment_snapshot.dart';
import '../../../../shared/recommendation/refresh_recommend_basis.dart';
import '../../../../shared/recommendation/refresh_recommend_context_resolver.dart';
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
  RefreshRecommendBasis? _recommendBasis;
  EnvironmentSnapshot? _environment;
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
        _recommendBasis = recommendation.basis;
        _environment = recommendation.environment;
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
    RefreshRecommendBasis? recommendBasis;
    EnvironmentSnapshot? environment;
    try {
      final recommendation = await _recommendService.resolve();
      if (recommendation != null) {
        recommended = recommendation.mode;
        recommendBasis = recommendation.basis;
        environment = recommendation.environment;
      }
    } catch (_) {}

    if (!mounted) {
      return;
    }

    setState(() {
      _presetModes = presets;
      _recommendedMode = recommended;
      _recommendBasis = recommendBasis;
      _environment = environment;
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
    setState(() {});
  }

  bool _isModeEnabled(RefreshMode mode) {
    return RefreshModeAvailability.isEnabled(mode, _scentCartridge);
  }

  void _onModeTap(RefreshMode mode) {
    if (!_isModeEnabled(mode)) {
      showRefreshScentUnavailableSnackBar(context);
      return;
    }
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
    final calendarStatus = LocalCalendarService().currentStatus;
    final scheduleAt =
        calendarStatus.nextEventStartAt ??
        (calendarStatus.isConnected ? DateTime.now() : null);
    final durationMinutes = (mode.durationSeconds / 60).round();
    final environment =
        _environment ?? RefreshRecommendContextResolver.neutralEnvironment;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RefreshSectionHeader(title: '맞춤 리프레시', subtitle: subtitle),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: AppRecommendFeaturedCard(
            headline: environment.dayEnvironmentHeadline,
            body: recommendFeaturedCardBody,
            metaTags: buildRecommendMetaTags(
              careName: mode.name,
              durationMinutes: durationMinutes,
              scheduleAt: scheduleAt,
            ),
            actionLabel: '헤어 상태 진단하기',
            onAction: context.pushMeasurePrepare,
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
