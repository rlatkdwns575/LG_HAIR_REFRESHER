import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Initialize Supabase and notification services before runApp.
  runApp(const ProviderScope(child: LgHairRefresherApp()));
}
