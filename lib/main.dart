import 'package:flutter/material.dart';
import 'package:device_calendar/device_calendar.dart';

import 'app/app.dart';
import 'core/services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  DeviceCalendarPlugin();
  await SupabaseService.initialize();

  runApp(const LgHairRefresherApp());
}
