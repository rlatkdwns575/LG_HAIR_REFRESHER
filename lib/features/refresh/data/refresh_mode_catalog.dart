import 'custom_mode_store.dart';
import 'model/refresh_mode.dart';

/// Supabase에서 불러온 프리셋 모드 캐시.
class RefreshPresetModeStore {
  RefreshPresetModeStore._();

  static final RefreshPresetModeStore instance = RefreshPresetModeStore._();

  List<RefreshMode> _presets = const [];

  List<RefreshMode> get presets => List.unmodifiable(_presets);

  void setPresets(List<RefreshMode> presets) {
    _presets = List.unmodifiable(presets);
  }
}

/// 앱 내에서 사용 가능한 전체 리프레시 모드 목록.
List<RefreshMode> getAllRefreshModes() {
  return [
    ...RefreshPresetModeStore.instance.presets,
    ...CustomModeStore.instance.modes,
  ];
}
