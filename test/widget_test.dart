import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/app/app.dart';
import 'package:lg_hair_refresher/app/router/app_router.dart';
import 'package:lg_hair_refresher/core/constants/route_paths.dart';

void main() {
  testWidgets('shows login screen on app start', (tester) async {
    await tester.pumpWidget(const LgHairRefresherApp());
    await tester.pumpAndSettle();

    expect(find.text('서비스 logo'), findsOneWidget);
    expect(find.text('서비스 설명'), findsOneWidget);
    expect(find.text('Google로 로그인하기'), findsOneWidget);
    expect(find.text('이메일로 로그인'), findsOneWidget);
  });

  testWidgets('shows home dashboard screen', (tester) async {
    appRouter.go(AppRoutePaths.home);
    await tester.pumpWidget(const LgHairRefresherApp());
    await tester.pumpAndSettle();

    expect(find.text('우리 기기 이름'), findsOneWidget);
    expect(find.text('배터리'), findsOneWidget);
    expect(find.text('60%'), findsOneWidget);
    expect(find.text('필터 상태'), findsOneWidget);
    expect(find.text('양호'), findsOneWidget);
    expect(find.text('디바이스 관리'), findsOneWidget);
    expect(find.text('퀵 리프레시'), findsNothing);
    expect(find.text('즐겨찾기 추천 추가하기'), findsNothing);
    expect(find.text('자주 사용한 모드'), findsNothing);
    expect(find.text('헤어 리프레시'), findsOneWidget);
    expect(find.text('헤어 상태 진단'), findsOneWidget);
    expect(find.text('진단하기'), findsOneWidget);
    expect(find.text('리프레시 내역'), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    expect(find.byIcon(Icons.widgets_outlined), findsOneWidget);
  });
}
