import '../care_duration_split.dart';
import 'refresh_mode.dart';

/// 상세 화면 케어 태그 (예: 먼지제거 + 집중관리).
class RefreshModeDetailCareTag {
  const RefreshModeDetailCareTag({
    required this.careLabel,
    required this.intensityLabel,
  });

  final String careLabel;
  final String intensityLabel;
}

/// 상세 화면 단계별 케어 항목.
class RefreshModeDetailStep {
  const RefreshModeDetailStep({
    required this.durationLabel,
    required this.title,
    required this.description,
  });

  final String durationLabel;
  final String title;
  final String description;
}

/// 리프레시 상세 화면 데이터.
///
/// [RefreshMode] 로부터 기본/커스텀 모드 공통 상세 정보를 생성합니다.
class RefreshModeDetail {
  const RefreshModeDetail({
    required this.mode,
    required this.careTags,
    required this.totalDurationLabel,
    required this.steps,
    this.preCheckItems = _defaultPreCheckItems,
  });

  final RefreshMode mode;
  final List<RefreshModeDetailCareTag> careTags;
  final String totalDurationLabel;
  final List<RefreshModeDetailStep> steps;
  final List<String> preCheckItems;

  static const _defaultPreCheckItems = [
    '디바이스를 머리 가까이에 유지해 주세요.',
    '케어 중에는 디바이스를 모발 전체에 골고루 움직여주세요.',
  ];

  static const _intensityLabels = ['집중관리', '일반관리', '간편관리'];

  static const _stepDescriptions = {
    '먼지': '모발 표면에 묻은 먼지를 빠르게 제거해요.',
    '냄새': '모발에 남은 냄새를 부드럽게 정리해요.',
    '향기': '은은한 향기로 마무리해요.',
    '두피': '두피를 시원하게 케어해요.',
  };

  factory RefreshModeDetail.fromMode(RefreshMode mode) {
    if (mode.isCustom) {
      return _fromCustomMode(mode);
    }
    return _fromDefaultMode(mode);
  }

  static RefreshModeDetail _fromCustomMode(RefreshMode mode) {
    final parsedTags = mode.tags.map(_parseCareTag).toList()
      ..sort(
        (a, b) =>
            _careSortKey(a.careLabel).compareTo(_careSortKey(b.careLabel)),
      );
    final weights = parsedTags
        .map((tag) => CareDurationSplit.getCareRatio(tag.intensity))
        .toList();
    final durations = CareDurationSplit.splitSeconds(
      totalMinutes: mode.durationMinutes,
      weights: weights,
    );
    final totalSeconds = mode.durationMinutes * 60;

    final steps = <RefreshModeDetailStep>[];
    for (var i = 0; i < parsedTags.length; i++) {
      final tag = parsedTags[i];
      final stepCare = _stepCareName(tag.careLabel);
      steps.add(
        RefreshModeDetailStep(
          durationLabel: _formatStepDurationLabel(durations[i]),
          title: '$stepCare ${tag.intensityLabel}',
          description: _stepDescriptions[stepCare] ?? mode.description,
        ),
      );
    }

    return RefreshModeDetail(
      mode: mode,
      careTags: [
        for (final tag in parsedTags)
          RefreshModeDetailCareTag(
            careLabel: tag.careLabel,
            intensityLabel: tag.intensityLabel,
          ),
      ],
      totalDurationLabel: _formatTotalDurationLabel(totalSeconds),
      steps: steps,
    );
  }

  static RefreshModeDetail _fromDefaultMode(RefreshMode mode) {
    final preset = _defaultPresets[mode.id] ?? _fallbackPreset(mode);
    final totalSeconds = mode.durationMinutes * 60;

    return RefreshModeDetail(
      mode: mode,
      careTags: preset.careTags,
      totalDurationLabel: _formatTotalDurationLabel(totalSeconds),
      steps: preset.steps
          .map(
            (step) => RefreshModeDetailStep(
              durationLabel: _formatStepDurationLabel(totalSeconds),
              title: '${step.stepCare} ${step.intensityLabel}',
              description: step.description,
            ),
          )
          .toList(),
    );
  }

  static _DefaultPreset _fallbackPreset(RefreshMode mode) {
    final care = switch (mode.category) {
      RefreshModeCategory.dust => _PresetCare(
        careLabel: '먼지제거',
        stepCare: '먼지',
        intensityLabel: '집중관리',
        intensity: CareIntensity.intensive,
      ),
      RefreshModeCategory.care => _PresetCare(
        careLabel: '두피관리',
        stepCare: '두피',
        intensityLabel: '일반관리',
        intensity: CareIntensity.normal,
      ),
      _ => _PresetCare(
        careLabel: '먼지제거',
        stepCare: '먼지',
        intensityLabel: '집중관리',
        intensity: CareIntensity.intensive,
      ),
    };

    return _DefaultPreset(
      careTags: [
        RefreshModeDetailCareTag(
          careLabel: care.careLabel,
          intensityLabel: care.intensityLabel,
        ),
      ],
      steps: [
        _PresetStep(
          stepCare: care.stepCare,
          intensityLabel: care.intensityLabel,
          description:
              _stepDescriptions[care.stepCare] ??
              mode.description.replaceAll('\n', ' '),
        ),
      ],
    );
  }

  static const _defaultPresets = <String, _DefaultPreset>{
    'quick-refresh': _DefaultPreset(
      careTags: [
        RefreshModeDetailCareTag(careLabel: '먼지제거', intensityLabel: '집중관리'),
      ],
      steps: [
        _PresetStep(
          stepCare: '먼지',
          intensityLabel: '집중관리',
          description: '모발 표면에 묻은 먼지를 빠르게 제거해요.',
        ),
      ],
    ),
    'scalp-deep-care': _DefaultPreset(
      careTags: [
        RefreshModeDetailCareTag(careLabel: '두피관리', intensityLabel: '집중관리'),
      ],
      steps: [
        _PresetStep(
          stepCare: '두피',
          intensityLabel: '집중관리',
          description: '두피를 시원하게 케어해요.',
        ),
      ],
    ),
    'fine-dust': _DefaultPreset(
      careTags: [
        RefreshModeDetailCareTag(careLabel: '먼지제거', intensityLabel: '집중관리'),
      ],
      steps: [
        _PresetStep(
          stepCare: '먼지',
          intensityLabel: '집중관리',
          description: '모발 표면에 묻은 먼지를 빠르게 제거해요.',
        ),
      ],
    ),
    'odor-care': _DefaultPreset(
      careTags: [
        RefreshModeDetailCareTag(careLabel: '냄새제거', intensityLabel: '집중관리'),
      ],
      steps: [
        _PresetStep(
          stepCare: '냄새',
          intensityLabel: '집중관리',
          description: '모발에 남은 냄새를 부드럽게 정리해요.',
        ),
      ],
    ),
    'night-care': _DefaultPreset(
      careTags: [
        RefreshModeDetailCareTag(careLabel: '두피관리', intensityLabel: '간편관리'),
      ],
      steps: [
        _PresetStep(
          stepCare: '두피',
          intensityLabel: '간편관리',
          description: '두피를 시원하게 케어해요.',
        ),
      ],
    ),
  };

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
      '먼지 케어' => '먼지제거',
      '냄새 케어' => '냄새제거',
      '향기 케어' => '향기케어',
      _ => careFull,
    };
  }

  static String _stepCareName(String careLabel) {
    return switch (careLabel) {
      '먼지제거' => '먼지',
      '냄새제거' => '냄새',
      '향기케어' => '향기',
      '두피관리' => '두피',
      _ => careLabel,
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

  static String _formatStepDurationLabel(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    if (seconds == 0) {
      return '$minutes분';
    }
    return CareDurationSplit.formatKoreanTime(totalSeconds);
  }

  static String _formatTotalDurationLabel(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    if (seconds == 0) {
      return '총 소요 시간 $minutes분';
    }
    return '총 소요 시간 ${CareDurationSplit.formatKoreanTime(totalSeconds)}';
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

class _PresetStep {
  const _PresetStep({
    required this.stepCare,
    required this.intensityLabel,
    required this.description,
  });

  final String stepCare;
  final String intensityLabel;
  final String description;
}

class _DefaultPreset {
  const _DefaultPreset({required this.careTags, required this.steps});

  final List<RefreshModeDetailCareTag> careTags;
  final List<_PresetStep> steps;
}

class _PresetCare {
  const _PresetCare({
    required this.careLabel,
    required this.stepCare,
    required this.intensityLabel,
    required this.intensity,
  });

  final String careLabel;
  final String stepCare;
  final String intensityLabel;
  final CareIntensity intensity;
}
