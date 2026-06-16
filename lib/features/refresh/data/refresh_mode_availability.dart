import '../../../shared/models/scent_cartridge_status.dart';
import 'model/refresh_mode.dart';

/// 향 카트리지 장착 여부에 따른 모드 사용 가능 여부.
class RefreshModeAvailability {
  const RefreshModeAvailability._();

  static const unavailableReason = '향 카트리지가 없어 사용할 수 없어요';

  static bool isEnabled(RefreshMode mode, ScentCartridgeStatus cartridge) {
    return !mode.scentYn || cartridge.isAttached;
  }

  /// 향 카트리지 미장착 시 선택 가능한 모드를 목록 상단으로 올립니다.
  /// 기존 탭별 정렬 순서는 각 그룹 안에서 유지합니다.
  static List<RefreshMode> orderSelectableFirst({
    required List<RefreshMode> modes,
    required ScentCartridgeStatus cartridge,
  }) {
    if (cartridge.isAttached) {
      return modes;
    }

    final enabled = <RefreshMode>[];
    final disabled = <RefreshMode>[];

    for (final mode in modes) {
      if (isEnabled(mode, cartridge)) {
        enabled.add(mode);
      } else {
        disabled.add(mode);
      }
    }

    return [...enabled, ...disabled];
  }
}
