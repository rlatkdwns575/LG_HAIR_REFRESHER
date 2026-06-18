import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_text.dart';

import '../../../../app/navigation/app_system_insets.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_box_button.dart';
import '../../../../shared/widgets/app_common_top_header.dart';
import '../../data/api/settings_api.dart';
import '../../data/model/settings_device_detail.dart';
import '../widgets/device_manage_scent_guide.dart';
import '../widgets/device_manage_status_panel.dart';
import '../widgets/settings_section_card.dart';

class DeviceManagePage extends StatefulWidget {
  const DeviceManagePage({super.key});

  @override
  State<DeviceManagePage> createState() => _DeviceManagePageState();
}

class _DeviceManagePageState extends State<DeviceManagePage> {
  final _settingsApi = const SettingsApi();

  SettingsDeviceDetail _device = SettingsDeviceDetail.fallback;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDevice();
  }

  Future<void> _loadDevice() async {
    setState(() => _isLoading = true);
    final device = await _settingsApi.fetchLinkedDevice();
    if (!mounted) {
      return;
    }
    setState(() {
      _device = device;
      _isLoading = false;
    });
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: AppText('$feature 기능은 준비 중입니다.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  String _displayDeviceId(String deviceId) {
    if (deviceId.isEmpty) {
      return '—';
    }
    if (deviceId.length <= 8) {
      return deviceId;
    }
    return '···${deviceId.substring(deviceId.length - 8)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppCommonTopHeader(
        variant: AppCommonTopHeaderVariant.gnb,
        title: '디바이스 관리',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDevice,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: AppSystemInsets.pageHorizontal(
                  context,
                  top: AppSpacing.lg,
                  extraBottom: 24,
                ),
                children: [
                  DeviceManageStatusPanel(device: _device),
                  const SizedBox(height: AppSpacing.lg),
                  SettingsSectionCard(
                    title: '기기 정보',
                    children: [
                      DeviceManageInfoRow(
                        label: '모델명',
                        value: _device.modelName,
                      ),
                      const SettingsDivider(),
                      DeviceManageInfoRow(
                        label: '기기 ID',
                        value: _displayDeviceId(_device.deviceId),
                      ),
                      const SettingsDivider(),
                      DeviceManageInfoRow(
                        label: '연결 상태',
                        value: _device.isConnected ? '연결됨' : '연결 안 됨',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SettingsSectionCard(
                    title: '소모품 안내',
                    children: [
                      DeviceManageScentCartridgeGuide(
                        cartridge: _device.scentCartridge,
                      ),
                      const SettingsDivider(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
                        child: AppText(
                          _consumableTip(_device),
                          style: AppTextStyles.bodyS.copyWith(
                            color: AppColors.gray600,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppBoxButton(
                    label: '필터 교체 가이드',
                    variant: AppBoxButtonVariant.line,
                    onPressed: () => _showComingSoon('필터 교체 가이드'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppBoxButton(
                    label: '기기 연결 해제',
                    variant: AppBoxButtonVariant.line,
                    onPressed: _device.isConnected
                        ? () => _showComingSoon('기기 연결 해제')
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppBoxButton(
                    label: '새 기기 연결',
                    variant: AppBoxButtonVariant.active,
                    onPressed: () => _showComingSoon('새 기기 연결'),
                  ),
                ],
              ),
            ),
    );
  }

  String _consumableTip(SettingsDeviceDetail device) {
    if (device.filterRemainingPercent <= 10) {
      return '필터 잔량이 거의 없습니다. 교체 후 리프레시 효과가 떨어지지 않도록 관리해 주세요.';
    }
    if (device.filterRemainingPercent <= 30) {
      return '필터 교체 시기가 가까워졌습니다. 교체 예정일을 확인하고 미리 준비해 두세요.';
    }
    if (device.batteryPercent <= 20) {
      return '배터리가 부족합니다. 충전 후 측정·리프레시를 진행하면 더 안정적으로 사용할 수 있습니다.';
    }
    return '배터리·필터·향 카트리지를 정기적으로 확인해 주세요.';
  }
}
