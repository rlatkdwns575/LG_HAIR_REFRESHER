import 'package:flutter/material.dart';

import '../../features/home/data/api/gemini_recommend_api.dart';
import '../../features/home/data/api/weather_recommend_fallback.dart';
import '../../features/refresh/data/api/refresh_api.dart';
import '../../features/refresh/data/api/refresh_recommend_api.dart';
import '../../features/refresh/data/api/refresh_recommend_fallback.dart';
import '../../features/refresh/data/model/refresh_mode.dart';
import '../../features/refresh/data/refresh_mode_catalog.dart';
import 'refresh_recommend_cache.dart';
import 'refresh_recommend_context_resolver.dart';
import 'refresh_recommend_result.dart';

/// 통합 Gemini 추천 — 모든 화면의 단일 진입점.
class RefreshRecommendService {
  const RefreshRecommendService({
    this.contextResolver = const RefreshRecommendContextResolver(),
    this.refreshApi = const RefreshApi(),
    this.refreshRecommendApi = const RefreshRecommendApi(),
    this.geminiRecommendApi = const GeminiRecommendApi(),
  });

  static const RefreshRecommendService instance = RefreshRecommendService();

  final RefreshRecommendContextResolver contextResolver;
  final RefreshApi refreshApi;
  final RefreshRecommendApi refreshRecommendApi;
  final GeminiRecommendApi geminiRecommendApi;

  RefreshRecommendCache get _cache => RefreshRecommendCache.instance;

  /// 캐시·Gemini를 통해 모드+문구를 반환합니다.
  Future<RefreshRecommendResult?> resolve({
    bool forceRefresh = false,
    String? userId,
    DateTime? now,
  }) async {
    final context = await contextResolver.resolve(userId: userId, now: now);
    final signature = context.buildSignature();

    if (!forceRefresh) {
      final cached = _cache.getIfValidFor(signature);
      if (cached != null) {
        debugPrint('RefreshRecommendService: using cached result');
        return cached;
      }
    }

    final presets = await refreshApi.fetchPresetModes();
    RefreshPresetModeStore.instance.setPresets(presets);
    if (presets.isEmpty) {
      debugPrint('RefreshRecommendService: no preset modes available');
      return null;
    }

    RefreshMode? mode;
    try {
      mode = await refreshRecommendApi.recommendMode(
        candidates: presets,
        context: context,
      );
    } catch (error, stackTrace) {
      debugPrint(
        'RefreshRecommendService mode Gemini failed: $error\n$stackTrace',
      );
    }

    mode ??= RefreshRecommendFallback.pickMode(
      candidates: presets,
      context: context,
    );
    mode ??= presets.first;

    String message;
    try {
      message = await geminiRecommendApi.generateMessage(
        context,
        recommendedModeName: mode.name,
      );
      debugPrint('RefreshRecommendService: Gemini message generated');
    } catch (error, stackTrace) {
      debugPrint(
        'RefreshRecommendService message Gemini failed: $error\n$stackTrace',
      );
      message = WeatherRecommendFallback.message(
        context,
        recommendedModeName: mode.name,
      );
    }

    final result = RefreshRecommendResult(
      mode: mode,
      message: message,
      basis: context.basis,
      resolvedAt: now ?? DateTime.now(),
      signature: signature,
    );

    _cache.save(result);
    return result;
  }

  /// 측정 저장·리프레시 완료 후 호출.
  static void invalidateCache() {
    RefreshRecommendCache.instance.invalidate();
  }

  /// 프리셋 없을 때 UI용 최소 fallback 모드.
  static RefreshMode fallbackMode() {
    return const RefreshMode(
      id: 'fallback-refresh',
      name: '리프레시',
      description: '모드를 불러오지 못했습니다.',
      category: RefreshModeTabs.afterOuting,
      durationSeconds: 300,
      icon: Icons.bolt_outlined,
      odorYn: true,
      dustYn: true,
    );
  }
}
