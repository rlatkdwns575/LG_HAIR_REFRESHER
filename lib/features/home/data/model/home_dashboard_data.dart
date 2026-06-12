import 'home_filter_status.dart';

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

/// API에서 자주 사용 모드를 못 가져올 때 우측 카드 기본값.
const homeFrequentModeFallback = HomeQuickRefreshMode(
  title: '자주 사용한 모드',
  durationLabel: '2분',
);

/// 홈 대시보드 목 데이터.
///
/// [hasUsageHistory]가 false이면 즐겨찾기·자주 사용한 모드 영역을 숨깁니다.
class HomeDashboardData {
  const HomeDashboardData({
    this.deviceName = '우리 기기 이름',
    this.modelName,
    this.batteryPercent = 60,
    this.filterStatus = HomeFilterStatus.freshDefault,
    this.recommendMessage = '대기 중 미세먼지량이 많은 하루였어요.\n잠들기 전 리프레시를 통해 안심하고 숙면하세요.',
    this.hasUsageHistory = false,
    this.frequentMode = const HomeQuickRefreshMode(
      title: '퀵 리프레시',
      durationLabel: '2분',
      captionItems: ['냄새 제거 중', '먼지 제거 중'],
    ),
    this.hasRecentDiagnosisResult = false,
    this.linkedDeviceId,
  });

  final String deviceName;
  final String? modelName;
  final String? linkedDeviceId;
  final int batteryPercent;
  final HomeFilterStatus filterStatus;

  /// 외부 환경 기반 추천 안내 문구.
  final String recommendMessage;

  /// 1회 이상 사용 후 true — 즐겨찾기·자주 사용한 모드 노출.
  final bool hasUsageHistory;

  /// 자주 사용한 모드 (사용 이력이 있을 때 노출).
  final HomeQuickRefreshMode? frequentMode;
  final bool hasRecentDiagnosisResult;

  HomeDashboardData copyWith({
    String? deviceName,
    String? modelName,
    int? batteryPercent,
    HomeFilterStatus? filterStatus,
    String? recommendMessage,
    bool? hasUsageHistory,
    HomeQuickRefreshMode? frequentMode,
    bool? hasRecentDiagnosisResult,
    String? linkedDeviceId,
  }) {
    return HomeDashboardData(
      deviceName: deviceName ?? this.deviceName,
      modelName: modelName ?? this.modelName,
      linkedDeviceId: linkedDeviceId ?? this.linkedDeviceId,
      batteryPercent: batteryPercent ?? this.batteryPercent,
      filterStatus: filterStatus ?? this.filterStatus,
      recommendMessage: recommendMessage ?? this.recommendMessage,
      hasUsageHistory: hasUsageHistory ?? this.hasUsageHistory,
      frequentMode: frequentMode ?? this.frequentMode,
      hasRecentDiagnosisResult:
          hasRecentDiagnosisResult ?? this.hasRecentDiagnosisResult,
    );
  }
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
