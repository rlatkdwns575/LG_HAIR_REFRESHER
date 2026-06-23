import 'package:go_router/go_router.dart';

import '../../core/constants/route_paths.dart';
import '../../core/services/auth_router_notifier.dart';

String? authRedirect(AuthRouterNotifier auth, GoRouterState state) {
  if (!auth.hasActiveSession) {
    return null;
  }

  final location = state.matchedLocation;
  if (location == AppRoutePaths.login ||
      location == AppRoutePaths.emailLogin ||
      location == AppRoutePaths.signUp ||
      location == AppRoutePaths.signUpStepTwo) {
    return AppRoutePaths.home;
  }

  return null;
}
