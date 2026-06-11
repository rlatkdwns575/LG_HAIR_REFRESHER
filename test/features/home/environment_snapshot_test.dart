import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/features/home/data/model/environment_snapshot.dart';

void main() {
  group('EnvironmentSnapshot.fromOpenWeather', () {
    test('parses temperature, humidity, rain and snow flags', () {
      final snapshot = EnvironmentSnapshot.fromOpenWeather({
        'main': {'temp': 12.3, 'humidity': 55},
        'weather': [
          {'id': 501, 'main': 'Rain', 'description': 'moderate rain'},
        ],
        'rain': {'1h': 1.2},
      });

      expect(snapshot.temperatureCelsius, 12.3);
      expect(snapshot.humidityPercent, 55);
      expect(snapshot.isRaining, isTrue);
      expect(snapshot.isSnowing, isFalse);
      expect(snapshot.toPromptJson(), {
        'temperature_celsius': 12.3,
        'humidity_percent': 55,
        'is_raining': true,
        'is_snowing': false,
      });
    });

    test('detects snow from weather condition', () {
      final snapshot = EnvironmentSnapshot.fromOpenWeather({
        'main': {'temp': -2.0, 'humidity': 80},
        'weather': [
          {'id': 601, 'main': 'Snow', 'description': 'snow'},
        ],
      });

      expect(snapshot.isRaining, isFalse);
      expect(snapshot.isSnowing, isTrue);
    });

    test('returns false precipitation flags on clear weather', () {
      final snapshot = EnvironmentSnapshot.fromOpenWeather({
        'main': {'temp': 20.0, 'humidity': 40},
        'weather': [
          {'id': 800, 'main': 'Clear', 'description': 'clear sky'},
        ],
      });

      expect(snapshot.isRaining, isFalse);
      expect(snapshot.isSnowing, isFalse);
    });
  });
}
