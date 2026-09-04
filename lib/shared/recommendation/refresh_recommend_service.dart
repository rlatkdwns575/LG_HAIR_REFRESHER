import '../../features/home/data/api/gemini_recommend_api.dart';
import '../../features/home/data/api/weather_recommend_fallback.dart';
import '../../features/refresh/data/api/refresh_api.dart';
import '../../features/refresh/data/api/refresh_recommend_fallback.dart';
import '../../features/refresh/data/model/refresh_mode.dart';
import '../../features/refresh/data/refresh_mode_catalog.dart';
import 'refresh_recommend_cache.dart';
import 'refresh_recommend_candidates.dart';
import 'refresh_recommend_context_resolver.dart';
import 'refresh_recommend_result.dart';

/// 통합 추천 — 모드는 규칙, 문구만 Gemini.
class RefreshRecommendService {
  RefreshRecommendService({
    RefreshRecommendContextResolver? contextResolver,
    this.refreshApi = const RefreshApi(),
    this.geminiRecommendApi = const GeminiRecommendApi(),
  }) : contextResolver = contextResolver ?? RefreshRecommendContextResolver();

  static final RefreshRecommendService instance = RefreshRecommendService();

  final RefreshRecommendContextResolver contextResolver;
  final RefreshApi refreshApi;
  final GeminiRecommendApi geminiRecommendApi;

  RefreshRecommendCache get _cache => RefreshRecommendCache.instance;

  /// 규칙으로 모드를 고르고, Gemini로 안내 문구를 만듭니다.
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
        return cached;
      }
    }

    final presets = await refreshApi.fetchPresetModes();
    RefreshPresetModeStore.instance.setPresets(presets);
    final candidates = RefreshRecommendCandidates.withoutScent(presets);
    if (candidates.isEmpty) {
      return null;
    }

    var mode = RefreshRecommendFallback.pickMode(
      candidates: candidates,
      context: context,
    );
    mode ??= RefreshRecommendCandidates.pickDefault(presets);
    mode ??= RefreshRecommendCandidates.fallbackWhenEmpty();

    String message;
    try {
      message = await geminiRecommendApi.generateMessage(
        context,
        recommendedModeName: mode.name,
      );
    } catch (_) {
      message = WeatherRecommendFallback.message(
        context,
        recommendedModeName: mode.name,
      );
    }

    final result = RefreshRecommendResult(
      mode: mode,
      message: message,
      basis: context.basis,
      environment: context.environment,
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

  /// 로컬 캘린더 동기화 후 추천을 다시 계산합니다.
  static Future<RefreshRecommendResult?> refreshAfterCalendarSync({
    String? userId,
    DateTime? now,
  }) async {
    RefreshRecommendCache.instance.markCalendarSynced();
    return instance.resolve(forceRefresh: true, userId: userId, now: now);
  }

  /// 프리셋 없을 때 UI용 최소 fallback 모드.
  static RefreshMode fallbackMode() {
    final presets = RefreshPresetModeStore.instance.presets;
    if (presets.isNotEmpty) {
      return RefreshRecommendCandidates.resolveDefault(presets);
    }
    return RefreshRecommendCandidates.fallbackWhenEmpty();
  }
}
