/// `consumable_status.filter_remaining_percent` → 홈 필터 배지 라벨.
class ConsumableStatusMapper {
  const ConsumableStatusMapper._();

  static String filterStatusLabel(int filterRemainingPercent) {
    if (filterRemainingPercent >= 70) {
      return '양호';
    }
    if (filterRemainingPercent >= 30) {
      return '교체 예정';
    }
    return '교체 필요';
  }
}
