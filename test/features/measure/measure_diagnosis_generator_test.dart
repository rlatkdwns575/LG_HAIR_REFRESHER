import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/features/measure/data/api/measure_diagnosis_generator.dart';

void main() {
  test('generateHighPollution includes smell_type for insert', () {
    final payload = MeasureDiagnosisGenerator.generateHighPollution(
      random: Random(1),
    );

    expect(payload.smellType, isNotEmpty);
    expect(
      payload.toJson('ud-1'),
      containsPair('smell_type', payload.smellType),
    );
  });
}
