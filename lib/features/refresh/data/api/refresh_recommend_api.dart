import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/constants/gemini_models.dart';
import '../../../../core/services/app_env.dart';
import '../../../../shared/recommendation/refresh_recommend_input.dart';
import '../../../../shared/recommendation/refresh_recommend_prompt.dart';
import '../model/refresh_mode.dart';

class RefreshRecommendApi {
  const RefreshRecommendApi();

  static const _models = GeminiModels.recommendFallbackOrder;
  static const _baseUrl = GeminiModels.generateContentBaseUrl;

  Future<RefreshMode?> recommendMode({
    required List<RefreshMode> candidates,
    required RefreshRecommendInput context,
  }) async {
    if (candidates.isEmpty) {
      return null;
    }

    final apiKey = AppEnv.geminiApiKey;
    final body = jsonEncode({
      'system_instruction': {
        'parts': [
          {
            'text': RefreshRecommendPrompt.modeSystemInstruction(
              context.basis,
            ).trim(),
          },
        ],
      },
      'contents': [
        {
          'parts': [
            {
              'text': RefreshRecommendPrompt.modeUserPrompt(
                candidates: candidates,
                context: context,
              ),
            },
          ],
        },
      ],
      'generationConfig': {'temperature': 0.2, 'maxOutputTokens': 256},
    });

    for (final model in _models) {
      final response = await _postGenerateContent(
        apiKey: apiKey,
        model: model,
        body: body,
      );
      if (response.statusCode == 200) {
        final modeId = _parseModeId(response.body);
        if (modeId != null) {
          for (final mode in candidates) {
            if (mode.id == modeId) {
              return mode;
            }
          }
        }
        continue;
      }
      if (response.statusCode != 429 && response.statusCode != 404) {
        break;
      }
    }
    return null;
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

  String? _parseModeId(String responseBody) {
    final json = jsonDecode(responseBody) as Map<String, dynamic>;
    final candidates = json['candidates'] as List<dynamic>? ?? [];
    if (candidates.isEmpty) {
      return null;
    }

    final candidate = candidates.first as Map<String, dynamic>;
    if (candidate['finishReason'] == 'MAX_TOKENS') {
      return null;
    }

    final contentMap = candidate['content'] as Map<String, dynamic>? ?? {};
    final parts = contentMap['parts'] as List<dynamic>? ?? [];
    if (parts.isEmpty) {
      return null;
    }

    final text = parts
        .map((part) => (part as Map<String, dynamic>)['text'] as String? ?? '')
        .join();
    if (text.trim().isEmpty) {
      return null;
    }

    final trimmed = text.trim();
    try {
      final parsed = jsonDecode(trimmed) as Map<String, dynamic>;
      return parsed['mode_id'] as String?;
    } catch (_) {
      final match = RegExp(
        r'[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}',
        caseSensitive: false,
      ).firstMatch(trimmed);
      return match?.group(0);
    }
  }
}
