/// OpenWeatherMap Current Weather 기반 환경 스냅샷.
class EnvironmentSnapshot {
  const EnvironmentSnapshot({
    required this.temperatureCelsius,
    required this.humidityPercent,
    required this.isRaining,
    required this.isSnowing,
  });

  final double temperatureCelsius;
  final int humidityPercent;
  final bool isRaining;
  final bool isSnowing;

  Map<String, dynamic> toPromptJson() => {
    'temperature_celsius': temperatureCelsius,
    'humidity_percent': humidityPercent,
    'is_raining': isRaining,
    'is_snowing': isSnowing,
  };

  factory EnvironmentSnapshot.fromOpenWeather(
    Map<String, dynamic> weatherJson,
  ) {
    final main = weatherJson['main'] as Map<String, dynamic>? ?? {};

    return EnvironmentSnapshot(
      temperatureCelsius: (main['temp'] as num?)?.toDouble() ?? 0,
      humidityPercent: (main['humidity'] as num?)?.round() ?? 0,
      isRaining: _detectPrecipitation(
        weatherJson: weatherJson,
        precipitationKey: 'rain',
        conditionMains: const ['Rain', 'Drizzle', 'Thunderstorm'],
        idRangeStart: 500,
        idRangeEnd: 600,
      ),
      isSnowing: _detectPrecipitation(
        weatherJson: weatherJson,
        precipitationKey: 'snow',
        conditionMains: const ['Snow'],
        idRangeStart: 600,
        idRangeEnd: 700,
      ),
    );
  }

  static bool _detectPrecipitation({
    required Map<String, dynamic> weatherJson,
    required String precipitationKey,
    required List<String> conditionMains,
    required int idRangeStart,
    required int idRangeEnd,
  }) {
    final precipitation =
        weatherJson[precipitationKey] as Map<String, dynamic>?;
    if (precipitation != null &&
        precipitation.values.any((value) => (value as num) > 0)) {
      return true;
    }

    final weatherList = weatherJson['weather'] as List<dynamic>? ?? [];
    for (final item in weatherList) {
      final weather = item as Map<String, dynamic>;
      final main = weather['main'] as String?;
      if (main != null && conditionMains.contains(main)) {
        return true;
      }

      final id = weather['id'] as num?;
      if (id != null && id >= idRangeStart && id < idRangeEnd) {
        return true;
      }
    }

    return false;
  }
}
