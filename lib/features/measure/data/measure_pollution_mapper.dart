import 'model/measure_care_level.dart';
import 'model/measure_pollution_snapshot.dart';

/// [MeasureCareLevel]을 추천 엔진용 오염도 점수로 변환합니다.
class MeasurePollutionMapper {
  const MeasurePollutionMapper._();

  static MeasurePollutionSnapshot fromLevels({
    required MeasureCareLevel odorLevel,
    required MeasureCareLevel dustLevel,
  }) {
    final odor = _scoreForLevel(odorLevel);
    final dust = _scoreForLevel(dustLevel);
    return MeasurePollutionSnapshot(
      odor: odor,
      dust: dust,
      total: MeasurePollutionSnapshot.composeTotal(odor: odor, dust: dust),
    );
  }

  static double _scoreForLevel(MeasureCareLevel level) {
    return switch (level) {
      MeasureCareLevel.notRequired => 0,
      MeasureCareLevel.normal => 20,
      MeasureCareLevel.recommended => 40,
      MeasureCareLevel.intensiveRecommended => 70,
      MeasureCareLevel.intensiveRequired => 90,
    };
  }
}
