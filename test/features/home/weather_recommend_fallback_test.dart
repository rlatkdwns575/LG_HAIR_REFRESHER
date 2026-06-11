import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/features/home/data/api/weather_recommend_fallback.dart';
import 'package:lg_hair_refresher/features/home/data/model/environment_snapshot.dart';

void main() {
  group('WeatherRecommendFallback', () {
    const environment = EnvironmentSnapshot(
      temperatureCelsius: 24.6,
      humidityPercent: 42,
      isRaining: false,
      isSnowing: false,
    );

    test('builds mode-aware message when mode name is provided', () {
      final message = WeatherRecommendFallback.message(
        environment,
        recommendedModeName: '외출 후 케어',
      );

      expect(message, contains('오늘 날씨가'));
      expect(message, contains('외출 후 케어 리프레시 모드를 추천해요'));
    });

    test('builds legacy weather message without mode name', () {
      final message = WeatherRecommendFallback.message(environment);

      expect(message, contains('25°C'));
      expect(message, contains('42%'));
    });

    test('uses rainy weather clause with mode name', () {
      const rainy = EnvironmentSnapshot(
        temperatureCelsius: 18,
        humidityPercent: 80,
        isRaining: true,
        isSnowing: false,
      );

      final message = WeatherRecommendFallback.message(
        rainy,
        recommendedModeName: '날씨 케어',
      );

      expect(message, contains('비가 오는'));
      expect(message, contains('날씨 케어 리프레시 모드를 추천해요'));
    });
  });
}
