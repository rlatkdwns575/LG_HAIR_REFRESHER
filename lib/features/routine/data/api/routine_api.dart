import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/supabase_tables.dart';
import '../../../../core/services/auth_session_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../model/routine.dart';

/// `REFRESH_RECOMMEND_ALARMS` 테이블 CRUD.
///
/// RLS 전제: `user_id = auth.uid()` 행만 접근 가능.
class RoutineApi {
  const RoutineApi();

  Future<List<Routine>> fetchAll({String? userId}) async {
    final resolvedUserId = _resolveUserId(userId);

    final rows = await SupabaseService.client
        .from(SupabaseTables.refreshRecommendAlarms)
        .select()
        .eq('user_id', resolvedUserId)
        .order('created_at', ascending: false);

    return [
      for (final row in rows) Routine.fromJson(Map<String, dynamic>.from(row)),
    ];
  }

  /// 모드 선택 드롭다운용 프리셋 모드 목록(`REFRESH_MODE`).
  Future<List<RoutineModeOption>> fetchModeOptions() async {
    try {
      final rows = await SupabaseService.client
          .from(SupabaseTables.refreshMode)
          .select('mode_id, display_name')
          .eq('custom_yn', false)
          .order('display_name');

      return [
        for (final row in rows)
          if (row['mode_id'] is String)
            RoutineModeOption(
              id: row['mode_id'] as String,
              name: (row['display_name'] as String?) ?? '이름 없는 모드',
            ),
      ];
    } catch (error, stackTrace) {
      debugPrint('RoutineApi.fetchModeOptions failed: $error\n$stackTrace');
      return const [];
    }
  }

  Future<Routine> create(Routine routine, {String? userId}) async {
    final resolvedUserId = _resolveUserId(userId);

    if (routine.modeId == null) {
      throw const RoutineApiException('리프레시 모드를 선택해주세요.');
    }

    final payload = routine.toJson()..['user_id'] = resolvedUserId;

    try {
      final row = await SupabaseService.client
          .from(SupabaseTables.refreshRecommendAlarms)
          .insert(payload)
          .select()
          .single();
      return Routine.fromJson(Map<String, dynamic>.from(row));
    } on PostgrestException catch (error, stackTrace) {
      debugPrint('RoutineApi.create failed: $error\n$stackTrace');
      throw RoutineApiException(_messageFromPostgrest(error));
    } catch (error, stackTrace) {
      debugPrint('RoutineApi.create failed: $error\n$stackTrace');
      throw const RoutineApiException('루틴을 저장하지 못했어요. 잠시 후 다시 시도해주세요.');
    }
  }

  Future<Routine> update(Routine routine) async {
    final id = routine.id;
    if (id == null) {
      throw const RoutineApiException('수정할 루틴 정보가 없어요.');
    }

    final payload = routine.toJson()
      ..['updated_at'] = DateTime.now().toUtc().toIso8601String();

    try {
      final row = await SupabaseService.client
          .from(SupabaseTables.refreshRecommendAlarms)
          .update(payload)
          .eq('alarm_id', id)
          .select()
          .single();
      return Routine.fromJson(Map<String, dynamic>.from(row));
    } on PostgrestException catch (error, stackTrace) {
      debugPrint('RoutineApi.update failed: $error\n$stackTrace');
      throw RoutineApiException(_messageFromPostgrest(error));
    } catch (error, stackTrace) {
      debugPrint('RoutineApi.update failed: $error\n$stackTrace');
      throw const RoutineApiException('루틴을 수정하지 못했어요. 잠시 후 다시 시도해주세요.');
    }
  }

  Future<void> delete(String id) async {
    try {
      await SupabaseService.client
          .from(SupabaseTables.refreshRecommendAlarms)
          .delete()
          .eq('alarm_id', id);
    } on PostgrestException catch (error, stackTrace) {
      debugPrint('RoutineApi.delete failed: $error\n$stackTrace');
      throw RoutineApiException(_messageFromPostgrest(error));
    } catch (error, stackTrace) {
      debugPrint('RoutineApi.delete failed: $error\n$stackTrace');
      throw const RoutineApiException('루틴을 삭제하지 못했어요.');
    }
  }

  /// RLS 테이블은 Supabase Auth 세션(`auth.uid()`)과 동일한 user_id만 허용합니다.
  String _resolveUserId(String? override) {
    final sessionUserId = AuthSessionService.currentUserId;
    if (override != null && override.trim().isNotEmpty) {
      return override.trim();
    }
    if (sessionUserId != null && sessionUserId.trim().isNotEmpty) {
      return sessionUserId.trim();
    }
    throw const RoutineApiException('로그인이 필요해요. 이메일 로그인 후 다시 시도해주세요.');
  }

  static String _messageFromPostgrest(PostgrestException error) {
    final message = error.message.toLowerCase();
    if (error.code == '42501' || message.contains('row-level security')) {
      return '추천 알림 저장 권한이 없어요. '
          'Supabase에서 REFRESH_RECOMMEND_ALARMS RLS 정책을 확인하거나 '
          '이메일 로그인 후 다시 시도해주세요.';
    }
    return '루틴을 저장하지 못했어요. (${error.message})';
  }
}

class RoutineApiException implements Exception {
  const RoutineApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
