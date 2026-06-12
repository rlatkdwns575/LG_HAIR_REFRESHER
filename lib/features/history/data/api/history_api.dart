import 'package:flutter/foundation.dart';

import '../../../../core/constants/supabase_tables.dart';
import '../../../../core/services/auth_session_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../model/refresh_history_report.dart';
import 'history_report_builder.dart';
import 'history_session_mapper.dart';

class HistoryApi {
  const HistoryApi();

  Future<RefreshHistoryReport> fetchReport({String? userId}) async {
    final resolvedUserId = AuthSessionService.resolveUserId(override: userId);

    var userDevice = await _fetchUserDeviceLink(resolvedUserId);

    if (userDevice == null && kDebugMode) {
      debugPrint(
        'HistoryApi: no USER_DEVICES for user_id=$resolvedUserId. '
        'Trying first linked device (debug fallback).',
      );
      userDevice = await _fetchUserDeviceLink(null);
    }

    if (userDevice == null) {
      throw HistoryApiException(
        '연결된 기기가 없어 리프레시 기록을 불러올 수 없어요. '
        'USER_DEVICES 연결과 RLS 정책을 확인해주세요.',
      );
    }

    final userDeviceId = userDevice['user_device_id'] as String;
    final userName = await _fetchUserName(resolvedUserId);
    final sessions = await _fetchSessions(userDeviceId);
    final modeById = await _fetchModesById(
      sessions
          .map((row) => row['mode_id'])
          .whereType<String>()
          .toSet()
          .toList(),
    );

    final records = sessions
        .map(
          (row) => HistorySessionMapper.fromSessionRow(
            session: row,
            mode: modeById[row['mode_id'] as String?],
          ),
        )
        .toList();

    return HistoryReportBuilder.build(records: records, userName: userName);
  }

  Future<List<Map<String, dynamic>>> _fetchSessions(String userDeviceId) async {
    try {
      final rows = await SupabaseService.client
          .from(SupabaseTables.refreshSessions)
          .select(HistorySessionMapper.sessionColumns)
          .eq('user_device_id', userDeviceId)
          .order('started_at', ascending: false);

      return [for (final row in rows) Map<String, dynamic>.from(row)];
    } catch (error, stackTrace) {
      debugPrint('HistoryApi.fetchSessions failed: $error\n$stackTrace');
      rethrow;
    }
  }

  Future<Map<String, Map<String, dynamic>>> _fetchModesById(
    List<String> modeIds,
  ) async {
    if (modeIds.isEmpty) {
      return const {};
    }

    try {
      final rows = await SupabaseService.client
          .from(SupabaseTables.refreshMode)
          .select('mode_id, display_name, odor_yn, dust_yn, scent_yn')
          .inFilter('mode_id', modeIds);

      return {
        for (final row in rows)
          row['mode_id'] as String: Map<String, dynamic>.from(row),
      };
    } catch (error, stackTrace) {
      debugPrint('HistoryApi.fetchModes failed: $error\n$stackTrace');
      return const {};
    }
  }

  Future<String> _fetchUserName(String userId) async {
    try {
      final row = await SupabaseService.client
          .from(SupabaseTables.authUsers)
          .select('nickname')
          .eq('user_id', userId)
          .maybeSingle();

      final nickname = row?['nickname'] as String?;
      if (nickname != null && nickname.trim().isNotEmpty) {
        return nickname.trim();
      }
    } catch (error, stackTrace) {
      debugPrint('HistoryApi.fetchUserName failed: $error\n$stackTrace');
    }
    return '고객';
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
}

class HistoryApiException implements Exception {
  const HistoryApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
