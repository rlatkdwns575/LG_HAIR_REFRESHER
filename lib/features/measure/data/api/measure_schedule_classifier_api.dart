import '../model/schedule_category.dart';
import '../model/schedule_timing.dart';

/// 일정 제목/내용을 카테고리로 분류합니다.
///
/// 현재는 로컬 일정 미연동으로 [ScheduleCategory.none]만 반환합니다.
/// 향후 Gemini API 연동 시 이 클래스를 확장합니다.
class MeasureScheduleClassifierApi {
  const MeasureScheduleClassifierApi();

  Future<ScheduleCategory> classify({String? title, String? content}) async {
    return ScheduleCategory.none;
  }

  Future<ScheduleTiming> resolveTiming({
    required DateTime now,
    DateTime? eventStart,
    DateTime? eventEnd,
  }) async {
    return ScheduleTiming.none;
  }
}
