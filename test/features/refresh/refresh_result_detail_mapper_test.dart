import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/app/theme/app_colors.dart';
import 'package:lg_hair_refresher/features/refresh/data/model/refresh_result.dart';
import 'package:lg_hair_refresher/features/refresh/data/model/refresh_result_detail.dart';
import 'package:lg_hair_refresher/features/refresh/data/refresh_result_detail_mapper.dart';
import 'package:lg_hair_refresher/shared/widgets/app_badge.dart';

void main() {
  group('RefreshResultDetailMapper', () {
    test('maps RefreshResult to detail', () {
      final result = RefreshResult.sample;

      final detail = RefreshResultDetailMapper.fromRefreshResult(result);

      expect(detail.necessityReductionPercent, 40.9);
      expect(detail.metrics, hasLength(3));
      expect(detail.odorSection.changes, hasLength(3));
      expect(detail.shareSummaryText, contains('리프레시 결과'));
      expect(detail.shareSummaryText, contains(detail.summaryMessage));
    });

    test('uses fallback mode name when recommendedMode is null', () {
      final detail = RefreshResultDetailMapper.fromRefreshResult(
        RefreshResult(
          dustRemovalPercent: 87,
          odorRemovalPercent: 92,
          overallImprovementPercent: 40.9,
          headlineBefore: '외출 후 남아 있던 냄새와 먼지가',
          headlineAfter: '줄어들었어요.',
          disclaimer: 'disclaimer',
          dustChange: RefreshResult.sample.dustChange,
          odorChange: RefreshResult.sample.odorChange,
        ),
      );

      expect(detail.modeName, '리프레시 모드');
    });

    test('maps record summary labels', () {
      final detail = RefreshResultDetailMapper.fromRecordSummary(
        modeName: '외부 냄새 리프레시',
        necessityReductionPercent: 71,
        odorBeforeLabel: '집중권장',
        odorAfterLabel: '좋음',
        dustBeforeLabel: '보통',
        dustAfterLabel: '좋음',
      );

      expect(detail.modeName, '외부 냄새 리프레시');
      expect(detail.metrics.first.beforePercent, 80);
      expect(detail.metrics.first.afterPercent, 26);
    });

    test('maps odor section to figma display labels', () {
      final detail = RefreshResultDetailMapper.fromRecordSummary(
        modeName: '외부 냄새 리프레시',
        odorBeforeLabel: '집중필요',
        odorAfterLabel: '보통',
      );

      final odorChanges = detail.odorSection.changes;
      expect(odorChanges[0].beforeLabel, '매우높음');
      expect(odorChanges[0].beforeVariant, AppBadgeSmallVariant.gray);
      expect(odorChanges[0].beforeStyle, AppBadgeStyle.text);
      expect(odorChanges[0].afterLabel, '낮음');
      expect(odorChanges[2].afterLabel, '낮음');
      expect(odorChanges[2].afterVariant, AppBadgeSmallVariant.low);
      expect(detail.odorSection.insight.badgeBackgroundColor, AppColors.gray0);
      expect(detail.odorSection.insight.badgeTextColor, AppColors.primary500);
      expect(detail.odorSection.insight.badgeBorderColor, AppColors.primary300);
    });

    test('maps dust section to figma display labels', () {
      final detail = RefreshResultDetailMapper.fromRecordSummary(
        modeName: '외부 냄새 리프레시',
        dustBeforeLabel: '권장',
        dustAfterLabel: '보통',
      );

      final dustChanges = detail.dustSection.changes;
      expect(dustChanges[0].beforeLabel, '보통');
      expect(dustChanges[0].afterLabel, '낮음');
      expect(dustChanges[0].afterVariant, AppBadgeSmallVariant.low);
      expect(dustChanges[1].beforeLabel, '보통');
      expect(dustChanges[1].afterLabel, '낮음');
      expect(dustChanges[1].afterVariant, AppBadgeSmallVariant.low);
    });
  });

  test('RefreshResultDetail sample matches figma headline percent', () {
    expect(RefreshResultDetail.sample.necessityReductionLabel, '40.9%');
    expect(RefreshResultDetail.sample.metrics, hasLength(3));
    expect(RefreshResultDetail.sample.hairSection.hairMetrics, hasLength(4));
    expect(
      RefreshResultDetail.sample.hairSection.hairMetrics[2].label,
      '모발 유분량',
    );
  });
}
