/// Supabase PostgreSQL 테이블명.
///
/// 이 프로젝트 DB는 대문자 테이블명(`USER_DEVICES` 등)으로 생성되어 있어
/// PostgREST 조회 시 동일한 대소문자를 사용해야 합니다.
class SupabaseTables {
  const SupabaseTables._();

  static const authUsers = 'AUTH_USERS';
  static const devices = 'DEVICES';
  static const userDevices = 'USER_DEVICES';
  static const consumableStatus = 'CONSUMABLE_STATUS';
  static const measureResults = 'MEASURE_RESULTS';
  static const refreshMode = 'REFRESH_MODE';
  static const refreshSessions = 'REFRESH_SESSIONS';
  static const calendarEvents = 'CALENDAR_EVENTS';
}
