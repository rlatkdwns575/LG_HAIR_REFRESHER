import 'measure_prepare_step.dart';

class MeasurePrepareStepCopy {
  const MeasurePrepareStepCopy({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  static const Map<MeasurePrepareStep, MeasurePrepareStepCopy> byStep = {
    MeasurePrepareStep.devicePower: MeasurePrepareStepCopy(
      title: '디바이스의 전원을 켜 주세요',
      subtitle: '등록된 디바이스가 켜지면 진단을 준비할 수 있어요.',
    ),
    MeasurePrepareStep.sensorAlign: MeasurePrepareStepCopy(
      title: '센서가 머리카락을 향하도록\n천천히 위치를 맞춰 주세요.',
    ),
    MeasurePrepareStep.ready: MeasurePrepareStepCopy(
      title: '이제 현재 헤어 상태를\n진단할 수 있어요.',
    ),
  };

  static MeasurePrepareStepCopy forStep(MeasurePrepareStep step) =>
      byStep[step]!;
}
