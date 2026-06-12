import 'model/refresh_history_report.dart';
import 'api/history_api.dart';

/// 리프레시 기록 리포트 데이터 소스.
class RefreshHistoryStore {
  RefreshHistoryStore._();

  static final RefreshHistoryStore instance = RefreshHistoryStore._();

  final HistoryApi _api = const HistoryApi();

  Future<RefreshHistoryReport> loadReport({String? userId}) {
    return _api.fetchReport(userId: userId);
  }
}
