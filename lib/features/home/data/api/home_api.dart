import 'package:flutter/foundation.dart';

import '../../../../core/constants/supabase_tables.dart';
import '../../../../core/services/app_env.dart';
import '../../../../core/services/supabase_service.dart';
import '../model/home_dashboard_data.dart';
import 'consumable_status_mapper.dart';

class HomeApi {
  const HomeApi();

  static const _defaultBatteryPercent = 60;
  static const _defaultFilterPercent = 80;

  Future<HomeDashboardData> fetchDashboard({String? userId}) async {
    final resolvedUserId = (userId ?? AppEnv.devUserId).trim();

    await _logDiagnostics(resolvedUserId);

    var userDevice = await _fetchUserDeviceLink(resolvedUserId);

    if (userDevice == null && kDebugMode) {
      debugPrint(
        'HomeApi: no USER_DEVICES for user_id=$resolvedUserId. '
        'Trying first linked device (debug fallback).',
      );
      userDevice = await _fetchUserDeviceLink(null);
      if (userDevice != null) {
        debugPrint(
          'HomeApi dev fallback: using user_id=${userDevice['user_id']}.',
        );
      }
    }

    if (userDevice == null) {
      throw HomeApiException(
        'No linked device for user_id=$resolvedUserId. '
        'AUTH_USERS에 user_id가 있어도 USER_DEVICES 연결 행이 없으면 조회되지 '
        '않습니다. Supabase SQL Editor에서 '
        'SELECT * FROM "USER_DEVICES" WHERE user_id = \'$resolvedUserId\'; '
        '를 확인하세요. RLS가 켜져 있으면 anon read policy도 필요합니다.',
      );
    }

    final userDeviceId = userDevice['user_device_id'] as String;
    final deviceId = userDevice['device_id'] as String;

    final device = await _fetchDevice(deviceId);
    final consumable = await _fetchConsumableStatus(deviceId);

    if (kDebugMode) {
      debugPrint(
        'HomeApi consumable_status for device_id=$deviceId: $consumable',
      );
    }

    final filterPercent = _readPercentField(
      consumable,
      'filter_remaining_percent',
      fallback: consumable == null ? _defaultFilterPercent : 0,
    );
    final batteryPercent = _readPercentField(
      consumable,
      'battery_remaining_percent',
      fallback: consumable == null ? _defaultBatteryPercent : 0,
    );
    final modelName = device?['model_name'] as String? ?? 'LG Hair Refresher';

    final sessionCount = await SupabaseService.client
        .from(SupabaseTables.refreshSessions)
        .count()
        .eq('user_device_id', userDeviceId);

    final hasUsageHistory = sessionCount > 0;
    final frequentMode = hasUsageHistory
        ? await _fetchFrequentMode(userDeviceId)
        : null;

    return HomeDashboardData(
      deviceName: _formatDeviceName(modelName),
      modelName: modelName,
      batteryPercent: batteryPercent,
      filterStatusLabel: ConsumableStatusMapper.filterStatusLabel(
        filterPercent,
      ),
      hasUsageHistory: hasUsageHistory,
      frequentMode: frequentMode,
    );
  }

  Future<void> _logDiagnostics(String userId) async {
    if (!kDebugMode) {
      return;
    }

    try {
      final authUser = await SupabaseService.client
          .from(SupabaseTables.authUsers)
          .select('user_id, email, nickname')
          .eq('user_id', userId)
          .maybeSingle();

      final linkedDevices = await SupabaseService.client
          .from(SupabaseTables.userDevices)
          .select('user_device_id, user_id, device_id')
          .eq('user_id', userId);

      final anyLinks = await SupabaseService.client
          .from(SupabaseTables.userDevices)
          .select('user_device_id, user_id, device_id')
          .limit(5);

      debugPrint(
        'HomeApi diagnostics for user_id=$userId: '
        'AUTH_USERS=${authUser != null ? 'found' : 'missing'}, '
        'USER_DEVICES(filtered)=${linkedDevices.length}, '
        'USER_DEVICES(any visible)=${anyLinks.length}',
      );

      if (authUser != null && linkedDevices.isEmpty && anyLinks.isNotEmpty) {
        debugPrint(
          'HomeApi: AUTH_USERS는 있지만 USER_DEVICES에 이 user_id 연결이 없습니다. '
          'USER_DEVICES.user_id=${anyLinks.first['user_id']} 등과 불일치할 수 있습니다.',
        );
      }

      if (anyLinks.isEmpty) {
        debugPrint(
          'HomeApi: USER_DEVICES 테이블에서 보이는 행이 0건입니다. '
          '데이터 미삽입 또는 RLS 정책으로 anon/publishable key read가 차단됐을 수 있습니다.',
        );
      }
    } catch (error, stackTrace) {
      debugPrint('HomeApi diagnostics failed: $error\n$stackTrace');
    }
  }

  Future<Map<String, dynamic>?> _fetchUserDeviceLink(String? userId) async {
    var query = SupabaseService.client
        .from(SupabaseTables.userDevices)
        .select('user_device_id, user_id, device_id');

    if (userId != null) {
      query = query.eq('user_id', userId);
    }

    final rows = await query.limit(1);
    if (rows.isEmpty) {
      return null;
    }

    return Map<String, dynamic>.from(rows.first);
  }

  Future<Map<String, dynamic>?> _fetchDevice(String deviceId) async {
    final row = await SupabaseService.client
        .from(SupabaseTables.devices)
        .select('model_name, serial_number')
        .eq('device_id', deviceId)
        .maybeSingle();

    if (row == null) {
      return null;
    }

    return Map<String, dynamic>.from(row);
  }

  Future<Map<String, dynamic>?> _fetchConsumableStatus(String deviceId) async {
    final row = await SupabaseService.client
        .from(SupabaseTables.consumableStatus)
        .select('filter_remaining_percent, battery_remaining_percent')
        .eq('device_id', deviceId)
        .maybeSingle();

    if (row == null) {
      return null;
    }

    return Map<String, dynamic>.from(row);
  }

  Future<HomeQuickRefreshMode?> _fetchFrequentMode(String userDeviceId) async {
    try {
      final rows = await SupabaseService.client
          .from(SupabaseTables.refreshSessions)
          .select('mode_id, duration_time')
          .eq('user_device_id', userDeviceId)
          .order('started_at', ascending: false)
          .limit(1);

      if (rows.isEmpty) {
        return null;
      }

      final session = Map<String, dynamic>.from(rows.first);
      final modeId = session['mode_id'] as String?;
      final durationTime = (session['duration_time'] as num?)?.round() ?? 0;

      if (modeId == null) {
        return null;
      }

      final presetRows = await SupabaseService.client
          .from(SupabaseTables.refreshMode)
          .select('display_name, odor_yn, dust_yn, scent_yn')
          .eq('mode_id', modeId)
          .maybeSingle();

      Map<String, dynamic>? mode = presetRows;

      mode ??= await SupabaseService.client
          .from(SupabaseTables.customModes)
          .select('display_name, odor_yn, dust_yn, scent_yn')
          .eq('mode_id', modeId)
          .maybeSingle();

      if (mode == null) {
        return null;
      }

      return HomeQuickRefreshMode(
        title: mode['display_name'] as String? ?? '퀵 리프레시',
        durationLabel: _formatDurationLabel(durationTime),
        captionItems: _buildCaptionItems(mode),
      );
    } catch (error, stackTrace) {
      debugPrint('HomeApi frequent mode lookup failed: $error\n$stackTrace');
      return null;
    }
  }

  String _formatDeviceName(String modelName) {
    final normalized = modelName.replaceAll('_', ' ').trim();
    if (normalized.isEmpty) {
      return '우리 기기';
    }
    return normalized;
  }

  String _formatDurationLabel(int durationSeconds) {
    if (durationSeconds <= 0) {
      return '0분';
    }
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    if (minutes == 0) {
      return '${seconds}초';
    }
    if (seconds == 0) {
      return '$minutes분';
    }
    return '$minutes분 $seconds초';
  }

  List<String> _buildCaptionItems(Map<String, dynamic> mode) {
    final captions = <String>[];
    if (mode['odor_yn'] == true) {
      captions.add('냄새 제거 중');
    }
    if (mode['dust_yn'] == true) {
      captions.add('먼지 제거 중');
    }
    if (mode['scent_yn'] == true) {
      captions.add('향 케어 중');
    }
    return captions;
  }

  int _readPercentField(
    Map<String, dynamic>? row,
    String fieldName, {
    required int fallback,
  }) {
    if (row == null) {
      return fallback;
    }

    for (final key in {fieldName, fieldName.toUpperCase()}) {
      final value = row[key];
      if (value is num) {
        return value.round();
      }
    }

    if (kDebugMode) {
      debugPrint(
        'HomeApi: missing $fieldName in CONSUMABLE_STATUS row keys=${row.keys}',
      );
    }

    return fallback;
  }
}

class HomeApiException implements Exception {
  const HomeApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
