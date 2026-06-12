/// 앱 공통 이미지 에셋 경로.
///
/// PNG 파일은 `assets/images/` 하위 feature 폴더에 둡니다.
class ImageAssets {
  const ImageAssets._();

  static const authDir = 'assets/images/auth';
  static const commonDir = 'assets/images/common';
  static const homeDir = 'assets/images/home';
  static const measureDir = 'assets/images/measure';
  static const refreshDir = 'assets/images/refresh';
  static const historyDir = 'assets/images/history';

  static const googleIcon = '$authDir/Google.png';
  static const checkIcon = '$commonDir/check.png';
  static const homeFilterIcon = '$homeDir/filter.png';
  static const measureAnalyzingIllustration = '$measureDir/analyzing.png';
  static const refreshTrashIcon = '$refreshDir/trash.png';
  static const refreshCollectingIllustration = '$refreshDir/refrash.png';
  static const historyCalendarIcon = '$historyDir/calendar.png';

  static const homeBatteryIconDir = '$homeDir/battery';
  static const homeBatteryIconStates = [0, 10, 30, 40, 50, 60, 80, 100];

  /// Figma `icon_battery_24` variant 중 가장 가까운 상태값.
  static int resolveHomeBatteryIconState(int batteryRemainingPercent) {
    final clamped = batteryRemainingPercent.clamp(0, 100);

    return homeBatteryIconStates.reduce(
      (best, candidate) => (candidate - clamped).abs() < (best - clamped).abs()
          ? candidate
          : best,
    );
  }

  static String homeBatteryIconFor(int batteryRemainingPercent) {
    final state = resolveHomeBatteryIconState(batteryRemainingPercent);
    return '$homeBatteryIconDir/icon_battery_24_state_$state.png';
  }
}
