import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_env.dart';

class SupabaseService {
  const SupabaseService._();

  static bool _initialized = false;

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    await AppEnv.load();

    await Supabase.initialize(
      url: AppEnv.supabaseUrl,
      publishableKey: AppEnv.supabasePublishableKey,
      debug: false,
    );
    _initialized = true;
  }
}
