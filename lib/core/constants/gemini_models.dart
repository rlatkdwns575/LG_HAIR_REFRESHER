/// Gemini `generateContent` API 모델 ID (fallback 순서).
///
/// 404·429 시 다음 모델로 재시도합니다. GA 모델을 프리뷰보다 앞에 둡니다.
class GeminiModels {
  const GeminiModels._();

  static const generateContentBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  static const recommendFallbackOrder = [
    'gemini-2.0-flash',
    'gemini-2.0-flash-lite',
    'gemini-2.5-flash-lite',
    'gemini-2.5-flash',
    'gemini-3-flash-preview',
  ];
}
