import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/features/home/data/model/environment_snapshot.dart';
import 'package:lg_hair_refresher/shared/recommendation/refresh_recommend_basis.dart';
import 'package:lg_hair_refresher/shared/recommendation/refresh_recommend_input.dart';
import 'package:lg_hair_refresher/shared/recommendation/refresh_recommend_prompt.dart';

void main() {
  group('HomeRecommendCraftPrompt compatibility', () {
    const environment = EnvironmentSnapshot(
      temperatureCelsius: 18.4,
      humidityPercent: 62,
      isRaining: true,
      isSnowing: false,
    );

    test('message system instruction includes CRAFT sections', () {
      final instruction = RefreshRecommendPrompt.messageSystemInstruction(
        RefreshRecommendBasis.weatherOnly,
      );

      expect(instruction, contains('Context:'));
      expect(instruction, contains('Role:'));
      expect(instruction, contains('Action:'));
      expect(instruction, contains('Format:'));
      expect(instruction, contains('Tone:'));
    });

    test('mode user prompt includes environment json fields', () {
      final prompt = RefreshRecommendPrompt.modeUserPrompt(
        candidates: const [],
        context: RefreshRecommendInput(
          basis: RefreshRecommendBasis.weatherOnly,
          environment: environment,
        ),
      );

      expect(prompt, contains('temperature_celsius'));
      expect(prompt, contains('humidity_percent'));
      expect(prompt, contains('is_raining'));
      expect(prompt, contains('is_snowing'));
      expect(prompt, contains('18.4'));
      expect(prompt, contains('62'));
    });

    test('message user prompt includes recommended mode name', () {
      final prompt = RefreshRecommendPrompt.messageUserPrompt(
        context: RefreshRecommendInput(
          basis: RefreshRecommendBasis.weatherOnly,
          environment: environment,
        ),
        recommendedModeName: '외출 후 케어',
      );

      expect(prompt, contains('외출 후 케어'));
      expect(prompt, contains('리프레시 모드를 추천해요'));
    });
  });
}
