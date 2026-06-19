import 'model/refresh_mode.dart';

/// 리프레시 완료 결과 상단 멘트.
///
/// 모드 [RefreshMode.category]와 케어 유형(냄새·먼지·향기)에 맞는 문구를 조합합니다.
class RefreshResultHeadlineBuilder {
  const RefreshResultHeadlineBuilder._();

  static ({String before, String after}) forMode(RefreshMode mode) {
    if (mode.isScentOnlyCare) {
      return (before: '은은한 향기 케어가', after: '완료되었어요.');
    }

    return (
      before: '${_categoryPrefix(mode.category)} ${_careTargetLabel(mode)}',
      after: '줄어들었어요.',
    );
  }

  static String _categoryPrefix(String category) {
    return switch (category) {
      RefreshModeTabs.afterOuting => '외출 후 남아 있던',
      RefreshModeTabs.beforeOuting => '외출 전에 쌓인',
      RefreshModeTabs.weather => '날씨에 쌓인',
      RefreshModeTabs.etc => '머리카락에 남아 있던',
      RefreshModeTabs.customMode => '머리카락에 남아 있던',
      _ => '머리카락에 남아 있던',
    };
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
