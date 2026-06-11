import '../api/refresh_mode_mapper.dart';
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

class _CareStepConfig {
  const _CareStepConfig({
    required this.label,
    required this.statusMessage,
    required this.intensityLabel,
    required this.weight,
  });

  final String label;
  final String statusMessage;
  final String intensityLabel;
  final int weight;
}

/// Figma Design `리프레시 > 모드 작동` (793:15950) 목 세션 데이터.
class RefreshProgressSession {
  const RefreshProgressSession({
    required this.modeName,
    required this.steps,
    required this.deviceGuide,
  });

  final String modeName;
  final List<RefreshProgressStep> steps;
  final String deviceGuide;

  int get totalDurationSeconds =>
      steps.fold(0, (sum, step) => sum + step.durationSeconds);

  static const _defaultDeviceGuide = '디바이스를 모발 가까이에서 천천히 고르게 움직여 주세요.';

  static const _intensityLabels = ['집중관리', '일반관리', '간편관리'];

  static const _dustStep = (
    label: '먼지 케어',
    statusMessage: '모발 표면에 외부 먼지를 정리하고 있어요.',
  );
  static const _odorStep = (
    label: '냄새 케어',
    statusMessage: '모발 표면에 남은 냄새를 정리하고 있어요.',
  );
  static const _scentStep = (
    label: '향기 케어',
    statusMessage: '건조한 모발을 부드럽게 정돈하고 있어요.',
  );

  factory RefreshProgressSession.fromMode(RefreshMode mode) {
    final steps = buildStepsForMode(mode);

    return RefreshProgressSession(
      modeName: mode.name.endsWith('모드') ? mode.name : '${mode.name} 모드',
      steps: steps,
      deviceGuide: _defaultDeviceGuide,
    );
  }

  /// 활성 케어만 포함해 [mode.durationSeconds]를 분배한 진행 단계 목록.
  static List<RefreshProgressStep> buildStepsForMode(RefreshMode mode) {
    final careSteps = _enabledCareSteps(mode);
    if (careSteps.isEmpty) {
      return _fallbackSteps(mode.durationSeconds);
    }

    final durations = CareDurationSplit.splitSeconds(
      totalSeconds: mode.durationSeconds,
      weights: careSteps.map((step) => step.weight).toList(),
    );

    return [
      for (var i = 0; i < careSteps.length; i++)
        RefreshProgressStep(
          label: careSteps[i].label,
          statusMessage: careSteps[i].statusMessage,
          durationSeconds: durations[i],
          intensityLabel: careSteps[i].intensityLabel,
        ),
    ];
  }

  static List<_CareStepConfig> _enabledCareSteps(RefreshMode mode) {
    if (mode.isCustom) {
      return _careStepsFromCustomTags(mode);
    }
    return _careStepsFromFlags(mode);
  }

  static List<_CareStepConfig> _careStepsFromFlags(RefreshMode mode) {
    final steps = <_CareStepConfig>[];

    if (mode.dustYn) {
      final intensityLabel = RefreshModeMapper.strengthLabel(mode.dustStrength);
      steps.add(
        _CareStepConfig(
          label: _dustStep.label,
          statusMessage: _dustStep.statusMessage,
          intensityLabel: intensityLabel,
          weight: CareDurationSplit.getCareRatio(
            _intensityFromLabel(intensityLabel),
          ),
        ),
      );
    }
    if (mode.odorYn) {
      final intensityLabel = RefreshModeMapper.strengthLabel(mode.odorStrength);
      steps.add(
        _CareStepConfig(
          label: _odorStep.label,
          statusMessage: _odorStep.statusMessage,
          intensityLabel: intensityLabel,
          weight: CareDurationSplit.getCareRatio(
            _intensityFromLabel(intensityLabel),
          ),
        ),
      );
    }
    if (mode.scentYn) {
      final intensityLabel = RefreshModeMapper.strengthLabel(
        mode.scentStrength,
      );
      steps.add(
        _CareStepConfig(
          label: _scentStep.label,
          statusMessage: _scentStep.statusMessage,
          intensityLabel: intensityLabel,
          weight: CareDurationSplit.getCareRatio(
            _intensityFromLabel(intensityLabel),
          ),
        ),
      );
    }

    return steps;
  }

  static List<_CareStepConfig> _careStepsFromCustomTags(RefreshMode mode) {
    final parsed = mode.tags.map(_parseCareTag).toList()
      ..sort(
        (a, b) =>
            _careSortKey(a.careLabel).compareTo(_careSortKey(b.careLabel)),
      );

    return [
      for (final tag in parsed)
        _CareStepConfig(
          label: _progressLabelForCare(tag.careLabel),
          statusMessage: _statusMessageForCare(tag.careLabel),
          intensityLabel: tag.intensityLabel,
          weight: CareDurationSplit.getCareRatio(tag.intensity),
        ),
    ];
  }

  static List<RefreshProgressStep> _fallbackSteps(int totalSeconds) {
    return [
      RefreshProgressStep(
        label: _dustStep.label,
        statusMessage: _dustStep.statusMessage,
        durationSeconds: totalSeconds,
        intensityLabel: '일반관리',
      ),
    ];
  }

  static _ParsedCareTag _parseCareTag(String tag) {
    for (final intensity in _intensityLabels) {
      if (tag.endsWith(' $intensity')) {
        final careFull = tag.substring(0, tag.length - intensity.length - 1);
        return _ParsedCareTag(
          careLabel: _careTagLabel(careFull),
          intensityLabel: intensity,
          intensity: _intensityFromLabel(intensity),
        );
      }
    }

    return _ParsedCareTag(
      careLabel: tag,
      intensityLabel: '일반관리',
      intensity: CareIntensity.normal,
    );
  }

  static CareIntensity _intensityFromLabel(String label) {
    return switch (label) {
      '집중관리' => CareIntensity.intensive,
      '간편관리' => CareIntensity.simple,
      _ => CareIntensity.normal,
    };
  }

  static String _careTagLabel(String careFull) {
    return switch (careFull) {
      '먼지 케어' || '먼지 제거' => '먼지제거',
      '냄새 케어' || '냄새 제거' => '냄새제거',
      '향기 케어' => '향기케어',
      _ => careFull,
    };
  }

  static String _progressLabelForCare(String careLabel) {
    return switch (careLabel) {
      '먼지제거' => _dustStep.label,
      '냄새제거' => _odorStep.label,
      '향기케어' => _scentStep.label,
      _ => '$careLabel 케어',
    };
  }

  static String _statusMessageForCare(String careLabel) {
    return switch (careLabel) {
      '먼지제거' => _dustStep.statusMessage,
      '냄새제거' => _odorStep.statusMessage,
      '향기케어' => _scentStep.statusMessage,
      _ => '모발 컨디션을 정돈하고 있어요.',
    };
  }

  static int _careSortKey(String careLabel) {
    return switch (careLabel) {
      '먼지제거' => 0,
      '냄새제거' => 1,
      '향기케어' => 2,
      _ => 3,
    };
  }
}

class _ParsedCareTag {
  const _ParsedCareTag({
    required this.careLabel,
    required this.intensityLabel,
    required this.intensity,
  });

  final String careLabel;
  final String intensityLabel;
  final CareIntensity intensity;
}
