/// 추천 문구·UI 라벨용 주근거. 입력 신호는 유효한 값을 모두 함께 씁니다.
enum RefreshRecommendBasis {
  /// 유효한 측정(2시간 이내·미리프레시)이 있을 때.
  measure,

  /// 측정은 없고 오늘 일정이 있을 때.
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
