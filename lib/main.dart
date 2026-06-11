import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/services/auth_session_notifier.dart';
import 'core/services/env_config.dart';
import 'core/services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EnvConfig.load();
  await SupabaseService.initialize();
  await AuthSessionNotifier.instance.initialize();

  runApp(const LgHairRefresherApp());
}
