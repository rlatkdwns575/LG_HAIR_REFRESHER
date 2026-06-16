import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/features/refresh/data/model/refresh_pollution_level.dart';
import 'package:lg_hair_refresher/features/refresh/data/model/refresh_result_change.dart';

void main() {
  group('RefreshResultChange axis fractions', () {
    test('uses score-based positions when scores are present', () {
      const change = RefreshResultChange(
        label: '냄새',
        beforeLevel: RefreshPollutionLevel.high,
        afterLevel: RefreshPollutionLevel.high,
        beforeScore: 72,
        afterScore: 47,
      );

      expect(change.beforeAxisFraction, closeTo(0.28, 0.001));
      expect(change.afterAxisFraction, closeTo(0.53, 0.001));
      expect(change.afterAxisFraction, greaterThan(change.beforeAxisFraction));
    });

    test('falls back to level fractions when scores are absent', () {
      const change = RefreshResultChange(
        label: '먼지',
        beforeLevel: RefreshPollutionLevel.high,
        afterLevel: RefreshPollutionLevel.good,
      );

      expect(
        change.beforeAxisFraction,
        RefreshPollutionLevel.high.axisFraction,
      );
      expect(change.afterAxisFraction, RefreshPollutionLevel.good.axisFraction);
    });
  });

  group('RefreshPollutionLevel.axisFractionFromScore', () {
    test('maps higher pollution scores to the left', () {
      expect(
        RefreshPollutionLevel.axisFractionFromScore(90),
        lessThan(RefreshPollutionLevel.axisFractionFromScore(30)),
      );
    });
  });
}
