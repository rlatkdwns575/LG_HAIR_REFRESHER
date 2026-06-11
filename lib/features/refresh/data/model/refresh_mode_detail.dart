import '../api/refresh_mode_mapper.dart';
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
    final totalSeconds = mode.durationSeconds;
    final durations = CareDurationSplit.splitSeconds(
      totalSeconds: totalSeconds,
      weights: weights,
    );

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
    final parsedTags = _parsedTagsFromFlags(mode);
    if (parsedTags.isEmpty) {
      return _fromCategoryFallback(mode);
    }

    final weights = parsedTags
        .map((tag) => CareDurationSplit.getCareRatio(tag.intensity))
        .toList();
    final totalSeconds = mode.durationSeconds;
    final durations = CareDurationSplit.splitSeconds(
      totalSeconds: totalSeconds,
      weights: weights,
    );

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

  static RefreshModeDetail _fromCategoryFallback(RefreshMode mode) {
    final totalSeconds = mode.durationSeconds;
    const careLabel = '먼지제거';
    const intensityLabel = '일반관리';

    return RefreshModeDetail(
      mode: mode,
      careTags: const [
        RefreshModeDetailCareTag(
          careLabel: careLabel,
          intensityLabel: intensityLabel,
        ),
      ],
      totalDurationLabel: _formatTotalDurationLabel(totalSeconds),
      steps: [
        RefreshModeDetailStep(
          durationLabel: _formatStepDurationLabel(totalSeconds),
          title: '먼지 $intensityLabel',
          description: mode.description.replaceAll('\n', ' '),
        ),
      ],
    );
  }

  static List<_ParsedCareTag> _parsedTagsFromFlags(RefreshMode mode) {
    final tags = <_ParsedCareTag>[];

    if (mode.dustYn) {
      tags.add(
        _ParsedCareTag(
          careLabel: RefreshModeMapper.careLabelForFlag(
            type: 'dust',
            enabled: true,
          ),
          intensityLabel: RefreshModeMapper.strengthLabel(mode.dustStrength),
          intensity: _intensityFromLabel(
            RefreshModeMapper.strengthLabel(mode.dustStrength),
          ),
        ),
      );
    }
    if (mode.odorYn) {
      tags.add(
        _ParsedCareTag(
          careLabel: RefreshModeMapper.careLabelForFlag(
            type: 'odor',
            enabled: true,
          ),
          intensityLabel: RefreshModeMapper.strengthLabel(mode.odorStrength),
          intensity: _intensityFromLabel(
            RefreshModeMapper.strengthLabel(mode.odorStrength),
          ),
        ),
      );
    }
    if (mode.scentYn) {
      tags.add(
        _ParsedCareTag(
          careLabel: RefreshModeMapper.careLabelForFlag(
            type: 'scent',
            enabled: true,
          ),
          intensityLabel: RefreshModeMapper.strengthLabel(mode.scentStrength),
          intensity: _intensityFromLabel(
            RefreshModeMapper.strengthLabel(mode.scentStrength),
          ),
        ),
      );
    }

    tags.sort(
      (a, b) => _careSortKey(a.careLabel).compareTo(_careSortKey(b.careLabel)),
    );
    return tags;
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
