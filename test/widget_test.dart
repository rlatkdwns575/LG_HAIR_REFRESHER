import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/app/app.dart';

void main() {
  testWidgets('shows home dashboard shell', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: LgHairRefresherApp()));
    await tester.pumpAndSettle();

    expect(find.text('LG Hair Refresher'), findsOneWidget);
    expect(find.text('홈'), findsOneWidget);
    expect(find.text('측정'), findsOneWidget);
    expect(find.text('리프레시'), findsOneWidget);
  });
}
