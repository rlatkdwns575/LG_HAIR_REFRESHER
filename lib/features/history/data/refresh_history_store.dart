import 'model/refresh_history_report.dart';

/// 리프레시 기록 리포트 데이터 제공자.
///
/// 현재는 mock([RefreshHistoryReport.sample])을 반환하지만, 추후
/// `features/history/data/api/` 의 Supabase API 결과로 교체할 수 있습니다.
class RefreshHistoryStore {
  RefreshHistoryStore._();

  static final RefreshHistoryStore instance = RefreshHistoryStore._();

  RefreshHistoryReport loadReport() => RefreshHistoryReport.sample;
}
