import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../constants/auth_constants.dart';

/// `.env` 파일을 한 번만 읽어 앱 전역에서 사용합니다.
class EnvConfig {
  const EnvConfig._();

  static bool _loaded = false;

  static String? _supabaseUrl;
  static String? _supabasePublishableKey;
  static String? _googleWebClientId;
  static String? _authRedirectUrl;
  static String? _geminiApiKey;
  static String? _weatherApiKey;
  static String? _devUserId;

  static String get supabaseUrl {
    _assertLoaded();
    return _supabaseUrl!;
  }

  static String get supabasePublishableKey {
    _assertLoaded();
    return _supabasePublishableKey!;
  }

  static String? get googleWebClientId {
    _assertLoaded();
    return _googleWebClientId;
  }

  static String get authRedirectUrl {
    _assertLoaded();
    final value = _authRedirectUrl;
    if (value != null && value.isNotEmpty) {
      return value;
    }
    return AuthConstants.oauthRedirectUrl;
  }

  static String? get geminiApiKey {
    _assertLoaded();
    return _geminiApiKey;
  }

  static String? get weatherApiKey {
    _assertLoaded();
    return _weatherApiKey;
  }

  static String? get devUserId {
    _assertLoaded();
    return _devUserId;
  }

  static bool get isGoogleSignInConfigured =>
      _googleWebClientId != null && _googleWebClientId!.isNotEmpty;

  static Future<void> load() async {
    if (_loaded) {
      return;
    }

    final env = _parseEnv(await rootBundle.loadString('.env'));

    _supabaseUrl = env['SUPABASE_URL'];
    _supabasePublishableKey = env['SUPABASE_PUBLISHABLE_KEY'];
    _googleWebClientId = env['GOOGLE_WEB_CLIENT_ID'];
    _authRedirectUrl = env['AUTH_REDIRECT_URL'];
    _geminiApiKey = env['GEMINI_API_KEY'];
    _weatherApiKey = env['WEATHER_API_KEY'];
    _devUserId = env['DEV_USER_ID'];

    if (_supabaseUrl == null || _supabaseUrl!.isEmpty) {
      throw StateError('Missing SUPABASE_URL in .env');
    }

    if (_supabasePublishableKey == null || _supabasePublishableKey!.isEmpty) {
      throw StateError('Missing SUPABASE_PUBLISHABLE_KEY in .env');
    }

    _loaded = true;
    _logMissingOptionalKeys();
  }

  static void _logMissingOptionalKeys() {
    if (!kDebugMode) {
      return;
    }

    if (!isGoogleSignInConfigured) {
      debugPrint('[EnvConfig] GOOGLE_WEB_CLIENT_ID 없음 → Supabase OAuth 방식 사용');
      debugPrint('[EnvConfig] Redirect URL: $authRedirectUrl');
    }
  }

  static void _assertLoaded() {
    if (!_loaded) {
      throw StateError(
        'EnvConfig.load() must be called before reading values.',
      );
    }
  }

  static Map<String, String> _parseEnv(String source) {
    final values = <String, String>{};

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
      values[key] = _stripQuotes(value);
    }

    return values;
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
