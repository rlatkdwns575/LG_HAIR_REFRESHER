import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  const SupabaseService._();

  static bool _initialized = false;

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    final env = _parseEnv(await rootBundle.loadString('.env'));
    final supabaseUrl = env['SUPABASE_URL'];
    final publishableKey = env['SUPABASE_PUBLISHABLE_KEY'];

    if (supabaseUrl == null || supabaseUrl.isEmpty) {
      throw StateError('Missing SUPABASE_URL in .env');
    }

    if (publishableKey == null || publishableKey.isEmpty) {
      throw StateError('Missing SUPABASE_PUBLISHABLE_KEY in .env');
    }

    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: publishableKey,
      debug: false,
    );
    _initialized = true;
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
