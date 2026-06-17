/// 일정 카테고리 — AI 분류 결과 또는 기본값 [none].
enum ScheduleCategory {
  none(odorImpact: 0, dustImpact: 0, socialImportance: 0, careHint: '기본 추천'),
  workSchool(
    odorImpact: 5,
    dustImpact: 5,
    socialImportance: 10,
    careHint: '약한 관리',
  ),
  commute(
    odorImpact: 8,
    dustImpact: 12,
    socialImportance: 5,
    careHint: '외출 후 케어',
  ),
  outdoorActivity(
    odorImpact: 8,
    dustImpact: 25,
    socialImportance: 5,
    careHint: '외출 후 케어',
  ),
  meal(
    odorImpact: 25,
    dustImpact: 5,
    socialImportance: 15,
    careHint: '냄새 중심 관리',
  ),
  cafeIndoor(
    odorImpact: 10,
    dustImpact: 8,
    socialImportance: 10,
    careHint: '가벼운 관리',
  ),
  bbqOrSmokyPlace(
    odorImpact: 35,
    dustImpact: 8,
    socialImportance: 20,
    careHint: '강한 냄새 관리',
  ),
  exercise(
    odorImpact: 18,
    dustImpact: 10,
    socialImportance: 5,
    careHint: '외출 후 또는 취침 전',
  ),
  importantMeeting(
    odorImpact: 12,
    dustImpact: 5,
    socialImportance: 40,
    careHint: '만남 전 케어',
  ),
  dateOrSocial(
    odorImpact: 20,
    dustImpact: 5,
    socialImportance: 35,
    careHint: '만남 전 케어',
  ),
  sleepRest(
    odorImpact: 5,
    dustImpact: 5,
    socialImportance: 0,
    careHint: '취침 전 케어',
  );

  const ScheduleCategory({
    required this.odorImpact,
    required this.dustImpact,
    required this.socialImportance,
    required this.careHint,
  });

  final int odorImpact;
  final int dustImpact;
  final int socialImportance;
  final String careHint;

  static ScheduleCategory? tryParseEventType(String value) {
    for (final category in ScheduleCategory.values) {
      if (category.name == value) {
        return category;
      }
    }
    return null;
  }
}
