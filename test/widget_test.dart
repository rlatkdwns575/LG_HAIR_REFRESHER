import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/app/app.dart';

void main() {
  testWidgets(
    'shows home dashboard for first-entry layout without quick modes',
    (tester) async {
      await tester.pumpWidget(const LgHairRefresherApp());
      await tester.pumpAndSettle();

      expect(find.text('우리 기기 이름'), findsOneWidget);
      expect(find.text('배터리'), findsOneWidget);
      expect(find.text('60%'), findsOneWidget);
      expect(find.text('필터 상태'), findsOneWidget);
      expect(find.text('양호'), findsOneWidget);
      expect(find.text('디바이스 관리'), findsOneWidget);
      expect(
        find.textContaining('대기 중 미세먼지량이 많은 하루였어요'),
        findsOneWidget,
      );
      expect(find.text('퀵 리프레시'), findsNothing);
      expect(find.text('즐겨찾기 추천 추가하기'), findsNothing);
      expect(find.text('자주 사용한 모드'), findsNothing);
      expect(find.text('헤어 리프레시'), findsOneWidget);
      expect(find.text('헤어 상태 진단'), findsOneWidget);
      expect(find.text('진단하기'), findsOneWidget);
      expect(find.text('리프레시 내역'), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
      expect(find.byIcon(Icons.widgets_outlined), findsOneWidget);
    },
  );
}
