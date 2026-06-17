import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/foundation.dart';

import '../utils/calendar_day_range.dart';

/// OS 캘린더에서 읽은 원본 일정 DTO.
class DeviceCalendarEvent {
  const DeviceCalendarEvent({
    required this.deviceEventId,
    required this.title,
    required this.startsAt,
    required this.endsAt,
  });

  final String deviceEventId;
  final String title;
  final DateTime startsAt;
  final DateTime endsAt;
}

/// 기기 fetch 진단 정보.
class DeviceCalendarFetchDiagnostics {
  const DeviceCalendarFetchDiagnostics({
    this.calendarCount = 0,
    this.rawEventCount = 0,
    this.note,
  });

  final int calendarCount;
  final int rawEventCount;
  final String? note;
}

class DeviceCalendarFetchResult {
  const DeviceCalendarFetchResult({
    required this.events,
    required this.diagnostics,
  });

  final List<DeviceCalendarEvent> events;
  final DeviceCalendarFetchDiagnostics diagnostics;
}

/// 기기 로컬 캘린더 읽기 (Android/iOS). 데스크톱은 빈 결과.
class DeviceCalendarReader {
  DeviceCalendarReader({
    DeviceCalendarPlugin? plugin,
    Future<bool> Function()? requestPermissionsOverride,
    Future<bool> Function()? hasPermissionsOverride,
    Future<DeviceCalendarFetchResult> Function(DateTime now)?
    fetchTodayEventsOverride,
  }) : _plugin = plugin ?? DeviceCalendarPlugin(),
       _requestPermissionsOverride = requestPermissionsOverride,
       _hasPermissionsOverride = hasPermissionsOverride,
       _fetchTodayEventsOverride = fetchTodayEventsOverride;

  final DeviceCalendarPlugin _plugin;
  final Future<bool> Function()? _requestPermissionsOverride;
  final Future<bool> Function()? _hasPermissionsOverride;
  final Future<DeviceCalendarFetchResult> Function(DateTime now)?
  _fetchTodayEventsOverride;

  bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<bool> requestPermissions() async {
    final override = _requestPermissionsOverride;
    if (override != null) {
      return override();
    }
    if (!isSupported) {
      return false;
    }

    if (await hasCalendarAccess()) {
      return true;
    }

    await _plugin.requestPermissions();
    return hasCalendarAccess();
  }

  Future<bool> hasPermissions() async {
    final override = _hasPermissionsOverride;
    if (override != null) {
      return override();
    }
    if (!isSupported) {
      return false;
    }

    final granted = await _plugin.hasPermissions();
    return granted.isSuccess && (granted.data ?? false);
  }

  /// 플러그인 권한 API + 캘린더 목록 조회로 실제 접근 가능 여부를 판단합니다.
  Future<bool> hasCalendarAccess() async {
    if (await hasPermissions()) {
      return true;
    }

    final calendarsResult = await _plugin.retrieveCalendars();
    return calendarsResult.isSuccess &&
        (calendarsResult.data?.isNotEmpty ?? false);
  }

  Future<List<DeviceCalendarEvent>> fetchTodayEvents(DateTime now) async {
    final result = await fetchTodayEventsWithDiagnostics(now);
    return result.events;
  }

  Future<DeviceCalendarFetchResult> fetchTodayEventsWithDiagnostics(
    DateTime now,
  ) async {
    final override = _fetchTodayEventsOverride;
    if (override != null) {
      return override(now);
    }
    if (!isSupported) {
      return const DeviceCalendarFetchResult(
        events: [],
        diagnostics: DeviceCalendarFetchDiagnostics(
          note: 'unsupported_platform',
        ),
      );
    }

    if (!await hasCalendarAccess()) {
      return const DeviceCalendarFetchResult(
        events: [],
        diagnostics: DeviceCalendarFetchDiagnostics(note: 'permission_denied'),
      );
    }

    final todayStart = CalendarDayRange.startOfDay(now);
    final todayEnd = CalendarDayRange.endOfDay(now);
    final queryStart = todayStart;
    final queryEnd = todayEnd;

    final calendarsResult = await _plugin.retrieveCalendars();
    if (!calendarsResult.isSuccess || calendarsResult.data == null) {
      return const DeviceCalendarFetchResult(
        events: [],
        diagnostics: DeviceCalendarFetchDiagnostics(
          note: 'retrieve_calendars_failed',
        ),
      );
    }

    final calendars = [...calendarsResult.data!]
      ..sort((a, b) {
        if (a.isDefault == true && b.isDefault != true) {
          return -1;
        }
        if (b.isDefault == true && a.isDefault != true) {
          return 1;
        }
        return 0;
      });

    final calendarIds = <String>[];
    for (final calendar in calendars) {
      final id = calendar.id?.trim();
      if (id != null && id.isNotEmpty) {
        calendarIds.add(id);
      }
    }
    if (calendarIds.isEmpty) {
      calendarIds.addAll(['1', '2', '3']);
    }

    final events = <DeviceCalendarEvent>[];
    final seenKeys = <String>{};
    var rawEventCount = 0;

    for (final calendarId in calendarIds) {
      final eventsResult = await _plugin.retrieveEvents(
        calendarId,
        RetrieveEventsParams(startDate: queryStart, endDate: queryEnd),
      );
      if (!eventsResult.isSuccess || eventsResult.data == null) {
        continue;
      }

      rawEventCount += eventsResult.data!.length;

      for (final event in eventsResult.data!) {
        if (event.status == EventStatus.Canceled) {
          continue;
        }

        final parsed = _parseEvent(
          event: event,
          calendarId: calendarId,
          todayStart: todayStart,
        );
        if (parsed == null) {
          continue;
        }

        final dedupeKey =
            '${parsed.deviceEventId}|${parsed.startsAt.millisecondsSinceEpoch}';
        if (seenKeys.add(dedupeKey)) {
          events.add(parsed);
        }
      }
    }

    events.sort((a, b) => a.startsAt.compareTo(b.startsAt));
    return DeviceCalendarFetchResult(
      events: events,
      diagnostics: DeviceCalendarFetchDiagnostics(
        calendarCount: calendarIds.length,
        rawEventCount: rawEventCount,
        note: events.isEmpty && rawEventCount > 0
            ? 'filtered_out'
            : (events.isEmpty ? 'empty' : null),
      ),
    );
  }

  DeviceCalendarEvent? _parseEvent({
    required Event event,
    required String calendarId,
    required DateTime todayStart,
  }) {
    final startsAt = _localInstant(event.start);
    if (startsAt == null) {
      return null;
    }

    var endsAt = _localInstant(event.end);
    if (event.allDay == true) {
      final dayStart = CalendarDayRange.startOfDay(startsAt);
      if (!_isSameLocalDay(dayStart, todayStart)) {
        return null;
      }
      return DeviceCalendarEvent(
        deviceEventId:
            event.eventId ?? '$calendarId-${dayStart.millisecondsSinceEpoch}',
        title: _eventTitle(event.title),
        startsAt: dayStart,
        endsAt: dayStart.add(const Duration(days: 1)),
      );
    }

    if (!_isSameLocalDay(startsAt, todayStart)) {
      return null;
    }

    endsAt ??= startsAt.add(const Duration(hours: 1));
    if (!endsAt.isAfter(startsAt)) {
      endsAt = startsAt.add(const Duration(hours: 1));
    }

    return DeviceCalendarEvent(
      deviceEventId:
          event.eventId ?? '$calendarId-${startsAt.millisecondsSinceEpoch}',
      title: _eventTitle(event.title),
      startsAt: startsAt,
      endsAt: endsAt,
    );
  }

  DateTime? _localInstant(DateTime? value) {
    if (value == null) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(value.millisecondsSinceEpoch);
  }

  bool _isSameLocalDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _eventTitle(String? title) {
    final trimmed = title?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return '일정';
    }
    return trimmed;
  }
}
