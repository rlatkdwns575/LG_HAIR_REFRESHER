import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/services/app_env.dart';
import '../model/environment_snapshot.dart';

class WeatherApi {
  const WeatherApi();

  static const _seoulLatitude = 37.5665;
  static const _seoulLongitude = 126.9780;

  Future<EnvironmentSnapshot> fetchSnapshot({
    double latitude = _seoulLatitude,
    double longitude = _seoulLongitude,
  }) async {
    final apiKey = AppEnv.weatherApiKey;
    final query = 'lat=$latitude&lon=$longitude&appid=$apiKey';

    final weatherResponse = await http.get(
      Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?$query&units=metric&lang=kr',
      ),
    );
    if (weatherResponse.statusCode != 200) {
      throw WeatherApiException(
        'Weather request failed (${weatherResponse.statusCode}): '
        '${weatherResponse.body}',
      );
    }

    return EnvironmentSnapshot.fromOpenWeather(
      jsonDecode(weatherResponse.body) as Map<String, dynamic>,
    );
  }
}

class WeatherApiException implements Exception {
  const WeatherApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
