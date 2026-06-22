import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/supabase_tables.dart';
import '../../../../core/services/auth_session_service.dart';
import '../../../../core/services/device_consumable_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/user_profile_service.dart';
import '../../../../shared/utils/scent_cartridge_mapper.dart';
import '../model/settings_device_detail.dart';
import '../model/settings_user_summary.dart';
import 'settings_device_mapper.dart';

class SettingsApi {
  const SettingsApi({
    this.userProfileService = const UserProfileService(),
    this.deviceConsumableService = const DeviceConsumableService(),
  });

  final UserProfileService userProfileService;
  final DeviceConsumableService deviceConsumableService;

  Future<SettingsUserSummary> fetchUserSummary({String? userId}) async {
    final resolvedUserId = AuthSessionService.resolveUserId(override: userId);

    try {
      final row = await SupabaseService.client
          .from(SupabaseTables.authUsers)
          .select('nickname, email, age, gender')
          .eq('user_id', resolvedUserId)
          .maybeSingle();

      final hairProfile = await userProfileService.fetchHairProfile(
        userId: resolvedUserId,
      );

      if (row == null) {
        return SettingsUserSummary.guest;
      }

      final json = Map<String, dynamic>.from(row);
      return SettingsUserSummary(
        nickname: json['nickname'] as String? ?? '사용자',
        email: json['email'] as String? ?? '',
        age: (json['age'] as num?)?.round(),
        gender: json['gender'] as String?,
        hairType: hairProfile?.hairType,
      );
    } catch (_) {
      return SettingsUserSummary.guest;
    }
  }

  Future<SettingsDeviceDetail> fetchLinkedDevice({String? userId}) async {
    final resolvedUserId = AuthSessionService.resolveUserId(override: userId);

    try {
      var userDevice = await _fetchUserDeviceLink(resolvedUserId);
      if (userDevice == null && kDebugMode) {
        userDevice = await _fetchUserDeviceLink(null);
      }

      if (userDevice == null) {
        return SettingsDeviceDetail.fallback;
      }

      final deviceId = userDevice['device_id'] as String;
      final device = await _fetchDevice(deviceId);
      final consumable = await _fetchConsumableStatus(deviceId);

      if (kDebugMode) {}

      final batteryPercent =
          (consumable?['battery_remaining_percent'] as num?)?.round() ?? 60;
      final filterPercent =
          (consumable?['filter_remaining_percent'] as num?)?.round() ?? 80;
      final scentCartridge = ScentCartridgeMapper.parseFromConsumable(
        consumable,
      );
      final modelName = SettingsDeviceMapper.displayModelName(
        device?['model_name'] as String?,
      );

      return SettingsDeviceDetail(
        deviceId: deviceId,
        modelName: modelName,
        batteryPercent: batteryPercent.clamp(0, 100),
        filterRemainingPercent: filterPercent.clamp(0, 100),
        filterStatusLabel: SettingsDeviceMapper.filterStatusLabel(
          filterPercent,
        ),
        scentCartridge: scentCartridge,
        isConnected: true,
        linkedAtLabel: '연결됨',
      );
    } catch (_) {
      return SettingsDeviceDetail.fallback;
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

  Future<Map<String, dynamic>?> _fetchDevice(String deviceId) async {
    final row = await SupabaseService.client
        .from(SupabaseTables.devices)
        .select('device_id, model_name')
        .eq('device_id', deviceId)
        .maybeSingle();
    if (row == null) {
      return null;
    }
    return Map<String, dynamic>.from(row);
  }

  Future<Map<String, dynamic>?> _fetchConsumableStatus(String deviceId) async {
    const extendedSelect =
        'battery_remaining_percent, filter_remaining_percent, '
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
      final row = await SupabaseService.client
          .from(SupabaseTables.consumableStatus)
          .select('battery_remaining_percent, filter_remaining_percent')
          .eq('device_id', deviceId)
          .maybeSingle();
      if (row == null) {
        return null;
      }

      final merged = Map<String, dynamic>.from(row);
      merged.addAll(await _fetchScentFieldsPartial(deviceId));
      return merged;
    }
  }

  Future<Map<String, dynamic>> _fetchScentFieldsPartial(String deviceId) async {
    const partialSelects = [
      'scent_category',
      'scent_cartridge_attached, scent_cartridge_remaining_percent',
    ];

    final merged = <String, dynamic>{};
    for (final columns in partialSelects) {
      try {
        final row = await SupabaseService.client
            .from(SupabaseTables.consumableStatus)
            .select(columns)
            .eq('device_id', deviceId)
            .maybeSingle();
        if (row != null) {
          merged.addAll(Map<String, dynamic>.from(row));
        }
      } on PostgrestException {
        // Older schemas may not expose every scent column yet.
        continue;
      }
    }
    return merged;
  }
}
