import 'package:flutter/material.dart';

import 'refresh_mode.dart';
import 'refresh_pollution_level.dart';
import 'refresh_progress_session.dart';
import 'refresh_result_change.dart';

/// 리프레시 완료 후 최종 결과 화면 데이터.
///
/// [dustRemovalPercent], [odorRemovalPercent], [overallImprovementPercent] 는
/// 추후 API 응답으로 교체할 수 있도록 분리되어 있습니다.
class RefreshResult {
  const RefreshResult({
    required this.dustRemovalPercent,
    required this.odorRemovalPercent,
    required this.overallImprovementPercent,
    required this.headlineBefore,
    required this.headlineAfter,
    required this.disclaimer,
    required this.dustChange,
    required this.odorChange,
    required this.recommendedMode,
    this.detailLinkLabel = '리프레시 결과 자세히 보기',
  });

  final double dustRemovalPercent;
  final double odorRemovalPercent;
  final double overallImprovementPercent;
  final String headlineBefore;
  final String headlineAfter;
  final String disclaimer;
  final RefreshResultChange dustChange;
  final RefreshResultChange odorChange;
  final RefreshMode recommendedMode;
  final String detailLinkLabel;

  String get overallImprovementLabel {
    final value = overallImprovementPercent;
    if (value == value.roundToDouble()) {
      return '${value.toInt()}%';
    }
    return '${value.toStringAsFixed(1)}%';
  }

  static const RefreshMode _scentCareMode = RefreshMode(
    id: 'scent-care',
    name: '향기 케어 모드',
    description: '리프레시 후 은은한 향으로 마무리할 수 있어요',
    category: RefreshModeCategory.care,
    durationMinutes: 2,
    icon: Icons.local_florist_outlined,
    tags: ['냄새 흔적 완화', '산뜻한 잔향', '외출 전 추천'],
  );

  /// 진행 세션 기반 mock 결과. 실제 API 연동 시 이 factory를 교체합니다.
  factory RefreshResult.fromProgressSession({
    required RefreshProgressSession session,
    RefreshMode? mode,
  }) {
    return RefreshResult(
      dustRemovalPercent: 87,
      odorRemovalPercent: 92,
      overallImprovementPercent: 40.9,
      headlineBefore: '외출 후 남아 있던 냄새와 먼지가',
      headlineAfter: '개선되었어요.',
      disclaimer: '외부 활동이 이어지면 냄새와 먼지가 다시 남을 수 있어요.',
      dustChange: const RefreshResultChange(
        label: '먼지',
        beforeLevel: RefreshPollutionLevel.high,
        afterLevel: RefreshPollutionLevel.good,
      ),
      odorChange: const RefreshResultChange(
        label: '냄새',
        beforeLevel: RefreshPollutionLevel.veryHigh,
        afterLevel: RefreshPollutionLevel.normal,
      ),
      recommendedMode: _scentCareMode,
    );
  }

  /// Figma 622-13066 기준 mock.
  static const sample = RefreshResult(
    dustRemovalPercent: 87,
    odorRemovalPercent: 92,
    overallImprovementPercent: 40.9,
    headlineBefore: '외출 후 남아 있던 냄새와 먼지가',
    headlineAfter: '개선되었어요.',
    disclaimer: '외부 활동이 이어지면 냄새와 먼지가 다시 남을 수 있어요.',
    dustChange: RefreshResultChange(
      label: '먼지',
      beforeLevel: RefreshPollutionLevel.high,
      afterLevel: RefreshPollutionLevel.good,
    ),
    odorChange: RefreshResultChange(
      label: '냄새',
      beforeLevel: RefreshPollutionLevel.veryHigh,
      afterLevel: RefreshPollutionLevel.normal,
    ),
    recommendedMode: _scentCareMode,
  );
}
