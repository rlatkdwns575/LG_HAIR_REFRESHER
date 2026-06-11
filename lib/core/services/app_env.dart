import 'package:flutter/services.dart';

/// `.env` asset 파싱 및 앱 전역 설정 접근.
class AppEnv {
  const AppEnv._();

  static Map<String, String>? _values;

  static Future<void> load() async {
    if (_values != null) {
      return;
    }

    _values = _parseEnv(await rootBundle.loadString('.env'));
  }

  static Map<String, String> get values {
    final loaded = _values;
    if (loaded == null) {
      throw StateError('AppEnv.load() must be called before reading values.');
    }
    return loaded;
  }

  static String? optional(String key) => values[key];

  static String require(String key) {
    final value = optional(key);
    if (value == null || value.isEmpty) {
      throw StateError('Missing $key in .env');
    }
    return value;
  }

  static String get supabaseUrl => require('SUPABASE_URL');

  static String get supabasePublishableKey =>
      require('SUPABASE_PUBLISHABLE_KEY');

  static String get weatherApiKey => require('WEATHER_API_KEY');

  static String get geminiApiKey => require('GEMINI_API_KEY');

  /// 개발용 사용자 ID — `AUTH_USERS.user_id` UUID.
  static String get devUserId => require('DEV_USER_ID').trim();

  static Map<String, String> _parseEnv(String source) {
    final parsed = <String, String>{};

    for (final rawLine in source.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty || line.startsWith('#')) {
        continue;
      }

      final separatorIndex = line.indexOf('=');
      if (separatorIndex < 1) {
        continue;
      }

      final key = line.substring(0, separatorIndex).trim();
      final value = line.substring(separatorIndex + 1).trim();
      parsed[key] = _stripQuotes(value);
    }

    return parsed;
  }

  static String _stripQuotes(String value) {
    if (value.length < 2) {
      return value;
    }

    final startsWithSingleQuote = value.startsWith("'");
    final endsWithSingleQuote = value.endsWith("'");
    final startsWithDoubleQuote = value.startsWith('"');
    final endsWithDoubleQuote = value.endsWith('"');

    if ((startsWithSingleQuote && endsWithSingleQuote) ||
        (startsWithDoubleQuote && endsWithDoubleQuote)) {
      return value.substring(1, value.length - 1);
    }

    return value;
  }
}
