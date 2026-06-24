import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/core/constants/gemini_models.dart';

void main() {
  test('recommendFallbackOrder includes stable and preview flash models', () {
    expect(GeminiModels.recommendFallbackOrder, [
      'gemini-2.0-flash',
      'gemini-2.0-flash-lite',
      'gemini-2.5-flash-lite',
      'gemini-2.5-flash',
      'gemini-3-flash-preview',
    ]);
  });
}
