import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_text.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../app/navigation/app_system_insets.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/app_common_top_header.dart';
import '../../../../core/services/device_consumable_service.dart';
import '../../../../shared/models/scent_cartridge_status.dart';
import '../../data/api/refresh_api.dart';
import '../../data/model/refresh_result.dart';
import '../../data/refresh_mode_availability.dart';
import '../../data/refresh_mode_catalog.dart';
import '../../data/refresh_result_store.dart';
import '../refresh_scent_unavailable.dart';
import '../widgets/refresh_result_content.dart';

/// Figma 622-13066 — 리프레시 완료 후 최종 결과 화면.
class RefreshResultPage extends StatefulWidget {
  const RefreshResultPage({super.key});

  @override
  State<RefreshResultPage> createState() => _RefreshResultPageState();
}

class _RefreshResultPageState extends State<RefreshResultPage> {
  final _deviceConsumableService = const DeviceConsumableService();
  late final RefreshResult _result;
  bool _isCartridgeLoading = true;
  bool _isScentCartridgeAttached = false;

  @override
  void initState() {
    super.initState();
    _result = RefreshResultStore.instance.consume();
    _loadScentCartridgeStatus();
  }

  Future<void> _loadScentCartridgeStatus() async {
    final cartridge = await _deviceConsumableService
        .fetchScentCartridgeStatus();
    if (!mounted) {
      return;
    }
    setState(() {
      _isScentCartridgeAttached = cartridge.isAttached;
      _isCartridgeLoading = false;
    });
  }

  void _goHome() => context.goHome();

  void _onDetailTap() {
    context.pushRefreshResultDetail(result: _result);
  }

  Future<void> _onRecommendTap() async {
    var mode = _result.recommendedMode ?? resolveScentCareMode();
    mode ??= await const RefreshApi().fetchScentCarePreset();
    if (mode == null) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: AppText('향기 케어 모드를 불러오지 못했어요.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    if (!RefreshModeAvailability.isEnabled(
      mode,
      ScentCartridgeStatus(isAttached: _isScentCartridgeAttached),
    )) {
      if (!mounted) {
        return;
      }
      showRefreshScentUnavailableSnackBar(context);
      return;
    }

    if (!mounted) {
      return;
    }

    context.pushRefreshProgress(mode: mode);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _goHome();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppCommonTopHeader(
          variant: AppCommonTopHeaderVariant.gnb,
          title: '헤어 리프레시',
          onBack: _goHome,
        ),
        body: ListView(
          padding: AppSystemInsets.pageHorizontal(
            context,
            top: AppSpacing.xl,
            extraBottom: AppSpacing.xl,
          ),
          children: [
            RefreshResultContent(
              result: _result,
              onDetailTap: _onDetailTap,
              onRecommendTap: _onRecommendTap,
              isScentRecommendEnabled:
                  !_isCartridgeLoading && _isScentCartridgeAttached,
            ),
          ],
        ),
      ),
    );
  }
}
