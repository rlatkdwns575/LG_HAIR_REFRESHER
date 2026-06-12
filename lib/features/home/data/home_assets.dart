import '../../../core/constants/image_assets.dart';

/// home feature에서 사용하는 에셋 경로.
class HomeAssets {
  const HomeAssets._();

  static const batteryIconDir = ImageAssets.homeBatteryIconDir;
  static const batteryIconStates = ImageAssets.homeBatteryIconStates;

  static const filterIcon = ImageAssets.homeFilterIcon;
  static const checkIcon = ImageAssets.checkIcon;

  static int batteryIconState(int batteryRemainingPercent) =>
      ImageAssets.resolveHomeBatteryIconState(batteryRemainingPercent);

  static String batteryIconFor(int batteryRemainingPercent) =>
      ImageAssets.homeBatteryIconFor(batteryRemainingPercent);
}
