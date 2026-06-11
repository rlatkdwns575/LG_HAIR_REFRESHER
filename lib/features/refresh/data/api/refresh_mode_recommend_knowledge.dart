import 'dart:convert';

import '../../../home/data/model/environment_snapshot.dart';
import '../model/refresh_mode.dart';

/// CRAFT 기반 리프레시 모드 추천 knowledge (정적 파일).
class RefreshModeRecommendKnowledge {
  const RefreshModeRecommendKnowledge._();

  static const categoryGuide = '''
카테고리 추천 기준:
- 외출 전: 외출 직전 모발을 빠르게 정돈하고 산뜻하게 마무리할 때
- 외출 후: 외출 후 모발에 쌓인 먼지·냄새·습기를 정리할 때
- 날씨: 비·눈·고습·건조 등 날씨 환경에 맞춰 두피·모발 컨디션을 케어할 때
''';

  static const systemInstruction =
      '''
Context: LG Hair Refresher 앱의 리프레시 모드 추천 기능입니다. 후보 모드는 REFRESH_MODE 프리셋 목록입니다.
Role: 모발·두피·날씨 환경을 고려하는 리프레시 모드 큐레이터입니다.
Action: 아래 knowledge, 후보 모드 JSON, 환경 JSON을 분석해 가장 적합한 모드 하나의 mode_id를 선택하세요.
Format: {"mode_id":"<uuid>"} JSON만 출력하세요. 다른 텍스트 금지.
Tone: 실용적이고 간결하게, 과장하지 마세요.

$categoryGuide
''';

  static String userPrompt({
    required List<RefreshMode> candidates,
    required EnvironmentSnapshot environment,
  }) {
    final modesJson = jsonEncode(
      candidates.map((mode) => mode.toRecommendJson()).toList(),
    );
    final environmentJson = jsonEncode(environment.toPromptJson());

    return '''
후보 모드 JSON:
$modesJson

환경 JSON:
$environmentJson
''';
  }
}
