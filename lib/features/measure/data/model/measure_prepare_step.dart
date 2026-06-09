enum MeasurePrepareStep { devicePower, sensorAlign, ready }

enum MeasurePrepareViewState { loading, loaded }

extension MeasurePrepareStepIndex on MeasurePrepareStep {
  int get index => switch (this) {
    MeasurePrepareStep.devicePower => 0,
    MeasurePrepareStep.sensorAlign => 1,
    MeasurePrepareStep.ready => 2,
  };

  MeasurePrepareStep? get next => switch (this) {
    MeasurePrepareStep.devicePower => MeasurePrepareStep.sensorAlign,
    MeasurePrepareStep.sensorAlign => MeasurePrepareStep.ready,
    MeasurePrepareStep.ready => null,
  };
}
