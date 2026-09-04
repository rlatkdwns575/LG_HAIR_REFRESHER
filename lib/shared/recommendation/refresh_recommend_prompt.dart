import 'dart:convert';

import 'refresh_recommend_input.dart';

/// Gemini 추천 문구 프롬프트. 모드 선택은 규칙에서 확정합니다.
class RefreshRecommendPrompt {
  const RefreshRecommendPrompt._();

  static String messageSystemInstruction(RefreshRecommendInput context) {
    final openingHint = _openingHint(context);

    return '''
Context: LG Hair Refresher 모바일 앱의 리프레시 추천 안내 문구입니다.
Role: 두피와 모발 환경을 고려하는 친절한 헤어 케어 코치입니다.
Action: 제공된 입력 JSON과 추천 리프레시 모드 이름을 분석하고, 해당 모드를 추천하는 안내 문구를 작성하세요. 제공된 JSON에 있는 정보만 언급하세요.
Format: 한국어 2문장, $openingHint 둘째 문장에서 추천 모드 이름을 포함해 "~ 리프레시 모드를 추천해요."로 마무리하세요. 줄바꿈은 최대 1회(\\n), 100자 내외, 이모지·따옴표·마크다운·불릿 금지. 문구만 출력하세요.
Tone: 따뜻하고 실용적이며, 과장하거나 의학적으로 단정하지 마세요.
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
      '${_messageExample(context, recommendedModeName)}',
    );
    return buffer.toString();
  }

  static String _openingHint(RefreshRecommendInput context) {
    if (context.includesMeasure && context.includesSchedule) {
      return '첫 문장은 측정 결과와 오늘 일정·날씨를 함께 언급하는 표현으로 시작하세요.';
    }
    if (context.includesMeasure) {
      return '첫 문장은 "측정 결과와 오늘 환경을 보면," 또는 유사한 표현으로 시작하세요.';
    }
    if (context.includesSchedule) {
      return '첫 문장은 "오늘 일정과 날씨를 보면," 또는 유사한 표현으로 시작하세요.';
    }
    return '첫 문장은 "오늘 날씨가 ~한 날이니," 형식으로 시작하세요.';
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

  static String _messageExample(
    RefreshRecommendInput context,
    String modeName,
  ) {
    if (context.includesMeasure && context.includesSchedule) {
      return '측정 결과와 오늘 일정·날씨를 보면,\n$modeName 리프레시 모드를 추천해요.';
    }
    if (context.includesMeasure) {
      return '측정 결과와 오늘 환경을 보면,\n$modeName 리프레시 모드를 추천해요.';
    }
    if (context.includesSchedule) {
      return '오늘 일정과 날씨를 보면,\n$modeName 리프레시 모드를 추천해요.';
    }
    return '오늘 날씨가 쾌적한 날이니,\n$modeName 리프레시 모드를 추천해요.';
  }
}
