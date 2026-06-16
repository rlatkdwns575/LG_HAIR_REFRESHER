import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/app/navigation/app_system_insets.dart';

void main() {
  group('AppSystemInsets', () {
    testWidgets('uses at least 48dp when system inset is zero', (tester) async {
      late double bottomInset;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              bottomInset = AppSystemInsets.bottomOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(bottomInset, AppSystemInsets.navigationBarMinHeight);
    });

    testWidgets('uses device inset when it exceeds 48dp', (tester) async {
      late double bottomInset;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              padding: EdgeInsets.only(bottom: 56),
              viewPadding: EdgeInsets.only(bottom: 56),
            ),
            child: Builder(
              builder: (context) {
                bottomInset = AppSystemInsets.bottomOf(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(bottomInset, 56);
    });

    testWidgets('floors at 48dp when device inset is smaller', (tester) async {
      late double bottomInset;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              padding: EdgeInsets.only(bottom: 34),
              viewPadding: EdgeInsets.only(bottom: 34),
            ),
            child: Builder(
              builder: (context) {
                bottomInset = AppSystemInsets.bottomOf(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(bottomInset, AppSystemInsets.navigationBarMinHeight);
    });

    testWidgets('pageHorizontal adds extra bottom spacing', (tester) async {
      late EdgeInsets padding;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              padding = AppSystemInsets.pageHorizontal(
                context,
                extraBottom: 24,
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(padding.bottom, AppSystemInsets.navigationBarMinHeight + 24);
    });
  });
}
