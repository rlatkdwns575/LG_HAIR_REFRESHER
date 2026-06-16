import 'package:flutter/material.dart';

import '../data/refresh_mode_availability.dart';

void showRefreshScentUnavailableSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      const SnackBar(
        content: Text(RefreshModeAvailability.unavailableReason),
        behavior: SnackBarBehavior.floating,
      ),
    );
}
