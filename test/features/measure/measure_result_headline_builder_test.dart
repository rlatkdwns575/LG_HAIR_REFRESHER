import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/features/measure/data/measure_result_headline_builder.dart';
import 'package:lg_hair_refresher/features/refresh/data/model/refresh_mode.dart';

void main() {
  group('MeasureResultHeadlineBuilder', () {
    const comboMode = RefreshMode(
      id: 'combo',
      name: '출근 전 향기 케어 모드',
      description: '복합',
      category: RefreshModeTabs.beforeOuting,
      durationSeconds: 180,
      icon: Icons.bolt_outlined,
      odorYn: true,
      dustYn: true,
    );

    test('경고형 — 모드명 + 케어 대상 멘트', () {
      final headline = MeasureResultHeadlineBuilder.forRecommendMode(
        mode: comboMode,
        needsAction: true,
      );

      expect(headline.isHighlighted, isTrue);
      expect(headline.before, '출근 전 향기 케어 모드로 남은 냄새와 먼지를 정리해 ');
      expect(headline.highlight, '안심할 수 있는 상태');
      expect(headline.after, '를 되찾아보세요.');
    });

    test('안정형 — 모드명 + 가벼운 관리 멘트', () {
      const dustMode = RefreshMode(
        id: 'dust',
        name: '데일리 라이트 리프레시',
        description: '먼지',
        category: RefreshModeTabs.beforeOuting,
        durationSeconds: 120,
        icon: Icons.bolt_outlined,
        dustYn: true,
      );

      final headline = MeasureResultHeadlineBuilder.forRecommendMode(
        mode: dustMode,
        needsAction: false,
      );

      expect(headline.isHighlighted, isFalse);
      expect(
        headline.text,
        '데일리 라이트 리프레시로 가벼운 관리만으로\n'
        '현재 헤어 상태를 유지할 수 있어요.',
      );
    });
  });
}
