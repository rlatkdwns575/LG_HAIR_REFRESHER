import 'model/refresh_mode.dart';
import 'refresh_mode_catalog.dart';

/// [GoRouter] extra 로 전달된 값을 [RefreshMode] 로 해석합니다.
RefreshMode? resolveRefreshMode(Object? extra) {
  if (extra is RefreshMode) {
    return extra;
  }
  if (extra is String) {
    for (final mode in getAllRefreshModes()) {
      if (mode.name == extra) {
        return mode;
      }
    }
  }
  return null;
}
