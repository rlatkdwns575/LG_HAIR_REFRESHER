import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../utils/notification_schedule_utils.dart';
import 'notification_schedule_readiness.dart';

/// 로컬 알림(예약 포함) 초기화·권한·스케줄링을 담당하는 전역 서비스.
///
/// 특정 feature 모델에 의존하지 않도록 원시 파라미터만 받습니다.
/// 루틴 알림 스케줄링은 `features/routine`에서 이 서비스를 호출합니다.
class NotificationService {
  const NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static const _fallbackTimezoneId = 'Asia/Seoul';
  static tz.Location? _scheduleLocation;

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
    await _configureScheduleLocation();

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

  /// 기기 IANA 타임존을 읽어 알림 예약 location을 설정합니다.
  static Future<void> _configureScheduleLocation() async {
    try {
      final deviceTimezone = await FlutterTimezone.getLocalTimezone();
      final location = tz.getLocation(deviceTimezone.identifier);
      tz.setLocalLocation(location);
      _scheduleLocation = location;
      if (kDebugMode) {
        debugPrint(
          'NotificationService: schedule timezone=${deviceTimezone.identifier}',
        );
      }
      return;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          'NotificationService: device timezone unavailable ($error), '
          'fallback=$_fallbackTimezoneId\n$stackTrace',
        );
      }
    }

    final fallback = tz.getLocation(_fallbackTimezoneId);
    tz.setLocalLocation(fallback);
    _scheduleLocation = fallback;
  }

  static tz.Location get _resolvedScheduleLocation {
    return _scheduleLocation ?? tz.local;
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
      return _ensureAndroidScheduleReady(requestExactAlarmIfNeeded: true);
    }

    return true;
  }

  /// 정확 알람 설정 화면을 엽니다 (Android 12+).
  static Future<void> openExactAlarmSettings() async {
    if (!Platform.isAndroid) {
      return;
    }
    await initialize();
    final android = _androidPlugin;
    await android?.requestExactAlarmsPermission();
  }

  /// Checks notification permission without opening a system permission prompt.
  static Future<bool> hasPermission() async {
    final readiness = await checkScheduleReadiness();
    return readiness.canSchedule;
  }

  /// 알림·정확 알람 권한 상태를 조회합니다.
  static Future<NotificationScheduleReadiness> checkScheduleReadiness() async {
    if (!_supportsLocalNotifications) {
      return const NotificationScheduleReadiness(
        notificationsEnabled: false,
        exactAlarmsEnabled: false,
      );
    }
    await initialize();

    if (Platform.isAndroid) {
      final android = _androidPlugin;
      final notificationsEnabled =
          await android?.areNotificationsEnabled() ?? false;
      final canExact = await android?.canScheduleExactNotifications();
      return NotificationScheduleReadiness(
        notificationsEnabled: notificationsEnabled,
        exactAlarmsEnabled: canExact ?? true,
      );
    }

    return const NotificationScheduleReadiness(
      notificationsEnabled: true,
      exactAlarmsEnabled: true,
    );
  }

  static AndroidFlutterLocalNotificationsPlugin? get _androidPlugin {
    return _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
  }

  static Future<bool> _ensureAndroidScheduleReady({
    required bool requestExactAlarmIfNeeded,
  }) async {
    final android = _androidPlugin;
    if (android == null) {
      return false;
    }

    var notificationsGranted = await android.requestNotificationsPermission();
    if (notificationsGranted == false) {
      return false;
    }

    final notificationsEnabled = await android.areNotificationsEnabled();
    if (notificationsEnabled != true) {
      return false;
    }

    var canExact = await android.canScheduleExactNotifications();
    if (canExact == false && requestExactAlarmIfNeeded) {
      await android.requestExactAlarmsPermission();
      canExact = await android.canScheduleExactNotifications();
      if (kDebugMode) {
        debugPrint(
          'NotificationService: exact alarm after settings canExact=$canExact',
        );
      }
    }

    return true;
  }

  /// 매주 [weekday](1=월~7=일) [hour]:[minute]에 반복되는 알림을 예약합니다.
  static Future<bool> scheduleWeekly({
    required int id,
    required String title,
    required String body,
    required int weekday,
    required int hour,
    required int minute,
  }) async {
    if (!_supportsLocalNotifications) {
      return false;
    }
    await initialize();

    final scheduledDate = _nextInstanceOf(weekday, hour, minute);
    if (kDebugMode) {
      debugPrint(
        'NotificationService: weekly #$id weekday=$weekday at $scheduledDate',
      );
    }

    return _zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  /// 다음 [weekday](1=월~7=일) [hour]:[minute]에 한 번만 알림을 예약합니다.
  static Future<bool> scheduleOnce({
    required int id,
    required String title,
    required String body,
    required int weekday,
    required int hour,
    required int minute,
  }) async {
    if (!_supportsLocalNotifications) {
      return false;
    }
    await initialize();

    final scheduledDate = _nextInstanceOf(weekday, hour, minute);
    if (kDebugMode) {
      debugPrint(
        'NotificationService: once #$id weekday=$weekday at $scheduledDate',
      );
    }

    return _zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
    );
  }

  static Future<bool> _zonedSchedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    try {
      final scheduleMode = await _resolveAndroidScheduleMode();
      if (kDebugMode && Platform.isAndroid) {
        final readiness = await checkScheduleReadiness();
        debugPrint(
          'NotificationService: schedule #$id mode=$scheduleMode '
          'notifications=${readiness.notificationsEnabled} '
          'exactAlarms=${readiness.exactAlarmsEnabled}',
        );
      }

      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: _notificationDetails,
        androidScheduleMode: scheduleMode,
        matchDateTimeComponents: matchDateTimeComponents,
      );

      if (Platform.isAndroid) {
        final pending = await _plugin.pendingNotificationRequests();
        final registered = pending.any((request) => request.id == id);
        if (!registered) {
          debugPrint(
            'NotificationService: schedule #$id failed to register '
            '(exact alarm permission or battery restriction suspected)',
          );
          return false;
        }
        if (kDebugMode) {
          debugPrint(
            'NotificationService: schedule #$id registered at $scheduledDate',
          );
        }
      }

      return true;
    } catch (error, stackTrace) {
      debugPrint(
        'NotificationService: schedule #$id failed: $error\n$stackTrace',
      );
      return false;
    }
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

    final canExact = await _androidPlugin?.canScheduleExactNotifications();
    if (canExact ?? false) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }
    return AndroidScheduleMode.inexactAllowWhileIdle;
  }

  static tz.TZDateTime _nextInstanceOf(int weekday, int hour, int minute) {
    return nextZonedNotificationTime(
      location: _resolvedScheduleLocation,
      weekday: weekday,
      hour: hour,
      minute: minute,
    );
  }
}
