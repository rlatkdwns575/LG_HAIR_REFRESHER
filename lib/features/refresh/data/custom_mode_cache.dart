import 'model/refresh_mode.dart';

/// Supabase에서 불러온 현재 사용자 커스텀 모드 세션 캐시.
class CustomModeCache {
  CustomModeCache._();

  static final CustomModeCache instance = CustomModeCache._();

  List<RefreshMode> _modes = const [];

  // API가 이미 최신순으로 정렬해서 주므로 .reversed를 제거함
  List<RefreshMode> get modes => List.unmodifiable(_modes);

  bool get isEmpty => _modes.isEmpty;

  void setModes(List<RefreshMode> modes) {
    _modes = List.unmodifiable(modes);
  }

  // 최신 등록한 모드가 리스트 맨 상단에 바로 뜨도록 앞쪽에 추가되게 수정
  void add(RefreshMode mode) {
    _modes = [mode, ..._modes];
  }

  bool removeById(String modeId) {
    final before = _modes.length;
    _modes = _modes.where((mode) => mode.id != modeId).toList(growable: false);
    return _modes.length < before;
  }
}
