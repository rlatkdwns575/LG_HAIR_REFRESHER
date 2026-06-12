import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/app_common_top_header.dart';
import '../../../../shared/widgets/app_confirm_dialog.dart';
import '../../../refresh/data/api/refresh_api.dart';
import '../../../refresh/data/api/refresh_recommend_api.dart';
import '../../../refresh/data/api/refresh_recommend_fallback.dart';
import '../../../refresh/data/model/refresh_mode.dart';
import '../../../refresh/data/refresh_mode_catalog.dart';
import '../../data/api/gemini_recommend_api.dart';
import '../../data/api/home_api.dart';
import '../../data/api/weather_api.dart';
import '../../data/api/weather_recommend_fallback.dart';
import '../../data/home_device_status_watcher.dart';
import '../../data/home_recommend_cache.dart';
import '../../data/home_shortcut_store.dart';
import '../../data/model/environment_snapshot.dart';
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
  final _weatherApi = const WeatherApi();
  final _refreshApi = const RefreshApi();
  final _geminiRecommendApi = const GeminiRecommendApi();
  final _refreshRecommendApi = const RefreshRecommendApi();

  HomeDashboardData _dashboardData = const HomeDashboardData();
  bool _isLoading = true;
  String? _recommendMessage;
  HomeQuickRefreshMode? get _favoriteMode =>
      HomeShortcutStore.instance.favoriteQuickMode;

  List<HomeQuickRefreshSlot> get _quickSlots {
    if (!_dashboardData.hasUsageHistory) {
      return const [];
    }

    final slots = <HomeQuickRefreshSlot>[
      if (_favoriteMode != null)
        HomeQuickRefreshSlot(
          type: HomeQuickSlotType.favoriteMode,
          mode: _favoriteMode,
        )
      else
        const HomeQuickRefreshSlot(type: HomeQuickSlotType.favoriteAdd),
    ];

    slots.add(
      HomeQuickRefreshSlot(
        type: HomeQuickSlotType.frequentMode,
        mode: _dashboardData.frequentMode ?? homeFrequentModeFallback,
      ),
    );

    return slots;
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_deviceStatusWatcher.refresh());
    }
  }

  Future<void> _loadDashboard() async {
    final fallback = const HomeDashboardData();
    var dashboard = fallback;

    try {
      dashboard = await _homeApi.fetchDashboard();
    } catch (error, stackTrace) {
      debugPrint('Home dashboard load failed: $error\n$stackTrace');
      dashboard = fallback.copyWith(
        modelName: 'Supabase 연동 필요 · RLS/USER_DEVICES 확인',
      );
      if (error is HomeApiException) {
        debugPrint(
          'HomeApi hint: Supabase SQL Editor에서 supabase/dev_read_policies.sql '
          '실행 후 USER_DEVICES 연결을 확인하세요.',
        );
      }
    }

    String? recommendMessage = HomeRecommendCache.instance.message;

    if (recommendMessage != null) {
      debugPrint('Home banner using cached recommend message.');
    } else {
      EnvironmentSnapshot? environment;

      try {
        environment = await _weatherApi.fetchSnapshot();
        debugPrint(
          'Home weather loaded: '
          '${environment.temperatureCelsius}°C, '
          'humidity ${environment.humidityPercent}%, '
          'rain=${environment.isRaining}, snow=${environment.isSnowing}',
        );

        final recommendedMode = await _resolveRecommendedMode(environment);
        final recommendedModeName = recommendedMode?.name;

        try {
          recommendMessage = await _geminiRecommendApi.generateMessage(
            environment,
            recommendedModeName: recommendedModeName,
          );
          debugPrint('Home Gemini banner message generated.');
        } catch (error, stackTrace) {
          debugPrint('Home Gemini failed: $error\n$stackTrace');
          recommendMessage = WeatherRecommendFallback.message(
            environment,
            recommendedModeName: recommendedModeName,
          );
          debugPrint('Home banner using weather fallback message.');
        }

        HomeRecommendCache.instance.save(recommendMessage);
      } catch (error, stackTrace) {
        debugPrint('Home weather failed: $error\n$stackTrace');
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _dashboardData = dashboard;
      _recommendMessage = recommendMessage;
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

  Future<RefreshMode?> _resolveRecommendedMode(
    EnvironmentSnapshot environment,
  ) async {
    try {
      final presets = await _refreshApi.fetchPresetModes();
      RefreshPresetModeStore.instance.setPresets(presets);
      if (presets.isEmpty) {
        return null;
      }

      final recommended = await _refreshRecommendApi.recommendMode(
        candidates: presets,
        environment: environment,
      );

      return recommended ??
          RefreshRecommendFallback.pickMode(
            candidates: presets,
            environment: environment,
          );
    } catch (error, stackTrace) {
      debugPrint('Home recommend mode resolve failed: $error\n$stackTrace');
      return null;
    }
  }

  Future<void> _handleDiagnosisTap() async {
    if (!_dashboardData.hasRecentDiagnosisResult) {
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
              onRefresh: _refreshDeviceStatus,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                children: [
                  HomeDeviceStatusSection(
                    data: _dashboardData,
                    onDeviceManagePressed: () {},
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _contentHorizontalPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: _sectionGap),
                        if (_recommendMessage != null) ...[
                          HomeRecommendBanner(message: _recommendMessage!),
                          const SizedBox(height: _sectionGap),
                        ],
                        if (_dashboardData.hasUsageHistory) ...[
                          HomeQuickRefreshRow(
                            slots: _quickSlots,
                            onFavoriteAddPressed: _handleFavoriteAdd,
                            onModePressed: (mode) => context
                                .pushRefreshProgress(modeName: mode.title),
                          ),
                          const SizedBox(height: _sectionGap),
                        ],
                        HomeNavigationMenu(
                          onRefreshPressed: context.pushRefresh,
                          onDiagnosisPressed: _handleDiagnosisTap,
                          onHistoryPressed: context.pushHistory,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: kDebugMode
          ? FloatingActionButton.small(
              heroTag: 'widgetGallery',
              tooltip: 'Shared Widget Gallery',
              onPressed: context.pushWidgetGallery,
              child: const Icon(Icons.widgets_outlined, size: 20),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
