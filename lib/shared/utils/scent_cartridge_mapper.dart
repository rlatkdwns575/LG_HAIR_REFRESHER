import '../models/scent_cartridge_status.dart';
import '../models/scent_category.dart';

/// `CONSUMABLE_STATUS` 향 카트리지 필드 파싱.
class ScentCartridgeMapper {
  const ScentCartridgeMapper._();

  /// `scent_cartridge_attached` + `scent_cartridge_remaining_percent` +
  /// `scent_category` 파싱.
  ///
  /// - `scent_cartridge_attached = false` → 미장착
  /// - `scent_cartridge_attached = true` 또는 잔량(%) 값이 있으면 → 장착
  static ScentCartridgeStatus parseFromConsumable(
    Map<String, dynamic>? consumable,
  ) {
    if (consumable == null) {
      return ScentCartridgeStatus.notAttached;
    }

    if (!consumable.containsKey('scent_cartridge_attached') &&
        !consumable.containsKey('scent_cartridge_remaining_percent') &&
        !consumable.containsKey('scent_category')) {
      return ScentCartridgeStatus.notAttached;
    }

    if (consumable['scent_cartridge_attached'] == false) {
      return ScentCartridgeStatus.notAttached;
    }

    final percent = _readPercent(
      consumable['scent_cartridge_remaining_percent'],
    );
    final attachedFlag = consumable['scent_cartridge_attached'];
    final isAttached = attachedFlag == true || percent != null;

    if (!isAttached) {
      return ScentCartridgeStatus.notAttached;
    }

    return ScentCartridgeStatus(
      isAttached: true,
      remainingPercent: (percent ?? 0).clamp(0, 100),
      category: ScentCategory.fromDbValue(consumable['scent_category']),
    );
  }

  static int? _readPercent(Object? raw) {
    if (raw == null) {
      return null;
    }
    if (raw is num) {
      return raw.round();
    }
    return int.tryParse(raw.toString());
  }

  static String statusLabel(int remainingPercent) {
    final percent = remainingPercent.clamp(0, 100);

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
}
