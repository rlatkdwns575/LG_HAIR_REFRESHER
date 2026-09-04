import 'model/refresh_progress_session.dart';

/// 리프레시 진행 화면 실행 재생 설정.
///
/// UI에 보이는 남은 시간·단계 라벨은 Supabase 모드 시간을 따르고,
/// 실제 완료까지 대기하는 시간만 [fixedDuration]으로 고정합니다.
class RefreshExecutionConfig {
  const RefreshExecutionConfig._();

  static const fixedDuration = Duration(seconds: 10);
  static const tickInterval = Duration(milliseconds: 100);

  static int get totalTicks =>
      fixedDuration.inMilliseconds ~/ tickInterval.inMilliseconds;

  static double progress(int elapsedTicks) {
    final total = totalTicks;
    if (total <= 0) {
      return 1;
    }
    return (elapsedTicks / total).clamp(0.0, 1.0);
  }

  static int displayRemainingSeconds({
    required int displayTotalSeconds,
    required int elapsedTicks,
  }) {
    if (displayTotalSeconds <= 0) {
      return 0;
    }
    final remaining = displayTotalSeconds * (1 - progress(elapsedTicks));
    return remaining.round().clamp(0, displayTotalSeconds);
  }

  static int activeStepIndex({
    required List<RefreshProgressStep> steps,
    required int elapsedTicks,
  }) {
    if (steps.isEmpty) {
      return 0;
    }

    final displayTotalSeconds = steps.fold<int>(
      0,
      (sum, step) => sum + step.durationSeconds,
    );
    if (displayTotalSeconds <= 0) {
      return 0;
    }

    final targetElapsed = displayTotalSeconds * progress(elapsedTicks);
    var accumulated = 0;
    for (var i = 0; i < steps.length; i++) {
      accumulated += steps[i].durationSeconds;
      if (targetElapsed < accumulated) {
        return i;
      }
    }

    return steps.length - 1;
  }
}
