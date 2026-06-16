/// `CONSUMABLE_STATUS.scent_category` 향 종류.
enum ScentCategory {
  cotton('cotton', '코튼'),
  floral('floral', '플로럴'),
  citrus('citrus', '시트러스'),
  woody('woody', '우디'),
  musk('musk', '머스크'),
  fruity('fruity', '프루티');

  const ScentCategory(this.dbValue, this.label);

  final String dbValue;
  final String label;

  static ScentCategory? fromDbValue(Object? raw) {
    if (raw == null) {
      return null;
    }
    final text = raw.toString().trim();
    if (text.isEmpty) {
      return null;
    }
    final normalized = text.toLowerCase();

    for (final category in ScentCategory.values) {
      if (category.dbValue == normalized ||
          category.name == normalized ||
          category.label == text) {
        return category;
      }
    }
    return null;
  }

  /// DB 값을 화면 라벨로 변환. 매핑되지 않으면 원문을 그대로 반환.
  static String displayLabel(Object? raw) {
    return fromDbValue(raw)?.label ?? raw?.toString().trim() ?? '';
  }

  static String get allLabels =>
      values.map((category) => category.label).join(', ');
}
