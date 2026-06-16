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

  /// 오염 점수(0–100, 높을수록 관리 필요) → 차트 X 위치.
  /// 왼쪽(0)이 나쁨, 오른쪽(1)이 좋음.
  static double axisFractionFromScore(int score) {
    final clamped = score.clamp(0, 100);
    return 1 - (clamped / 100);
  }
}
