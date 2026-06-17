import '../../features/measure/data/api/measure_schedule_classifier_api.dart';
import '../../shared/models/calendar_event.dart';
import '../../shared/models/local_calendar_status.dart';
import '../../shared/recommendation/refresh_recommend_cache.dart';
import '../utils/stable_calendar_event_id.dart';
import 'auth_session_service.dart';
import 'calendar_events_api.dart';
import 'device_calendar_reader.dart';
import 'local_calendar_connect_result.dart';
import 'local_calendar_connection_store.dart';

/// 기기 로컬 캘린더 연동·동기화.
class LocalCalendarService {
  LocalCalendarService({
    DeviceCalendarReader? calendarReader,
    CalendarEventsApi? calendarEventsApi,
    MeasureScheduleClassifierApi? classifierApi,
    LocalCalendarConnectionStore? store,
  }) : calendarReader = calendarReader ?? DeviceCalendarReader(),
       calendarEventsApi = calendarEventsApi ?? const CalendarEventsApi(),
       classifierApi = classifierApi ?? const MeasureScheduleClassifierApi(),
       _storeOverride = store;

  final DeviceCalendarReader calendarReader;
  final CalendarEventsApi calendarEventsApi;
  final MeasureScheduleClassifierApi classifierApi;
  final LocalCalendarConnectionStore? _storeOverride;

  LocalCalendarConnectionStore get _store =>
      _storeOverride ?? LocalCalendarConnectionStore.instance;

  LocalCalendarStatus get currentStatus => _buildStatus();

  Future<LocalCalendarStatus> fetchStatus() async {
    await _syncPermissionFromOs();
    return _buildStatus();
  }

  /// OS 권한 요청 → 일정 동기화까지 한 번에 수행합니다.
  Future<LocalCalendarConnectResult> connect({String? userId}) async {
    if (!calendarReader.isSupported) {
      return const LocalCalendarConnectResult(
        outcome: LocalCalendarConnectOutcome.skipped,
      );
    }

    await _syncPermissionFromOs();

    if (!await calendarReader.hasCalendarAccess()) {
      await calendarReader.requestPermissions();
      if (!await calendarReader.hasCalendarAccess()) {
        return LocalCalendarConnectResult(
          outcome: LocalCalendarConnectOutcome.permissionDenied,
          status: await fetchStatus(),
          errorMessage: '캘린더 접근 권한이 필요합니다.',
        );
      }
    }

    _store.grantPermission();

    try {
      final connectedStatus = await refreshConnection(userId: userId);
      return LocalCalendarConnectResult(
        outcome: LocalCalendarConnectOutcome.connected,
        status: connectedStatus,
      );
    } on CalendarEventsApiException catch (error) {
      final status = await fetchStatus();
      if (status.todayEventCount > 0) {
        return LocalCalendarConnectResult(
          outcome: LocalCalendarConnectOutcome.connected,
          status: status,
          errorMessage:
              '기기 일정 ${status.todayEventCount}건을 확인했지만 서버 저장에 실패했습니다. '
              '${error.message}',
        );
      }
      return LocalCalendarConnectResult(
        outcome: LocalCalendarConnectOutcome.syncFailed,
        status: status,
        errorMessage: error.message,
      );
    } catch (error) {
      return LocalCalendarConnectResult(
        outcome: LocalCalendarConnectOutcome.syncFailed,
        status: await fetchStatus(),
        errorMessage: '캘린더 연동에 실패했습니다.',
      );
    }
  }

  Future<LocalCalendarStatus> requestAccess({String? userId}) async {
    if (!calendarReader.isSupported) {
      return _buildStatus();
    }

    if (await calendarReader.hasCalendarAccess()) {
      _store.grantPermission();
      return refreshConnection(userId: userId);
    }

    await calendarReader.requestPermissions();

    if (!await calendarReader.hasCalendarAccess()) {
      _store.permissionGranted = false;
      _store.isConnected = false;
      return _buildStatus();
    }

    _store.grantPermission();
    return refreshConnection(userId: userId);
  }

  /// 기기 캘린더에서 오늘 일정을 읽어 Supabase에 저장합니다.
  Future<LocalCalendarStatus> refreshConnection({
    String? userId,
    DateTime? now,
  }) async {
    if (!await calendarReader.hasCalendarAccess()) {
      _store.permissionGranted = false;
      return _buildStatus();
    }

    _store.grantPermission();

    final resolvedNow = now ?? DateTime.now();
    final fetchResult = await calendarReader.fetchTodayEventsWithDiagnostics(
      resolvedNow,
    );
    _store.applyFetchDiagnostics(
      calendarCount: fetchResult.diagnostics.calendarCount,
      rawEventCount: fetchResult.diagnostics.rawEventCount,
      note: fetchResult.diagnostics.note,
    );

    final deviceEvents = fetchResult.events;
    final resolvedUserId = AuthSessionService.resolveUserId(override: userId);

    final calendarEvents = await _buildCalendarEvents(
      deviceEvents: deviceEvents,
      userId: resolvedUserId,
    );

    // 기기에서 읽은 결과를 UI에 먼저 반영합니다 (Supabase 실패와 무관).
    _store.applySyncedEvents(calendarEvents, checkedAt: resolvedNow);
    RefreshRecommendCache.instance.invalidate();

    try {
      await calendarEventsApi.replaceTodayEvents(
        userId: resolvedUserId,
        events: calendarEvents,
        now: resolvedNow,
      );
    } on CalendarEventsApiException catch (_) {
      rethrow;
    }

    return _buildStatus();
  }

  Future<List<CalendarEvent>> _buildCalendarEvents({
    required List<DeviceCalendarEvent> deviceEvents,
    required String userId,
  }) async {
    final calendarEvents = <CalendarEvent>[];
    for (final deviceEvent in deviceEvents) {
      final category = await classifierApi.classify(title: deviceEvent.title);
      calendarEvents.add(
        CalendarEvent(
          eventId: stableCalendarEventId(
            userId: userId,
            deviceEventId: deviceEvent.deviceEventId,
            startsAt: deviceEvent.startsAt,
          ),
          userId: userId,
          title: deviceEvent.title,
          eventType: category.name,
          startsAt: deviceEvent.startsAt,
          endsAt: deviceEvent.endsAt,
        ),
      );
    }
    return calendarEvents;
  }

  Future<LocalCalendarStatus> disconnect({
    String? userId,
    DateTime? now,
  }) async {
    try {
      if (_store.isConnected || _store.permissionGranted) {
        await calendarEventsApi.deleteTodayEvents(userId: userId, now: now);
      }
    } finally {
      _store.clear();
      RefreshRecommendCache.instance.invalidate();
    }
    return _buildStatus();
  }

  Future<void> _syncPermissionFromOs() async {
    if (!calendarReader.isSupported) {
      return;
    }

    final osGranted = await calendarReader.hasCalendarAccess();
    if (osGranted) {
      _store.grantPermission();
      return;
    }

    if (_store.permissionGranted || _store.isConnected) {
      _store.permissionGranted = false;
      _store.isConnected = false;
      _store.lastCheckedAt = null;
      _store.todayEventCount = 0;
      _store.nextEventTitle = null;
      _store.nextEventStartAt = null;
    }
  }

  LocalCalendarStatus _buildStatus() {
    return LocalCalendarStatus(
      isConnected: _store.isConnected,
      permissionGranted: _store.permissionGranted,
      lastCheckedAt: _store.lastCheckedAt,
      todayEventCount: _store.todayEventCount,
      nextEventTitle: _store.nextEventTitle,
      nextEventStartAt: _store.nextEventStartAt,
      deviceCalendarCount: _store.deviceCalendarCount,
      deviceRawEventCount: _store.deviceRawEventCount,
      lastFetchNote: _store.lastFetchNote,
    );
  }
}
