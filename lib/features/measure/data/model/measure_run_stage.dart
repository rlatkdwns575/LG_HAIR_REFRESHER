/// 헤어 상태 진단 진행 화면의 단계.
///
/// 진행률(0.0~1.0)에 따라 단계가 결정되며, 각 단계마다 안내 문구를 갖습니다.
enum MeasureRunStage {
  analyzing(title: '현재 헤어 상태를 진단 중이에요', subtitle: '디바이스를 모자처럼 쓰고 잠시 유지해 주세요.'),
  scanning(
    title: '헤어 손상도와 오염도를 분석하고 있어요',
    subtitle: '디바이스를 모자처럼 쓰고 잠시 유지해 주세요.',
  ),
  finishing(title: '거의 다 됐어요', subtitle: '디바이스를 모자처럼 쓰고 조금만 더 유지해 주세요.'),
  completed(title: '진단이 완료되었어요', subtitle: '곧 진단 결과를 보여드릴게요.');

  const MeasureRunStage({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  /// 진행률을 단계로 변환합니다. (0~40% 분석, 40~80% 스캔, 80~100% 마무리)
  static MeasureRunStage fromProgress(double progress) {
    if (progress >= 1.0) {
      return MeasureRunStage.completed;
    }
    if (progress >= 0.8) {
      return MeasureRunStage.finishing;
    }
    if (progress >= 0.4) {
      return MeasureRunStage.scanning;
    }
    return MeasureRunStage.analyzing;
  }
}
