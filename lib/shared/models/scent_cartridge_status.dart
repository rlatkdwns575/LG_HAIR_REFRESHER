import 'scent_category.dart';

/// 향 카트리지 장착·잔량·향 종류 상태.
class ScentCartridgeStatus {
  const ScentCartridgeStatus({
    required this.isAttached,
    this.remainingPercent,
    this.category,
  });

  final bool isAttached;
  final int? remainingPercent;
  final ScentCategory? category;

  static const notAttached = ScentCartridgeStatus(isAttached: false);

  String get displayValue {
    if (!isAttached) {
      return '카트리지 없음';
    }
    return '${remainingPercent!.clamp(0, 100)}%';
  }

  String get detailDisplayValue {
    if (!isAttached) {
      return '카트리지 없음';
    }

    final percent = (remainingPercent ?? 0).clamp(0, 100);
    if (category != null) {
      return '${category!.label} · $percent%';
    }
    return '$percent%';
  }

  String? get categoryLabel => category?.label;
}
