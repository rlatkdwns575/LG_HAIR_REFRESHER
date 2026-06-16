import '../../../../shared/utils/scent_cartridge_mapper.dart';

/// `CONSUMABLE_STATUS` 소모품 필드 → 화면 표시 값.
class SettingsDeviceMapper {
  const SettingsDeviceMapper._();

  static String filterStatusLabel(int filterRemainingPercent) {
    final percent = filterRemainingPercent.clamp(0, 100);

    if (percent <= 10) {
      return '교체 예정';
    }
    if (percent <= 30) {
      return '교체 권장';
    }
    if (percent <= 70) {
      return '보통';
    }
    return '좋음';
  }

  static String displayModelName(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return 'LG 퓨리헤어';
    }
    final normalized = raw.trim();
    if (normalized.toLowerCase() == 'lghairrefresher') {
      return 'LG 퓨리헤어';
    }
    return normalized;
  }

  static String scentCartridgeStatusLabel(int remainingPercent) {
    return ScentCartridgeMapper.statusLabel(remainingPercent);
  }
}
