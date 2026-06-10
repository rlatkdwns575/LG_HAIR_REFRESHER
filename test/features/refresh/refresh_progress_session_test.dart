import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/features/refresh/data/model/refresh_mode.dart';
import 'package:lg_hair_refresher/features/refresh/data/model/refresh_progress_session.dart';

void main() {
  group('RefreshProgressSession.fromMode', () {
    test('uses each mode durationMinutes for total runtime', () {
      for (final mode in RefreshMode.samples) {
        final session = RefreshProgressSession.fromMode(mode);

        expect(
          session.totalDurationSeconds,
          mode.durationMinutes * 60,
          reason: mode.name,
        );
        expect(session.totalDurationMinutes, mode.durationMinutes);
      }
    });

    test('quick refresh is shorter than scalp deep care', () {
      final quick = RefreshProgressSession.fromMode(
        RefreshMode.samples.firstWhere((m) => m.id == 'quick-refresh'),
      );
      final deep = RefreshProgressSession.fromMode(
        RefreshMode.samples.firstWhere((m) => m.id == 'scalp-deep-care'),
      );

      expect(quick.totalDurationSeconds, lessThan(deep.totalDurationSeconds));
      expect(quick.totalDurationMinutes, 3);
      expect(deep.totalDurationMinutes, 12);
    });

    test('splits duration across three steps using 2:3:2 ratio', () {
      final steps = RefreshProgressSession.buildStepsForDuration(10);

      expect(steps, hasLength(3));
      expect(
        steps.fold<int>(0, (sum, step) => sum + step.durationSeconds),
        600,
      );
      expect(steps[0].durationSeconds, 171);
      expect(steps[1].durationSeconds, 257);
      expect(steps[2].durationSeconds, 172);
    });

    test('uses Figma care step labels and intensity metadata', () {
      final session = RefreshProgressSession.fromMode(
        RefreshMode.samples.first,
      );

      expect(session.steps[0].label, '먼지 케어');
      expect(session.steps[1].label, '냄새 케어');
      expect(session.steps[2].label, '향기 케어');
      expect(session.steps[0].intensityLabel, '집중관리');
      expect(session.steps[1].intensityLabel, '일반관리');
      expect(session.steps[0].durationLabel, isNotEmpty);
    });
  });
}
