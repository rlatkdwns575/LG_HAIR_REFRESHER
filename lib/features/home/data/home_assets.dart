/// home feature에서 사용하는 에셋 경로.
class HomeAssets {
  const HomeAssets._();

  static const batteryIconDir = 'lib/features/home/assets/battery';
  static const batteryIconStates = [0, 10, 30, 40, 50, 60, 80, 100];

  static const filterIcon = 'lib/features/home/filter.png';
  static const checkIcon = 'lib/features/home/check.png';

  /// Figma `icon_battery_24` variant 중 가장 가까운 상태값.
  static int batteryIconState(int batteryRemainingPercent) {
    final clamped = batteryRemainingPercent.clamp(0, 100);

    return batteryIconStates.reduce(
      (best, candidate) => (candidate - clamped).abs() < (best - clamped).abs()
          ? candidate
          : best,
    );
  }

  static String batteryIconFor(int batteryRemainingPercent) {
    final state = batteryIconState(batteryRemainingPercent);
    return '$batteryIconDir/icon_battery_24_state_$state.png';
  }
}
