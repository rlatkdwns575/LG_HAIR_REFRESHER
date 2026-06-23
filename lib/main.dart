import 'package:flutter/material.dart';
import 'package:device_calendar/device_calendar.dart';

import 'app/app.dart';
import 'app/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/services/supabase_service.dart';
import 'features/routine/data/api/routine_alarm_scheduler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  DeviceCalendarPlugin();
  await SupabaseService.initialize();
  initializeAppRouterAuth();
  await NotificationService.initialize();
  await RoutineAlarmScheduler.rescheduleAll(requestPermissionIfNeeded: false);

  runApp(const LgHairRefresherApp());
}
