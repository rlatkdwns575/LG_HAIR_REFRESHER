import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/core/services/calendar_events_api.dart';
import 'package:lg_hair_refresher/core/services/device_calendar_reader.dart';
import 'package:lg_hair_refresher/core/services/local_calendar_connection_store.dart';
import 'package:lg_hair_refresher/core/services/local_calendar_service.dart';
import 'package:lg_hair_refresher/shared/models/calendar_event.dart';
import 'package:lg_hair_refresher/shared/recommendation/refresh_recommend_cache.dart';

class _FakeCalendarEventsApi extends CalendarEventsApi {
  _FakeCalendarEventsApi();

  List<CalendarEvent> savedEvents = const [];
  var deleteCalled = false;

  @override
  Future<List<CalendarEvent>> fetchTodayEvents({
    String? userId,
    DateTime? now,
  }) async {
    return savedEvents;
  }

  @override
  Future<void> replaceTodayEvents({
    required String userId,
    required List<CalendarEvent> events,
    DateTime? now,
  }) async {
    savedEvents = List<CalendarEvent>.from(events);
  }

  @override
  Future<void> deleteTodayEvents({String? userId, DateTime? now}) async {
    deleteCalled = true;
    savedEvents = const [];
  }
}

void main() {
  late LocalCalendarConnectionStore store;
  late _FakeCalendarEventsApi api;
  late LocalCalendarService service;

  setUp(() {
    store = LocalCalendarConnectionStore.instance..clear();
    api = _FakeCalendarEventsApi();
    RefreshRecommendCache.instance.invalidate();
    service = LocalCalendarService(
      store: store,
      calendarEventsApi: api,
      calendarReader: DeviceCalendarReader(
        requestPermissionsOverride: () async => true,
        hasPermissionsOverride: () async => true,
        fetchTodayEventsOverride: (_) async => DeviceCalendarFetchResult(
          events: [
            DeviceCalendarEvent(
              deviceEventId: 'device-1',
              title: '회식',
              startsAt: DateTime(2026, 6, 17, 19),
              endsAt: DateTime(2026, 6, 17, 21),
            ),
          ],
          diagnostics: const DeviceCalendarFetchDiagnostics(
            calendarCount: 1,
            rawEventCount: 1,
          ),
        ),
      ),
    );
  });

  tearDown(() => LocalCalendarConnectionStore.instance.clear());

  group('LocalCalendarService', () {
    test('starts disconnected', () async {
      final status = await service.fetchStatus();
      expect(status.isConnected, isFalse);
      expect(status.listRightLabel, '미연동');
    });

    test('requestAccess syncs device events to api and store', () async {
      final status = await service.refreshConnection(
        userId: 'test-user',
        now: DateTime(2026, 6, 17, 12),
      );

      expect(status.permissionGranted, isTrue);
      expect(status.isConnected, isTrue);
      expect(status.todayEventCount, 1);
      expect(status.nextEventTitle, '회식');
      expect(api.savedEvents, hasLength(1));
      expect(api.savedEvents.first.eventType, 'meal');
      expect(status.listRightLabel, '연동됨');
    });

    test('disconnect clears connection state and deletes api rows', () async {
      await service.refreshConnection(
        userId: 'test-user',
        now: DateTime(2026, 6, 17, 12),
      );
      final status = await service.disconnect(userId: 'test-user');

      expect(status.isConnected, isFalse);
      expect(status.permissionGranted, isFalse);
      expect(api.deleteCalled, isTrue);
      expect(api.savedEvents, isEmpty);
    });
  });
}
