import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/services/notification_service.dart';
import 'core/services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseService.initialize();
  await NotificationService.initialize();

  runApp(const LgHairRefresherApp());
}
