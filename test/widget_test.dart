import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/app/app.dart';

void main() {
  testWidgets('shows home hub with diagnosis and refresh entry points', (
    tester,
  ) async {
    await tester.pumpWidget(const LgHairRefresherApp());
    await tester.pumpAndSettle();

    expect(find.text('LG ThinQ'), findsOneWidget);
    expect(find.text('헤어상태 진단'), findsOneWidget);
    expect(find.text('진단하기'), findsOneWidget);
    expect(find.text('헤어 리프레시'), findsOneWidget);
    expect(find.text('기록 보러가기'), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    expect(find.byIcon(Icons.widgets_outlined), findsOneWidget);
  });
}
