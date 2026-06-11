import '../care_duration_split.dart';
import 'refresh_mode.dart';

/// 리프레시 진행 화면의 단계 정보.
class RefreshProgressStep {
  const RefreshProgressStep({
    required this.label,
    required this.statusMessage,
    required this.durationSeconds,
    required this.intensityLabel,
    this.pausedHint,
  });

  final String label;
  final String statusMessage;
  final int durationSeconds;
  final String intensityLabel;
  final String? pausedHint;

  String get durationLabel =>
      CareDurationSplit.formatKoreanDuration(durationSeconds);

  /// Figma 단계명 (예: `먼지 집중관리`).
  String get stepTitle {
    final careName = label.replaceAll(' 케어', '');
    return '$careName $intensityLabel';
  }
}

/// Figma Design `리프레시 > 모드 작동` (793:15950) 목 세션 데이터.
class RefreshProgressSession {
  const RefreshProgressSession({
    required this.modeName,
    required this.steps,
    required this.deviceGuide,
    required this.totalDurationMinutes,
  });

  final String modeName;
  final List<RefreshProgressStep> steps;
  final String deviceGuide;
  final int totalDurationMinutes;

  int get totalDurationSeconds =>
      steps.fold(0, (sum, step) => sum + step.durationSeconds);

  static const _defaultDeviceGuide = '디바이스를 모발 가까이에서 천천히 고르게 움직여 주세요.';

  static const _stepRatios = [2, 3, 2];

  static const _intensityLabels = ['집중관리', '일반관리', '간편관리'];

  static const _stepTemplates = [
    (label: '먼지 케어', statusMessage: '모발 표면에 외부 먼지를 정리하고 있어요.'),
    (label: '냄새 케어', statusMessage: '모발 표면에 남은 냄새를 정리하고 있어요.'),
    (label: '향기 케어', statusMessage: '건조한 모발을 부드럽게 정돈하고 있어요.'),
  ];

  factory RefreshProgressSession.fromMode(RefreshMode mode) {
    final steps = buildStepsForDuration(mode.durationMinutes);

    return RefreshProgressSession(
      modeName: mode.name.endsWith('모드') ? mode.name : '${mode.name} 모드',
      steps: steps,
      deviceGuide: _defaultDeviceGuide,
      totalDurationMinutes: mode.durationMinutes,
    );
  }

  /// [durationMinutes]를 Figma 단계 비율(2:3:2)로 나눈 진행 단계 목록.
  static List<RefreshProgressStep> buildStepsForDuration(int durationMinutes) {
    final totalSeconds = durationMinutes * 60;
    final ratioSum = _stepRatios.fold<int>(0, (sum, ratio) => sum + ratio);
    final durations = <int>[];
    var assigned = 0;

    for (var i = 0; i < _stepTemplates.length; i++) {
      if (i == _stepTemplates.length - 1) {
        durations.add(totalSeconds - assigned);
        continue;
      }

      final stepSeconds = (totalSeconds * _stepRatios[i] / ratioSum).round();
      durations.add(stepSeconds);
      assigned += stepSeconds;
    }

    return [
      for (var i = 0; i < _stepTemplates.length; i++)
        RefreshProgressStep(
          label: _stepTemplates[i].label,
          statusMessage: _stepTemplates[i].statusMessage,
          durationSeconds: durations[i],
          intensityLabel: _intensityLabels[i % _intensityLabels.length],
        ),
    ];
  }
}
