import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/route_paths.dart';
import '../../core/services/auth_session_notifier.dart';

bool isAuthRoute(String location) {
  return location == AppRoutePaths.login || location.startsWith('/login/');
}

String? authRedirect(BuildContext context, GoRouterState state) {
  final isLoggedIn = AuthSessionNotifier.instance.isLoggedIn;
  final onAuthRoute = isAuthRoute(state.matchedLocation);

  if (isLoggedIn && onAuthRoute) {
    return AppRoutePaths.home;
  }

  if (!isLoggedIn && !onAuthRoute) {
    return AppRoutePaths.login;
  }

  return null;
}
