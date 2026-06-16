import '../../../../shared/models/scent_cartridge_status.dart';
import '../../../../shared/models/scent_category.dart';

/// 설정 · 디바이스 관리 화면용 연결 기기 정보.
class SettingsDeviceDetail {
  const SettingsDeviceDetail({
    required this.deviceId,
    required this.modelName,
    required this.batteryPercent,
    required this.filterRemainingPercent,
    required this.filterStatusLabel,
    required this.scentCartridge,
    required this.isConnected,
    this.linkedAtLabel,
  });

  final String deviceId;
  final String modelName;
  final int batteryPercent;
  final int filterRemainingPercent;
  final String filterStatusLabel;
  final ScentCartridgeStatus scentCartridge;
  final bool isConnected;
  final String? linkedAtLabel;

  static const fallback = SettingsDeviceDetail(
    deviceId: '',
    modelName: 'LG 퓨리헤어',
    batteryPercent: 60,
    filterRemainingPercent: 80,
    filterStatusLabel: '좋음',
    scentCartridge: ScentCartridgeStatus(
      isAttached: true,
      remainingPercent: 70,
      category: ScentCategory.floral,
    ),
    isConnected: false,
    linkedAtLabel: null,
  );
}
