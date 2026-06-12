import '../model/home_filter_status.dart';

/// `consumable_status.filter_remaining_percent` → 홈 필터 배지 상태.
class ConsumableStatusMapper {
  const ConsumableStatusMapper._();

  static HomeFilterStatus filterStatus(int filterRemainingPercent) {
    final percent = filterRemainingPercent.clamp(0, 100);

    if (percent <= 10) {
      return const HomeFilterStatus(
        tier: HomeFilterStatusTier.replaceSoon,
        label: '교체 예정',
      );
    }
    if (percent <= 30) {
      return const HomeFilterStatus(
        tier: HomeFilterStatusTier.replaceRecommended,
        label: '교체 권장',
      );
    }
    if (percent <= 70) {
      return const HomeFilterStatus(
        tier: HomeFilterStatusTier.normal,
        label: '보통',
      );
    }
    return const HomeFilterStatus(
      tier: HomeFilterStatusTier.fresh,
      label: '새거',
    );
  }

  static String filterStatusLabel(int filterRemainingPercent) {
    return filterStatus(filterRemainingPercent).label;
  }
}
