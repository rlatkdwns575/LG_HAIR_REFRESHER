# LG Hair Refresher 파일별 기능 보고서

작성 기준: 2026-06-22

이 문서는 `lib/` 기준으로 각 Dart 파일이 맡는 역할, 사용한 주요 라이브러리, 핵심 클래스/함수를 백엔드 연결 부분과 프론트 부분으로 나눠 정리합니다.

현재 반영된 변경:

- `lib/shared/widgets/`에서 이전 미사용 후보였던 여러 위젯 파일이 삭제되었습니다.
- `shared_widgets.dart`는 현재 존재하는 shared widget만 export하도록 정리되어 있습니다.
- `Assets/images/home/LOGO.png`, `Assets/images/home/LOGO2.png`는 현재 폴더에 없습니다.
- `supabase/` 로컬 폴더는 없습니다. RLS·테이블 정책은 Supabase 대시보드에서 관리하며, API 권한 오류 메시지도 로컬 SQL 파일을 안내하지 않습니다.

## 1. 먼저 알아야 할 라이브러리

| 라이브러리 | 어디에 쓰이나 | 초보자 설명 |
| --- | --- | --- |
| `package:flutter/material.dart` | 거의 모든 화면/위젯 | 버튼, 텍스트, 화면 배치 등 Flutter 기본 UI 도구입니다. |
| `package:flutter/cupertino.dart` | 일부 iOS 느낌 UI | iOS 스타일 picker나 아이콘을 쓸 때 사용합니다. |
| `package:go_router/go_router.dart` | 라우터, 화면 이동 | `context.go`, `context.push`, `GoRoute`로 화면을 이동합니다. |
| `package:supabase_flutter/supabase_flutter.dart` | Supabase Auth/DB/Realtime | 로그인, 회원가입, DB 조회/저장, 실시간 채널 연결에 사용합니다. |
| `package:http/http.dart` | Gemini, 날씨 API | 외부 서버에 HTTP 요청을 보낼 때 사용합니다. |
| `package:device_calendar/device_calendar.dart` | 로컬 캘린더 | 휴대폰 캘린더 권한, 일정 조회에 사용합니다. |
| `package:flutter_local_notifications/flutter_local_notifications.dart` | 알림 | 루틴 알림, 예약 알림을 띄울 때 사용합니다. |
| `package:timezone/timezone.dart` | 예약 알림 시간 | 로컬 시간대 기준으로 알림 시간을 계산합니다. |
| `package:shared_preferences/shared_preferences.dart` | 로컬 저장 | 간단한 앱 데이터를 휴대폰 안에 저장합니다. |
| `package:url_launcher/url_launcher.dart` | 외부 링크 열기 | 구매 링크나 외부 앱/브라우저를 열 때 사용합니다. |
| `package:flutter_svg/flutter_svg.dart` | SVG 이미지 | LG 로고 같은 SVG 이미지를 화면에 표시합니다. |

## 2. 백엔드 연결 파일

백엔드 연결 파일은 서버, Supabase, 외부 API, 기기 캘린더, 로컬 저장소, 알림처럼 앱 밖의 데이터와 연결되는 코드입니다.

### 2.1 앱 초기화와 전역 서비스

| 파일 | 기능 | 주요 라이브러리/함수 |
| --- | --- | --- |
| `lib/main.dart` | 앱 시작점. Flutter 엔진 준비, 캘린더 플러그인 생성, Supabase 초기화, 알림 초기화, 루틴 알림 재등록 후 앱 실행. | `WidgetsFlutterBinding.ensureInitialized`, `DeviceCalendarPlugin`, `SupabaseService.initialize`, `NotificationService.initialize`, `RoutineAlarmScheduler.rescheduleAll`, `runApp` |
| `lib/core/services/app_env.dart` | `.env` asset을 읽어서 Supabase/Gemini/Weather/dev user id 값을 제공합니다. | `rootBundle.loadString`, `AppEnv.load`, `require`, `optional`, `_parseEnv` |
| `lib/core/services/supabase_service.dart` | Supabase client를 앱 전체에서 한 번만 초기화하고 공유합니다. | `Supabase.initialize`, `Supabase.instance.client`, `AppEnv.supabaseUrl`, `AppEnv.supabasePublishableKey` |
| `lib/core/services/auth_session_service.dart` | 현재 로그인 사용자 id를 찾고, 없으면 `.env`의 개발용 user id를 사용합니다. | `SupabaseService.client.auth.currentUser`, `AppEnv.devUserId` |
| `lib/core/services/notification_service.dart` | 로컬 알림 초기화, 권한 요청, 즉시/예약 알림 등록과 취소를 담당합니다. | `FlutterLocalNotificationsPlugin`, `initialize`, `zonedSchedule`, `cancel`, `requestNotificationsPermission` |

### 2.2 Supabase DB/API 연결

| 파일 | 기능 | 주요 라이브러리/함수 |
| --- | --- | --- |
| `lib/features/auth/data/api/auth_api.dart` | Supabase Auth 로그인/회원가입/로그아웃, 사용자 프로필 조회와 생성. | `signInWithPassword`, `signUp`, `signOut`, `.from(authUsers).select/insert`, `AuthApiException` |
| `lib/core/services/user_profile_service.dart` | 사용자 헤어 프로필 조회/저장/초기 생성. | `.from(authUsers).select/update/insert`, `UserHairProfile.fromJson`, `AuthSessionService.currentUserIdOrDev` |
| `lib/core/services/calendar_events_api.dart` | 캘린더 이벤트를 Supabase에 저장, 조회, 삭제합니다. | `.from(calendarEvents).select/upsert/delete`, `CalendarEvent.fromJson`, `CalendarDayRange` |
| `lib/core/services/device_consumable_service.dart` | 사용자 기기와 소모품 상태를 Supabase에서 조회합니다. | `.from(userDevices)`, `.from(consumableStatus)`, `maybeSingle`, `limit` |
| `lib/features/home/data/api/home_api.dart` | 홈 대시보드 데이터 조회, 기기 상태, 소모품 상태, 최근 리프레시, Realtime 채널 구독. | `.from(refreshSessions/devices/consumableStatus)`, `SupabaseService.client.channel`, `removeChannel`, `HomeApiException` |
| `lib/features/measure/data/api/measure_api.dart` | 측정 결과 저장/조회, 사용자 기본 기기 조회. | `.from(measureResults).insert/select`, `.from(userDevices)`, `MeasureResultRecord.fromJson` |
| `lib/features/refresh/data/api/refresh_api.dart` | 기본 리프레시 모드 목록/상세를 Supabase에서 가져옵니다. | `.from(refreshMode).select`, `RefreshModeMapper.fromJson` |
| `lib/features/refresh/data/api/custom_mode_api.dart` | 커스텀 리프레시 모드 목록, 생성, 삭제를 처리합니다. | `.from(refreshMode).select/insert/delete`, `CustomModeApiException` |
| `lib/features/refresh/data/api/refresh_session_api.dart` | 리프레시 실행 세션 저장과 최근 세션 조회를 담당합니다. | `.from(refreshSessions).select/insert`, `RefreshSessionApiException`, `RefreshSessionOutcome` |
| `lib/features/history/data/api/history_api.dart` | 리프레시/측정 기록, 모드 메타데이터, 사용자/기기 데이터를 조회해 기록 화면에 제공합니다. | `.from(refreshSessions/measureResults/refreshMode/authUsers/userDevices)`, `HistoryApiException` |
| `lib/features/settings/data/api/settings_api.dart` | 설정 화면 사용자 요약, 기기 상세, 소모품 상태 조회/갱신. | `.from(authUsers/userDevices/devices/consumableStatus)`, `SettingsApi` |
| `lib/features/routine/data/api/routine_api.dart` | 루틴 등록 화면에서 사용할 리프레시 모드 옵션을 Supabase에서 조회합니다. | `.from(refreshMode).select`, `RoutineApiException` |

### 2.3 외부 HTTP API 연결

| 파일 | 기능 | 주요 라이브러리/함수 |
| --- | --- | --- |
| `lib/features/home/data/api/weather_api.dart` | 외부 날씨 API를 호출해 현재 환경 데이터를 만듭니다. | `http.get`, `jsonDecode`, `AppEnv.weatherApiKey`, `WeatherApiException` |
| `lib/features/home/data/api/gemini_recommend_api.dart` | Gemini API로 홈/추천 문구를 생성합니다. | `http.post`, `jsonEncode`, `jsonDecode`, `AppEnv.geminiApiKey`, `_postGenerateContent`, `_parseMessage` |

### 2.4 기기/로컬 저장소 연결

| 파일 | 기능 | 주요 라이브러리/함수 |
| --- | --- | --- |
| `lib/core/services/device_calendar_reader.dart` | 휴대폰 로컬 캘린더 권한 확인과 일정 조회. | `DeviceCalendarPlugin`, `retrieveCalendars`, `retrieveEvents`, `CalendarDayRange` |
| `lib/core/services/local_calendar_service.dart` | 로컬 캘린더 연결 상태, 일정 읽기, Supabase 동기화, 일정 분류를 묶어 처리합니다. | `DeviceCalendarReader`, `CalendarEventsApi`, `MeasureScheduleClassifierApi`, `LocalCalendarConnectResult` |
| `lib/core/services/local_calendar_connection_store.dart` | 로컬 캘린더 연결 상태를 저장/조회합니다. | 로컬 상태 저장용 service |
| `lib/core/services/local_calendar_login_prompt.dart` | 로그인/회원가입 뒤 캘린더 연결 유도 흐름을 처리합니다. | `BuildContext`, dialog/navigation 연결 |
| `lib/features/routine/data/api/routine_local_store.dart` | 루틴 목록을 휴대폰 로컬 저장소에 저장합니다. | `SharedPreferences.getInstance`, `jsonEncode`, `jsonDecode`, `Routine.fromJson` |
| `lib/features/routine/data/api/routine_alarm_scheduler.dart` | 저장된 루틴을 읽어 알림을 예약/취소합니다. | `RoutineLocalStore`, `NotificationService`, `NotificationScheduleUtils` |
| `lib/features/home/data/home_shortcut_store.dart` | 홈 바로가기 리프레시 모드를 임시로 메모리에 저장합니다. | static list/cache, `RefreshModeHomeShortcut` extension |
| `lib/features/home/data/home_device_status_watcher.dart` | 홈 기기 상태 변화를 감시하는 watcher 역할입니다. | `supabase_flutter`, stream/channel 성격 |

### 2.5 백엔드 데이터 변환/추천 조립

| 파일 | 기능 | 주요 함수/클래스 |
| --- | --- | --- |
| `lib/features/home/data/api/consumable_status_mapper.dart` | Supabase 소모품 값을 홈 필터 상태로 변환합니다. | `ConsumableStatusMapper` |
| `lib/features/home/data/api/weather_recommend_fallback.dart` | Gemini 실패 시 날씨 기반 기본 추천 문구를 만듭니다. | `WeatherRecommendFallback` |
| `lib/features/measure/data/api/measure_diagnosis_generator.dart` | 측정 분석 단계에서 사용할 샘플 진단 점수를 생성합니다. | `MeasureDiagnosisGenerator`, `MeasureResultInsertPayload` |
| `lib/features/measure/data/api/measure_refresh_recommend_service.dart` | 측정 결과와 통합 추천 서비스를 조합해 최종 `MeasureResult`를 만듭니다. | `MeasureRefreshRecommendService` |
| `lib/features/measure/data/api/measure_result_mapper.dart` | DB 측정 기록을 화면 결과/기록 상세 모델로 변환합니다. | `MeasureResultMapper` |
| `lib/features/measure/data/api/measure_schedule_classifier_api.dart` | 캘린더 일정 내용을 보고 측정 타이밍/카테고리를 분류합니다. | `MeasureScheduleClassifierApi` |
| `lib/features/refresh/data/api/refresh_mode_mapper.dart` | Supabase 리프레시 모드 row를 `RefreshMode`로 변환합니다. | `RefreshModeMapper` |
| `lib/features/refresh/data/api/refresh_recommend_fallback.dart` | 측정·날씨·일정 규칙으로 리프레시 모드를 고릅니다. | `RefreshRecommendFallback` |
| `lib/features/refresh/data/api/refresh_session_result_generator.dart` | 리프레시 실행 후 냄새/먼지 제거율 같은 결과 값을 생성합니다. | `RefreshSessionResultGenerator`, `sampleRemoval` |
| `lib/features/history/data/api/history_measure_mapper.dart` | 측정 결과 row를 history 기록 모델로 변환합니다. | `HistoryMeasureMapper` |
| `lib/features/history/data/api/history_session_mapper.dart` | 리프레시 세션 row를 history 기록 모델로 변환합니다. | `HistorySessionMapper` |
| `lib/features/history/data/api/history_report_builder.dart` | 여러 기록을 오늘/최근/월간/누적 리포트로 가공합니다. | `HistoryReportBuilder` |
| `lib/features/settings/data/api/settings_device_mapper.dart` | Supabase 기기/소모품 row를 설정 화면 모델로 변환합니다. | `SettingsDeviceMapper` |
| `lib/shared/recommendation/refresh_recommend_context_resolver.dart` | 날씨, 측정, 리프레시 세션을 모아 추천 입력 context를 만듭니다. | `WeatherApi`, `MeasureApi`, `RefreshSessionApi` |
| `lib/shared/recommendation/refresh_recommend_service.dart` | 규칙 모드 선택, Gemini 문구, 캐시를 묶은 통합 추천 진입점입니다. | `RefreshRecommendService`, `RefreshRecommendCache`, `GeminiRecommendApi` |
| `lib/shared/recommendation/refresh_recommend_prompt.dart` | Gemini에 보낼 prompt 문자열을 만듭니다. | `jsonEncode`, `RefreshRecommendPrompt` |
| `lib/shared/recommendation/refresh_recommend_cache.dart` | 같은 입력에 대한 추천 결과를 메모리에 캐시합니다. | `RefreshRecommendCache` |

## 3. 프론트 화면/위젯 파일

프론트 파일은 사용자가 보는 화면, 버튼, 카드, 테마, 화면 이동을 담당합니다.

### 3.1 앱 shell, 라우팅, 테마

| 파일 | 기능 | 주요 라이브러리/함수 |
| --- | --- | --- |
| `lib/app/app.dart` | 앱 최상위 위젯. `MaterialApp.router`에 router/theme를 연결하고 하단 safe area를 보정합니다. | `MaterialApp.router`, `MediaQuery`, `math.max`, `AppTheme.light`, `appRouter` |
| `lib/app/router/app_router.dart` | 전체 화면 경로 등록. 로그인, 홈, 측정, 리프레시, 기록, 설정, 루틴 화면을 연결합니다. | `GoRouter`, `ShellRoute`, `GoRoute`, `state.extra`, `context.go` |
| `lib/app/router/app_navigation.dart` | 화면 이동 함수를 `BuildContext` extension으로 제공합니다. | `context.go`, `context.push`, `context.pushNamed`, `context.goNamed` |
| `lib/app/layout/app_layout.dart` | 모바일 화면 최대 폭, 중앙 정렬 shell, 공통 page container입니다. | `AppMaxWidthPageShell`, `AppMaxWidthContainer`, `MediaQuery` |
| `lib/app/layout/app_page_backgrounds.dart` | route별 배경색/배경 스타일을 결정합니다. | `AppPageBackgrounds` |
| `lib/app/navigation/app_system_insets.dart` | 시스템 내비게이션 최소 하단 inset 값 관리. | `AppSystemInsets` |
| `lib/app/theme/app_theme.dart` | 앱 전체 `ThemeData`를 만듭니다. | `ThemeData`, `ColorScheme`, `AppTextStyles` |
| `lib/app/theme/app_colors.dart` | 앱 색상 토큰 모음. | `Color` |
| `lib/app/theme/app_component_colors.dart` | 컴포넌트별 색상 토큰. | `Color` |
| `lib/app/theme/app_text_styles.dart` | Pretendard 기반 텍스트 스타일 모음. | `TextStyle` |
| `lib/app/theme/app_spacing.dart` | 간격 토큰과 ThemeExtension. | `ThemeExtension`, `AppSpacingExtension` |
| `lib/app/theme/app_radius.dart` | 모서리 반경 토큰. | `BorderRadius` |
| `lib/app/theme/app_shadows.dart` | 그림자 스타일 모음. | `BoxShadow` |

### 3.2 Auth 화면

| 파일 | 기능 | 주요 라이브러리/함수 |
| --- | --- | --- |
| `lib/features/auth/ui/page/login_screen.dart` | 로그인 방법 선택 화면. Google 버튼은 개발 계정 로그인으로 대체되어 있고, 이메일 로그인/회원가입으로 이동합니다. | `StatefulWidget`, `AuthApi.signInWithEmail`, `AuthDevCredentials`, `context.go/push`, `Image.asset`, `AppBrandLogo` |
| `lib/features/auth/ui/page/email_login_screen.dart` | 이메일/비밀번호 로그인 화면. 입력값 검증 후 로그인합니다. | `TextEditingController`, `AuthCredentialsValidator`, `AuthApi`, `context.go` |
| `lib/features/auth/ui/page/signup_step_one_screen.dart` | 회원가입 1단계. 이메일/비밀번호 입력과 비밀번호 규칙 검증 후 draft를 다음 단계로 넘깁니다. | `SignUpDraft`, `context.push`, `buildAuthEmailField`, `AuthPasswordRulesChecklist` |
| `lib/features/auth/ui/page/signup_step_two_screen.dart` | 회원가입 2단계. 이름/헤어 프로필/캘린더 연결 후 가입 처리. | `Cupertino`, `AuthApi.signUp`, `HairProfileOptions`, `LocalCalendarLoginPrompt`, `context.go` |
| `lib/features/auth/ui/widgets/auth_screen_widgets.dart` | auth 화면 공통 헤더, 버튼, 입력 필드, 비밀번호 체크리스트. | `AuthCloseHeader`, `AuthSignupProgressLine`, `AuthPrimaryButton`, `buildAuthTextField`, `FilteringTextInputFormatter` |
| `lib/features/auth/ui/widgets/auth_screen_styles.dart` | auth 화면 여백, 색상, 입력 border 등 스타일 상수. | `AuthScreenStyles`, `InputDecoration`, `AppCommonTopHeader` |

### 3.3 Home 화면

| 파일 | 기능 | 주요 라이브러리/함수 |
| --- | --- | --- |
| `lib/features/home/ui/page/home_page.dart` | 홈 대시보드. 기기 상태, 추천, 빠른 리프레시, 최근 측정/기록 이동을 구성합니다. | `StatefulWidget`, `WidgetsBindingObserver`, `HomeApi`, `RefreshRecommendService`, `context.pushMeasure/pushRefresh` |
| `lib/features/home/ui/page/home_refresh_shortcut_add_page.dart` | 홈 바로가기 리프레시 모드 선택/추가 화면. | `RefreshShortcutSelectCard`, `context.pushRefreshCustomCreate`, `Navigator.pop` |
| `lib/features/home/ui/widgets/home_device_status_section.dart` | 홈 상단 기기 이미지, 배터리, 필터 상태 표시. | `StatefulWidget`, `AssetImage`, `Image.asset`, `HomeAssets.batteryIconFor` |
| `lib/features/home/ui/widgets/home_navigation_card.dart` | 홈 메뉴 카드/행 UI. | `HomeActionCard`, `HomeNavigationCard`, `HomeNavigationRow` |
| `lib/features/home/ui/widgets/home_navigation_menu.dart` | 홈의 측정/리프레시/기록 메뉴 묶음. | `HomeNavigationMenu` |
| `lib/features/home/ui/widgets/home_quick_refresh_row.dart` | 빠른 리프레시 카드 가로 목록과 실행/편집 버튼. | `HomeQuickRefreshRow`, `RefreshMode`, `GestureDetector` |
| `lib/features/home/ui/widgets/home_recommend_banner.dart` | 추천 문구 배너와 sparkle 이미지. | `HomeRecommendBanner`, `Image.asset` |
| `lib/features/home/ui/widgets/refresh_shortcut_select_card.dart` | 바로가기 모드 선택 카드. | `RefreshShortcutSelectCard`, `RefreshShortcutSelectState` |

### 3.4 Measure 화면

| 파일 | 기능 | 주요 라이브러리/함수 |
| --- | --- | --- |
| `lib/features/measure/ui/page/measure_hair_profile_page.dart` | 측정 전 헤어 프로필 선택 화면. | `StatefulWidget`, `MeasureHairProfileRadioTile`, `context.pushMeasurePrepare` |
| `lib/features/measure/ui/page/measure_prepare_page.dart` | 측정 준비 단계 화면. 타이머로 안내 단계를 진행합니다. | `Timer`, `MeasurePrepareBody`, `context.pushMeasureRun` |
| `lib/features/measure/ui/page/measure_run_page.dart` | 측정 실행 진행 화면. 진행률 후 분석 화면으로 이동합니다. | `TickerProviderStateMixin`, `AnimationController`, `context.pushReplacementNamed` |
| `lib/features/measure/ui/page/measure_analyzing_page.dart` | 측정 결과 분석 중 화면. 분석 완료 후 결과 화면으로 이동합니다. | `Timer`, `MeasureDiagnosisGenerator`, `MeasureApi`, `MeasureResultStore` |
| `lib/features/measure/ui/page/measure_result_page.dart` | 측정 결과 요약 화면. 추천 리프레시 실행/상세 이동을 제공합니다. | `MeasureResultStore`, `MeasureResultContent`, `context.pushRefreshDetail` |
| `lib/features/measure/ui/page/measure_result_detail_page.dart` | 측정 결과 상세 화면. 지표, 필요도, 추천 모드를 표시합니다. | `MeasureResultDetail.fromMeasureResult`, `MeasureResultDetailContent` |
| `lib/features/measure/ui/widgets/measure_analyzing_illustration.dart` | 분석 중 이미지 영역. | `Image.asset`, `MeasureAssets.analyzingIllustration` |
| `lib/features/measure/ui/widgets/measure_hair_profile_radio_tile.dart` | 헤어 프로필 선택 라디오 타일. | `InkWell`, `Radio`, `AppText` |
| `lib/features/measure/ui/widgets/measure_prepare_body.dart` | 준비 화면 본문 조립. | `MeasurePrepareImageArea`, `MeasurePrepareInstruction`, `MeasureStepIndicator` |
| `lib/features/measure/ui/widgets/measure_prepare_bottom_bar.dart` | 준비 화면 하단 버튼 영역. | `AppFixedBottomButtonArea` |
| `lib/features/measure/ui/widgets/measure_prepare_image_area.dart` | 준비 단계별 이미지 표시. | `Image.asset`, `MeasureAssets.imageForPrepareStep` |
| `lib/features/measure/ui/widgets/measure_prepare_instruction.dart` | 준비 단계별 안내 문구. | `MeasurePrepareStepCopy` |
| `lib/features/measure/ui/widgets/measure_progress_ring.dart` | 측정/분석 진행 원형 그래프. | `CustomPainter`, `Canvas.drawArc`, `MeasureProgressRing` |
| `lib/features/measure/ui/widgets/measure_result_content.dart` | 결과 요약 화면의 전체 content 조립. | `MeasureResultVisual`, `MeasureResultStatusRow`, `RefreshModeCard` |
| `lib/features/measure/ui/widgets/measure_result_detail_content.dart` | 결과 상세 화면 content 조립. | `MeasureResultDetailHeader`, `MeasureResultDetailSummary`, `MeasureResultDetailSectionBlock` |
| `lib/features/measure/ui/widgets/measure_result_detail_header.dart` | 상세 화면 상단 완료 시간/제목. | `formatKoreanCompletionLabel` |
| `lib/features/measure/ui/widgets/measure_result_detail_metric_tile.dart` | 상세 지표 카드. | `AppBadge`, `AppMetricHelpIcon` |
| `lib/features/measure/ui/widgets/measure_result_detail_need_bars.dart` | 리프레시 필요도 막대 그래프. | `CustomPainter`, `_HorizontalBar`, `_DashedVerticalLinePainter` |
| `lib/features/measure/ui/widgets/measure_result_detail_section_badge.dart` | 상세 섹션 상태 badge. | `AppBadge`, `AppColors` |
| `lib/features/measure/ui/widgets/measure_result_detail_section_block.dart` | 냄새/먼지 상세 분석 섹션. | `MeasureResultDetailMetricTile`, `_AnalysisCard` |
| `lib/features/measure/ui/widgets/measure_result_detail_summary.dart` | 상세 상단 요약과 추천 모드 카드. | `MeasureResultMapper`, `RefreshModeCard`, `AppMetricHelpIcon` |
| `lib/features/measure/ui/widgets/measure_result_header.dart` | 결과 화면 상단 header. | `MeasureResultHeader` |
| `lib/features/measure/ui/widgets/measure_result_headline.dart` | 결과 headline 문장 렌더링. | model alias import, `MeasureResultHeadline` |
| `lib/features/measure/ui/widgets/measure_result_refresh_need_summary.dart` | 리프레시 필요도 요약. | `MeasureResultRefreshNeedSummary` |
| `lib/features/measure/ui/widgets/measure_result_visual.dart` | 냄새·먼지 조합별 진단 결과 그래픽 표시. | `MeasureResultVisualMapper`, `Image.asset` |
| `lib/features/measure/ui/widgets/measure_result_status_row.dart` | 냄새/먼지 등 결과 상태 row. | `MeasureResultStatusItem`, `_StatusItem` |
| `lib/features/measure/ui/widgets/measure_step_indicator.dart` | 준비 단계 indicator. | `MeasureStepIndicator`, `_StepDot` |

### 3.5 Refresh 화면

| 파일 | 기능 | 주요 라이브러리/함수 |
| --- | --- | --- |
| `lib/features/refresh/ui/page/refresh_page.dart` | 리프레시 모드 목록, 탭 필터, 커스텀 모드 생성/삭제 흐름. | `RefreshApi`, `CustomModeApi`, `RefreshModeCard`, `context.pushRefreshDetail` |
| `lib/features/refresh/ui/page/refresh_detail_page.dart` | 리프레시 모드 상세와 실행 시작 화면. | `RefreshDetailTimeline`, `RefreshAssets.trashIcon`, `context.pushRefreshProgress` |
| `lib/features/refresh/ui/page/refresh_progress_page.dart` | 리프레시 실행 진행 화면. 진행 완료 후 결과 수집 화면으로 이동합니다. | `Timer`, `RefreshProgressSession`, `RefreshSessionApi`, `context.pushReplacementNamed` |
| `lib/features/refresh/ui/page/refresh_result_collecting_page.dart` | 결과 수집 중 화면. 일정 시간 뒤 결과 화면으로 이동합니다. | `Timer`, `RefreshResultCollectingIllustration` |
| `lib/features/refresh/ui/page/refresh_result_page.dart` | 리프레시 결과 요약 화면. 재실행/상세/홈 이동. | `RefreshResultStore`, `RefreshResultContent`, `context.pushRefreshResultDetail` |
| `lib/features/refresh/ui/page/refresh_result_detail_page.dart` | 리프레시 결과 상세 화면. | `RefreshResultDetailContent`, fallback page |
| `lib/features/refresh/ui/page/refresh_custom_create_page.dart` | 커스텀 리프레시 모드 생성 화면. | `StatefulWidget`, chips, duration picker, `CustomModeApi` |
| `lib/features/refresh/ui/refresh_scent_unavailable.dart` | 향 케어 불가 상태 안내 UI. | `RefreshScentUnavailable` |
| `lib/features/refresh/ui/widgets/duration_badge.dart` | 소요 시간 badge. | `DurationBadge` |
| `lib/features/refresh/ui/widgets/refresh_detail_timeline.dart` | 상세 화면 단계 timeline. | `RefreshDetailTimeline`, `_TimelineStepRow` |
| `lib/features/refresh/ui/widgets/refresh_mode_card.dart` | 리프레시 모드 카드. 기본/추천/커스텀 상태를 표시합니다. | `RefreshModeCard`, `Image.asset`, `_CardShell`, `_ArrowButton` |
| `lib/features/refresh/ui/widgets/refresh_progress_ring.dart` | 리프레시 진행 원형 그래프. | `CustomPainter`, `RefreshProgressRing` |
| `lib/features/refresh/ui/widgets/refresh_progress_status_section.dart` | 진행 중 현재 단계/남은 시간 표시. | `RefreshProgressStatusSection` |
| `lib/features/refresh/ui/widgets/refresh_progress_step_strip.dart` | 진행 단계 가로 strip. | `RefreshProgressStepStrip`, `_StepColumn` |
| `lib/features/refresh/ui/widgets/refresh_result_change_chart.dart` | 리프레시 전후 변화 차트. | `CustomPainter`, `RefreshResultChangeChart` |
| `lib/features/refresh/ui/widgets/refresh_result_collecting_illustration.dart` | 결과 수집 이미지. | `Image.asset`, `RefreshAssets.collectingIllustration` |
| `lib/features/refresh/ui/widgets/refresh_result_content.dart` | 결과 요약 content 조립. | `RefreshResultHeader`, `RefreshResultHeadline`, `RefreshResultChangeChart` |
| `lib/features/refresh/ui/widgets/refresh_result_detail_content.dart` | 결과 상세 content 조립. | `RefreshResultDetailMetricBars`, `RefreshResultDetailStatusSection` |
| `lib/features/refresh/ui/widgets/refresh_result_detail_metric_bars.dart` | 결과 상세 냄새/먼지/필요도 막대. | `CustomPainter`, `_DashedLinePainter` |
| `lib/features/refresh/ui/widgets/refresh_result_detail_status_section.dart` | 결과 상세 상태 변화/인사이트/헤어 지표. | `CustomPainter`, `_FilledTriangleArrowPainter` |
| `lib/features/refresh/ui/widgets/refresh_result_header.dart` | 결과 화면 header. | `RefreshResultHeader` |
| `lib/features/refresh/ui/widgets/refresh_result_headline.dart` | 결과 headline 표시. | `RefreshResultHeadline` |
| `lib/features/refresh/ui/widgets/refresh_section_header.dart` | 리프레시 섹션 제목 row. | `RefreshSectionHeader` |

### 3.6 History 화면

| 파일 | 기능 | 주요 라이브러리/함수 |
| --- | --- | --- |
| `lib/features/history/ui/page/history_page.dart` | 기록 메인 화면. 오늘/최근/누적 탭과 상세 이동, 루틴 등록 이동을 처리합니다. | `HistoryApi`, `RefreshHistoryStore`, `context.pushMeasureHistoryRecordDetail`, `context.pushRoutineRegister` |
| `lib/features/history/ui/widgets/history_today_section.dart` | 오늘의 기록과 루틴 추천 카드. | `HistoryTodaySection`, `Image.asset`, `_TodayRecordTile` |
| `lib/features/history/ui/widgets/history_recent_section.dart` | 최근 기록, 월 이동, 선택 날짜 기록 표시. | `HistoryRecentSection`, `HistoryMonthCalendar` |
| `lib/features/history/ui/widgets/history_total_section.dart` | 누적 통계, 시간대 차트, 모드 사용량 그래프. | `CustomPainter`, `_ClockDonutPainter`, `_StackedBar` |
| `lib/features/history/ui/widgets/history_month_calendar.dart` | 월간 달력 UI. | `HistoryMonthCalendar`, `_DayCell`, `_DayCountIndicator` |
| `lib/features/history/ui/widgets/history_month_picker.dart` | 연/월 선택 picker UI. | picker field, `DateTime` |
| `lib/features/history/ui/widgets/history_care_badge.dart` | 케어 상태 badge, 상태 변화 arrow, 그룹 row. | `HistoryCareBadge`, `HistoryStatusArrow`, `HistoryCareStatusGroup` |
| `lib/features/history/ui/widgets/history_common.dart` | 기록 화면 공통 텍스트, 카드, divider, 상세 링크. | `HistoryWhiteCard`, `HistoryDeltaText`, `HistoryDetailLink` |

### 3.7 Settings 화면

| 파일 | 기능 | 주요 라이브러리/함수 |
| --- | --- | --- |
| `lib/features/settings/ui/page/settings_page.dart` | 설정 메인 화면. 프로필, 기기 관리, 캘린더, 루틴, 로그아웃 이동. | `SettingsApi`, `AuthApi.signOut`, `context.pushDeviceManage`, `context.pushRoutineList` |
| `lib/features/settings/ui/page/device_manage_page.dart` | 기기 상세/소모품/향 카트리지 관리 화면. 외부 구매 링크도 엽니다. | `url_launcher`, `launchUrl`, `SettingsApi`, `DeviceManageStatusPanel` |
| `lib/features/settings/ui/page/local_calendar_settings_page.dart` | 로컬 캘린더 연결/해제/동기화 상태 화면. | `LocalCalendarService`, `LocalCalendarConnectResult`, `_ConnectionHero` |
| `lib/features/settings/ui/widgets/settings_section_card.dart` | 설정 섹션 카드, divider, list tile. | `SettingsSectionCard`, `SettingsListTile`, `AppListItem` |
| `lib/features/settings/ui/widgets/settings_profile_card.dart` | 설정 상단 사용자 프로필 카드. | `SettingsProfileCard`, `SettingsUserSummary` |
| `lib/features/settings/ui/widgets/device_manage_status_panel.dart` | 기기 이미지, 연결 상태, 배터리/필터/향 카트리지 상태 패널. | `Image.asset`, `ScentCartridgeMapper`, `DeviceManageInfoRow` |
| `lib/features/settings/ui/widgets/device_manage_scent_guide.dart` | 향 카트리지 상태와 향 타입 가이드. | `StatefulWidget`, `ScentCategory`, `ScentCategoryDescriptions` |

### 3.8 Routine 화면

| 파일 | 기능 | 주요 라이브러리/함수 |
| --- | --- | --- |
| `lib/features/routine/ui/page/routine_list_page.dart` | 루틴 목록 화면. 등록/수정/삭제와 알림 재예약을 처리합니다. | `RoutineLocalStore`, `RoutineAlarmScheduler`, `context.pushRoutineRegister` |
| `lib/features/routine/ui/page/routine_register_page.dart` | 루틴 등록/수정 화면. 모드, 시간, 요일, 알림 on/off를 선택합니다. | `RoutineApi`, `RoutineTimePicker`, `RoutineModePicker`, `RoutineWeekdayPicker` |
| `lib/features/routine/ui/widgets/routine_mode_picker.dart` | 루틴 모드 선택 UI. | `RoutineModeOption` |
| `lib/features/routine/ui/widgets/routine_time_picker.dart` | 시간 선택 bottom sheet/wheel picker. | `CupertinoPicker` 성격, `_RoutineTimePickerSheet`, `_Wheel` |
| `lib/features/routine/ui/widgets/routine_weekday_picker.dart` | 요일 선택 chip UI. | `RoutineWeekdayPicker`, `_WeekdayChip` |

### 3.9 Shared 공통 위젯

| 파일 | 기능 | 주요 클래스/함수 |
| --- | --- | --- |
| `lib/shared/widgets/app_text.dart` | 공통 텍스트 위젯. 깨진 문자열 보정 extension과 같이 쓰입니다. | `AppText` |
| `lib/shared/widgets/app_badge.dart` | small/large badge 공통 컴포넌트. | `AppBadge`, `AppBadgeSize`, `AppBadgeStyle` |
| `lib/shared/widgets/app_battery_status.dart` | 배터리 퍼센트와 상태 아이콘 표시. | `AppBatteryStatus`, `Image.asset` |
| `lib/shared/widgets/app_bottom_button_bar.dart` | 하단 1개/2개 버튼 bar. | `AppBottomButtonBar`, `AppBottomButtonBarType` |
| `lib/shared/widgets/app_box_button.dart` | 박스 형태 버튼. | `AppBoxButton`, `AppBoxButtonSize`, `AppBoxButtonVariant` |
| `lib/shared/widgets/app_brand_logo.dart` | SVG 브랜드 로고 표시. | `SvgPicture.asset`, `AppBrandLogo` |
| `lib/shared/widgets/app_calendar_day_strip.dart` | 일 단위 캘린더 strip. | `AppCalendarDayStrip`, `AppCalendarDayCell` |
| `lib/shared/widgets/app_calendar_item.dart` | 캘린더 항목 카드. | `AppCalendarItem` |
| `lib/shared/widgets/app_calendar_week_strip.dart` | 주 단위 캘린더 strip. | `AppCalendarWeekStrip`, `AppCalendarWeekCell` |
| `lib/shared/widgets/app_capsule_button.dart` | 캡슐 형태 텍스트 버튼. | `AppCapsuleButton` |
| `lib/shared/widgets/app_capsule_icon_button.dart` | 캡슐 형태 아이콘 버튼. | `AppCapsuleIconButton` |
| `lib/shared/widgets/app_checkbox.dart` | 공통 checkbox UI. | `AppCheckbox`, `AppCheckboxSize` |
| `lib/shared/widgets/app_chip_tab_bar.dart` | chip 형태 탭 bar. | `AppChipTabBar`, `AppChipTabBarShell` |
| `lib/shared/widgets/app_common_top_header.dart` | 여러 화면에서 쓰는 상단 header. | `AppCommonTopHeader`, `_HeaderBackButton`, `_HeaderIconButton` |
| `lib/shared/widgets/app_confirm_dialog.dart` | 확인/취소 dialog. | `AppConfirmDialog` |
| `lib/shared/widgets/app_fixed_bottom_button_area.dart` | 하단 고정 버튼 영역. | `AppFixedBottomButtonArea`, `AppBottomButtonLayout` |
| `lib/shared/widgets/app_list_item.dart` | 설정/목록 row item. | `AppListItem`, `AppListItemVariant` |
| `lib/shared/widgets/app_metric_help_icon.dart` | 지표 설명 tooltip 아이콘. | `AppMetricHelpIcon`, `SvgPicture.string` |
| `lib/shared/widgets/app_radio.dart` | generic radio UI. | `AppRadio<T>` |
| `lib/shared/widgets/app_recommend_card.dart` | 추천 카드. | `AppRecommendCard`, `GradientBoxBorder` |
| `lib/shared/widgets/app_search_text_field.dart` | 검색 입력창. | `AppSearchTextField` |
| `lib/shared/widgets/app_section_divider.dart` | 상세 화면 divider와 horizontal padding helper. | `AppSectionDivider`, `DetailPageHorizontalPadding` |
| `lib/shared/widgets/app_section_title.dart` | 섹션 제목. | `AppSectionTitle` |
| `lib/shared/widgets/app_text_field.dart` | 공통 텍스트 필드. | `AppTextField`, `AppTextFieldState` |
| `lib/shared/widgets/app_text_link_button.dart` | 텍스트 링크 버튼. | `AppTextLinkButton` |
| `lib/shared/widgets/app_toggle.dart` | 토글 스위치 UI. | `AppToggle`, `AppToggleSize` |
| `lib/shared/widgets/shared_widgets.dart` | shared widget barrel export. 현재 존재하는 shared widget 파일만 한 번에 export합니다. | `export ...` |

## 4. 공통 모델/순수 로직 파일

이 파일들은 화면도 아니고 서버 연결도 아닙니다. 데이터 모양, 상수, 계산, mapper, 저장소 역할입니다.

### 4.1 Core 상수/유틸/모델

| 파일 | 기능 | 주요 클래스/함수 |
| --- | --- | --- |
| `lib/core/constants/route_paths.dart` | 전체 route path/name 상수. | `AppRoutePaths`, `AppRouteNames` |
| `lib/core/constants/image_assets.dart` | 이미지 asset 경로 상수와 배터리 아이콘 상태 계산. | `ImageAssets`, `resolveHomeBatteryIconState`, `homeBatteryIconFor` |
| `lib/core/constants/supabase_tables.dart` | Supabase table 이름 상수. | `SupabaseTables` |
| `lib/core/constants/external_urls.dart` | 외부 링크 URL 상수. | `ExternalUrls` |
| `lib/core/constants/hair_profile_options.dart` | 헤어 프로필 선택지 상수. | `HairProfileOptions` |
| `lib/core/models/user_hair_profile.dart` | 사용자 헤어 프로필 데이터 모델. | `UserHairProfile`, `fromJson`, `toJson`, `copyWith` |
| `lib/core/extensions/string_extension.dart` | 문자열 표시 보정 extension. | `StringExtension` |
| `lib/core/utils/calendar_day_range.dart` | 하루 시작/끝 범위 계산. | `CalendarDayRange` |
| `lib/core/utils/korean_date_time_format.dart` | 한국어 날짜/시간 표시 문자열 생성. | `formatKoreanTime`, `formatKoreanDateWithWeekday`, `formatKoreanCompletionLabel` |
| `lib/core/utils/notification_schedule_utils.dart` | 알림 예약 시간 계산. | timezone 기반 utility |
| `lib/core/utils/session_end_time.dart` | 시작 시간과 duration으로 종료 시간 계산. | `SessionEndTime` |
| `lib/core/utils/stable_calendar_event_id.dart` | 캘린더 이벤트의 안정적인 id 생성. | `dart:convert`, `stableCalendarEventId` |

### 4.2 Auth 데이터

| 파일 | 기능 | 주요 클래스/함수 |
| --- | --- | --- |
| `lib/features/auth/data/auth_assets.dart` | auth 이미지 경로 wrapper. | `AuthAssets.googleIcon` |
| `lib/features/auth/data/auth_credentials_validator.dart` | 이메일/비밀번호 규칙 검사. | `AuthCredentialsValidator`, `PasswordRuleId`, `PasswordRuleStatus` |
| `lib/features/auth/data/auth_dev_credentials.dart` | 개발용 로그인 계정 정보. | `AuthDevCredentials` |
| `lib/features/auth/data/model/auth_user_profile.dart` | 인증 사용자 프로필 모델. | `AuthUserProfile`, `fromJson` |
| `lib/features/auth/data/model/sign_up_draft.dart` | 회원가입 단계 사이에서 넘기는 임시 입력 데이터. | `SignUpDraft` |

### 4.3 Home 데이터

| 파일 | 기능 | 주요 클래스/함수 |
| --- | --- | --- |
| `lib/features/home/data/home_assets.dart` | 홈 이미지 경로 wrapper. | `HomeAssets`, `batteryIconFor` |
| `lib/features/home/data/model/environment_snapshot.dart` | 날씨/환경 정보 모델. | `EnvironmentSnapshot` |
| `lib/features/home/data/model/home_dashboard_data.dart` | 홈 화면 전체 데이터 모델. | `HomeDashboardData`, `HomeQuickRefreshMode`, `HomeQuickRefreshSlot` |
| `lib/features/home/data/model/home_device_status_snapshot.dart` | 홈 기기 상태 스냅샷. | `HomeDeviceStatusSnapshot` |
| `lib/features/home/data/model/home_filter_status.dart` | 필터 상태 모델과 등급 enum. | `HomeFilterStatus`, `HomeFilterStatusTier` |

### 4.4 Measure 데이터

| 파일 | 기능 | 주요 클래스/함수 |
| --- | --- | --- |
| `lib/features/measure/data/measure_assets.dart` | 측정 화면 이미지 경로 wrapper. | `MeasureAssets.imageForPrepareStep` |
| `lib/features/measure/data/measure_result_headline_builder.dart` | 측정 결과 headline 생성. | `MeasureResultHeadlineBuilder` |
| `lib/features/measure/data/measure_result_store.dart` | 측정 결과 임시 보관. | `MeasureResultStore` |
| `lib/features/measure/data/measure_result_visual_mapper.dart` | 냄새/먼지 조합을 결과 이미지로 매핑. | `MeasureResultVisualMapper` |
| `lib/features/measure/data/model/measure_care_level.dart` | 측정 케어 수준 enum. | `MeasureCareLevel` |
| `lib/features/measure/data/model/measure_prepare_step.dart` | 측정 준비 단계 enum. | `MeasurePrepareStep`, `MeasurePrepareStepIndex` |
| `lib/features/measure/data/model/measure_prepare_step_copy.dart` | 준비 단계별 안내 문구 모델. | `MeasurePrepareStepCopy` |
| `lib/features/measure/data/model/measure_result.dart` | 측정 결과 화면 모델. | `MeasureResult`, sample 데이터 |
| `lib/features/measure/data/model/measure_result_detail.dart` | 측정 결과 상세 모델. | `MeasureResultDetail.fromMeasureResult` |
| `lib/features/measure/data/model/measure_result_detail_metric.dart` | 상세 지표 모델. | `MeasureResultDetailMetric` |
| `lib/features/measure/data/model/measure_result_detail_section.dart` | 상세 섹션 모델. | `MeasureResultDetailSection` |
| `lib/features/measure/data/model/measure_result_headline.dart` | headline 텍스트 조각 모델. | `MeasureResultHeadline` |
| `lib/features/measure/data/model/measure_result_record.dart` | Supabase 측정 결과 row 모델. | `MeasureResultRecord`, `fromJson`, `toInsertJson`, `toPromptJson` |
| `lib/features/measure/data/model/measure_result_status_item.dart` | 결과 상태 row item 모델. | `MeasureResultStatusItem` |
| `lib/features/measure/data/model/measure_result_view_type.dart` | 결과 view type enum. | `MeasureResultViewType` |
| `lib/features/measure/data/model/measure_run_stage.dart` | 측정 실행 단계 enum. | `MeasureRunStage` |
| `lib/features/measure/data/model/schedule_category.dart` | 일정 카테고리 enum. | `ScheduleCategory` |
| `lib/features/measure/data/model/schedule_timing.dart` | 일정 타이밍 enum. | `ScheduleTiming` |

### 4.5 Refresh 데이터

| 파일 | 기능 | 주요 클래스/함수 |
| --- | --- | --- |
| `lib/features/refresh/data/care_duration_split.dart` | 케어 강도별 시간 배분 계산. | `CareIntensity`, `CareDurationSplit` |
| `lib/features/refresh/data/custom_mode_cache.dart` | 커스텀 모드 메모리 캐시. | `CustomModeCache` |
| `lib/features/refresh/data/refresh_assets.dart` | 리프레시 이미지 경로 wrapper. | `RefreshAssets` |
| `lib/features/refresh/data/refresh_mode_availability.dart` | 향 카트리지 상태 등에 따른 모드 사용 가능 여부 계산. | availability helpers |
| `lib/features/refresh/data/refresh_mode_catalog.dart` | 기본 리프레시 모드 catalog. | `RefreshMode` 목록 |
| `lib/features/refresh/data/refresh_mode_filter.dart` | 탭/조건별 모드 필터링. | `RefreshModeFilter` |
| `lib/features/refresh/data/refresh_result_detail_mapper.dart` | 결과 요약을 상세 모델로 변환. | `RefreshResultDetailMapper` |
| `lib/features/refresh/data/refresh_result_headline_builder.dart` | 리프레시 결과 headline 생성. | `RefreshResultHeadlineBuilder` |
| `lib/features/refresh/data/refresh_result_store.dart` | 리프레시 결과 임시 보관. | `RefreshResultStore` |
| `lib/features/refresh/data/refresh_route_extra.dart` | `GoRouter` extra 값을 `RefreshMode`/상세 결과로 해석. | `resolveRefreshMode`, `resolveRefreshResultDetail` |
| `lib/features/refresh/data/model/refresh_mode.dart` | 리프레시 모드 모델. | `RefreshMode`, `RefreshModeTabs` |
| `lib/features/refresh/data/model/refresh_mode_detail.dart` | 리프레시 상세 단계/태그 모델. | `RefreshModeDetail`, `RefreshModeDetailStep`, `RefreshModeDetailCareTag` |
| `lib/features/refresh/data/model/refresh_pollution_level.dart` | 오염도 enum. | `RefreshPollutionLevel` |
| `lib/features/refresh/data/model/refresh_progress_session.dart` | 리프레시 진행 세션과 단계 계산. | `RefreshProgressSession`, `RefreshProgressStep` |
| `lib/features/refresh/data/model/refresh_result.dart` | 리프레시 결과 요약 모델. | `RefreshResult`, sample |
| `lib/features/refresh/data/model/refresh_result_change.dart` | 수치 변화 모델. | `RefreshResultChange` |
| `lib/features/refresh/data/model/refresh_result_detail.dart` | 리프레시 결과 상세 모델. | `RefreshResultDetail`, `RefreshResultMetricPair`, `RefreshResultStatusSection` |
| `lib/features/refresh/data/model/refresh_session_outcome.dart` | 리프레시 세션 저장 결과 모델. | `RefreshSessionOutcome`, `RefreshSessionScores` |

### 4.6 History 데이터

| 파일 | 기능 | 주요 클래스/함수 |
| --- | --- | --- |
| `lib/features/history/data/history_assets.dart` | history 이미지 경로 wrapper. | `HistoryAssets.calendarIcon` |
| `lib/features/history/data/refresh_history_store.dart` | history report 임시 상태 저장. | `RefreshHistoryStore` |
| `lib/features/history/data/model/care_status.dart` | 기록 상태 enum과 badge 매핑. | `CareStatus` |
| `lib/features/history/data/model/refresh_history_record.dart` | 개별 기록 모델. | `RefreshHistoryRecord`, `CareType` |
| `lib/features/history/data/model/refresh_history_report.dart` | history 화면 전체 리포트 모델. | `RefreshHistoryReport`, `RefreshMonthlySummary`, `RefreshTotalSummary`, sample |

### 4.7 Settings/Routine/Shared 데이터

| 파일 | 기능 | 주요 클래스/함수 |
| --- | --- | --- |
| `lib/features/settings/data/model/settings_device_detail.dart` | 설정 기기 상세 모델. | `SettingsDeviceDetail` |
| `lib/features/settings/data/model/settings_user_summary.dart` | 설정 사용자 요약 모델. | `SettingsUserSummary` |
| `lib/features/routine/data/model/routine.dart` | 루틴 모델, 요일, 모드 옵션. | `Routine`, `RoutineWeekday`, `RoutineModeOption`, `fromJson`, `toJson` |
| `lib/shared/models/calendar_event.dart` | 캘린더 이벤트 모델. | `CalendarEvent`, `fromJson`, `toJson` |
| `lib/shared/models/local_calendar_status.dart` | 로컬 캘린더 연결 상태 모델. | `LocalCalendarStatus` |
| `lib/shared/models/scent_cartridge_status.dart` | 향 카트리지 상태 모델. | `ScentCartridgeStatus` |
| `lib/shared/models/scent_category.dart` | 향 카테고리 enum. | `ScentCategory` |
| `lib/shared/utils/metric_badge_mapper.dart` | 지표 값에 따른 badge 표시 변환. | `MetricBadgeMapper` |
| `lib/shared/utils/scent_cartridge_mapper.dart` | 향 카트리지 상태/카테고리 표시 변환. | `ScentCartridgeMapper` |
| `lib/shared/recommendation/refresh_recommend_basis.dart` | 추천 근거 enum과 label. | `RefreshRecommendBasis`, extension |
| `lib/shared/recommendation/refresh_recommend_input.dart` | 추천 입력 context 모델. | `RefreshRecommendInput` |
| `lib/shared/recommendation/refresh_recommend_result.dart` | 추천 결과 모델. | `RefreshRecommendResult` |
| `lib/shared/recommendation/refresh_recommend_schedule_snapshot.dart` | Gemini prompt용 일정 스냅샷. | `RefreshRecommendScheduleSnapshot`, `RefreshRecommendScheduleEventSnapshot` |

## 5. 백엔드와 프론트가 만나는 흐름

### 로그인

1. `login_screen.dart` 또는 `email_login_screen.dart`
2. `AuthApi`
3. `SupabaseService.client.auth`
4. 성공 시 `context.go(AppRoutePaths.home)`

### 홈

1. `home_page.dart`
2. `HomeApi`, `RefreshRecommendService`
3. Supabase/Weather/Gemini 조회
4. `HomeDeviceStatusSection`, `HomeRecommendBanner`, `HomeQuickRefreshRow`로 표시

### 측정

1. `measure_*_page.dart`
2. `MeasureDiagnosisGenerator`, `MeasureApi`, `MeasureRefreshRecommendService`
3. Supabase 저장, Gemini 추천 조합
4. `MeasureResultContent`, `MeasureResultDetailContent`로 표시

### 리프레시

1. `refresh_page.dart`, `refresh_progress_page.dart`
2. `RefreshApi`, `RefreshSessionApi`, `CustomModeApi`
3. Supabase 모드/세션 저장
4. `RefreshResultContent`, `RefreshResultDetailContent`로 표시

### 기록

1. `history_page.dart`
2. `HistoryApi`
3. `HistoryReportBuilder`
4. 오늘/최근/누적 history 위젯으로 표시

## 6. 주의할 파일

| 파일 | 이유 |
| --- | --- |
| `lib/core/services/app_env.dart` | `.env`를 asset으로 읽기 때문에 운영 secret 노출 위험이 있습니다. |
| `lib/features/auth/data/auth_dev_credentials.dart` | 개발용 계정 정보가 실제 로그인 버튼에서 쓰입니다. 운영 전 제거/분리 검토가 필요합니다. |
| `lib/shared/widgets/shared_widgets.dart` | barrel export 파일입니다. 현재 export 대상은 존재하는 파일로 정리되어 있습니다. |