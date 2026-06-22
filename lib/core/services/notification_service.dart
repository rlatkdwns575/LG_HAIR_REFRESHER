import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../utils/notification_schedule_utils.dart';

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

  /// 로컬 알림은 Android/iOS 전용 (Windows/macOS/Linux 데스크톱 빌드 제외).
  static bool get _supportsLocalNotifications {
    if (kIsWeb) {
      return false;
    }
    return Platform.isAndroid || Platform.isIOS;
  }

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    if (!_supportsLocalNotifications) {
      _initialized = true;
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

    if (Platform.isAndroid) {
      await _createAndroidChannel();
    }

    _initialized = true;
  }

  static Future<void> _createAndroidChannel() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) {
      return;
    }

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );
    await android.createNotificationChannel(channel);
  }

  /// 알림·정확한 예약 권한을 요청합니다. 허용되면 true.
  static Future<bool> requestPermission() async {
    if (!_supportsLocalNotifications) {
      return false;
    }
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
      if (granted == false) {
        return false;
      }

      final canExact = await android?.canScheduleExactNotifications();
      if (canExact == false) {
        await android?.requestExactAlarmsPermission();
      }
      return true;
    }

    return true;
  }

  /// Checks notification permission without opening a system permission prompt.
  static Future<bool> hasPermission() async {
    if (!_supportsLocalNotifications) {
      return false;
    }
    await initialize();

    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await android?.areNotificationsEnabled() ?? true;
    }

    // Avoid requesting iOS notification permission during app cold start.
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
    if (!_supportsLocalNotifications) {
      return;
    }
    await initialize();

    final scheduledDate = _nextInstanceOf(weekday, hour, minute);
    if (kDebugMode) {
      debugPrint(
        'NotificationService: weekly #$id weekday=$weekday at $scheduledDate',
      );
    }

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: _notificationDetails,
      androidScheduleMode: await _resolveAndroidScheduleMode(),
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  /// 다음 [weekday](1=월~7=일) [hour]:[minute]에 한 번만 알림을 예약합니다.
  static Future<void> scheduleOnce({
    required int id,
    required String title,
    required String body,
    required int weekday,
    required int hour,
    required int minute,
  }) async {
    if (!_supportsLocalNotifications) {
      return;
    }
    await initialize();

    final scheduledDate = _nextInstanceOf(weekday, hour, minute);
    if (kDebugMode) {
      debugPrint(
        'NotificationService: once #$id weekday=$weekday at $scheduledDate',
      );
    }

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: _notificationDetails,
      androidScheduleMode: await _resolveAndroidScheduleMode(),
    );
  }

  static Future<void> cancel(int id) async {
    if (!_supportsLocalNotifications) {
      return;
    }
    await initialize();
    await _plugin.cancel(id: id);
  }

  static Future<void> cancelAll() async {
    if (!_supportsLocalNotifications) {
      return;
    }
    await initialize();
    await _plugin.cancelAll();
  }

  static const NotificationDetails _notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.reminder,
      playSound: true,
      enableVibration: true,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );

  static Future<AndroidScheduleMode> _resolveAndroidScheduleMode() async {
    if (!Platform.isAndroid) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final canExact = await android?.canScheduleExactNotifications();
    if (canExact ?? true) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }
    return AndroidScheduleMode.inexactAllowWhileIdle;
  }

  static tz.TZDateTime _nextInstanceOf(int weekday, int hour, int minute) {
    return nextZonedNotificationTime(
      location: tz.local,
      weekday: weekday,
      hour: hour,
      minute: minute,
    );
  }
}
