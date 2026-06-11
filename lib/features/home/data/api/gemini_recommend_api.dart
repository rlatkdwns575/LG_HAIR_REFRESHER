import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../../core/services/app_env.dart';
import '../model/environment_snapshot.dart';
import 'home_recommend_craft_prompt.dart';

class GeminiRecommendApi {
  const GeminiRecommendApi();

  static const _models = [
    'gemini-2.0-flash',
    'gemini-2.0-flash-lite',
    'gemini-2.5-flash',
  ];
  static const _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';
  static const _minMessageLength = 25;

  Future<String> generateMessage(
    EnvironmentSnapshot environment, {
    String? recommendedModeName,
  }) async {
    final apiKey = AppEnv.geminiApiKey;
    final body = jsonEncode({
      'system_instruction': {
        'parts': [
          {'text': HomeRecommendCraftPrompt.systemInstruction.trim()},
        ],
      },
      'contents': [
        {
          'parts': [
            {
              'text': HomeRecommendCraftPrompt.userPrompt(
                environment,
                recommendedModeName: recommendedModeName,
              ),
            },
          ],
        },
      ],
      'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 512},
    });

    http.Response? lastResponse;
    for (final model in _models) {
      final response = await _postGenerateContent(
        apiKey: apiKey,
        model: model,
        body: body,
      );
      lastResponse = response;

      if (response.statusCode == 200) {
        try {
          final message = _parseMessage(response.body);
          debugPrint('GeminiRecommendApi succeeded with model=$model');
          return message;
        } catch (error) {
          debugPrint('GeminiRecommendApi model=$model parse failed: $error');
        }
        continue;
      }

      debugPrint(
        'GeminiRecommendApi model=$model failed (${response.statusCode})',
      );

      if (response.statusCode != 429 && response.statusCode != 404) {
        break;
      }
    }

    final statusCode = lastResponse?.statusCode ?? 0;
    final responseBody = lastResponse?.body ?? '';
    debugPrint('GeminiRecommendApi failed ($statusCode): $responseBody');
    throw GeminiRecommendApiException('Gemini request failed ($statusCode)');
  }

  Future<http.Response> _postGenerateContent({
    required String apiKey,
    required String model,
    required String body,
  }) {
    final uri = Uri.parse('$_baseUrl/$model:generateContent');

    return http.post(
      uri,
      headers: {'Content-Type': 'application/json', 'x-goog-api-key': apiKey},
      body: body,
    );
  }

  String _parseMessage(String responseBody) {
    final json = jsonDecode(responseBody) as Map<String, dynamic>;
    final candidates = json['candidates'] as List<dynamic>? ?? [];
    if (candidates.isEmpty) {
      throw const GeminiRecommendApiException('Gemini returned no candidates');
    }

    final candidate = candidates.first as Map<String, dynamic>;
    final finishReason = candidate['finishReason'] as String?;
    if (finishReason == 'MAX_TOKENS') {
      throw const GeminiRecommendApiException('Gemini response truncated');
    }

    final contentMap = candidate['content'] as Map<String, dynamic>? ?? {};
    final parts = contentMap['parts'] as List<dynamic>? ?? [];
    if (parts.isEmpty) {
      throw const GeminiRecommendApiException('Gemini returned empty content');
    }

    final text = parts
        .map((part) => (part as Map<String, dynamic>)['text'] as String? ?? '')
        .join()
        .trim();

    if (text.isEmpty) {
      throw const GeminiRecommendApiException('Gemini returned empty text');
    }
    if (text.length < _minMessageLength) {
      throw GeminiRecommendApiException(
        'Gemini response too short (${text.length})',
      );
    }

    return text;
  }
}

class GeminiRecommendApiException implements Exception {
  const GeminiRecommendApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
