class HomeQuickRefreshMode {
  const HomeQuickRefreshMode({
    required this.title,
    required this.durationLabel,
    this.captionItems = const [],
  });

  final String title;
  final String durationLabel;
  final List<String> captionItems;
}

/// 홈 대시보드 목 데이터.
///
/// [hasUsageHistory]가 false이면 즐겨찾기·자주 사용한 모드 영역을 숨깁니다.
class HomeDashboardData {
  const HomeDashboardData({
    this.deviceName = '우리 기기 이름',
    this.batteryPercent = 60,
    this.filterStatusLabel = '양호',
    this.recommendMessage = '대기 중 미세먼지량이 많은 하루였어요.\n잠들기 전 리프레시를 통해 안심하고 숙면하세요.',
    this.hasUsageHistory = false,
    this.frequentMode = const HomeQuickRefreshMode(
      title: '퀵 리프레시',
      durationLabel: '2분',
      captionItems: ['냄새 제거 중', '먼지 제거 중'],
    ),
    this.hasRecentDiagnosisResult = false,
  });

  final String deviceName;
  final int batteryPercent;
  final String filterStatusLabel;

  /// 외부 환경 기반 추천 안내 문구.
  final String recommendMessage;

  /// 1회 이상 사용 후 true — 즐겨찾기·자주 사용한 모드 노출.
  final bool hasUsageHistory;

  /// 자주 사용한 모드 (사용 이력이 있을 때 노출).
  final HomeQuickRefreshMode? frequentMode;
  final bool hasRecentDiagnosisResult;
}

/// 간편 리프레시 행 슬롯 종류.
enum HomeQuickSlotType {
  /// 즐겨찾기 미등록 — "즐겨찾기 추천 추가하기" 카드.
  favoriteAdd,

  /// 등록된 즐겨찾기 모드.
  favoriteMode,

  /// 자주 사용한 모드.
  frequentMode,
}

class HomeQuickRefreshSlot {
  const HomeQuickRefreshSlot({required this.type, this.mode});

  final HomeQuickSlotType type;
  final HomeQuickRefreshMode? mode;
}
