import 'package:flutter/material.dart';

import '../../../refresh/data/model/refresh_mode.dart';
import '../../../../app/theme/app_colors.dart';
import 'measure_care_level.dart';
import 'measure_result_headline.dart';
import 'measure_result_status_item.dart';
import 'measure_result_view_type.dart';

/// 헤어 상태 진단 결과 화면 데이터.
///
/// [odorLevel], [dustLevel] 로 화면 타입이 결정되며,
/// 추후 API 응답을 이 모델로 변환해 연결합니다.
class MeasureResult {
  const MeasureResult({
    required this.odorLevel,
    required this.dustLevel,
    required this.headline,
    required this.recommendedMode,
    this.detailLinkLabel = '상세 결과 보기',
  });

  final MeasureCareLevel odorLevel;
  final MeasureCareLevel dustLevel;
  final MeasureResultHeadline headline;
  final RefreshMode recommendedMode;
  final String detailLinkLabel;

  MeasureResultViewType get viewType =>
      odorLevel.needsAction || dustLevel.needsAction
      ? MeasureResultViewType.actionRequired
      : MeasureResultViewType.stable;

  List<MeasureResultStatusItem> get statusItems => [
    odorLevel.toStatusItem('냄새 관리'),
    dustLevel.toStatusItem('먼지 관리'),
  ];

  static const RefreshMode _outdoorSafeRefresh = RefreshMode(
    id: 'outdoor-safe-refresh',
    name: '외출 후 안심 리프레시',
    description: '외출 후 머리카락에 남은 냄새와 먼지를 집중적으로 관리해요.',
    category: RefreshModeCategory.dust,
    durationMinutes: 10,
    icon: Icons.air_outlined,
    tags: ['집중 냄새 케어', '집중 먼지 케어'],
  );

  static const RefreshMode _dailyRefresh = RefreshMode(
    id: 'daily-light-refresh',
    name: '데일리 라이트 리프레시',
    description: '현재 상태를 유지하기 위한 가벼운 리프레시예요.',
    category: RefreshModeCategory.normal,
    durationMinutes: 5,
    icon: Icons.bolt_outlined,
    tags: ['데일리', '가벼운 케어'],
  );

  /// 경고형 mock — Figma 621-12885 (냄새 집중 권장 + 먼지 집중 필요).
  static const sampleActionRequired = MeasureResult(
    odorLevel: MeasureCareLevel.intensiveRecommended,
    dustLevel: MeasureCareLevel.intensiveRequired,
    headline: MeasureResultHeadline.highlighted(
      before: '외출 후 남은 냄새와 먼지를 정리해 ',
      highlight: '안심할 수 있는 상태',
      after: '를 되찾아보세요.',
      highlightColor: AppColors.orange700,
    ),
    recommendedMode: _outdoorSafeRefresh,
  );

  /// 안정형 mock — Figma 621-12875 (냄새/먼지 보통).
  static const sampleStable = MeasureResult(
    odorLevel: MeasureCareLevel.normal,
    dustLevel: MeasureCareLevel.normal,
    headline: MeasureResultHeadline.plain('현재 헤어 상태는 안정적이에요.\n가벼운 관리만으로 충분해요.'),
    recommendedMode: _dailyRefresh,
  );

  /// 화면 기본 mock. 개발 중 타입 확인 시 [sampleStable] 로 교체 가능.
  static const sample = sampleActionRequired;
}
