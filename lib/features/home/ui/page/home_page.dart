import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/app_common_top_header.dart';
import '../../../../shared/widgets/app_confirm_dialog.dart';
import '../../data/home_shortcut_store.dart';
import '../../data/model/home_dashboard_data.dart';
import '../widgets/home_device_status_section.dart';
import '../widgets/home_navigation_card.dart';
import '../widgets/home_quick_refresh_row.dart';
import '../widgets/home_recommend_banner.dart';

/// Figma `홈_첫진입 시` (710:17738) 및 사용 이력 이후 상태.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _contentHorizontalPadding = 15.0;

  /// 기본값: 기록 없는 첫 진입.
  final _dashboardData = const HomeDashboardData();

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

    final frequent = _dashboardData.frequentMode;
    if (frequent != null) {
      slots.add(
        HomeQuickRefreshSlot(
          type: HomeQuickSlotType.frequentMode,
          mode: frequent,
        ),
      );
    }

    return slots;
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
      body: ListView(
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
              children: [
                const SizedBox(height: AppSpacing.lg),
                HomeRecommendBanner(message: _dashboardData.recommendMessage),
                if (_dashboardData.hasUsageHistory &&
                    _quickSlots.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  HomeQuickRefreshRow(
                    slots: _quickSlots,
                    onFavoriteAddPressed: _handleFavoriteAdd,
                    onModePressed: (mode) =>
                        context.pushRefreshProgress(modeName: mode.title),
                  ),
                ],
                const SizedBox(height: 6),
                HomeActionCard(
                  child: HomeTappableNavigationRow(
                    title: '헤어 리프레시',
                    onTap: context.pushRefresh,
                  ),
                ),
                const SizedBox(height: 6),
                HomeActionCard(
                  child: HomeDiagnosisRow(
                    onDiagnosisPressed: _handleDiagnosisTap,
                  ),
                ),
                const SizedBox(height: 6),
                HomeActionCard(
                  child: HomeTappableNavigationRow(
                    title: '리프레시 내역',
                    onTap: context.pushHistory,
                  ),
                ),
              ],
            ),
          ),
        ],
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
