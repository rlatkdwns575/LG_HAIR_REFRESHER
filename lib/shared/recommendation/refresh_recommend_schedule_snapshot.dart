import '../../shared/models/local_calendar_status.dart';

/// Gemini 프롬프트용 일정 스냅샷.
class RefreshRecommendScheduleSnapshot {
  const RefreshRecommendScheduleSnapshot({
    required this.todayEventCount,
    this.nextEventTitle,
    this.nextEventStartAt,
  });

  final int todayEventCount;
  final String? nextEventTitle;
  final DateTime? nextEventStartAt;

  bool get hasEventsToday => todayEventCount > 0;

  factory RefreshRecommendScheduleSnapshot.fromCalendarStatus(
    LocalCalendarStatus status,
  ) {
    if (!status.isConnected || status.todayEventCount <= 0) {
      return const RefreshRecommendScheduleSnapshot(todayEventCount: 0);
    }

    return RefreshRecommendScheduleSnapshot(
      todayEventCount: status.todayEventCount,
      nextEventTitle: status.nextEventTitle,
      nextEventStartAt: status.nextEventStartAt,
    );
  }

  Map<String, dynamic> toPromptJson() => {
    'today_event_count': todayEventCount,
    if (nextEventTitle != null) 'next_event_title': nextEventTitle,
    if (nextEventStartAt != null)
      'next_event_start_at': nextEventStartAt!.toIso8601String(),
  };

  String get fingerprint =>
      '$todayEventCount|${nextEventTitle ?? ''}|${nextEventStartAt?.millisecondsSinceEpoch ?? 0}';
}
