import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/features/refresh/data/care_duration_split.dart';
import 'package:lg_hair_refresher/features/refresh/data/model/refresh_mode.dart';
import 'package:lg_hair_refresher/features/refresh/data/model/refresh_progress_session.dart';

const _dustOnlyMode = RefreshMode(
  id: 'quick-refresh',
  name: '퀵 리프레시',
  description: '가벼운 리프레시',
  category: RefreshModeTabs.beforeOuting,
  durationSeconds: 180,
  icon: Icons.bolt_outlined,
  dustYn: true,
);

const _fullCareMode = RefreshMode(
  id: 'scalp-deep-care',
  name: '두피 딥 케어',
  description: '집중 케어',
  category: RefreshModeTabs.afterOuting,
  durationSeconds: 720,
  icon: Icons.spa_outlined,
  odorYn: true,
  dustYn: true,
  scentYn: true,
);

const _dustOdorMode = RefreshMode(
  id: 'dust-odor',
  name: '먼지·냄새 케어',
  description: '먼지와 냄새 케어',
  category: RefreshModeTabs.afterOuting,
  durationSeconds: 600,
  icon: Icons.air_outlined,
  dustYn: true,
  odorYn: true,
  dustStrength: 3,
  odorStrength: 2,
);

void main() {
  group('RefreshProgressSession.fromMode', () {
    test('uses each mode durationSeconds for total runtime', () {
      for (final mode in [_dustOnlyMode, _fullCareMode]) {
        final session = RefreshProgressSession.fromMode(mode);

        expect(
          session.totalDurationSeconds,
          mode.durationSeconds,
          reason: mode.name,
        );
      }
    });

    test('dust-only mode shows a single enabled care step', () {
      final session = RefreshProgressSession.fromMode(_dustOnlyMode);

      expect(session.steps, hasLength(1));
      expect(session.steps.first.label, '먼지 케어');
      expect(session.steps.first.durationSeconds, 180);
    });

    test('disabled care flags are omitted from progress steps', () {
      final session = RefreshProgressSession.fromMode(_dustOdorMode);

      expect(session.steps, hasLength(2));
      expect(session.steps[0].label, '먼지 케어');
      expect(session.steps[1].label, '냄새 케어');
      expect(session.steps.any((step) => step.label == '향기 케어'), isFalse);
      expect(session.totalDurationSeconds, 600);
    });

    test('full care mode includes all three enabled steps', () {
      final session = RefreshProgressSession.fromMode(_fullCareMode);

      expect(session.steps, hasLength(3));
      expect(session.steps[0].label, '먼지 케어');
      expect(session.steps[1].label, '냄새 케어');
      expect(session.steps[2].label, '향기 케어');
    });

    test('splits duration across enabled steps by care intensity', () {
      final session = RefreshProgressSession.fromMode(_dustOdorMode);

      expect(session.steps[0].stepTitle, '먼지 집중관리');
      expect(session.steps[1].stepTitle, '냄새 일반관리');
      expect(
        session.steps.fold<int>(0, (sum, step) => sum + step.durationSeconds),
        600,
      );
    });

    test('custom mode uses selected tags only', () {
      final mode = RefreshMode.custom(
        id: 'custom-1',
        name: '나만의 모드',
        description: '커스텀',
        durationMinutes: 5,
        tags: ['먼지 케어 집중관리', '향기 케어 간편관리'],
      );

      final session = RefreshProgressSession.fromMode(mode);

      expect(session.steps, hasLength(2));
      expect(session.steps[0].label, '먼지 케어');
      expect(session.steps[1].label, '향기 케어');
      expect(session.totalDurationSeconds, 300);
    });
  });

  group('CareDurationSplit.formatKoreanDuration', () {
    test('shows seconds only under one minute', () {
      expect(CareDurationSplit.formatKoreanDuration(30), '30초');
    });

    test('shows minutes and seconds at or above one minute', () {
      expect(CareDurationSplit.formatKoreanDuration(60), '1분');
      expect(CareDurationSplit.formatKoreanTime(180), '3분');
      expect(CareDurationSplit.formatKoreanDuration(270), '4분 30초');
    });
  });
}
