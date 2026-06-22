import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/features/refresh/data/model/refresh_mode.dart';
import 'package:lg_hair_refresher/features/refresh/data/model/refresh_progress_session.dart';
import 'package:lg_hair_refresher/features/refresh/data/model/refresh_result.dart';
import 'package:lg_hair_refresher/features/refresh/data/refresh_mode_catalog.dart';

void main() {
  const scentOnlyMode = RefreshMode(
    id: 'scent-preset',
    name: '향기 케어 모드',
    description: '은은한 향으로 마무리',
    category: RefreshModeTabs.afterOuting,
    durationSeconds: 120,
    icon: Icons.local_florist_outlined,
    scentYn: true,
  );

  const dustMode = RefreshMode(
    id: 'dust-preset',
    name: '먼지 케어',
    description: '먼지 제거',
    category: RefreshModeTabs.afterOuting,
    durationSeconds: 180,
    icon: Icons.bolt_outlined,
    dustYn: true,
  );

  const scentCarePreset = RefreshMode(
    id: 'db-scent',
    name: '향기 케어',
    description: '향기 케어 프리셋',
    category: RefreshModeTabs.afterOuting,
    durationSeconds: 90,
    icon: Icons.local_florist_outlined,
    scentYn: true,
  );

  tearDown(() {
    RefreshPresetModeStore.instance.setPresets(const []);
  });

  group('resolveScentCareMode', () {
    test('prefers scent-only preset from cache', () {
      RefreshPresetModeStore.instance.setPresets([
        dustMode,
        const RefreshMode(
          id: 'combo',
          name: '복합',
          description: '복합',
          category: RefreshModeTabs.afterOuting,
          durationSeconds: 180,
          icon: Icons.bolt_outlined,
          dustYn: true,
          scentYn: true,
        ),
        scentOnlyMode,
      ]);

      expect(resolveScentCareMode(), scentOnlyMode);
    });
  });

  group('RefreshResult.fromProgressSession', () {
    test('uses care-specific result headline', () {
      final result = RefreshResult.fromProgressSession(
        session: RefreshProgressSession.fromMode(dustMode),
        mode: dustMode,
      );

      expect(result.headlineBefore, '외출 후 남아 있던 먼지가');
    });

    test('recommends cached scent care mode after non-scent refresh', () {
      RefreshPresetModeStore.instance.setPresets([scentCarePreset]);

      final result = RefreshResult.fromProgressSession(
        session: RefreshProgressSession.fromMode(dustMode),
        mode: dustMode,
      );

      expect(result.recommendedMode, scentCarePreset);
      expect(result.showScentCareRecommendation, isTrue);
    });

    test('builds scent care result after scent-only refresh', () {
      final session = RefreshProgressSession.fromMode(scentOnlyMode);
      final result = RefreshResult.fromProgressSession(
        session: session,
        mode: scentOnlyMode,
      );

      expect(result.isScentCareResult, isTrue);
      expect(result.showChangeChart, isFalse);
      expect(result.showImprovementPercent, isFalse);
      expect(result.showScentCareRecommendation, isFalse);
      expect(result.headlineBefore, '은은한 향기 케어가');
      expect(result.headlineAfter, '완료되었어요.');
    });

    test(
      'does not recommend scent care when executed mode already includes scent',
      () {
        RefreshPresetModeStore.instance.setPresets([scentCarePreset]);

        final comboMode = const RefreshMode(
          id: 'combo',
          name: '복합',
          description: '복합',
          category: RefreshModeTabs.afterOuting,
          durationSeconds: 180,
          icon: Icons.bolt_outlined,
          dustYn: true,
          scentYn: true,
        );

        final result = RefreshResult.fromProgressSession(
          session: RefreshProgressSession.fromMode(comboMode),
          mode: comboMode,
        );

        expect(result.recommendedMode, isNull);
      },
    );
  });
}
