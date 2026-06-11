/// 리프레시 결과 그래프의 오염도 단계 (매우 높음 → 좋음).
enum RefreshPollutionLevel {
  veryHigh('매우 높음', 0),
  high('높음', 1),
  normal('보통', 2),
  good('좋음', 3);

  const RefreshPollutionLevel(this.label, this.axisIndex);

  final String label;

  /// 그래프 X축 인덱스 (0~3).
  final int axisIndex;

  static List<String> get axisLabels =>
      RefreshPollutionLevel.values.map((level) => level.label).toList();

  /// 차트 영역 내 0.0~1.0 위치.
  double get axisFraction {
    final maxIndex = RefreshPollutionLevel.values.length - 1;
    return axisIndex / maxIndex;
  }
}
