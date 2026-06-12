import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'api/home_api.dart';
import 'model/home_device_status_snapshot.dart';

/// 홈 배터리·필터 상태를 실시간/주기적으로 동기화합니다.
class HomeDeviceStatusWatcher {
  HomeDeviceStatusWatcher({
    HomeApi api = const HomeApi(),
    this.pollInterval = const Duration(seconds: 8),
  }) : _api = api;

  final HomeApi _api;
  final Duration pollInterval;

  RealtimeChannel? _channel;
  Timer? _pollTimer;
  String? _deviceId;
  ValueChanged<HomeDeviceStatusSnapshot>? _onChanged;

  void start({
    required String deviceId,
    required ValueChanged<HomeDeviceStatusSnapshot> onChanged,
  }) {
    unawaited(stop());
    _deviceId = deviceId;
    _onChanged = onChanged;

    _channel = _api.subscribeDeviceStatus(
      deviceId: deviceId,
      onChanged: (snapshot) {
        if (kDebugMode) {
          debugPrint(
            'HomeDeviceStatusWatcher realtime: battery=${snapshot.batteryPercent}',
          );
        }
        _onChanged?.call(snapshot);
      },
    );

    _pollTimer = Timer.periodic(pollInterval, (_) => unawaited(refresh()));
  }

  Future<void> refresh() async {
    final deviceId = _deviceId;
    final onChanged = _onChanged;
    if (deviceId == null || onChanged == null) {
      return;
    }

    try {
      final snapshot = await _api.fetchDeviceStatusSnapshot(deviceId: deviceId);
      if (snapshot != null) {
        onChanged(snapshot);
      }
    } catch (error, stackTrace) {
      debugPrint('HomeDeviceStatusWatcher refresh failed: $error\n$stackTrace');
    }
  }

  Future<void> stop() async {
    _pollTimer?.cancel();
    _pollTimer = null;
    _deviceId = null;
    _onChanged = null;

    final channel = _channel;
    _channel = null;
    if (channel != null) {
      await _api.unsubscribeDeviceStatus(channel);
    }
  }
}
