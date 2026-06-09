import 'model/refresh_mode.dart';

/// 사용자가 생성한 커스텀 모드를 앱 실행 중 메모리에 보관하는 세션 store.
///
/// MVP 단계의 임시 저장소이며, 추후 `data/api` 의 Supabase 연동으로 대체합니다.
/// 앱을 완전히 종료하면 데이터는 사라집니다.
class CustomModeStore {
  CustomModeStore._();

  static final CustomModeStore instance = CustomModeStore._();

  final List<RefreshMode> _modes = [];

  /// 생성된 커스텀 모드 목록 (최신순).
  List<RefreshMode> get modes => List.unmodifiable(_modes.reversed);

  bool get isEmpty => _modes.isEmpty;

  void add(RefreshMode mode) => _modes.add(mode);
}
