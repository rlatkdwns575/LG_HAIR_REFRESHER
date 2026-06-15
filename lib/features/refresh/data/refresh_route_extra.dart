import 'model/refresh_mode.dart';
import 'model/refresh_result.dart';
import 'model/refresh_result_detail.dart';
import 'refresh_mode_catalog.dart';
import 'refresh_result_detail_mapper.dart';

/// [GoRouter] extra 로 전달된 값을 [RefreshMode] 로 해석합니다.
RefreshMode? resolveRefreshMode(Object? extra) {
  if (extra is RefreshMode) {
    return extra;
  }
  if (extra is String) {
    for (final mode in getAllRefreshModes()) {
      if (mode.name == extra) {
        return mode;
      }
    }
  }
  return null;
}

/// [GoRouter] extra → [RefreshResultDetail] 해석.
RefreshResultDetail? resolveRefreshResultDetail(Object? extra) {
  if (extra is RefreshResultDetail) {
    return extra;
  }
  if (extra is RefreshResult) {
    return RefreshResultDetailMapper.fromRefreshResult(extra);
  }
  return null;
}

/// 기록 요약 필드 map → [RefreshResultDetail].
RefreshResultDetail resolveRefreshResultDetailFromSummary(
  Map<String, dynamic> summary,
) {
  return RefreshResultDetailMapper.fromRecordSummary(
    modeName: summary['modeName'] as String? ?? '리프레시',
    necessityReductionPercent: (summary['necessityReductionPercent'] as num?)
        ?.toDouble(),
    odorBeforeLabel: summary['odorBeforeLabel'] as String?,
    odorAfterLabel: summary['odorAfterLabel'] as String?,
    dustBeforeLabel: summary['dustBeforeLabel'] as String?,
    dustAfterLabel: summary['dustAfterLabel'] as String?,
  );
}
