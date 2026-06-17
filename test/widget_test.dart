import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/app/app.dart';
import 'package:lg_hair_refresher/app/router/app_router.dart';
import 'package:lg_hair_refresher/core/constants/route_paths.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('shows login screen on app start', (tester) async {
    await tester.pumpWidget(const LgHairRefresherApp());
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsAtLeastNWidgets(2));
    expect(findDisplayText('Google로 로그인하기'), findsOneWidget);
    expect(findDisplayText('이메일로 로그인'), findsOneWidget);
  });

  testWidgets('shows home dashboard screen', (tester) async {
    appRouter.go(AppRoutePaths.home);
    await tester.pumpWidget(const LgHairRefresherApp());
    await tester.pumpAndSettle();

    expect(findDisplayText('LG 퓨리헤어'), findsOneWidget);
    expect(findDisplayText('배터리'), findsOneWidget);
    expect(findDisplayText('60%'), findsOneWidget);
    expect(findDisplayText('필터 상태'), findsOneWidget);
    expect(findDisplayText('좋음'), findsOneWidget);
    expect(findDisplayText('디바이스 관리'), findsOneWidget);
    expect(findDisplayText('취침 전 안심 케어'), findsOneWidget);
    expect(findDisplayText('자주 쓰는 리프레시를\n홈에 등록해보세요.'), findsOneWidget);
    expect(findDisplayText('자주 사용한 모드'), findsNothing);
    expect(findDisplayText('자주 사용'), findsNothing);
    expect(findDisplayText('추천'), findsOneWidget);
    expect(findDisplayText('리프레시 모드 보기'), findsOneWidget);
    expect(findDisplayText('헤어 상태 진단'), findsOneWidget);
    expect(findDisplayText('리프레시 기록 보기'), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    expect(find.byIcon(Icons.widgets_outlined), findsNothing);
  });
}
