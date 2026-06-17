import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/supabase_tables.dart';
import '../utils/calendar_day_range.dart';
import '../../shared/models/calendar_event.dart';
import 'auth_session_service.dart';
import 'supabase_service.dart';

class CalendarEventsApiException implements Exception {
  const CalendarEventsApiException(this.message);

  final String message;

  @override
  String toString() => message;

  static const permissionDeniedHint =
      'Supabase SQL Editor에서 supabase/calendar_events_policies.sql을 실행해주세요.';

  static String fromPostgrest(PostgrestException error) {
    final message = error.message;
    if (message.contains('permission denied') || error.code == '42501') {
      return 'CALENDAR_EVENTS 테이블 권한이 없습니다. $permissionDeniedHint';
    }
    return message;
  }
}

class CalendarEventsApi {
  const CalendarEventsApi();

  static const eventColumns =
      'event_id, user_id, title, event_type, starts_at, ends_at';

  /// 오늘(로컬) 일정을 조회합니다.
  Future<List<CalendarEvent>> fetchTodayEvents({
    String? userId,
    DateTime? now,
  }) async {
    final resolvedUserId = AuthSessionService.resolveUserId(override: userId);
    final range = CalendarDayRange.forDate(now ?? DateTime.now());

    try {
      final rows = await SupabaseService.client
          .from(SupabaseTables.calendarEvents)
          .select(eventColumns)
          .eq('user_id', resolvedUserId)
          .gte('starts_at', range.start.toUtc().toIso8601String())
          .lt('starts_at', range.end.toUtc().toIso8601String())
          .order('starts_at');

      return rows
          .map((row) => CalendarEvent.fromJson(Map<String, dynamic>.from(row)))
          .toList();
    } on PostgrestException catch (error) {
      throw CalendarEventsApiException(
        '오늘 일정 조회에 실패했습니다. (${CalendarEventsApiException.fromPostgrest(error)})',
      );
    } catch (_) {
      throw CalendarEventsApiException('오늘 일정 조회에 실패했습니다.');
    }
  }

  /// 오늘 구간 일정을 교체합니다 (delete + insert).
  Future<void> replaceTodayEvents({
    required String userId,
    required List<CalendarEvent> events,
    DateTime? now,
  }) async {
    final resolvedUserId = AuthSessionService.resolveUserId(override: userId);
    final range = CalendarDayRange.forDate(now ?? DateTime.now());

    try {
      await SupabaseService.client
          .from(SupabaseTables.calendarEvents)
          .delete()
          .eq('user_id', resolvedUserId)
          .gte('starts_at', range.start.toUtc().toIso8601String())
          .lt('starts_at', range.end.toUtc().toIso8601String());

      if (events.isEmpty) {
        return;
      }

      final payload = events
          .map((event) => event.copyWith(userId: resolvedUserId).toInsertJson())
          .toList();

      await SupabaseService.client
          .from(SupabaseTables.calendarEvents)
          .insert(payload);
    } on PostgrestException catch (error) {
      throw CalendarEventsApiException(
        '오늘 일정 저장에 실패했습니다. (${CalendarEventsApiException.fromPostgrest(error)})',
      );
    } catch (_) {
      throw CalendarEventsApiException('오늘 일정 저장에 실패했습니다.');
    }
  }

  /// 연동 해제 시 오늘 일정을 삭제합니다.
  Future<void> deleteTodayEvents({String? userId, DateTime? now}) async {
    final resolvedUserId = AuthSessionService.resolveUserId(override: userId);
    final range = CalendarDayRange.forDate(now ?? DateTime.now());

    try {
      await SupabaseService.client
          .from(SupabaseTables.calendarEvents)
          .delete()
          .eq('user_id', resolvedUserId)
          .gte('starts_at', range.start.toUtc().toIso8601String())
          .lt('starts_at', range.end.toUtc().toIso8601String());
    } on PostgrestException catch (error) {
      throw CalendarEventsApiException(
        '오늘 일정 삭제에 실패했습니다. (${CalendarEventsApiException.fromPostgrest(error)})',
      );
    } catch (_) {
      throw CalendarEventsApiException('오늘 일정 삭제에 실패했습니다.');
    }
  }
}
