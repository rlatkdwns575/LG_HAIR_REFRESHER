import '../../shared/models/calendar_event.dart';
import 'device_calendar_reader.dart';

/// 로컬 캘린더 연동 세션 저장소.
class LocalCalendarConnectionStore {
  LocalCalendarConnectionStore._();

  static final LocalCalendarConnectionStore instance =
      LocalCalendarConnectionStore._();

  bool permissionGranted = false;
  bool isConnected = false;
  DateTime? lastCheckedAt;
  int todayEventCount = 0;
  String? nextEventTitle;
  DateTime? nextEventStartAt;
  int deviceCalendarCount = 0;
  int deviceRawEventCount = 0;
  String? lastFetchNote;

  void grantPermission() {
    permissionGranted = true;
  }

  void applyFetchDiagnostics({
    required int calendarCount,
    required int rawEventCount,
    String? note,
  }) {
    deviceCalendarCount = calendarCount;
    deviceRawEventCount = rawEventCount;
    lastFetchNote = note;
  }

  void applySyncedEvents(
    List<CalendarEvent> events, {
    required DateTime checkedAt,
  }) {
    todayEventCount = events.length;
    lastCheckedAt = checkedAt;
    isConnected = permissionGranted;

    CalendarEvent? next;
    for (final event in events) {
      if (!event.startsAt.isBefore(checkedAt)) {
        if (next == null || event.startsAt.isBefore(next.startsAt)) {
          next = event;
        }
      }
    }

    nextEventTitle = next?.title;
    nextEventStartAt = next?.startsAt;
  }

  void applyDevicePreview({
    required List<DeviceCalendarEvent> events,
    required DateTime checkedAt,
  }) {
    todayEventCount = events.length;
    lastCheckedAt = checkedAt;
    isConnected = permissionGranted;

    DeviceCalendarEvent? next;
    for (final event in events) {
      if (!event.startsAt.isBefore(checkedAt)) {
        if (next == null || event.startsAt.isBefore(next.startsAt)) {
          next = event;
        }
      }
    }

    nextEventTitle = next?.title;
    nextEventStartAt = next?.startsAt;
  }

  void clear() {
    permissionGranted = false;
    isConnected = false;
    lastCheckedAt = null;
    todayEventCount = 0;
    nextEventTitle = null;
    nextEventStartAt = null;
    deviceCalendarCount = 0;
    deviceRawEventCount = 0;
    lastFetchNote = null;
  }
}
