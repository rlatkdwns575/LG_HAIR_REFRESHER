import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// 로컬 알림(예약 포함) 초기화·권한·스케줄링을 담당하는 전역 서비스.
///
/// 특정 feature 모델에 의존하지 않도록 원시 파라미터만 받습니다.
/// 루틴 알림 스케줄링은 `features/routine`에서 이 서비스를 호출합니다.
class NotificationService {
  const NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static const _channelId = 'routine_reminders';
  static const _channelName = '루틴 알림';
  static const _channelDescription = '등록한 리프레시 루틴 시간을 알려드려요.';

  static FlutterLocalNotificationsPlugin get plugin => _plugin;

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    tz_data.initializeTimeZones();
    // 기기 타임존 자동 감지는 별도 패키지가 필요해 한국 표준시로 고정합니다.
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      ),
    );

    _initialized = true;
  }

  /// 알림 권한을 요청합니다. 허용되면 true.
  static Future<bool> requestPermission() async {
    await initialize();

    if (Platform.isIOS) {
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    }

    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final granted = await android?.requestNotificationsPermission();
      return granted ?? true;
    }

    return true;
  }

  /// 매주 [weekday](1=월~7=일) [hour]:[minute]에 반복되는 알림을 예약합니다.
  static Future<void> scheduleWeekly({
    required int id,
    required String title,
    required String body,
    required int weekday,
    required int hour,
    required int minute,
  }) async {
    await initialize();

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: _nextInstanceOf(weekday, hour, minute),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  static Future<void> cancel(int id) async {
    await initialize();
    await _plugin.cancel(id: id);
  }

  static Future<void> cancelAll() async {
    await initialize();
    await _plugin.cancelAll();
  }

  static tz.TZDateTime _nextInstanceOf(int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    while (scheduled.weekday != weekday || !scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    if (kDebugMode) {
      debugPrint('NotificationService: scheduled #$weekday at $scheduled');
    }

    return scheduled;
  }
}
