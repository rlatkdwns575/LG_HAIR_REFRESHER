import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/features/refresh/data/model/refresh_progress_session.dart';
import 'package:lg_hair_refresher/features/refresh/data/refresh_execution_config.dart';

void main() {
  final steps = [
    const RefreshProgressStep(
      label: '먼지 케어',
      statusMessage: '먼지',
      durationSeconds: 180,
      intensityLabel: '집중관리',
    ),
    const RefreshProgressStep(
      label: '냄새 케어',
      statusMessage: '냄새',
      durationSeconds: 120,
      intensityLabel: '일반관리',
    ),
  ];

  group('RefreshExecutionConfig', () {
    test('fixed execution completes in 10 seconds of ticks', () {
      expect(RefreshExecutionConfig.fixedDuration, const Duration(seconds: 10));
      expect(RefreshExecutionConfig.totalTicks, 100);
    });

    test('display remaining starts at full duration and reaches zero', () {
      expect(
        RefreshExecutionConfig.displayRemainingSeconds(
          displayTotalSeconds: 300,
          elapsedTicks: 0,
        ),
        300,
      );
      expect(
        RefreshExecutionConfig.displayRemainingSeconds(
          displayTotalSeconds: 300,
          elapsedTicks: RefreshExecutionConfig.totalTicks,
        ),
        0,
      );
    });

    test('active step advances proportionally to display durations', () {
      expect(
        RefreshExecutionConfig.activeStepIndex(steps: steps, elapsedTicks: 0),
        0,
      );
      expect(
        RefreshExecutionConfig.activeStepIndex(
          steps: steps,
          elapsedTicks: (RefreshExecutionConfig.totalTicks * 0.55).round(),
        ),
        0,
      );
      expect(
        RefreshExecutionConfig.activeStepIndex(
          steps: steps,
          elapsedTicks: (RefreshExecutionConfig.totalTicks * 0.65).round(),
        ),
        1,
      );
      expect(
        RefreshExecutionConfig.activeStepIndex(
          steps: steps,
          elapsedTicks: RefreshExecutionConfig.totalTicks,
        ),
        1,
      );
    });
  });
}
