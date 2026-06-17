import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/services/device_consumable_service.dart';
import '../../../../app/layout/app_layout.dart';
import '../../../../app/navigation/app_system_insets.dart';
import '../../../../app/router/app_navigation.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/app_common_top_header.dart';
import '../../../../shared/widgets/app_confirm_dialog.dart';
import '../../../../shared/models/scent_cartridge_status.dart';
import '../../../../shared/recommendation/refresh_recommend_service.dart';
import '../../../measure/data/api/measure_api.dart';
import '../../../measure/data/api/measure_refresh_recommend_service.dart';
import '../../../measure/data/measure_result_store.dart';
import '../../../refresh/data/model/refresh_mode.dart';
import '../../../refresh/data/refresh_mode_availability.dart';
import '../../../refresh/ui/refresh_scent_unavailable.dart';
import '../../data/api/home_api.dart';
import '../../data/home_device_status_watcher.dart';
import '../../data/home_shortcut_store.dart';
import '../../data/model/home_dashboard_data.dart';
import '../../data/model/home_device_status_snapshot.dart';
import '../widgets/home_device_status_section.dart';
import '../widgets/home_navigation_menu.dart';
import '../widgets/home_quick_refresh_row.dart';
import '../widgets/home_recommend_banner.dart';

/// Figma `631:18545` — 첫진입(710:17738) · 리프레시 1회+(801:23885/801:24040).
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  static const _contentHorizontalPadding = 15.0;

  /// Figma Frame 4947 내부 섹션 간격 6px.
  static const _sectionGap = 6.0;
  final _homeApi = const HomeApi();
  final _deviceStatusWatcher = HomeDeviceStatusWatcher();
  final _measureApi = const MeasureApi();
  final _measureRecommendService = MeasureRefreshRecommendService();
  final _recommendService = RefreshRecommendService.instance;
  final _deviceConsumableService = const DeviceConsumableService();

  HomeDashboardData _dashboardData = const HomeDashboardData();
  bool _isLoading = true;
  bool _isScentCartridgeAttached = false;
  String? _recommendMessage;
  RefreshMode? _recommendedRefreshMode;
  HomeQuickRefreshMode? _recommendedQuickMode;
  bool _useRecommendForQuickSlot = false;
  HomeQuickRefreshMode? get _favoriteMode =>
      HomeShortcutStore.instance.favoriteQuickMode;

  HomeQuickRefreshSlot _primaryQuickSlot() {
    if (_useRecommendForQuickSlot && _recommendedQuickMode != null) {
      return HomeQuickRefreshSlot(
        type: HomeQuickSlotType.recommendedMode,
        mode: _recommendedQuickMode,
      );
    }

    final mode = _dashboardData.hasUsageHistory
        ? (_dashboardData.frequentMode ?? homeFrequentModeFallback)
        : homeFrequentModeFallback;

    return HomeQuickRefreshSlot(
      type: HomeQuickSlotType.frequentMode,
      mode: mode,
    );
  }

  List<HomeQuickRefreshSlot> get _quickSlots {
    if (!_dashboardData.hasUsageHistory) {
      return [
        _primaryQuickSlot(),
        const HomeQuickRefreshSlot(type: HomeQuickSlotType.favoriteAdd),
      ];
    }

    return [
      _primaryQuickSlot(),
      if (_favoriteMode != null)
        HomeQuickRefreshSlot(
          type: HomeQuickSlotType.favoriteMode,
          mode: _favoriteMode,
        )
      else
        const HomeQuickRefreshSlot(type: HomeQuickSlotType.favoriteAdd),
    ];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadDashboard();
  }

  @override
  void dispose() {
    unawaited(_deviceStatusWatcher.stop());
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void activate() {
    super.activate();
    unawaited(_refreshRecentDiagnosisFlag());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshDeviceStatus());
      unawaited(_refreshRecentDiagnosisFlag());
    }
  }

  Future<void> _loadDashboard() async {
    final fallback = const HomeDashboardData();
    var dashboard = fallback;

    try {
      dashboard = await _homeApi.fetchDashboard();
    } catch (error, _) {
      dashboard = fallback.copyWith(
        modelName: error is HomeApiException
            ? error.message
            : 'Supabase 연동 필요 · RLS/USER_DEVICES 확인',
      );
    }

    String? recommendMessage;
    RefreshMode? recommendedRefreshMode;
    HomeQuickRefreshMode? recommendedQuickMode;
    var useRecommendForQuickSlot = false;

    try {
      final recommendation = await _recommendService.resolve();
      if (recommendation != null) {
        recommendMessage = recommendation.message;
        recommendedRefreshMode = recommendation.mode;
        recommendedQuickMode = recommendation.mode.toHomeQuickRefreshMode();
        useRecommendForQuickSlot = true;
      }
    } catch (_) {}

    if (!mounted) {
      return;
    }

    var hasRecentDiagnosis = await _fetchHasRecentDiagnosisResult();

    final cartridge = await _deviceConsumableService
        .fetchScentCartridgeStatus();

    setState(() {
      _dashboardData = dashboard.copyWith(
        hasRecentDiagnosisResult: hasRecentDiagnosis,
      );
      _recommendMessage = recommendMessage;
      _recommendedRefreshMode = recommendedRefreshMode;
      _recommendedQuickMode = recommendedQuickMode;
      _useRecommendForQuickSlot = useRecommendForQuickSlot;
      _isScentCartridgeAttached = cartridge.isAttached;
      _isLoading = false;
    });

    final deviceId = dashboard.linkedDeviceId;
    if (deviceId != null) {
      _deviceStatusWatcher.start(
        deviceId: deviceId,
        onChanged: _applyDeviceStatusSnapshot,
      );
    }
  }

  void _applyDeviceStatusSnapshot(HomeDeviceStatusSnapshot snapshot) {
    if (!mounted) {
      return;
    }

    final currentFilter = _dashboardData.filterStatus;
    final hasChanges =
        _dashboardData.batteryPercent != snapshot.batteryPercent ||
        currentFilter.tier != snapshot.filterStatus.tier ||
        currentFilter.label != snapshot.filterStatus.label;

    if (!hasChanges) {
      return;
    }

    setState(() {
      _dashboardData = _dashboardData.copyWith(
        batteryPercent: snapshot.batteryPercent,
        filterStatus: snapshot.filterStatus,
      );
    });
  }

  Future<void> _refreshDeviceStatus() => _deviceStatusWatcher.refresh();

  Future<bool> _fetchHasRecentDiagnosisResult() async {
    try {
      return await _measureApi.hasRecentResult();
    } catch (_) {
      return false;
    }
  }

  Future<void> _refreshRecentDiagnosisFlag() async {
    final hasRecent = await _fetchHasRecentDiagnosisResult();
    if (!mounted || _dashboardData.hasRecentDiagnosisResult == hasRecent) {
      return;
    }
    setState(() {
      _dashboardData = _dashboardData.copyWith(
        hasRecentDiagnosisResult: hasRecent,
      );
    });
  }

  Future<void> _refreshHomeIndicators() async {
    await Future.wait([_refreshDeviceStatus(), _refreshRecentDiagnosisFlag()]);
  }

  Future<void> _handleDiagnosisTap() async {
    final hasRecent = await _fetchHasRecentDiagnosisResult();
    if (!mounted) {
      return;
    }

    if (_dashboardData.hasRecentDiagnosisResult != hasRecent) {
      setState(() {
        _dashboardData = _dashboardData.copyWith(
          hasRecentDiagnosisResult: hasRecent,
        );
      });
    }

    if (!hasRecent) {
      context.pushMeasure();
      return;
    }

    final result = await AppConfirmDialog.show(
      context,
      title: '이전 진단 결과가 존재합니다.',
      message: '지금의 헤어 상태를 정확히 보려면\n재진단이 필요해요.',
      primaryLabel: '재진단하기',
      secondaryLabel: '결과 보기',
    );

    if (!mounted) {
      return;
    }

    if (result == true) {
      context.pushMeasure();
    } else if (result == false) {
      try {
        final measureResult = await _measureRecommendService
            .buildMeasureResult();
        MeasureResultStore.instance.setPending(measureResult);
      } catch (_) {}
      if (!mounted) {
        return;
      }
      context.pushMeasureResult();
    }
  }

  Future<void> _handleFavoriteAdd() async {
    final selected = await context.pushRefreshShortcutAdd();
    if (!mounted || selected == null) {
      return;
    }

    HomeShortcutStore.instance.setFavorite(selected);
    setState(() {});
  }

  void _handleRecommendBannerTap() {
    final mode = _recommendedRefreshMode;
    if (mode == null) {
      return;
    }

    if (!RefreshModeAvailability.isEnabled(
      mode,
      ScentCartridgeStatus(isAttached: _isScentCartridgeAttached),
    )) {
      showRefreshScentUnavailableSnackBar(context);
      return;
    }

    context.pushRefreshDetail(mode: mode);
  }

  // 즐겨찾기 수정 UI — HomeQuickRefreshRow.onFavoriteEditPressed 연결 시 활성화
  // ignore: unused_element
  Future<void> _handleFavoriteEdit() async {
    final current = HomeShortcutStore.instance.favoriteMode;
    if (current == null) {
      return;
    }

    final selected = await context.pushRefreshShortcutAdd(initialMode: current);
    if (!mounted || selected == null) {
      return;
    }

    HomeShortcutStore.instance.setFavorite(selected);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      appBar: AppCommonTopHeader(
        variant: AppCommonTopHeaderVariant.gnb,
        title: _dashboardData.deviceName,
        onSettings: context.pushSettings,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshHomeIndicators,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: AppSystemInsets.onlyBottom(
                  context,
                  extra: AppSpacing.xl,
                ),
                children: [
                  HomeDeviceStatusSection(
                    data: _dashboardData,
                    onDeviceManagePressed: context.pushDeviceManage,
                  ),
                  AppMaxWidthPageShell(
                    backgroundColor: AppColors.homeBackground,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: _contentHorizontalPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: _sectionGap),
                          if (_recommendMessage != null) ...[
                            HomeRecommendBanner(
                              message: _recommendMessage!,
                              onTap: _recommendedRefreshMode == null
                                  ? null
                                  : _handleRecommendBannerTap,
                            ),
                            const SizedBox(height: _sectionGap),
                          ],
                          HomeQuickRefreshRow(
                            slots: _quickSlots,
                            isScentCartridgeAttached: _isScentCartridgeAttached,
                            onFavoriteAddPressed: _handleFavoriteAdd,
                            onScentUnavailable: () =>
                                showRefreshScentUnavailableSnackBar(context),
                            onModePressed: (mode) => context
                                .pushRefreshProgress(modeName: mode.title),
                          ),
                          const SizedBox(height: _sectionGap),
                          HomeNavigationMenu(
                            onRefreshPressed: context.pushRefresh,
                            onDiagnosisPressed: _handleDiagnosisTap,
                            onHistoryPressed: context.pushHistory,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
