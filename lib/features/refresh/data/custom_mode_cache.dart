import 'model/refresh_mode.dart';

/// Supabase에서 불러온 현재 사용자 커스텀 모드 세션 캐시.
class CustomModeCache {
  CustomModeCache._();

  static final CustomModeCache instance = CustomModeCache._();

  List<RefreshMode> _modes = const [];

  List<RefreshMode> get modes => List.unmodifiable(_modes.reversed);

  bool get isEmpty => _modes.isEmpty;

  void setModes(List<RefreshMode> modes) {
    _modes = List.unmodifiable(modes);
  }

  void add(RefreshMode mode) {
    _modes = [..._modes, mode];
  }

  bool removeById(String modeId) {
    final before = _modes.length;
    _modes = _modes.where((mode) => mode.id != modeId).toList(growable: false);
    return _modes.length < before;
  }
}
