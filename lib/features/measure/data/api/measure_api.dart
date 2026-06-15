import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/supabase_tables.dart';
import '../../../../core/services/auth_session_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../model/measure_result_record.dart';
import 'measure_diagnosis_generator.dart';

class MeasureApiException implements Exception {
  const MeasureApiException(this.message);

  final String message;

  @override
  String toString() => message;

  static const permissionDeniedHint =
      'Supabase SQL Editor에서 supabase/dev_read_policies.sql을 실행해주세요.';

  static String fromPostgrest(PostgrestException error) {
    final message = error.message;
    if (message.contains('permission denied') || error.code == '42501') {
      return 'MEASURE_RESULTS 테이블 권한이 없습니다. $permissionDeniedHint';
    }
    return message;
  }
}

class MeasureApi {
  const MeasureApi();

  static const resultColumns =
      'measure_id, user_device_id, hair_dust_score, hair_odor_score, '
      'total_pollution_score, hair_damage_score, hair_thickness, '
      'hair_sebum, smell_type, created_at';

  /// 연결된 기기의 `user_device_id`를 조회합니다.
  Future<String?> fetchUserDeviceId({String? userId}) async {
    final link = await _fetchUserDeviceLink(
      AuthSessionService.resolveUserId(override: userId),
    );
    return link?['user_device_id'] as String?;
  }

  /// 진단 결과를 `MEASURE_RESULTS`에 저장합니다.
  Future<MeasureResultRecord> insertDiagnosisResult({
    required MeasureResultInsertPayload payload,
    String? userId,
  }) async {
    final userDeviceId = await fetchUserDeviceId(userId: userId);
    if (userDeviceId == null || userDeviceId.isEmpty) {
      throw const MeasureApiException('연결된 기기가 없어 진단 결과를 저장할 수 없습니다.');
    }

    try {
      final row = await SupabaseService.client
          .from(SupabaseTables.measureResults)
          .insert(payload.toJson(userDeviceId))
          .select(resultColumns)
          .single();

      if (kDebugMode) {
        debugPrint('MeasureApi.insertDiagnosisResult saved: $row');
      }

      return MeasureResultRecord.fromJson(Map<String, dynamic>.from(row));
    } on PostgrestException catch (error) {
      throw MeasureApiException(
        '진단 결과 저장에 실패했습니다. (${MeasureApiException.fromPostgrest(error)})',
      );
    } catch (error, stackTrace) {
      debugPrint(
        'MeasureApi.insertDiagnosisResult failed: $error\n$stackTrace',
      );
      throw MeasureApiException('진단 결과 저장에 실패했습니다.');
    }
  }

  /// 연결된 기기의 가장 최근 진단 결과를 조회합니다.
  Future<MeasureResultRecord?> fetchLatestResult({String? userId}) async {
    final userDevice = await _fetchUserDeviceLink(
      AuthSessionService.resolveUserId(override: userId),
    );

    if (userDevice == null) {
      if (kDebugMode) {
        debugPrint(
          'MeasureApi: no USER_DEVICES link for latest measure result.',
        );
      }
      return null;
    }

    final userDeviceId = userDevice['user_device_id'] as String;

    try {
      final row = await SupabaseService.client
          .from(SupabaseTables.measureResults)
          .select(resultColumns)
          .eq('user_device_id', userDeviceId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (row == null) {
        return null;
      }

      return MeasureResultRecord.fromJson(Map<String, dynamic>.from(row));
    } on PostgrestException catch (error) {
      throw MeasureApiException(
        '진단 결과 조회에 실패했습니다. (${MeasureApiException.fromPostgrest(error)})',
      );
    } catch (error, stackTrace) {
      debugPrint('MeasureApi.fetchLatestResult failed: $error\n$stackTrace');
      return null;
    }
  }

  /// 2시간 이내 진단 결과가 있는지 확인합니다.
  Future<bool> hasRecentResult({
    String? userId,
    Duration within = const Duration(hours: 2),
  }) async {
    final record = await fetchLatestResult(userId: userId);
    if (record == null) {
      return false;
    }
    return DateTime.now().difference(record.createdAt.toLocal()) <= within;
  }

  Future<Map<String, dynamic>?> _fetchUserDeviceLink(String userId) async {
    final rows = await SupabaseService.client
        .from(SupabaseTables.userDevices)
        .select('user_device_id, user_id, device_id')
        .eq('user_id', userId)
        .limit(1);

    if (rows.isNotEmpty) {
      return Map<String, dynamic>.from(rows.first);
    }

    if (!kDebugMode) {
      return null;
    }

    final fallbackRows = await SupabaseService.client
        .from(SupabaseTables.userDevices)
        .select('user_device_id, user_id, device_id')
        .limit(1);

    if (fallbackRows.isEmpty) {
      return null;
    }

    return Map<String, dynamic>.from(fallbackRows.first);
  }
}
