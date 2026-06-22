# 전체 백엔드 보고서

작성 기준: 2026-06-22

이 문서는 LG Hair Refresher 앱의 전체 백엔드 연결 구조를 Dart/Flutter 초보자 기준으로 설명합니다.

여기서 말하는 백엔드는 서버 코드만 뜻하지 않습니다. 이 Flutter 앱에서는 Supabase, Gemini, 날씨 API, 캘린더, 알림, 로컬 저장소처럼 화면 밖의 데이터를 가져오거나 저장하는 코드 전체를 백엔드 연결 영역으로 봅니다.

## 1. 전체 요약

이 프로젝트의 백엔드 구조는 크게 5가지입니다.

| 영역 | 역할 | 대표 위치 |
| --- | --- | --- |
| Supabase 연결 | 로그인, 사용자, 기기, 측정, 리프레시, 기록 저장/조회 | `features/*/data/api/`, `core/services/supabase_service.dart` |
| 외부 API | Gemini 추천/문구 생성, 날씨 정보 조회 | `home/data/api`, `refresh/data/api`, `shared/recommendation` |
| 기기/로컬 서비스 | 캘린더, 알림, 향기 카트리지 상태, 로컬 저장 | `core/services`, `features/routine/data/api` |
| 모델 변환 | Supabase row나 API 응답을 Dart 객체로 변환 | `features/*/data/model`, `features/*/data/api/*_mapper.dart` |
| 임시 상태/cache | 화면 이동 중 데이터 보관, 추천 cache, 커스텀 모드 cache | `*_store.dart`, `*_cache.dart` |

백엔드 흐름을 아주 단순하게 보면 아래와 같습니다.

```text
UI 화면
-> data/api 또는 core/services 호출
-> Supabase/API/로컬 저장소 접근
-> Dart model로 변환
-> UI 화면에 반환
```

## 2. 백엔드 코드 위치 규칙

이 프로젝트의 원칙상 Supabase Client는 아래 위치에서만 사용해야 합니다.

```text
features/{feature}/data/api/
core/services/supabase_service.dart
```

금지 위치:

```text
features/{feature}/ui/
shared/widgets/
app/router/
app/theme/
```

초보자 기준 설명:

- `ui/`는 화면을 그리는 곳입니다.
- `data/api/`는 서버나 DB와 통신하는 곳입니다.
- 화면 파일에서 Supabase를 직접 부르면 화면 코드가 복잡해지고 유지보수가 어려워집니다.

## 3. 핵심 백엔드 폴더

```text
lib/
 ├─ core/
 │   ├─ constants/
 │   └─ services/
 ├─ features/
 │   └─ {feature}/data/
 │       ├─ api/
 │       └─ model/
 └─ shared/
     └─ recommendation/
```

| 폴더 | 역할 |
| --- | --- |
| `core/constants/` | table name, route path, image path 같은 전역 상수 |
| `core/services/` | 여러 feature가 같이 쓰는 서비스 |
| `features/*/data/api/` | feature별 Supabase/API 호출 |
| `features/*/data/model/` | 데이터 구조를 나타내는 Dart class |
| `shared/recommendation/` | 홈/측정/리프레시에서 함께 쓰는 추천 로직 |

## 4. Supabase table 상수

파일: `lib/core/constants/supabase_tables.dart`

이 파일은 Supabase table 이름을 한 곳에서 관리합니다.

```dart
class SupabaseTables {
  static const authUsers = 'AUTH_USERS';
  static const devices = 'DEVICES';
  static const userDevices = 'USER_DEVICES';
  static const consumableStatus = 'CONSUMABLE_STATUS';
  static const measureResults = 'MEASURE_RESULTS';
  static const refreshMode = 'REFRESH_MODE';
  static const refreshSessions = 'REFRESH_SESSIONS';
  static const calendarEvents = 'CALENDAR_EVENTS';
  static const refreshRecommendAlarms = 'REFRESH_RECOMMEND_ALARMS';
}
```

왜 필요한가:

- table 이름을 문자열로 여기저기 쓰면 오타가 생기기 쉽습니다.
- table 이름이 바뀌면 한 파일만 고치면 됩니다.
- Supabase table 이름이 대문자라 정확히 맞춰야 합니다.

## 5. Core Services

위치: `lib/core/services/`

여러 feature에서 같이 쓰는 백엔드성 서비스입니다.

| 파일 | 역할 |
| --- | --- |
| `supabase_service.dart` | Supabase client 초기화/공통 접근점 |
| `app_env.dart` | `.env` 값, API key, 환경 설정 로드 |
| `auth_session_service.dart` | 현재 로그인 사용자 id/session 확인 |
| `user_profile_service.dart` | 사용자 프로필 공통 조회/저장 |
| `calendar_events_api.dart` | 캘린더 이벤트를 Supabase에 저장/조회 |
| `device_calendar_reader.dart` | 기기 로컬 캘린더 읽기 |
| `local_calendar_service.dart` | 로컬 캘린더 연동 흐름 관리 |
| `local_calendar_connection_store.dart` | 캘린더 연결 상태 로컬 저장 |
| `local_calendar_connect_result.dart` | 캘린더 연결 결과 모델 |
| `local_calendar_login_prompt.dart` | 캘린더 로그인 안내 모델/처리 |
| `device_consumable_service.dart` | 향기 카트리지 등 소모품 상태 조회 |
| `notification_service.dart` | 로컬 알림 예약/권한 처리 |

초보자 기준:

- `Service`는 여러 화면/기능에서 같이 쓰는 일을 담당합니다.
- 예를 들어 알림은 routine에서도 쓰고 settings에서도 쓸 수 있으므로 `core/services`에 둘 수 있습니다.

## 6. Auth 백엔드

위치: `lib/features/auth/data/`

역할:

- 로그인
- 회원가입
- 사용자 프로필 저장
- 개발용 로그인 정보 관리
- 입력값 검증

대표 파일:

| 파일 | 역할 |
| --- | --- |
| `api/auth_api.dart` | Supabase auth 또는 사용자 table과 연결되는 인증 API |
| `auth_credentials_validator.dart` | 이메일/비밀번호 입력값 검증 |
| `auth_dev_credentials.dart` | 개발용 계정 정보 |
| `model/auth_user_profile.dart` | 로그인 사용자 프로필 모델 |
| `model/sign_up_draft.dart` | 회원가입 중 임시 입력값 모델 |

프론트와 연결:

```text
login_screen.dart
-> AuthApi
-> Supabase Auth / AUTH_USERS
-> AuthUserProfile
```

## 7. Home 백엔드

위치: `lib/features/home/data/`

홈은 대시보드에 필요한 데이터를 모읍니다.

대표 파일:

| 파일 | 역할 |
| --- | --- |
| `api/home_api.dart` | 홈 대시보드 데이터 조회 |
| `api/weather_api.dart` | 날씨/환경 정보 조회 |
| `api/gemini_recommend_api.dart` | Gemini로 추천 문구 생성 |
| `api/weather_recommend_fallback.dart` | Gemini 실패 시 추천 문구 fallback |
| `api/consumable_status_mapper.dart` | 소모품 상태 row를 화면 모델로 변환 |
| `home_device_status_watcher.dart` | 홈에서 기기 상태 변경 감시 |
| `home_shortcut_store.dart` | 빠른 리프레시 바로가기 로컬 저장 |
| `model/environment_snapshot.dart` | 날씨/습도/비/눈 환경 snapshot |
| `model/home_dashboard_data.dart` | 홈 화면 전체 데이터 모델 |
| `model/home_device_status_snapshot.dart` | 기기 상태 snapshot |
| `model/home_filter_status.dart` | 필터 상태 모델 |

홈 백엔드 흐름:

```text
HomePage
-> HomeApi.fetchDashboard()
-> Supabase USER_DEVICES / DEVICES / CONSUMABLE_STATUS 등 조회
-> HomeDashboardData 반환
```

추천 문구 흐름:

```text
RefreshRecommendService
-> GeminiRecommendApi.generateMessage()
-> 실패 시 WeatherRecommendFallback.message()
```

## 8. Measure 백엔드

위치: `lib/features/measure/data/`

Measure는 헤어 상태 측정 결과를 만들고 저장하고 화면용 데이터로 변환합니다.

대표 파일:

| 파일 | 역할 |
| --- | --- |
| `api/measure_api.dart` | 측정 결과 저장/최신 결과 조회 |
| `api/measure_diagnosis_generator.dart` | 현재 mock 성격의 측정 오염도 payload 생성 |
| `api/measure_refresh_recommend_service.dart` | 측정 결과에 추천 리프레시 모드를 붙임 |
| `api/measure_result_mapper.dart` | 측정 점수를 화면 상태/문구/badge로 변환 |
| `api/measure_schedule_classifier_api.dart` | 일정 기반 측정/추천 분류 보조 |
| `measure_result_store.dart` | 화면 이동 중 측정 결과 임시 보관 |
| `measure_result_visual_mapper.dart` | 냄새/먼지 단계에 맞는 이미지 선택 |
| `measure_result_headline_builder.dart` | 측정 결과 headline 생성 |
| `model/measure_result_record.dart` | Supabase `MEASURE_RESULTS` row 모델 |
| `model/measure_result.dart` | 측정 결과 요약 화면 모델 |
| `model/measure_result_detail.dart` | 측정 상세 화면 모델 |
| `model/measure_care_level.dart` | 냄새/먼지 케어 단계 enum |

측정 저장 흐름:

```text
MeasureAnalyzingPage
-> MeasureDiagnosisGenerator.generateHighPollution()
-> MeasureApi.insertDiagnosisResult()
-> Supabase MEASURE_RESULTS 저장
-> RefreshRecommendService.invalidateCache()
```

측정 조회 흐름:

```text
MeasureResultPage
-> MeasureRefreshRecommendService.buildMeasureResult()
-> MeasureApi.fetchLatestResult()
-> MeasureResultMapper
-> MeasureResult 반환
```

중요:

- 현재 측정 점수 생성은 실제 센서/AI 알고리즘이라기보다 mock 고오염 데이터 성격입니다.
- 실제 기기 연동 시 `measure_diagnosis_generator.dart`가 교체 또는 분리 대상입니다.

## 9. Refresh 백엔드

위치: `lib/features/refresh/data/`

Refresh는 리프레시 모드 목록, 커스텀 모드, 실행 세션, 결과 생성/저장을 담당합니다.

대표 API 파일:

| 파일 | 역할 |
| --- | --- |
| `api/refresh_api.dart` | 프리셋 리프레시 모드 조회 |
| `api/custom_mode_api.dart` | 사용자 커스텀 모드 저장/조회/삭제 |
| `api/refresh_mode_mapper.dart` | Supabase row를 `RefreshMode`로 변환 |
| `api/refresh_recommend_api.dart` | Gemini로 추천 mode_id 선택 |
| `api/refresh_recommend_fallback.dart` | Gemini 실패 시 규칙 기반 추천 |
| `api/refresh_session_api.dart` | 리프레시 세션 저장/조회 |
| `api/refresh_session_result_generator.dart` | 리프레시 실행 전후 결과 생성 |

대표 data/helper 파일:

| 파일 | 역할 |
| --- | --- |
| `custom_mode_cache.dart` | 커스텀 모드 cache |
| `refresh_mode_catalog.dart` | 리프레시 모드 tab/category 정의 |
| `refresh_mode_filter.dart` | 선택 tab에 맞게 모드 필터링 |
| `refresh_mode_availability.dart` | 향기 카트리지 상태 기준 실행 가능 여부 판단 |
| `refresh_result_store.dart` | 결과 화면 이동 중 결과 임시 보관 |
| `refresh_result_detail_mapper.dart` | 결과 상세 화면 데이터 변환 |
| `refresh_result_headline_builder.dart` | 결과 headline 생성 |
| `care_duration_split.dart` | 초 단위 시간을 화면용 시간으로 변환 |

대표 모델:

| 파일 | 역할 |
| --- | --- |
| `model/refresh_mode.dart` | 리프레시 모드 모델 |
| `model/refresh_mode_detail.dart` | 리프레시 모드 상세 모델 |
| `model/refresh_progress_session.dart` | 실행 중 세션 모델 |
| `model/refresh_result.dart` | 결과 요약 모델 |
| `model/refresh_result_detail.dart` | 결과 상세 모델 |
| `model/refresh_result_change.dart` | before/after 변화 모델 |
| `model/refresh_session_outcome.dart` | 저장된 세션 결과 모델 |
| `model/refresh_pollution_level.dart` | 결과 차트용 오염도 단계 |

프리셋 모드 조회 흐름:

```text
RefreshPage
-> RefreshApi.fetchPresetModes()
-> Supabase REFRESH_MODE 조회
-> RefreshModeMapper
-> List<RefreshMode>
```

리프레시 실행 결과 흐름:

```text
RefreshProgressPage
-> RefreshResultCollectingPage
-> RefreshSessionResultGenerator
-> RefreshSessionApi 저장
-> RefreshResultStore
-> RefreshResultPage
```

## 10. Recommendation 공통 백엔드

위치: `lib/shared/recommendation/`

추천 모드는 home, measure, refresh에서 함께 쓰므로 `shared/recommendation`에 있습니다.

대표 파일:

| 파일 | 역할 |
| --- | --- |
| `refresh_recommend_service.dart` | 추천 모드 전체 흐름의 중심 서비스 |
| `refresh_recommend_context_resolver.dart` | 측정/날씨/일정 데이터를 모아 추천 입력 생성 |
| `refresh_recommend_input.dart` | Gemini/fallback에 넘길 입력 모델 |
| `refresh_recommend_result.dart` | 최종 추천 결과 모델 |
| `refresh_recommend_basis.dart` | 추천 근거 enum |
| `refresh_recommend_prompt.dart` | Gemini prompt 생성 |
| `refresh_recommend_cache.dart` | 추천 결과 1시간 cache |
| `refresh_recommend_schedule_snapshot.dart` | 일정 snapshot 모델 |

추천 백엔드 흐름:

```text
RefreshRecommendService.resolve()
-> RefreshRecommendContextResolver.resolve()
-> RefreshApi.fetchPresetModes()
-> RefreshRecommendApi.recommendMode()
-> RefreshRecommendFallback.pickMode()
-> GeminiRecommendApi.generateMessage()
-> WeatherRecommendFallback.message()
-> RefreshRecommendResult
```

추천 근거 우선순위:

```text
최근 측정 결과
-> 오늘 일정 + 날씨
-> 날씨만
```

## 11. History 백엔드

위치: `lib/features/history/data/`

History는 측정 기록과 리프레시 기록을 조회하고 화면용 report로 변환합니다.

대표 파일:

| 파일 | 역할 |
| --- | --- |
| `api/history_api.dart` | 측정/리프레시 기록 조회 |
| `api/history_measure_mapper.dart` | 측정 record를 history 화면 모델로 변환 |
| `api/history_session_mapper.dart` | 리프레시 session row를 history 화면 모델로 변환 |
| `api/history_report_builder.dart` | 월간/일간 기록 report 생성 |
| `refresh_history_store.dart` | 기록 상세 이동용 임시 저장 |
| `model/care_status.dart` | 좋음/보통/권장 등 기록 상태 enum |
| `model/refresh_history_record.dart` | 리프레시 기록 item 모델 |
| `model/refresh_history_report.dart` | history 화면 전체 report 모델 |

기록 조회 흐름:

```text
HistoryPage
-> HistoryApi
-> Supabase MEASURE_RESULTS / REFRESH_SESSIONS 조회
-> mapper
-> RefreshHistoryReport
```

## 12. Settings 백엔드

위치: `lib/features/settings/data/`

Settings는 사용자/기기/설정 정보를 조회해서 설정 화면에 제공합니다.

대표 파일:

| 파일 | 역할 |
| --- | --- |
| `api/settings_api.dart` | 설정 화면에 필요한 사용자/기기 정보 조회 |
| `api/settings_device_mapper.dart` | 기기 row를 설정 화면 모델로 변환 |
| `model/settings_device_detail.dart` | 설정 화면 기기 상세 모델 |
| `model/settings_user_summary.dart` | 설정 화면 사용자 요약 모델 |

설정 백엔드 흐름:

```text
SettingsPage
-> SettingsApi
-> Supabase AUTH_USERS / USER_DEVICES / DEVICES 등 조회
-> SettingsUserSummary / SettingsDeviceDetail
```

## 13. Routine 백엔드

위치: `lib/features/routine/data/`

Routine은 리프레시 알림/루틴을 저장하고 알림을 예약합니다.

대표 파일:

| 파일 | 역할 |
| --- | --- |
| `api/routine_api.dart` | 루틴 저장/조회/삭제 API |
| `api/routine_local_store.dart` | 루틴 로컬 저장 |
| `api/routine_alarm_scheduler.dart` | 루틴 알림 예약 |
| `model/routine.dart` | 루틴 모델 |

루틴 흐름:

```text
RoutineRegisterPage
-> RoutineApi 저장
-> RoutineAlarmScheduler 알림 예약
-> RoutineListPage에서 조회
```

저장소는 현재 로컬 저장과 Supabase table 설계가 섞일 수 있으므로, 운영 기준에서는 저장 위치 정책을 명확히 해야 합니다.

## 14. 모델과 Mapper 개념

### 14.1 Model

Model은 데이터를 담는 Dart class입니다.

예:

```dart
class RefreshMode {
  final String id;
  final String name;
  final int durationSeconds;
}
```

초보자 기준:

- DB row나 API 응답을 그대로 Map으로 쓰면 실수하기 쉽습니다.
- class로 만들면 어떤 값이 있는지 명확합니다.

### 14.2 Mapper

Mapper는 한 데이터 형태를 다른 데이터 형태로 바꾸는 코드입니다.

예:

```text
Supabase row Map
-> RefreshModeMapper
-> RefreshMode
```

대표 mapper:

| 파일 | 변환 |
| --- | --- |
| `refresh_mode_mapper.dart` | `REFRESH_MODE` row -> `RefreshMode` |
| `measure_result_mapper.dart` | 측정 record -> 화면 상태/문구 |
| `history_session_mapper.dart` | refresh session row -> history record |
| `history_measure_mapper.dart` | measure row -> history item |
| `settings_device_mapper.dart` | device row -> 설정 화면 기기 모델 |
| `consumable_status_mapper.dart` | 소모품 row -> 홈 상태 모델 |

## 15. Store와 Cache

이 프로젝트에는 서버 저장소가 아닌 앱 내부 임시 저장소도 있습니다.

| 파일 | 역할 |
| --- | --- |
| `measure_result_store.dart` | 측정 결과 화면 이동 중 결과 임시 저장 |
| `refresh_result_store.dart` | 리프레시 결과 화면 이동 중 결과 임시 저장 |
| `refresh_history_store.dart` | history 상세 이동용 데이터 보관 |
| `custom_mode_cache.dart` | 커스텀 모드 목록 cache |
| `refresh_recommend_cache.dart` | 추천 결과 cache |
| `home_shortcut_store.dart` | 홈 빠른 실행 모드 저장 |
| `routine_local_store.dart` | 루틴 로컬 저장 |

주의:

- Store/cache는 DB가 아닙니다.
- 앱을 재시작하면 사라질 수 있거나, 로컬 저장 방식에 따라 유지됩니다.
- 중요한 사용자 데이터는 Supabase 또는 명확한 local persistence 정책이 필요합니다.

## 16. 외부 API와 보안

### 16.1 Gemini

관련 파일:

| 파일 | 역할 |
| --- | --- |
| `refresh_recommend_api.dart` | Gemini에게 추천 mode_id 요청 |
| `gemini_recommend_api.dart` | Gemini에게 추천 문구 요청 |
| `refresh_recommend_prompt.dart` | Gemini prompt 생성 |
| `app_env.dart` | Gemini API key 로드 |

주의:

- Gemini API key가 Flutter 앱 asset에 포함되는 구조라면 운영 배포 전 보안 검토가 필요합니다.
- 클라이언트 앱에 secret을 넣으면 사용자가 추출할 수 있습니다.
- 운영에서는 Supabase Edge Function 같은 서버 중계가 더 안전합니다.

### 16.2 날씨

관련 파일:

| 파일 | 역할 |
| --- | --- |
| `weather_api.dart` | 날씨 정보 조회 |
| `environment_snapshot.dart` | 날씨 결과 모델 |
| `weather_recommend_fallback.dart` | 날씨 기반 추천 문구 fallback |

### 16.3 캘린더

관련 파일:

| 파일 | 역할 |
| --- | --- |
| `device_calendar_reader.dart` | 기기 캘린더 읽기 |
| `local_calendar_service.dart` | 로컬 캘린더 연동 관리 |
| `calendar_events_api.dart` | 캘린더 이벤트 Supabase 저장/조회 |
| `local_calendar_connection_store.dart` | 연결 상태 저장 |

추천 모드는 캘린더 일정이 있으면 `weatherAndSchedule` 기준으로 동작할 수 있습니다.

## 17. 주요 사용자 흐름별 백엔드 연결

### 17.1 로그인

```text
LoginScreen
-> AuthApi
-> Supabase Auth / AUTH_USERS
-> AuthUserProfile
-> HomePage
```

### 17.2 홈 진입

```text
HomePage
-> HomeApi.fetchDashboard()
-> DeviceConsumableService
-> RefreshRecommendService.resolve()
-> HomeDashboardData
```

### 17.3 측정

```text
Measure flow
-> MeasureDiagnosisGenerator
-> MeasureApi.insertDiagnosisResult()
-> MEASURE_RESULTS 저장
-> 추천 cache 무효화
-> MeasureRefreshRecommendService
-> MeasureResult
```

### 17.4 추천

```text
RefreshRecommendService
-> 측정/날씨/일정 context 생성
-> REFRESH_MODE 후보 조회
-> Gemini 추천
-> fallback
-> 추천 문구 생성
-> cache 저장
```

### 17.5 리프레시 실행

```text
RefreshDetailPage
-> RefreshProgressPage
-> RefreshSessionResultGenerator
-> RefreshSessionApi
-> REFRESH_SESSIONS 저장
-> RefreshResult
```

### 17.6 기록 확인

```text
HistoryPage
-> HistoryApi
-> MEASURE_RESULTS / REFRESH_SESSIONS 조회
-> HistoryReportBuilder
-> History UI
```

### 17.7 루틴 알림

```text
RoutineRegisterPage
-> RoutineApi / RoutineLocalStore
-> RoutineAlarmScheduler
-> NotificationService
```

## 18. 초보자용 Dart 문법 설명

### 18.1 Future

`Future`는 “나중에 결과가 오는 값”입니다.

```dart
Future<RefreshRecommendResult?> resolve()
```

의미:

- 지금 바로 결과가 있는 것이 아닙니다.
- API 요청이 끝난 뒤 `RefreshRecommendResult` 또는 `null`이 옵니다.

### 18.2 nullable `?`

```dart
RefreshRecommendResult?
```

`?`는 null일 수도 있다는 뜻입니다.

추천 결과가 없으면 `null`이 반환될 수 있습니다.

### 18.3 try/catch

```dart
try {
  final result = await api.fetch();
} catch (_) {
  return fallback;
}
```

API 실패 시 앱이 바로 꺼지지 않도록 예외를 잡습니다.

### 18.4 factory constructor

모델에서 자주 나오는 패턴입니다.

```dart
factory MeasureResultRecord.fromJson(Map<String, dynamic> json) {
  ...
}
```

의미:

- Supabase에서 받은 `Map`을 Dart 객체로 바꿉니다.

### 18.5 enum

정해진 선택지 중 하나를 표현합니다.

```dart
enum RefreshRecommendBasis {
  measure,
  weatherAndSchedule,
  weatherOnly,
}
```

문자열보다 안전합니다.

## 19. 현재 백엔드 리스크

| 리스크 | 설명 |
| --- | --- |
| 실제 측정 알고리즘 부재 | 측정 오염도는 현재 mock 생성기에 가까워 실제 센서/AI 연동이 필요합니다. |
| API key 노출 가능성 | Gemini API key가 클라이언트에 포함되는 구조라면 운영 배포 전 개선이 필요합니다. |
| 한글 인코딩 깨짐 | 일부 코드/문서/문자열이 깨져 있어 prompt와 사용자 문구 품질에 영향을 줄 수 있습니다. |
| `catch (_) {}` 다수 | 실패 원인을 숨겨 디버깅이 어렵습니다. |
| fallback 정책 분산 | 추천 fallback, 측정 fallback, 리프레시 fallback이 여러 파일에 나뉘어 있습니다. |
| Supabase schema 문서 부족 | table/column/RLS 정책이 코드에는 쓰이지만 `supabase/` 폴더가 없는 상태로 보입니다. |
| cache stale 가능성 | 추천 cache가 1시간 유지되어 실제 날씨/측정 상태와 다를 수 있습니다. |
| 로컬 저장과 서버 저장 경계 | 루틴/바로가기/cache 등 어떤 데이터가 영구 저장인지 정책이 더 명확해야 합니다. |

## 20. 개선 제안

1. Supabase schema 문서 복구 또는 작성

```text
tables
columns
RLS policy
seed data
```

이 네 가지를 문서화하면 백엔드 유지보수가 쉬워집니다.

2. Gemini 호출을 서버 중계로 이동

운영 배포에서는 Flutter 앱이 직접 Gemini API key를 들고 있지 않도록 Edge Function 등을 검토합니다.

3. 측정 알고리즘 인터페이스 분리

현재 mock 생성기를 아래처럼 분리하면 실제 센서 연동 시 교체가 쉽습니다.

```text
MeasureDiagnosisGenerator
MockMeasureDiagnosisGenerator
DeviceMeasureDiagnosisGenerator
```

4. error logging 추가

`catch (_) {}` 대신 최소한 개발 모드에서 실패 이유를 알 수 있게 로그를 남깁니다.

5. 추천 정책 단일화

측정 기반 추천 fallback이 날씨만 보는 문제를 줄이려면 추천 정책을 한 파일로 모으는 것이 좋습니다.

6. 백엔드 테스트 강화

우선순위:

```text
mapper 테스트
추천 fallback 테스트
측정 점수 변환 테스트
리프레시 결과 생성 테스트
history report builder 테스트
```

7. table name과 column name 점검

Supabase table은 대문자 이름을 쓰고 있으므로, PostgREST 호출에서 table/column 이름이 정확한지 계속 확인해야 합니다.

## 21. 초보자용 최종 요약

이 앱의 백엔드는 아래처럼 이해하면 됩니다.

```text
core/services
  여러 기능이 같이 쓰는 외부 연결

features/*/data/api
  기능별 서버/API 연결

features/*/data/model
  데이터를 담는 Dart class

*_mapper.dart
  DB/API 데이터를 화면용 데이터로 바꾸는 파일

*_store.dart, *_cache.dart
  앱 안에서 잠깐 보관하는 임시 저장소
```

가장 중요한 원칙:

```text
화면은 API를 직접 알 필요가 없고,
API는 데이터를 가져오고,
model/mapper는 데이터를 앱이 쓰기 좋게 바꾼다.
```

즉, 백엔드 코드는 “데이터를 안전하게 가져오고 저장한 뒤, Flutter 화면이 이해하기 쉬운 Dart 객체로 바꿔주는 층”입니다.
