import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/data/api/auth_api.dart';

/// Supabase 세션 변화를 [GoRouter.refreshListenable]에 전달합니다.
class AuthSessionNotifier extends ChangeNotifier {
  AuthSessionNotifier._();

  static final AuthSessionNotifier instance = AuthSessionNotifier._();

  final AuthApi _authApi = const AuthApi();
  StreamSubscription<AuthState>? _subscription;

  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  Future<void> initialize() async {
    _isLoggedIn = _authApi.hasSession;

    await _subscription?.cancel();
    _subscription = _authApi.authStateChanges.listen((authState) {
      final loggedIn = authState.session != null;
      if (_isLoggedIn == loggedIn) {
        return;
      }
      _isLoggedIn = loggedIn;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
