import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/supabase_tables.dart';
import '../../../../core/services/auth_session_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../model/refresh_history_report.dart';
import 'history_measure_mapper.dart';
import 'history_report_builder.dart';
import 'history_session_mapper.dart';

class HistoryApi {
  const HistoryApi();

  Future<RefreshHistoryReport> fetchReport({String? userId}) async {
    final resolvedUserId = AuthSessionService.resolveUserId(override: userId);

    var userDevice = await _fetchUserDeviceLink(resolvedUserId);

    if (userDevice == null && kDebugMode) {
      userDevice = await _fetchUserDeviceLink(null);
    }

    if (userDevice == null) {
      throw HistoryApiException(
        '연결된 기기가 없어 리프레시 기록을 불러올 수 없어요. '
        'USER_DEVICES 연결과 RLS 정책을 확인해주세요.',
      );
    }

    final userDeviceId = userDevice['user_device_id'] as String;
    if (kDebugMode) {}

    final userName = await _fetchUserName(resolvedUserId);
    final measures = await _fetchMeasureResults(userDeviceId);
    final measureById = {
      for (final row in measures)
        if (row['measure_id'] is String) row['measure_id'] as String: row,
    };

    final sessions = await _fetchSessions(userDeviceId);
    final modeById = await _fetchModesById(
      sessions
          .map((row) => row['mode_id'])
          .whereType<String>()
          .toSet()
          .toList(),
    );

    final linkedMeasureIds = sessions
        .map((row) => row['measure_id'])
        .whereType<String>()
        .toSet();

    final sessionRecords = sessions
        .map(
          (row) => HistorySessionMapper.fromSessionRow(
            session: row,
            mode: modeById[row['mode_id'] as String?],
            measure: measureById[row['measure_id'] as String?],
          ),
        )
        .toList();

    final diagnosisRecords = measures
        .where((row) {
          final measureId = row['measure_id'];
          return measureId is! String || !linkedMeasureIds.contains(measureId);
        })
        .map(HistoryMeasureMapper.fromMeasureRow)
        .toList();

    final records = [...sessionRecords, ...diagnosisRecords];

    if (kDebugMode) {}

    return HistoryReportBuilder.build(records: records, userName: userName);
  }

  Future<List<Map<String, dynamic>>> _fetchSessions(String userDeviceId) async {
    try {
      final rows = await _selectSessions(
        userDeviceId,
        HistorySessionMapper.sessionColumns,
      );
      return rows;
    } on PostgrestException catch (error) {
      if (!error.message.contains('measure_id')) {
        rethrow;
      }
      return _selectSessions(
        userDeviceId,
        HistorySessionMapper.sessionColumnsWithoutMeasureId,
      );
    } catch (_) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> _selectSessions(
    String userDeviceId,
    String columns,
  ) async {
    final rows = await SupabaseService.client
        .from(SupabaseTables.refreshSessions)
        .select(columns)
        .eq('user_device_id', userDeviceId)
        .order('started_at', ascending: false);

    return [for (final row in rows) Map<String, dynamic>.from(row)];
  }

  Future<List<Map<String, dynamic>>> _fetchMeasureResults(
    String userDeviceId,
  ) async {
    try {
      final rows = await SupabaseService.client
          .from(SupabaseTables.measureResults)
          .select(HistoryMeasureMapper.resultColumns)
          .eq('user_device_id', userDeviceId)
          .order('created_at', ascending: false);

      return [for (final row in rows) Map<String, dynamic>.from(row)];
    } catch (_) {
      return const [];
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
    } catch (_) {
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
    } catch (_) {}
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
