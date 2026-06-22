import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/features/measure/data/measure_result_store.dart';
import 'package:lg_hair_refresher/features/measure/data/model/measure_result.dart';

void main() {
  group('MeasureResultStore', () {
    tearDown(() {
      MeasureResultStore.instance.consume();
    });

    test('setPending and consume return stored result', () {
      final pending = MeasureResult.sampleStable;
      MeasureResultStore.instance.setPending(pending);

      expect(MeasureResultStore.instance.peek(), pending);
      expect(MeasureResultStore.instance.consume(), pending);
      expect(MeasureResultStore.instance.peek(), isNull);
    });

    test('consume without pending returns null', () {
      expect(MeasureResultStore.instance.consume(), isNull);
    });

    test('consume without pending and explicit fallback uses fallback', () {
      final fallback = MeasureResult.sampleStable;
      expect(MeasureResultStore.instance.consume(fallback: fallback), fallback);
    });
  });
}
