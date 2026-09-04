import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/features/home/data/api/weather_recommend_fallback.dart';
import 'package:lg_hair_refresher/features/home/data/model/environment_snapshot.dart';
import 'package:lg_hair_refresher/features/measure/data/model/measure_result_record.dart';
import 'package:lg_hair_refresher/shared/recommendation/refresh_recommend_basis.dart';
import 'package:lg_hair_refresher/shared/recommendation/refresh_recommend_input.dart';

void main() {
  group('WeatherRecommendFallback', () {
    const environment = EnvironmentSnapshot(
      temperatureCelsius: 24.6,
      humidityPercent: 42,
      isRaining: false,
      isSnowing: false,
    );

    RefreshRecommendInput input(
      EnvironmentSnapshot env, {
      RefreshRecommendBasis basis = RefreshRecommendBasis.weatherOnly,
    }) {
      return RefreshRecommendInput(basis: basis, environment: env);
    }

    test('builds weatherOnly message with mode name', () {
      final message = WeatherRecommendFallback.message(
        input(environment),
        recommendedModeName: '외출 후 케어',
      );

      expect(message, contains('오늘 날씨가'));
      expect(message, contains('외출 후 케어 리프레시 모드를 추천해요'));
    });

    test('builds measure opening when measure is present', () {
      final message = WeatherRecommendFallback.message(
        RefreshRecommendInput(
          basis: RefreshRecommendBasis.measure,
          environment: environment,
          measure: MeasureResultRecord(
            measureId: 'm-1',
            userDeviceId: 'd-1',
            createdAt: DateTime(2026, 6, 18),
            hairDustScore: 70,
            hairOdorScore: 65,
            totalPollutionScore: 68,
          ),
        ),
        recommendedModeName: '외출 후 케어',
      );

      expect(message, contains('측정 결과와 오늘 환경을 보면,'));
    });

    test('uses rainy weather clause with mode name', () {
      const rainy = EnvironmentSnapshot(
        temperatureCelsius: 18,
        humidityPercent: 80,
        isRaining: true,
        isSnowing: false,
      );

      final message = WeatherRecommendFallback.message(
        input(rainy),
        recommendedModeName: '날씨 케어',
      );

      expect(message, contains('비가 오는'));
      expect(message, contains('날씨 케어 리프레시 모드를 추천해요'));
    });
  });
}
