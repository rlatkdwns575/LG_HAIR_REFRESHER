import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/features/home/data/api/home_recommend_craft_prompt.dart';
import 'package:lg_hair_refresher/features/home/data/model/environment_snapshot.dart';

void main() {
  group('HomeRecommendCraftPrompt', () {
    const environment = EnvironmentSnapshot(
      temperatureCelsius: 18.4,
      humidityPercent: 62,
      isRaining: true,
      isSnowing: false,
    );

    test('system instruction includes CRAFT constraints', () {
      expect(HomeRecommendCraftPrompt.systemInstruction, contains('Context:'));
      expect(HomeRecommendCraftPrompt.systemInstruction, contains('Role:'));
      expect(HomeRecommendCraftPrompt.systemInstruction, contains('Action:'));
      expect(HomeRecommendCraftPrompt.systemInstruction, contains('Format:'));
      expect(HomeRecommendCraftPrompt.systemInstruction, contains('Tone:'));
      expect(HomeRecommendCraftPrompt.systemInstruction, contains('강수 여부'));
    });

    test('user prompt includes environment json fields', () {
      final prompt = HomeRecommendCraftPrompt.userPrompt(environment);

      expect(prompt, contains('temperature_celsius'));
      expect(prompt, contains('humidity_percent'));
      expect(prompt, contains('is_raining'));
      expect(prompt, contains('is_snowing'));
      expect(prompt, contains('18.4'));
      expect(prompt, contains('62'));
    });

    test('user prompt includes recommended mode name and format hint', () {
      final prompt = HomeRecommendCraftPrompt.userPrompt(
        environment,
        recommendedModeName: '외출 후 케어',
      );

      expect(prompt, contains('외출 후 케어'));
      expect(prompt, contains('오늘 날씨가'));
      expect(prompt, contains('리프레시 모드를 추천해요'));
    });
  });
}
