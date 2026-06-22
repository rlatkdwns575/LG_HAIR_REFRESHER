import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/features/refresh/data/model/refresh_mode.dart';
import 'package:lg_hair_refresher/features/refresh/data/refresh_result_headline_builder.dart';

void main() {
  group('RefreshResultHeadlineBuilder', () {
    test('모드명 + 냄새·먼지 케어 멘트', () {
      const mode = RefreshMode(
        id: 'combo',
        name: 'LG DX 정상인소유지',
        description: '복합',
        category: RefreshModeTabs.afterOuting,
        durationSeconds: 180,
        icon: Icons.bolt_outlined,
        odorYn: true,
        dustYn: true,
      );

      final headline = RefreshResultHeadlineBuilder.forMode(mode);

      expect(headline.before, '외출 후 남아 있던 냄새와 먼지가');
      expect(headline.after, '줄어들었어요.');
    });

    test('모드명 + 먼지 케어 멘트', () {
      const mode = RefreshMode(
        id: 'dust',
        name: '먼지 케어',
        description: '먼지',
        category: RefreshModeTabs.beforeOuting,
        durationSeconds: 120,
        icon: Icons.bolt_outlined,
        dustYn: true,
      );

      final headline = RefreshResultHeadlineBuilder.forMode(mode);

      expect(headline.before, '외출 전에 쌓인 먼지가');
    });

    test('모드명 + 냄새 케어 멘트', () {
      const mode = RefreshMode(
        id: 'odor',
        name: '습도 케어',
        description: '냄새',
        category: RefreshModeTabs.weather,
        durationSeconds: 120,
        icon: Icons.bolt_outlined,
        odorYn: true,
      );

      final headline = RefreshResultHeadlineBuilder.forMode(mode);

      expect(headline.before, '날씨에 쌓인 냄새가');
    });

    test('향기 전용 모드', () {
      const mode = RefreshMode(
        id: 'scent',
        name: '출근 전 향기 케어 모드',
        description: '향기',
        category: RefreshModeTabs.afterOuting,
        durationSeconds: 90,
        icon: Icons.local_florist_outlined,
        scentYn: true,
      );

      final headline = RefreshResultHeadlineBuilder.forMode(mode);

      expect(headline.before, '은은한 향기 케어가');
      expect(headline.after, '완료되었어요.');
    });
  });
}
