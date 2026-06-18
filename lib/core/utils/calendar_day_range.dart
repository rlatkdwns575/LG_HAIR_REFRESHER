/// 로컬 타임존 기준 하루 구간 [start, end).
class CalendarDayRange {
  const CalendarDayRange._();

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime endOfDay(DateTime date) {
    return startOfDay(date).add(const Duration(days: 1));
  }

  static ({DateTime start, DateTime end}) forDate(DateTime date) {
    final start = startOfDay(date);
    return (start: start, end: start.add(const Duration(days: 1)));
  }
}
