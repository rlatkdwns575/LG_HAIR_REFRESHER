import 'model/refresh_mode.dart';

/// 리프레시 완료 결과 상단 멘트.
///
/// 실행한 [RefreshMode.name]과 케어 유형(냄새·먼지·향기)에 맞는 문구를 조합합니다.
class RefreshResultHeadlineBuilder {
  const RefreshResultHeadlineBuilder._();

  static ({String before, String after}) forMode(RefreshMode mode) {
    if (mode.isScentOnlyCare) {
      return (before: '${mode.name}로 은은한 향기 케어가', after: '완료되었어요.');
    }

    return (
      before: '${mode.name}로 남아 있던 ${_careTargetLabel(mode)}',
      after: '줄어들었어요.',
    );
  }

  static String _careTargetLabel(RefreshMode mode) {
    final hasOdor = mode.odorYn;
    final hasDust = mode.dustYn;

    if (hasOdor && hasDust) {
      return '냄새와 먼지가';
    }
    if (hasOdor) {
      return '냄새가';
    }
    if (hasDust) {
      return '먼지가';
    }
    if (mode.scentYn) {
      return '향기 케어가';
    }

    return '냄새와 먼지가';
  }
}
