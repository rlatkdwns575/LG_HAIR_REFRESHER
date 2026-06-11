import 'dart:convert';

import '../model/environment_snapshot.dart';

/// CRAFT 프롬프트 빌더 (Context + Role + Action + Format + Tone).
class HomeRecommendCraftPrompt {
  const HomeRecommendCraftPrompt._();

  static const systemInstruction = '''
Context: LG Hair Refresher 모바일 앱 홈 화면의 날씨·환경 안내 배너입니다. 이 제품은 헤어 리프레셔로 모발·두피의 먼지, 냄새, 향 케어를 돕습니다.
Role: 두피와 모발 환경을 고려하는 친절한 헤어 케어 코치입니다.
Action: 사용자에게 제공된 환경 JSON(기온, 습도, 강수 여부, 강설 여부)과 추천 리프레시 모드 이름을 분석하고, 오늘 날씨에 맞춰 해당 모드를 추천하는 안내 문구를 작성하세요.
Format: 한국어 2문장, 첫 문장은 "오늘 날씨가 ~한 날이니,"로 시작하고, 둘째 문장에서 추천 모드 이름을 포함해 "~ 리프레시 모드를 추천해요."로 마무리하세요. 줄바꿈은 최대 1회(\\n), 100자 내외, 이모지·따옴표·마크다운·불릿 금지. 문구만 출력하세요.
Tone: 따뜻하고 실용적이며, 과장하거나 의학적으로 단정하지 마세요.
''';

  static String userPrompt(
    EnvironmentSnapshot environment, {
    String? recommendedModeName,
  }) {
    final buffer = StringBuffer(
      '환경 데이터 JSON:\n${jsonEncode(environment.toPromptJson())}',
    );

    if (recommendedModeName != null && recommendedModeName.isNotEmpty) {
      buffer.writeln('\n추천 리프레시 모드 이름: $recommendedModeName');
    }

    buffer.writeln(
      '\n출력 예시:\n'
      '오늘 날씨가 비가 오는 날이니,\n'
      '외출 후 케어 리프레시 모드를 추천해요.',
    );

    return buffer.toString();
  }
}
