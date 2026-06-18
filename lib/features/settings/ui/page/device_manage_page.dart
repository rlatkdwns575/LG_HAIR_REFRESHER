import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/widgets/app_text.dart';

import '../../../../app/navigation/app_system_insets.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/constants/external_urls.dart';
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

  Future<void> _openLgeHome() async {
    final uri = Uri.parse(ExternalUrls.lgeHome);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!mounted || launched) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: AppText('LGE.com 페이지를 열지 못했습니다.'),
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
                        onPurchaseTap: _openLgeHome,
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
}
