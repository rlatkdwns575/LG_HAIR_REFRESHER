# 추천 모드 함수 보고서

작성 기준: 2026-06-22

이 문서는 LG Hair Refresher 앱에서 리프레시 추천 모드가 어떻게 결정되는지 정리합니다.

## 1. 결론 요약

추천 모드의 중심 함수는 아래입니다.

```dart
RefreshRecommendService.resolve()
```

위 함수가 추천에 필요한 데이터를 모으고, 규칙으로 모드를 고른 뒤 Gemini로 안내 문구만 생성합니다.

추천 모드 결정 순서:

```text
1. 추천 cache 확인
2. 날씨 + (유효 측정) + (오늘 일정)을 모두 수집
3. Supabase에서 프리셋 리프레시 모드 조회
4. 규칙으로 모드 확정 (측정 점수 우선, 날씨·일정은 카테고리 보조)
5. 그래도 없으면 기본 프리셋
6. Gemini로 추천 문구 생성 (제공된 신호만 언급)
7. 문구 실패 시 규칙 문구
8. 추천 결과 cache 저장
```

## 2. 관련 파일

| 파일 | 역할 |
| --- | --- |
| `lib/shared/recommendation/refresh_recommend_service.dart` | 추천 모드 전체 흐름의 메인 진입점입니다. |
| `lib/shared/recommendation/refresh_recommend_context_resolver.dart` | 측정 결과, 날씨, 일정 정보를 모아 추천 기준을 결정합니다. |
| `lib/shared/recommendation/refresh_recommend_input.dart` | Gemini/fallback에 넘길 추천 입력 데이터 모델입니다. |
| `lib/shared/recommendation/refresh_recommend_basis.dart` | 추천 근거 enum입니다. 측정/일정+날씨/날씨 기준을 구분합니다. |
| `lib/shared/recommendation/refresh_recommend_prompt.dart` | Gemini 문구 prompt를 생성합니다. |
| `lib/shared/recommendation/refresh_recommend_result.dart` | 최종 추천 결과 모델입니다. 추천 모드, 문구, 근거, 환경, cache signature를 담습니다. |
| `lib/shared/recommendation/refresh_recommend_cache.dart` | 추천 결과를 1시간 동안 cache합니다. |
| `lib/features/refresh/data/api/refresh_recommend_fallback.dart` | 측정·날씨·일정 규칙으로 모드를 고릅니다. |
| `lib/features/home/data/api/gemini_recommend_api.dart` | 추천 모드에 대한 안내 문구를 Gemini로 생성합니다. |
| `lib/features/home/data/api/weather_recommend_fallback.dart` | Gemini 문구 생성 실패 시 fallback 문구를 만듭니다. |
| `lib/features/measure/data/api/measure_refresh_recommend_service.dart` | 측정 결과 화면에서 추천 모드를 붙여 `MeasureResult`를 만듭니다. |
| `lib/features/refresh/data/api/refresh_api.dart` | Supabase에서 프리셋 리프레시 모드를 조회합니다. |

## 3. 추천 결과 모델

파일: `lib/shared/recommendation/refresh_recommend_result.dart`

```dart
class RefreshRecommendResult {
  final RefreshMode mode;
  final String message;
  final RefreshRecommendBasis basis;
  final EnvironmentSnapshot environment;
  final DateTime resolvedAt;
  final String signature;
}
```

각 값의 의미:

| 필드 | 의미 |
| --- | --- |
| `mode` | 최종 추천된 리프레시 모드입니다. |
| `message` | 사용자에게 보여줄 추천 문구입니다. |
| `basis` | 추천 근거입니다. 측정/일정+날씨/날씨 중 하나입니다. |
| `environment` | 추천 시점의 날씨/습도/기온 정보입니다. |
| `resolvedAt` | 추천 계산 시각입니다. |
| `signature` | cache 비교용 입력 요약값입니다. 같은 입력이면 cache를 재사용합니다. |

## 4. 추천 기준 결정 함수

파일: `lib/shared/recommendation/refresh_recommend_context_resolver.dart`

핵심 함수:

```dart
Future<RefreshRecommendInput> resolve(...)
static RefreshRecommendBasis resolveBasis(...)
```

### 4.1 수집하는 데이터

`RefreshRecommendContextResolver.resolve()`는 아래 데이터를 모읍니다.

| 데이터 | 가져오는 곳 | 실패 시 |
| --- | --- | --- |
| 날씨/환경 | `WeatherApi.fetchSnapshot()` | 기본 환경값 사용 |
| 오늘 일정 | `LocalCalendarService`, `CalendarEventsApi` | 빈 일정으로 처리 |
| 최신 측정 결과 | `MeasureApi.fetchLatestResult()` | 측정 결과 없음 |
| 측정 후 리프레시 여부 | `RefreshSessionApi.hasCompletedRefreshSinceMeasure()` | false 성격으로 처리 |

기본 환경값:

```dart
temperatureCelsius: 22
humidityPercent: 50
isRaining: false
isSnowing: false
```

### 4.2 추천 근거 라벨과 입력 포함 규칙

`resolveBasis()`는 **문구·UI 라벨**용입니다. 입력 JSON은 유효한 신호를 모두 넣습니다.

| 조건 | 입력에 포함 | 라벨 (`basis`) |
| --- | --- | --- |
| 최신 측정 + 아직 리프레시 안 함 + 2시간 이내 | 날씨 + 측정 + (오늘 일정 있으면 일정) | `measure` |
| 위가 아니고 오늘 일정 있음 | 날씨 + 일정 | `weatherAndSchedule` |
| 그 외 | 날씨만 | `weatherOnly` |

측정이 만료됐거나 리프레시 이후면 점수에는 쓰지 않지만, 날씨·일정은 그대로 씁니다.

코드 흐름:

```dart
if (latestMeasure != null && !refreshedAfterMeasure) {
  final age = now.difference(latestMeasure.createdAt.toLocal());
  if (age <= measureWindow) {
    return RefreshRecommendBasis.measure;
  }
}

if (schedule.hasEventsToday) {
  return RefreshRecommendBasis.weatherAndSchedule;
}

return RefreshRecommendBasis.weatherOnly;
```

## 5. 통합 추천 함수

파일: `lib/shared/recommendation/refresh_recommend_service.dart`

핵심 함수:

```dart
Future<RefreshRecommendResult?> resolve({
  bool forceRefresh = false,
  String? userId,
  DateTime? now,
})
```

### 5.1 동작 순서

```text
1. contextResolver.resolve()로 날씨·유효 측정·오늘 일정을 함께 담은 context 생성
2. context.buildSignature()로 cache key 생성
3. forceRefresh가 아니면 cache 확인
4. RefreshApi.fetchPresetModes()로 후보 모드 조회
5. RefreshRecommendFallback.pickMode()로 모드 확정
6. GeminiRecommendApi.generateMessage()로 추천 문구 생성
7. 문구 생성 실패 시 WeatherRecommendFallback.message() 사용
8. RefreshRecommendResult 생성
9. cache 저장 후 반환
```

### 5.2 후보 모드가 없을 때

```dart
if (presets.isEmpty) {
  return null;
}
```

Supabase에서 리프레시 모드를 하나도 못 가져오면 추천 결과는 `null`입니다.

### 5.3 추천 모드 선택 우선순위

```dart
RefreshMode? mode = RefreshRecommendFallback.pickMode(...);
mode ??= RefreshRecommendCandidates.pickDefault(presets);
```

모드는 규칙으로만 고릅니다. Gemini는 확정된 모드 이름으로 문구만 생성합니다.
날씨·일정은 같은 점수대 후보 안에서 카테고리(외출 전/후/날씨)를 고르는 데 사용합니다.

## 6. Gemini 역할

Gemini는 추천 문구 생성에만 사용합니다. 모드 `mode_id` 선택은 하지 않습니다.

파일: `lib/features/home/data/api/gemini_recommend_api.dart`

핵심 함수:

```dart
Future<String> generateMessage(
  RefreshRecommendInput context, {
  required String recommendedModeName,
})
```

제공된 입력 JSON과 이미 확정된 모드 이름만 넣고 한국어 안내 문구를 받습니다.

## 7. Gemini prompt 생성 함수

파일: `lib/shared/recommendation/refresh_recommend_prompt.dart`

핵심 함수:

| 함수 | 역할 |
| --- | --- |
| `messageSystemInstruction` | 추천 문구 작성 규칙을 지시합니다. |
| `messageUserPrompt` | 제공된 입력 JSON과 추천 모드 이름을 넣어 문구 생성을 요청합니다. |

### 7.1 추천 기준별 Gemini 지시

| `basis` | Gemini에게 주는 핵심 기준 |
| --- | --- |
| `measure` | 측정 점수, 즉 냄새/먼지/종합 오염도를 최우선으로 반영합니다. 날씨와 일정은 보조 신호입니다. |
| `weatherAndSchedule` | 오늘 일정과 날씨를 균형 있게 반영합니다. |
| `weatherOnly` | 기온/습도/비/눈 등 환경 JSON만 사용합니다. 일정과 측정 데이터는 언급하지 않습니다. |

### 7.2 추천 입력 섹션

`_inputSections()`는 basis에 따라 아래 데이터를 prompt에 포함합니다.

| 조건 | 포함 데이터 |
| --- | --- |
| 항상 | 환경 JSON |
| 측정 기준 | 측정 결과 JSON |
| 일정 기준 | 오늘 일정 JSON |

## 8. fallback 추천 함수

파일: `lib/features/refresh/data/api/refresh_recommend_fallback.dart`

핵심 함수:

```dart
static RefreshMode? pickMode(...)
static RefreshMode? pickModeFromEnvironment(...)
```

모드는 이 규칙으로만 고릅니다. Gemini는 관여하지 않습니다.

### fallback 규칙

| 조건 | 추천 모드 |
| --- | --- |
| 비가 오거나 눈이 옴 | `weather` 카테고리 첫 번째 모드 |
| 습도 70% 이상 | `afterOuting` 카테고리 첫 번째 모드 |
| 습도 70% 이상인데 `afterOuting` 없음 | `weather` 카테고리 첫 번째 모드 |
| 그 외 | `beforeOuting` 카테고리 첫 번째 모드 |
| 그래도 없음 | 후보 목록의 첫 번째 모드 |

코드 흐름:

```dart
if (environment.isSnowing || environment.isRaining) {
  return first weather mode;
}

if (environment.humidityPercent >= 70) {
  return first afterOuting mode ?? first weather mode;
}

return first beforeOuting mode ?? candidates.first;
```

주의:

- 측정이 유효하면 fallback도 점수 규칙을 먼저 보고, 날씨·일정은 카테고리 보조로 씁니다.
- 측정이 없으면 비/눈 → `weather`, 지난 일정 → `afterOuting`, 습도 70% → `afterOuting`, 그 외 `beforeOuting`입니다.

## 9. 추천 문구 생성 함수

### 9.1 Gemini 문구 생성

파일: `lib/features/home/data/api/gemini_recommend_api.dart`

핵심 함수:

```dart
Future<String> generateMessage(
  RefreshRecommendInput context, {
  required String recommendedModeName,
})
```

동작:

1. 추천 근거에 맞는 문구 작성 system instruction 생성
2. 추천 입력 JSON과 추천 모드 이름을 user prompt로 전달
3. Gemini 응답에서 text 추출
4. 응답이 비어 있거나 너무 짧으면 실패 처리

최소 문구 길이:

```dart
_minMessageLength = 25
```

### 9.2 문구 fallback

파일: `lib/features/home/data/api/weather_recommend_fallback.dart`

핵심 함수:

```dart
static String message(
  RefreshRecommendInput context, {
  required String recommendedModeName,
})
```

추천 근거별 시작 문구:

| basis | 시작 문구 성격 |
| --- | --- |
| `measure` | 측정 결과와 오늘 환경을 보면 |
| `weatherAndSchedule` | 오늘 일정과 날씨를 보면 |
| `weatherOnly` | 오늘 날씨가 ~한 날이니 |

## 10. 측정 결과 화면에서 추천 모드 붙이기

파일: `lib/features/measure/data/api/measure_refresh_recommend_service.dart`

핵심 함수:

```dart
Future<MeasureResult> buildMeasureResult(...)
```

역할:

1. 측정 record 조회
2. 냄새/먼지 점수를 `MeasureCareLevel`로 변환
3. Supabase에서 프리셋 리프레시 모드 조회
4. `RefreshRecommendService.resolve()`로 추천 모드와 문구 조회
5. 추천 실패 시 `_fallbackMode(presets)` 사용
6. 최종 `MeasureResult.recommendedMode`에 저장

### 측정 화면 fallback 모드 규칙

함수:

```dart
static RefreshMode _fallbackMode(List<RefreshMode> presets)
```

규칙:

| 조건 | 결과 |
| --- | --- |
| 프리셋 없음 | `RefreshRecommendService.fallbackMode()` |
| `afterOuting` + `odorYn` + `dustYn` 모드 있음 | 해당 모드 |
| 위 조건 없음 | `presets.first` |

즉, 측정 결과 화면에서는 냄새와 먼지를 모두 케어하는 외출 후 모드를 fallback으로 선호합니다.

## 11. 홈 화면에서 추천 모드 사용

관련 파일:

- `lib/features/home/ui/page/home_page.dart`
- `lib/features/home/ui/widgets/home_recommend_banner.dart`
- `lib/features/home/ui/widgets/home_quick_refresh_row.dart`

홈 화면은 직접 추천 알고리즘을 갖고 있기보다 `RefreshRecommendService.resolve()` 결과를 받아 표시합니다.

사용 방식:

```text
추천 결과 mode -> 홈 빠른 리프레시 카드
추천 결과 message -> 추천 배너 문구
```

## 12. cache 함수

파일: `lib/shared/recommendation/refresh_recommend_cache.dart`

추천 결과는 cache됩니다.

| 값 | 내용 |
| --- | --- |
| cache TTL | 1시간 |
| cache key | `RefreshRecommendInput.buildSignature()` |
| 무효화 함수 | `invalidate()` |
| 캘린더 동기화 후 무효화 | `markCalendarSynced()` |

동작:

```dart
RefreshRecommendResult? getIfValidFor(String signature)
```

입력 signature가 같고 1시간이 지나지 않았으면 기존 추천 결과를 재사용합니다.

측정 결과 저장 후에는 cache를 지웁니다.

```dart
RefreshRecommendService.invalidateCache()
```

`MeasureApi.insertDiagnosisResult()`의 `finally`에서 호출됩니다.

## 13. 추천 모드 전체 흐름

### 13.1 일반 홈 추천

```text
HomePage
-> RefreshRecommendService.resolve()
-> RefreshRecommendContextResolver.resolve()
-> RefreshApi.fetchPresetModes()
-> RefreshRecommendFallback.pickMode()
-> GeminiRecommendApi.generateMessage()
-> WeatherRecommendFallback.message() if needed
-> RefreshRecommendResult
```

### 13.2 측정 결과 기반 추천

```text
MeasureAnalyzingPage 또는 MeasureResultPage
-> MeasureRefreshRecommendService.buildMeasureResult()
-> MeasureApi.fetchLatestResult() 또는 저장된 sourceRecord 사용
-> MeasureResultMapper.odorLevel/dustLevel()
-> RefreshRecommendService.resolve(forceRefresh: true)
-> 추천 mode/message
-> MeasureResult.recommendedMode
```

### 13.3 캘린더 동기화 후 추천 갱신

```text
Local calendar sync
-> RefreshRecommendService.refreshAfterCalendarSync()
-> RefreshRecommendCache.markCalendarSynced()
-> resolve(forceRefresh: true)
```

## 14. 현재 구조의 리스크

| 리스크 | 설명 |
| --- | --- |
| Gemini 실패 시 측정 점수 fallback 미반영 | 측정이 유효하면 점수로 모드를 먼저 확정합니다. 날씨·일정은 카테고리 보조입니다. |
| prompt 문자열 인코딩 깨짐 | 일부 prompt와 fallback 문구의 한글이 깨져 있어 추천 품질에 영향을 줄 수 있습니다. |
| 후보 모드 품질 의존 | Gemini는 후보 JSON 안에서만 고릅니다. Supabase 프리셋 모드가 부족하거나 flag가 부정확하면 추천 품질이 낮아집니다. |
| cache stale 가능성 | cache TTL은 1시간입니다. 날씨나 측정 상태가 바뀌어도 signature가 같으면 cache를 재사용합니다. |
| API key 노출 구조 | Gemini API key는 `AppEnv.geminiApiKey`에서 읽고, `.env`가 asset으로 포함되는 구조입니다. 운영 배포 전 보안 검토가 필요합니다. |

## 15. 개선 제안

1. 측정 기반 fallback을 강화하기

```text
hairOdorScore가 높으면 odorYn 모드 우선
hairDustScore가 높으면 dustYn 모드 우선
둘 다 높으면 odorYn && dustYn 모드 우선
```

2. 추천 기준 정책을 문서화하기

```text
measure > schedule > weather
2시간 window
측정 후 리프레시 완료 시 measure 기준 제외
```

3. prompt 한글 인코딩 복구하기

추천 품질은 prompt 품질에 직접 영향을 받습니다.

4. Gemini 실패 로그를 남기기

현재는 `catch (_) {}`가 많아 실패 원인을 알기 어렵습니다.

5. API key를 클라이언트 asset에서 분리하기

운영 배포에서는 Edge Function 같은 서버 중계가 더 안전합니다.

