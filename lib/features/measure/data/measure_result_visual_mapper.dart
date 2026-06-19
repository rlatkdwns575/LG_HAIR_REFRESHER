import '../../../../core/constants/image_assets.dart';
import 'model/measure_care_level.dart';

/// Figma 진단 결과 간편보기 그래픽 — `{냄새 배지}|{먼지 배지}` 조합별 매핑.
abstract final class MeasureResultVisualMapper {
  static String assetPath({
    required MeasureCareLevel odorLevel,
    required MeasureCareLevel dustLevel,
  }) {
    final key =
        '${odorLevel.simpleViewBadgeLabel}|${dustLevel.simpleViewBadgeLabel}';
    return _exact[key] ?? _fallback(odorLevel, dustLevel);
  }

  /// Figma 프레임명과 1:1 대응. `나쁨|나쁨` 프레임은 없어 `매우나쁨|나쁨` 그래픽 사용.
  static const _exact = <String, String>{
    '보통|좋음': ImageAssets.measureResultOdorNormalDustGood,
    '나쁨|좋음': ImageAssets.measureResultOdorBadDustGood,
    '나쁨|보통': ImageAssets.measureResultOdorBadDustNormal,
    '나쁨|나쁨': ImageAssets.measureResultOdorVeryBadDustBad,
    '매우나쁨|보통': ImageAssets.measureResultOdorVeryBadDustNormal,
    '매우나쁨|나쁨': ImageAssets.measureResultOdorVeryBadDustBad,
    '매우나쁨|매우나쁨': ImageAssets.measureResultOdorVeryBadDustBad,
  };

  static String _fallback(
    MeasureCareLevel odorLevel,
    MeasureCareLevel dustLevel,
  ) {
    final odor = _severityIndex(odorLevel);
    final dust = _severityIndex(dustLevel);

    if (odor <= 1 && dust == 0) {
      return ImageAssets.measureResultOdorNormalDustGood;
    }
    if (dust == 0) {
      return ImageAssets.measureResultOdorBadDustGood;
    }
    if (odor <= 2 && dust <= 2) {
      return ImageAssets.measureResultOdorBadDustNormal;
    }
    if (odor == 4 && dust <= 1) {
      return ImageAssets.measureResultOdorVeryBadDustNormal;
    }
    if (dust >= 3) {
      return ImageAssets.measureResultOdorVeryBadDustBad;
    }
    return ImageAssets.measureResultOdorBadDustNormal;
  }

  static int _severityIndex(MeasureCareLevel level) => switch (level) {
    MeasureCareLevel.notRequired => 0,
    MeasureCareLevel.normal => 1,
    MeasureCareLevel.recommended => 2,
    MeasureCareLevel.intensiveRecommended => 3,
    MeasureCareLevel.intensiveRequired => 4,
  };
}
