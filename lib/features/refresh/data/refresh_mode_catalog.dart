import 'custom_mode_store.dart';
import 'model/refresh_mode.dart';

/// 앱 내에서 사용 가능한 전체 리프레시 모드 목록.
///
/// 정해진 모드는 [RefreshMode.samples], 커스텀 모드는 [CustomModeStore]에서 합칩니다.
/// 커스텀 모드는 추후 Supabase `data/api` 연동으로 대체됩니다.
List<RefreshMode> getAllRefreshModes() {
  return [...RefreshMode.samples, ...CustomModeStore.instance.modes];
}
