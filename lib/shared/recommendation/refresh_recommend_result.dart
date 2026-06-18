import '../../features/refresh/data/model/refresh_mode.dart';
import 'refresh_recommend_basis.dart';

/// 통합 추천 결과 — 모든 화면에서 공유.
class RefreshRecommendResult {
  const RefreshRecommendResult({
    required this.mode,
    required this.message,
    required this.basis,
    required this.resolvedAt,
    required this.signature,
  });

  final RefreshMode mode;
  final String message;
  final RefreshRecommendBasis basis;
  final DateTime resolvedAt;
  final String signature;
}
