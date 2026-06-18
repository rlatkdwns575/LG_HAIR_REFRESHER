import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/app/app.dart';
import 'package:lg_hair_refresher/app/router/app_router.dart';
import 'package:lg_hair_refresher/core/constants/route_paths.dart';
import 'package:lg_hair_refresher/features/home/ui/widgets/home_quick_refresh_row.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('shows login screen on app start', (tester) async {
    await tester.pumpWidget(const LgHairRefresherApp());
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('LG PuriHair'), findsOneWidget);
    expect(findDisplayText('헤어 케어의 새로운 기준'), findsOneWidget);
    expect(find.byType(SvgPicture), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(findDisplayText('Google로 로그인하기'), findsOneWidget);
    expect(findDisplayText('이메일로 로그인'), findsOneWidget);
  });

  testWidgets('shows home dashboard screen', (tester) async {
    appRouter.go(AppRoutePaths.home);
    await tester.pumpWidget(const LgHairRefresherApp());
    await tester.pump();

    // Supabase/날씨 API 미초기화 환경에서 대시보드 로딩 완료까지 대기.
    // pumpAndSettle은 홈 디바이스 폴링 타이머 때문에 타임아웃됩니다.
    for (var i = 0; i < 50; i++) {
      if (find.byType(CircularProgressIndicator).evaluate().isEmpty) {
        break;
      }
      await tester.binding.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump();
    }

    expect(findDisplayText('LG 퓨리헤어'), findsOneWidget);
    expect(findDisplayText('배터리'), findsOneWidget);
    expect(findDisplayText('60%'), findsOneWidget);
    expect(findDisplayText('필터 상태'), findsOneWidget);
    expect(findDisplayText('좋음'), findsOneWidget);
    expect(findDisplayText('디바이스 관리'), findsOneWidget);
    expect(find.byType(HomeQuickRefreshRow), findsOneWidget);
    expect(findDisplayText('리프레시하기'), findsOneWidget);
    expect(findDisplayText('헤어 상태 진단하기'), findsOneWidget);
    expect(findDisplayText('리프레시 기록 보기'), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    expect(find.byIcon(Icons.widgets_outlined), findsNothing);
  });
}
