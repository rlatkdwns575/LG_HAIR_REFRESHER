import 'package:flutter/foundation.dart';

import '../../../../core/services/notification_service.dart';
import '../model/routine.dart';
import 'routine_local_store.dart';

/// [Routine] → 로컬 알림 예약 변환 담당.
class RoutineAlarmScheduler {
  const RoutineAlarmScheduler._();

  /// 저장된 모든 루틴 알림을 OS에 다시 등록합니다.
  ///
  /// 앱 cold start·재부팅 후에도 설정한 시간에 알림이 뜨도록 합니다.
  static Future<void> rescheduleAll({
    RoutineLocalStore? localStore,
    bool requestPermissionIfNeeded = true,
  }) async {
    final store = localStore ?? const RoutineLocalStore();
    final routines = await store.loadAll();
    if (routines.isEmpty) {
      return;
    }

    final granted = requestPermissionIfNeeded
        ? await NotificationService.requestPermission()
        : await NotificationService.hasPermission();
    if (!granted) {
      if (kDebugMode) {
        debugPrint('RoutineAlarmScheduler: notification permission denied');
      }
      return;
    }

    for (final routine in routines) {
      try {
        if (routine.enabled) {
          await _schedule(
            routine,
            requestPermissionIfNeeded: requestPermissionIfNeeded,
          );
        } else {
          await cancel(routine);
        }
      } catch (error, stackTrace) {
        debugPrint(
          'RoutineAlarmScheduler: failed to schedule ${routine.id}: '
          '$error\n$stackTrace',
        );
      }
    }
  }

  static Future<bool> schedule(Routine routine) async {
    return _schedule(routine, requestPermissionIfNeeded: true);
  }

  static Future<bool> _schedule(
    Routine routine, {
    required bool requestPermissionIfNeeded,
  }) async {
    final id = routine.id;
    if (id == null || routine.weekdays.isEmpty) {
      return false;
    }

    final granted = requestPermissionIfNeeded
        ? await NotificationService.requestPermission()
        : await NotificationService.hasPermission();
    if (!granted) {
      return false;
    }

    await cancel(routine);
    if (!routine.enabled) {
      return true;
    }

    var allSucceeded = true;
    if (routine.isRepeating) {
      for (final weekday in routine.weekdays) {
        final scheduled = await NotificationService.scheduleWeekly(
          id: _notificationId(id, weekday),
          title: routine.modeName ?? '리프레시 루틴',
          body: _body(routine),
          weekday: weekday,
          hour: routine.hour,
          minute: routine.minute,
        );
        allSucceeded = allSucceeded && scheduled;
      }
    } else {
      final weekday = routine.weekdays.first;
      allSucceeded = await NotificationService.scheduleOnce(
        id: _notificationId(id, weekday),
        title: routine.modeName ?? '리프레시 루틴',
        body: _body(routine),
        weekday: weekday,
        hour: routine.hour,
        minute: routine.minute,
      );
    }
    return allSucceeded;
  }

  static Future<void> cancel(Routine routine) async {
    final id = routine.id;
    if (id == null) {
      return;
    }
    for (final weekday in RoutineWeekday.ordered) {
      await NotificationService.cancel(_notificationId(id, weekday));
    }
  }

  static int _notificationId(String routineId, int weekday) {
    final base = routineId.hashCode & 0x00FFFFFF;
    return base * 10 + weekday;
  }

  static String _body(Routine routine) {
    final mode = routine.modeName;
    if (mode != null && mode.trim().isNotEmpty) {
      return '$mode 모드로 리프레시할 시간이에요.';
    }
    return '리프레시로 컨디션을 가볍게 정리해보세요.';
  }
}
