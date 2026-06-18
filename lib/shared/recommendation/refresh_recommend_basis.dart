/// 통합 추천 입력 근거.
enum RefreshRecommendBasis {
  /// 2시간 이내 측정 + 미리프레시.
  measure,

  /// 날씨 + 오늘 일정.
  weatherAndSchedule,

  /// 날씨만 (오늘 일정 없음 또는 미연동).
  weatherOnly,
}

extension RefreshRecommendBasisLabels on RefreshRecommendBasis {
  String get refreshSectionSubtitle => switch (this) {
    RefreshRecommendBasis.measure => '측정 결과를 바탕으로 추천한 모드예요',
    RefreshRecommendBasis.weatherAndSchedule => '오늘 일정과 날씨를 바탕으로 추천한 모드예요',
    RefreshRecommendBasis.weatherOnly => '오늘 날씨를 바탕으로 추천한 모드예요',
  };
}
