import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/supabase_tables.dart';
import '../../shared/models/scent_cartridge_status.dart';
import '../../shared/utils/scent_cartridge_mapper.dart';
import 'auth_session_service.dart';
import 'supabase_service.dart';

/// 연결 기기의 소모품(향 카트리지 등) 상태 조회.
class DeviceConsumableService {
  const DeviceConsumableService();

  Future<ScentCartridgeStatus> fetchScentCartridgeStatus({
    String? userId,
  }) async {
    try {
      final resolvedUserId = AuthSessionService.resolveUserId(override: userId);
      var userDevice = await _fetchUserDeviceLink(resolvedUserId);
      if (userDevice == null && kDebugMode) {
        userDevice = await _fetchUserDeviceLink(null);
      }

      if (userDevice == null) {
        return ScentCartridgeStatus.notAttached;
      }

      final deviceId = userDevice['device_id'] as String;
      final consumable = await _fetchConsumableStatus(deviceId);
      if (kDebugMode) {}
      return ScentCartridgeMapper.parseFromConsumable(consumable);
    } catch (_) {
      return ScentCartridgeStatus.notAttached;
    }
  }

  Future<Map<String, dynamic>?> _fetchUserDeviceLink(String? userId) async {
    final query = SupabaseService.client
        .from(SupabaseTables.userDevices)
        .select('user_device_id, user_id, device_id');

    if (userId != null) {
      final row = await query.eq('user_id', userId).maybeSingle();
      if (row != null) {
        return Map<String, dynamic>.from(row);
      }
      return null;
    }

    final rows = await query.limit(1);
    if (rows.isEmpty) {
      return null;
    }
    return Map<String, dynamic>.from(rows.first);
  }

  Future<Map<String, dynamic>?> _fetchConsumableStatus(String deviceId) async {
    const extendedSelect =
        'scent_cartridge_attached, scent_cartridge_remaining_percent, '
        'scent_category';

    try {
      final row = await SupabaseService.client
          .from(SupabaseTables.consumableStatus)
          .select(extendedSelect)
          .eq('device_id', deviceId)
          .maybeSingle();
      if (row == null) {
        return null;
      }
      return Map<String, dynamic>.from(row);
    } on PostgrestException catch (error) {
      if (!error.message.contains('scent_cartridge') &&
          !error.message.contains('scent_category')) {
        rethrow;
      }
      return null;
    }
  }
}
