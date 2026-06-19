import '../../../../core/services/notification_service.dart';
import '../model/routine.dart';

/// [Routine] → 로컬 알림 예약 변환 담당.
class RoutineAlarmScheduler {
  const RoutineAlarmScheduler._();

  static Future<bool> schedule(Routine routine) async {
    final id = routine.id;
    if (id == null || routine.weekdays.isEmpty) {
      return false;
    }

    final granted = await NotificationService.requestPermission();
    if (!granted) {
      return false;
    }

    await cancel(routine);
    if (!routine.enabled) {
      return true;
    }

    if (routine.isRepeating) {
      for (final weekday in routine.weekdays) {
        await NotificationService.scheduleWeekly(
          id: _notificationId(id, weekday),
          title: routine.modeName ?? '리프레시 루틴',
          body: _body(routine),
          weekday: weekday,
          hour: routine.hour,
          minute: routine.minute,
        );
      }
    } else {
      final weekday = routine.weekdays.first;
      await NotificationService.scheduleOnce(
        id: _notificationId(id, weekday),
        title: routine.modeName ?? '리프레시 루틴',
        body: _body(routine),
        weekday: weekday,
        hour: routine.hour,
        minute: routine.minute,
      );
    }
    return true;
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
