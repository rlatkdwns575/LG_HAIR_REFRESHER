/// 케어 관리 강도 (집중관리 / 일반관리 / 간편관리).
enum CareIntensity { intensive, normal, simple }

/// 커스텀 모드 케어 시간 분배.
class CareDurationSplit {
  const CareDurationSplit._();

  static int getCareRatio(CareIntensity intensity) {
    return switch (intensity) {
      CareIntensity.intensive => 3,
      CareIntensity.normal => 2,
      CareIntensity.simple => 1,
    };
  }

  /// 선택된 총 분을 초 단위로 환산한 뒤 [weights] 비율로 분배합니다.
  ///
  /// [weights] 의 합이 0이면 모든 항목에 0초를 반환합니다.
  /// 마지막 항목은 나머지 초를 받아 합계가 [totalMinutes] × 60과 정확히 같습니다.
  static List<int> splitSeconds({
    required int totalMinutes,
    required List<int> weights,
  }) {
    if (weights.isEmpty) {
      return [];
    }

    final totalSeconds = totalMinutes * 60;
    final weightSum = weights.fold<int>(0, (sum, weight) => sum + weight);
    if (weightSum == 0) {
      return List.filled(weights.length, 0);
    }
    if (weights.length == 1) {
      return [totalSeconds];
    }

    final results = <int>[];
    var allocated = 0;

    for (var i = 0; i < weights.length; i++) {
      if (i == weights.length - 1) {
        results.add(totalSeconds - allocated);
      } else {
        final portion = totalSeconds * weights[i] ~/ weightSum;
        results.add(portion);
        allocated += portion;
      }
    }

    return results;
  }

  /// 초를 `N분 N초` 형식으로 포맷합니다. (예: 90 → `1분 30초`)
  static String formatKoreanTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final remainSeconds = totalSeconds % 60;
    return '$minutes분 $remainSeconds초';
  }
}
