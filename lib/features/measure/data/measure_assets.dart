import '../../../core/constants/image_assets.dart';
import 'model/measure_prepare_step.dart';

/// measure feature에서 사용하는 에셋 경로.
class MeasureAssets {
  const MeasureAssets._();

  static const analyzingIllustration = ImageAssets.measureAnalyzingIllustration;
  static const prepareDevice = ImageAssets.measurePrepareDevice;
  static const prepareHair = ImageAssets.measurePrepareHair;

  static String imageForPrepareStep(MeasurePrepareStep step) {
    return switch (step) {
      MeasurePrepareStep.devicePower => prepareDevice,
      MeasurePrepareStep.sensorAlign => prepareHair,
      MeasurePrepareStep.ready => prepareHair,
    };
  }
}
