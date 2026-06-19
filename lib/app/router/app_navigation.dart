import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/route_paths.dart';
import '../../features/measure/data/api/measure_result_mapper.dart';
import '../../features/measure/data/model/measure_result.dart';
import '../../features/measure/data/model/measure_result_record.dart';
import '../../features/refresh/data/model/refresh_mode.dart';
import '../../features/refresh/data/model/refresh_result.dart';
import '../../features/refresh/data/model/refresh_result_detail.dart';
import '../../features/refresh/data/refresh_result_detail_mapper.dart';
import '../../features/routine/data/model/routine.dart';

/// 화면에서 route path 문자열을 직접 쓰지 않고 이동할 때 사용합니다.
///
/// 홈 허브에서 하위 화면으로 갈 때는 [push] 계열을 사용해 뒤로가기가 동작하게 합니다.
extension AppNavigation on BuildContext {
  void goLogin() => go(AppRoutePaths.login);

  void pushEmailLogin() => push(AppRoutePaths.emailLogin);

  void goHome() => go(AppRoutePaths.home);

  void pushMeasure() => push(AppRoutePaths.measure);

  void pushMeasurePrepare() => push(AppRoutePaths.measurePrepare);

  void pushMeasureRun() => push(AppRoutePaths.measureRun);

  void pushMeasureAnalyzing() => push(AppRoutePaths.measureAnalyzing);

  void pushMeasureResult() => push(AppRoutePaths.measureResult);

  void pushMeasureResultDetail({required MeasureResult result}) {
    push(AppRoutePaths.measureResultDetail, extra: result);
  }

  /// 기록(히스토리)의 과거 진단 데이터를 진단 상세 화면으로 엽니다.
  void pushMeasureHistoryRecordDetail({required MeasureResultRecord record}) {
    push(
      AppRoutePaths.measureResultDetail,
      extra: MeasureResultMapper.toMeasureResult(record),
    );
  }

  void pushRefresh() => push(AppRoutePaths.refresh);

  void pushRefreshDetail({required RefreshMode mode}) {
    push(AppRoutePaths.refreshDetail, extra: mode);
  }

  /// 리프레시 상세로 이동하고, 커스텀 모드 삭제 여부를 반환합니다.
  Future<bool?> pushRefreshDetailForResult({required RefreshMode mode}) =>
      push<bool>(AppRoutePaths.refreshDetail, extra: mode);

  void pushRefreshProgress({RefreshMode? mode, String? modeName}) {
    assert(mode == null || modeName == null, 'mode 또는 modeName 중 하나만 전달하세요.');
    push(AppRoutePaths.refreshProgress, extra: mode ?? modeName);
  }

  void pushRefreshResultCollecting() =>
      push(AppRoutePaths.refreshResultCollecting);

  void pushRefreshResult() => push(AppRoutePaths.refreshResult);

  void pushRefreshResultDetail({
    RefreshResultDetail? detail,
    RefreshResult? result,
  }) {
    assert(detail == null || result == null, 'detail 또는 result 중 하나만 전달하세요.');
    push(AppRoutePaths.refreshResultDetail, extra: detail ?? result);
  }

  void pushRefreshHistoryRecordDetail({
    required String modeName,
    double? necessityReductionPercent,
    String? odorBeforeLabel,
    String? odorAfterLabel,
    String? dustBeforeLabel,
    String? dustAfterLabel,
    DateTime? completedAt,
  }) {
    push(
      AppRoutePaths.refreshResultDetail,
      extra: RefreshResultDetailMapper.fromRecordSummary(
        modeName: modeName,
        necessityReductionPercent: necessityReductionPercent,
        odorBeforeLabel: odorBeforeLabel,
        odorAfterLabel: odorAfterLabel,
        dustBeforeLabel: dustBeforeLabel,
        dustAfterLabel: dustAfterLabel,
        completedAt: completedAt,
      ),
    );
  }

  /// 커스텀 모드 생성 화면으로 이동하고, 저장 성공 여부를 반환합니다.
  Future<bool?> pushRefreshCustomCreate() =>
      push<bool>(AppRoutePaths.refreshCustomCreate);

  /// 홈 즐겨찾기(리프레시 바로가기) 추가·수정 화면으로 이동하고, 선택한 모드를 반환합니다.
  Future<RefreshMode?> pushRefreshShortcutAdd({RefreshMode? initialMode}) =>
      push<RefreshMode>(AppRoutePaths.refreshShortcutAdd, extra: initialMode);

  void pushHistory() => push(AppRoutePaths.history);

  void pushSettings() => push(AppRoutePaths.settings);

  void pushDeviceManage() => push(AppRoutePaths.settingsDevice);

  Future<void> pushLocalCalendarSettings() =>
      push(AppRoutePaths.settingsLocalCalendar);

  /// 루틴 알림 관리(목록) 화면으로 이동합니다.
  Future<void> pushRoutineList() => push(AppRoutePaths.routineList);

  /// 루틴 알림 등록/수정 화면으로 이동하고, 저장 성공 여부를 반환합니다.
  Future<bool?> pushRoutineRegister({Routine? initial}) =>
      push<bool>(AppRoutePaths.routineRegister, extra: initial);

  void goHomeNamed() => goNamed(AppRouteNames.home);

  void pushMeasureNamed() => pushNamed(AppRouteNames.measure);

  void pushMeasurePrepareNamed() => pushNamed(AppRouteNames.measurePrepare);

  void pushMeasureRunNamed() => pushNamed(AppRouteNames.measureRun);

  void pushMeasureAnalyzingNamed() => pushNamed(AppRouteNames.measureAnalyzing);

  void pushMeasureResultNamed() => pushNamed(AppRouteNames.measureResult);

  void pushMeasureResultDetailNamed({required MeasureResult result}) {
    pushNamed(AppRouteNames.measureResultDetail, extra: result);
  }

  void pushRefreshNamed() => pushNamed(AppRouteNames.refresh);

  void pushRefreshProgressNamed() => pushNamed(AppRouteNames.refreshProgress);

  void pushRefreshResultCollectingNamed() =>
      pushNamed(AppRouteNames.refreshResultCollecting);

  void pushRefreshResultNamed() => pushNamed(AppRouteNames.refreshResult);

  void pushRefreshResultDetailNamed({Object? extra}) =>
      pushNamed(AppRouteNames.refreshResultDetail, extra: extra);

  void pushHistoryNamed() => pushNamed(AppRouteNames.history);

  void pushSettingsNamed() => pushNamed(AppRouteNames.settings);

  void pushDeviceManageNamed() => pushNamed(AppRouteNames.settingsDevice);

  void pushLocalCalendarSettingsNamed() =>
      pushNamed(AppRouteNames.settingsLocalCalendar);
}
