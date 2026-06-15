/// 진단 기반 오염도 스냅샷 (0~100).
class MeasurePollutionSnapshot {
  const MeasurePollutionSnapshot({
    required this.odor,
    required this.dust,
    required this.total,
  });

  final double odor;
  final double dust;
  final double total;

  static double composeTotal({required double odor, required double dust}) {
    return odor * 0.45 + dust * 0.55;
  }
}
