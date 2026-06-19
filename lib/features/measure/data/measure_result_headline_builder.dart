import '../../refresh/data/model/refresh_mode.dart';
import '../../../../app/theme/app_colors.dart';
import 'model/measure_result_headline.dart';

/// 진단 결과 상단 멘트.
///
/// 추천 [RefreshMode.name]과 케어 유형에 맞는 문구를 조합합니다.
class MeasureResultHeadlineBuilder {
  const MeasureResultHeadlineBuilder._();

  static MeasureResultHeadline forRecommendMode({
    required RefreshMode mode,
    required bool needsAction,
  }) {
    if (!needsAction) {
      return _stableHeadline(mode);
    }

    if (mode.isScentOnlyCare) {
      return MeasureResultHeadline.highlighted(
        before: '${mode.name}로 ',
        highlight: '산뜻한 향기 케어',
        after: '를 시작해 보세요.',
        highlightColor: AppColors.orange700,
      );
    }

    return MeasureResultHeadline.highlighted(
      before: '${mode.name}로\n남은 ${_careTargetNoun(mode)}를 정리해 ',
      highlight: '안심할 수 있는 상태',
      after: '를 되찾아보세요.',
      highlightColor: AppColors.orange700,
    );
  }

  static MeasureResultHeadline _stableHeadline(RefreshMode mode) {
    if (mode.isScentOnlyCare) {
      return MeasureResultHeadline.plain('${mode.name}로\n은은한 향기 케어를\n시작해 보세요.');
    }

    return MeasureResultHeadline.plain(
      '${mode.name}로 가벼운 관리만으로\n현재 헤어 상태를 유지할 수 있어요.',
    );
  }

  static String _careTargetNoun(RefreshMode mode) {
    final hasOdor = mode.odorYn;
    final hasDust = mode.dustYn;

    if (hasOdor && hasDust) {
      return '냄새와 먼지';
    }
    if (hasOdor) {
      return '냄새';
    }
    if (hasDust) {
      return '먼지';
    }
    if (mode.scentYn) {
      return '향기';
    }

    return '냄새와 먼지';
  }
}
