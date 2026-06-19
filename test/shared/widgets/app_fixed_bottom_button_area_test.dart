import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/app/navigation/app_system_insets.dart';
import 'package:lg_hair_refresher/shared/widgets/app_fixed_bottom_button_area.dart';

void main() {
  group('AppBottomButtonLayout', () {
    testWidgets('applies 15/10/15/20 padding plus system bottom inset', (
      tester,
    ) async {
      const viewPadding = EdgeInsets.only(bottom: 34);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(viewPadding: viewPadding),
          child: MaterialApp(
            home: Scaffold(
              body: AppFixedBottomButtonArea(
                child: SizedBox(
                  key: const Key('cta'),
                  height: 48,
                  width: double.infinity,
                ),
              ),
            ),
          ),
        ),
      );

      final areaFinder = find.ancestor(
        of: find.byKey(const Key('cta')),
        matching: find.byType(Padding),
      );
      final padding = tester.widget<Padding>(areaFinder);
      expect(
        padding.padding,
        AppBottomButtonLayout.padding(
          tester.element(find.byKey(const Key('cta'))),
        ),
      );

      final context = tester.element(find.byKey(const Key('cta')));
      expect(
        padding.padding,
        EdgeInsets.fromLTRB(15, 10, 15, 20 + AppSystemInsets.bottomOf(context)),
      );
    });

    testWidgets('uses minimum 48dp bottom inset when system inset is smaller', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(viewPadding: EdgeInsets.zero),
          child: MaterialApp(
            home: Scaffold(
              body: AppFixedBottomButtonArea(child: SizedBox(key: Key('cta'))),
            ),
          ),
        ),
      );

      final padding = tester.widget<Padding>(
        find.ancestor(
          of: find.byKey(const Key('cta')),
          matching: find.byType(Padding),
        ),
      );

      final insets = padding.padding as EdgeInsets;
      expect(insets.bottom, 20 + AppSystemInsets.navigationBarMinHeight);
    });
  });
}
