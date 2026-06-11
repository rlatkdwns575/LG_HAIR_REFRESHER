import '../model/environment_snapshot.dart';

/// Gemini 실패 시 Weather + 추천 모드 기반 규칙 안내 문구.
class WeatherRecommendFallback {
  const WeatherRecommendFallback._();

  static String message(
    EnvironmentSnapshot environment, {
    String? recommendedModeName,
  }) {
    final modeName = recommendedModeName?.trim();
    if (modeName != null && modeName.isNotEmpty) {
      return '오늘 날씨가 ${_weatherClause(environment)} 날이니,\n'
          '$modeName 리프레시 모드를 추천해요.';
    }

    return _legacyMessage(environment);
  }

  static String _weatherClause(EnvironmentSnapshot environment) {
    if (environment.isSnowing) {
      return '눈이 내리는';
    }
    if (environment.isRaining) {
      return '비가 오는';
    }
    if (environment.humidityPercent >= 70) {
      return '습도가 높은';
    }
    if (environment.humidityPercent <= 30) {
      return '공기가 건조한';
    }

    final temp = environment.temperatureCelsius.round();
    if (temp >= 28) {
      return '기온이 높은';
    }
    if (temp <= 5) {
      return '쌀쌀한';
    }

    return '쾌적한';
  }

  static String _legacyMessage(EnvironmentSnapshot environment) {
    final temp = environment.temperatureCelsius.round();

    if (environment.isSnowing) {
      return '눈이 내리는 날이에요.\n외출 전 리프레시로 모발을 정돈해 보세요.';
    }

    if (environment.isRaining) {
      return '비가 오는 하루예요.\n귀가 후 리프레시로 눅눅함을 덜어내 보세요.';
    }

    if (environment.humidityPercent >= 70) {
      return '습도가 높은 하루예요.\n짧은 리프레시로 산뜻함을 더해 보세요.';
    }

    if (environment.humidityPercent <= 30) {
      return '공기가 건조한 하루예요.\n가벼운 리프레시로 모발 컨디션을 챙겨 보세요.';
    }

    if (temp >= 28) {
      return '기온이 높은 하루예요.\n저녁 리프레시로 두피를 시원하게 정돈해 보세요.';
    }

    if (temp <= 5) {
      return '쌀쌀한 날씨예요.\n따뜻한 실내에서 리프레시로 컨디션을 회복해 보세요.';
    }

    return '오늘은 $temp°C, 습도 ${environment.humidityPercent}%예요.\n'
        '리프레시로 하루 마무리를 가볍게 해보세요.';
  }
}
