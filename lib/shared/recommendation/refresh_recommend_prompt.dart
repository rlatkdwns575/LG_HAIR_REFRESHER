import 'dart:convert';

import '../../features/refresh/data/model/refresh_mode.dart';
import 'refresh_recommend_basis.dart';
import 'refresh_recommend_input.dart';

/// CRAFT 기반 통합 추천 프롬프트.
class RefreshRecommendPrompt {
  const RefreshRecommendPrompt._();

  static const _categoryGuide = '''
카테고리 추천 기준:
- 외출 전: 외출 직전 모발을 빠르게 정돈하고 산뜻하게 마무리할 때
- 외출 후: 외출 후 모발에 쌓인 먼지·냄새·습기를 정리할 때
- 날씨: 비·눈·고습·건조 등 날씨 환경에 맞춰 두피·모발 컨디션을 케어할 때
''';

  static String modeSystemInstruction(RefreshRecommendBasis basis) {
    final basisRule = switch (basis) {
      RefreshRecommendBasis.measure =>
        '측정 점수(냄새·먼지·종합 오염)를 최우선으로 반영하고, 날씨·일정은 보조 신호로 사용하세요.',
      RefreshRecommendBasis.weatherAndSchedule =>
        '날씨와 오늘 일정을 균형 있게 반영해 가장 적합한 모드를 선택하세요.',
      RefreshRecommendBasis.weatherOnly =>
        '환경 JSON(기온·습도·강수)만 사용하세요. 일정이나 측정 데이터는 제공되지 않았으므로 언급하지 마세요.',
    };

    return '''
Context: LG Hair Refresher 앱의 리프레시 모드 추천 기능입니다. 후보 모드는 REFRESH_MODE 프리셋 목록입니다.
Role: 모발·두피·환경을 고려하는 리프레시 모드 큐레이터입니다.
Action: 아래 knowledge, 후보 모드 JSON, 제공된 입력 JSON을 분석해 가장 적합한 모드 하나의 mode_id를 선택하세요.
Format: {"mode_id":"<uuid>"} JSON만 출력하세요. 다른 텍스트 금지.
Tone: 실용적이고 간결하게, 과장하지 마세요.

추천 근거: $basisRule

$_categoryGuide
''';
  }

  static String messageSystemInstruction(RefreshRecommendBasis basis) {
    final openingHint = switch (basis) {
      RefreshRecommendBasis.measure =>
        '첫 문장은 "측정 결과와 오늘 환경을 보면," 또는 유사한 표현으로 시작하세요.',
      RefreshRecommendBasis.weatherAndSchedule =>
        '첫 문장은 "오늘 일정과 날씨를 보면," 또는 유사한 표현으로 시작하세요.',
      RefreshRecommendBasis.weatherOnly => '첫 문장은 "오늘 날씨가 ~한 날이니," 형식으로 시작하세요.',
    };

    return '''
Context: LG Hair Refresher 모바일 앱의 리프레시 추천 안내 문구입니다.
Role: 두피와 모발 환경을 고려하는 친절한 헤어 케어 코치입니다.
Action: 제공된 입력 JSON과 추천 리프레시 모드 이름을 분석하고, 해당 모드를 추천하는 안내 문구를 작성하세요.
Format: 한국어 2문장, $openingHint 둘째 문장에서 추천 모드 이름을 포함해 "~ 리프레시 모드를 추천해요."로 마무리하세요. 줄바꿈은 최대 1회(\\n), 100자 내외, 이모지·따옴표·마크다운·불릿 금지. 문구만 출력하세요.
Tone: 따뜻하고 실용적이며, 과장하거나 의학적으로 단정하지 마세요.
''';
  }

  static String modeUserPrompt({
    required List<RefreshMode> candidates,
    required RefreshRecommendInput context,
  }) {
    final modesJson = jsonEncode(
      candidates.map((mode) => mode.toRecommendJson()).toList(),
    );

    return '''
후보 모드 JSON:
$modesJson

${_inputSections(context)}
''';
  }

  static String messageUserPrompt({
    required RefreshRecommendInput context,
    required String recommendedModeName,
  }) {
    final buffer = StringBuffer(_inputSections(context));
    buffer.writeln('\n추천 리프레시 모드 이름: $recommendedModeName');
    buffer.writeln(
      '\n출력 예시:\n'
      '${_messageExample(context.basis, recommendedModeName)}',
    );
    return buffer.toString();
  }

  static String _inputSections(RefreshRecommendInput context) {
    final sections = <String>[
      '환경 JSON:\n${jsonEncode(context.environment.toPromptJson())}',
    ];

    if (context.includesMeasure) {
      sections.add(
        '측정 결과 JSON:\n${jsonEncode(context.measure!.toRecommendJson())}',
      );
    }

    if (context.includesSchedule) {
      sections.add(
        '오늘 일정 JSON:\n${jsonEncode(context.schedule!.toPromptJson())}',
      );
    }

    return sections.join('\n\n');
  }

  static String _messageExample(RefreshRecommendBasis basis, String modeName) {
    return switch (basis) {
      RefreshRecommendBasis.measure =>
        '측정 결과와 오늘 환경을 보면,\n$modeName 리프레시 모드를 추천해요.',
      RefreshRecommendBasis.weatherAndSchedule =>
        '오늘 일정과 날씨를 보면,\n$modeName 리프레시 모드를 추천해요.',
      RefreshRecommendBasis.weatherOnly =>
        '오늘 날씨가 쾌적한 날이니,\n$modeName 리프레시 모드를 추천해요.',
    };
  }
}
