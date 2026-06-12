import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/shared/widgets/app_battery_status.dart';

void main() {
  group('AppBatteryStatus.resolveIconState', () {
    test('maps to nearest Figma icon_battery_24 variant', () {
      expect(AppBatteryStatus.resolveIconState(0), 0);
      expect(AppBatteryStatus.resolveIconState(8), 10);
      expect(AppBatteryStatus.resolveIconState(25), 30);
      expect(AppBatteryStatus.resolveIconState(45), 40);
      expect(AppBatteryStatus.resolveIconState(55), 50);
      expect(AppBatteryStatus.resolveIconState(60), 60);
      expect(AppBatteryStatus.resolveIconState(75), 80);
      expect(AppBatteryStatus.resolveIconState(95), 100);
    });
  });

  group('AppBatteryStatus.iconAssetFor', () {
    test('uses exported Figma asset path', () {
      expect(
        AppBatteryStatus.iconAssetFor(60),
        'assets/images/home/battery/icon_battery_24_state_60.png',
      );
    });
  });

  testWidgets('shows battery icon, label, and percent text', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AppBatteryStatus(percent: 60))),
    );

    expect(find.text('배터리'), findsOneWidget);
    expect(find.text('60%'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('clamps percent to 0 through 100', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AppBatteryStatus(percent: 150))),
    );

    expect(find.text('100%'), findsOneWidget);
  });

  testWidgets('hides title when showTitle is false', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AppBatteryStatus(percent: 42, showTitle: false)),
      ),
    );

    expect(find.text('배터리'), findsNothing);
    expect(find.text('42%'), findsOneWidget);
  });
}
