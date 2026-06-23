import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

/// [GoRouter.refreshListenable]용 Supabase Auth 세션 변경 알림.
class AuthRouterNotifier extends ChangeNotifier {
  StreamSubscription<AuthState>? _subscription;
  bool _bound = false;

  void bind() {
    if (_bound || !SupabaseService.isInitialized) {
      return;
    }
    _bound = true;
    _subscription = SupabaseService.client.auth.onAuthStateChange.listen((_) {
      notifyListeners();
    });
    notifyListeners();
  }

  bool get hasActiveSession {
    if (!SupabaseService.isInitialized) {
      return false;
    }
    return SupabaseService.client.auth.currentSession != null;
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }
}
