import '../model/schedule_category.dart';
import '../model/schedule_timing.dart';

/// 일정 제목/내용을 카테고리로 분류합니다 (MVP: 규칙 기반).
class MeasureScheduleClassifierApi {
  const MeasureScheduleClassifierApi();

  Future<ScheduleCategory> classify({String? title, String? content}) async {
    return classifySync(title: title, content: content);
  }

  ScheduleCategory classifySync({String? title, String? content}) {
    final text = '${title ?? ''} ${content ?? ''}'.trim().toLowerCase();
    if (text.isEmpty) {
      return ScheduleCategory.none;
    }

    if (_containsAny(text, ['카페'])) {
      return ScheduleCategory.cafeIndoor;
    }
    if (_containsAny(text, ['회의', '미팅', '면접'])) {
      return ScheduleCategory.importantMeeting;
    }
    if (_containsAny(text, ['데이트', '약속', '모임'])) {
      return ScheduleCategory.dateOrSocial;
    }
    if (_containsAny(text, ['식사', '점심', '저녁', '아침', '브런치', '회식'])) {
      return ScheduleCategory.meal;
    }
    if (_containsAny(text, ['운동', '헬스', '러닝', '조깅', '필라테스', '요가'])) {
      return ScheduleCategory.exercise;
    }
    if (_containsAny(text, ['출근', '통근'])) {
      return ScheduleCategory.commute;
    }

    return ScheduleCategory.none;
  }

  Future<ScheduleTiming> resolveTiming({
    required DateTime now,
    DateTime? eventStart,
    DateTime? eventEnd,
  }) async {
    return resolveTimingSync(
      now: now,
      eventStart: eventStart,
      eventEnd: eventEnd,
    );
  }

  ScheduleTiming resolveTimingSync({
    required DateTime now,
    DateTime? eventStart,
    DateTime? eventEnd,
  }) {
    if (eventStart == null) {
      return ScheduleTiming.none;
    }

    final end = eventEnd ?? eventStart;
    if (now.isBefore(eventStart)) {
      return ScheduleTiming.before;
    }
    if (now.isBefore(end)) {
      return ScheduleTiming.during;
    }
    return ScheduleTiming.after;
  }

  bool _containsAny(String text, List<String> keywords) {
    for (final keyword in keywords) {
      if (text.contains(keyword)) {
        return true;
      }
    }
    return false;
  }
}
