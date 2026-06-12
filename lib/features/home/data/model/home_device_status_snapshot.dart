import 'home_filter_status.dart';

/// `CONSUMABLE_STATUS` 기반 배터리·필터 잔량 스냅샷.
class HomeDeviceStatusSnapshot {
  const HomeDeviceStatusSnapshot({
    required this.batteryPercent,
    required this.filterStatus,
  });

  final int batteryPercent;
  final HomeFilterStatus filterStatus;
}
