import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/core/constants/image_assets.dart';
import 'package:lg_hair_refresher/features/measure/data/measure_result_visual_mapper.dart';
import 'package:lg_hair_refresher/features/measure/data/model/measure_care_level.dart';

void main() {
  group('MeasureResultVisualMapper', () {
    test('maps Figma exact pairs', () {
      expect(
        MeasureResultVisualMapper.assetPath(
          odorLevel: MeasureCareLevel.normal,
          dustLevel: MeasureCareLevel.notRequired,
        ),
        ImageAssets.measureResultOdorNormalDustGood,
      );
      expect(
        MeasureResultVisualMapper.assetPath(
          odorLevel: MeasureCareLevel.intensiveRecommended,
          dustLevel: MeasureCareLevel.notRequired,
        ),
        ImageAssets.measureResultOdorBadDustGood,
      );
      expect(
        MeasureResultVisualMapper.assetPath(
          odorLevel: MeasureCareLevel.intensiveRecommended,
          dustLevel: MeasureCareLevel.normal,
        ),
        ImageAssets.measureResultOdorBadDustNormal,
      );
      expect(
        MeasureResultVisualMapper.assetPath(
          odorLevel: MeasureCareLevel.intensiveRequired,
          dustLevel: MeasureCareLevel.normal,
        ),
        ImageAssets.measureResultOdorVeryBadDustNormal,
      );
      expect(
        MeasureResultVisualMapper.assetPath(
          odorLevel: MeasureCareLevel.intensiveRecommended,
          dustLevel: MeasureCareLevel.intensiveRecommended,
        ),
        ImageAssets.measureResultOdorVeryBadDustBad,
      );
      expect(
        MeasureResultVisualMapper.assetPath(
          odorLevel: MeasureCareLevel.intensiveRequired,
          dustLevel: MeasureCareLevel.intensiveRecommended,
        ),
        ImageAssets.measureResultOdorVeryBadDustBad,
      );
    });

    test('odor and dust changes can select different assets', () {
      final stable = MeasureResultVisualMapper.assetPath(
        odorLevel: MeasureCareLevel.normal,
        dustLevel: MeasureCareLevel.normal,
      );
      final actionRequired = MeasureResultVisualMapper.assetPath(
        odorLevel: MeasureCareLevel.intensiveRecommended,
        dustLevel: MeasureCareLevel.intensiveRequired,
      );

      expect(stable, isNot(actionRequired));
    });
  });
}
