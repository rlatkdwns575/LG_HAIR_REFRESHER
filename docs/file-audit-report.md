# LG Hair Refresher 파일 점검 보고서

작성 기준: 2026-06-21, `D:\lg_hair_refresher`

## 1. 결론 요약

현재 앱은 Flutter/Dart 모바일 앱이며, 실제 실행 흐름은 `lib/main.dart` -> `lib/app/app.dart` -> `lib/app/router/app_router.dart` -> 각 feature 화면으로 이어집니다.

바로 삭제 대상으로 볼 수 있는 것은 대부분 코드가 아니라 빌드 산출물, 크래시 로그, 로컬 IDE/Gradle 캐시입니다. 반대로 `lib/`, `Assets/`, `test/`, 플랫폼 폴더(`android/`, `ios/`, `web/`, `windows/`, `macos/`, `linux/`)는 앱 구동과 직접 관련이 있으므로 초보자 기준에서는 함부로 삭제하면 안 됩니다.

주의할 점:

- `README.md`, `docs/decisions/*`, `docs/conventions/*`, `tests/README.md`, 일부 테스트 기대 문자열에 한글이 깨진 문자가 있습니다. 더미 파일은 아니지만 문서 품질 정리 대상입니다.
- `pubspec.yaml`은 `assets/...` 소문자 경로를 등록하고 있지만 실제 폴더명은 `Assets/` 대문자입니다. Windows에서는 동작할 수 있으나, 대소문자를 구분하는 빌드 환경에서는 asset 로딩 문제가 날 수 있습니다.
- `.env`가 앱 asset으로 포함되어 있습니다. Flutter 앱에 포함되는 asset은 최종 앱 패키지에 들어가므로 production secret을 넣으면 안 됩니다.
- `flutter analyze`, `dart analyze`는 각각 5분/3분 타임아웃으로 완료되지 않았습니다. 정적 참조 검토 기준의 보고서이며, analyzer 기반의 최종 미사용 판정은 아직 못 했습니다.

## 2. 폴더별 역할

### 루트 폴더

| 경로 | 역할 | 삭제 판단 |
| --- | --- | --- |
| `AGENTS.md` | AI Agent 작업 규칙. 프로젝트 구조, 금지 사항, 검증 명령을 정의합니다. | 유지 |
| `README.md` | 프로젝트 소개 문서. 현재 한글 인코딩이 깨져 있어 복구 필요. | 유지, 내용 복구 |
| `pubspec.yaml` | Flutter 패키지 설정. 의존성, asset, font 등록 위치입니다. | 유지 |
| `pubspec.lock` | 설치된 패키지 버전 잠금 파일. 앱 재현 빌드에 중요합니다. | 유지 |
| `analysis_options.yaml` | Dart/Flutter lint 규칙. 코드 품질 검사 기준입니다. | 유지 |
| `.env` | Supabase, 외부 API 키 등 로컬 실행 설정. 현재 앱 asset으로 읽습니다. | 로컬 유지, 커밋 금지 |
| `.env.example` | `.env` 작성 예시. 협업자에게 필요한 샘플입니다. | 유지 |
| `.gitignore` | Git에 올리지 않을 파일 규칙. | 유지 |
| `.metadata` | Flutter 프로젝트 메타데이터. | 유지 |
| `LICENSE` | 라이선스 문서. | 유지 |
| `.cursor/` | Cursor 규칙과 보조 skill 문서. 개발 도구용입니다. | 팀 사용 시 유지 |
| `.idea/`, `*.iml` | IntelliJ/Android Studio 로컬 설정. | 보통 Git 제외/정리 후보 |
| `.dart_tool/` | Flutter/Dart가 만든 로컬 캐시. | 삭제 가능, 자동 재생성 |
| `build/` | 빌드 결과물. | 삭제 가능, 자동 재생성 |
| `release/` | 릴리스 APK와 빌드 로그. 배포 파일 보관용이면 유지, 아니면 Git 제외 대상. | 보류 |

### `lib/`

앱의 실제 Dart 코드입니다. 삭제하면 앱 기능이 깨질 가능성이 가장 큽니다.

| 폴더 | 역할 |
| --- | --- |
| `lib/main.dart` | 앱 시작점입니다. Flutter 초기화, Supabase 초기화, 알림 초기화, 루틴 알람 재등록 후 `runApp`을 호출합니다. |
| `lib/app/` | 앱 전체 설정입니다. `MaterialApp`, 라우터, 테마, 화면 최대 너비, 시스템 inset 처리를 담당합니다. |
| `lib/core/` | 여러 feature가 같이 쓰는 상수, 서비스, 유틸, 확장 메서드입니다. |
| `lib/features/` | 기능 단위 코드입니다. auth, home, measure, refresh, history, settings, routine이 있습니다. |
| `lib/shared/` | 여러 feature에서 공통으로 쓰는 모델, 추천 로직, UI 위젯입니다. |

### `lib/app/`

| 경로 | 역할 |
| --- | --- |
| `app.dart` | `LgHairRefresherApp`. Flutter의 최상위 앱 위젯입니다. 라우터와 테마를 연결합니다. |
| `router/app_router.dart` | `go_router` 라우팅 테이블입니다. 어떤 URL 경로가 어떤 화면으로 갈지 정합니다. |
| `router/app_navigation.dart` | `BuildContext`에 화면 이동 함수를 붙인 extension입니다. |
| `layout/app_layout.dart` | 앱 화면 최대 너비와 공통 shell 레이아웃을 담당합니다. |
| `layout/app_page_backgrounds.dart` | 화면별 배경 스타일 헬퍼입니다. |
| `navigation/app_system_insets.dart` | 하단 시스템 내비게이션 높이 보정값을 관리합니다. |
| `theme/*` | 색상, 글꼴, 간격, 반경, 그림자, `ThemeData`를 관리합니다. 화면에서 색상값을 직접 반복하지 않게 해줍니다. |

초보자 설명:

- `MaterialApp.router`는 Flutter 앱의 큰 껍데기입니다.
- `GoRouter`는 버튼을 눌렀을 때 어느 화면으로 갈지 정하는 길 안내표입니다.
- `ThemeData`는 앱 전체 색상/폰트/버튼 스타일의 기본값입니다.

### `lib/core/`

| 폴더 | 역할 |
| --- | --- |
| `constants/` | route path, 이미지 경로, Supabase table name, 외부 URL, 헤어 프로필 선택지입니다. |
| `models/` | 여러 feature가 공유하는 핵심 데이터 모델입니다. 현재 `UserHairProfile`이 있습니다. |
| `services/` | Supabase, 알림, 캘린더, 유저 프로필, 환경변수 같은 앱 전역 서비스입니다. |
| `utils/` | 날짜 범위, 세션 종료 시간, 알림 시간 계산 같은 순수 계산 도구입니다. |
| `extensions/` | 기존 타입에 편의 기능을 붙이는 Dart extension입니다. |

주의:

- `AppEnv`는 `.env` asset을 읽습니다. `GEMINI_API_KEY`, `WEATHER_API_KEY` 같은 키가 앱에 포함될 수 있으므로 운영 배포 전 구조 검토가 필요합니다.
- `SupabaseService`는 Supabase client 초기화 위치로 적절합니다.

### `lib/features/auth/`

로그인, 이메일 로그인, 회원가입 화면과 관련 데이터입니다.

| 경로 | 역할 |
| --- | --- |
| `data/api/auth_api.dart` | Supabase Auth API 호출을 담당합니다. |
| `data/auth_credentials_validator.dart` | 이메일/비밀번호 규칙 검사입니다. |
| `data/auth_dev_credentials.dart` | 개발용 인증 정보. 운영 코드 포함 여부를 주의해야 합니다. |
| `data/auth_assets.dart` | auth 화면에서 쓰는 이미지 경로 모음입니다. |
| `data/model/auth_user_profile.dart` | 로그인 사용자 프로필 모델입니다. |
| `data/model/sign_up_draft.dart` | 회원가입 1단계에서 2단계로 넘기는 임시 데이터 모델입니다. |
| `ui/page/*` | 로그인, 이메일 로그인, 회원가입 1/2단계 화면입니다. |
| `ui/widgets/*` | auth 화면 안에서만 쓰는 버튼, 진행선, 입력 스타일 위젯입니다. |

### `lib/features/home/`

홈 대시보드, 기기 상태, 추천 배너, 바로 리프레시 shortcut을 담당합니다.

| 폴더/파일 | 역할 |
| --- | --- |
| `data/api/home_api.dart` | 홈 화면 데이터 조회 API입니다. |
| `data/api/gemini_recommend_api.dart` | Gemini 추천 문구/API 호출입니다. |
| `data/api/weather_api.dart` | 날씨 API 호출입니다. |
| `data/api/weather_recommend_fallback.dart` | 외부 추천 실패 시 기본 추천 문구입니다. |
| `data/api/consumable_status_mapper.dart` | 소모품 상태 값을 화면용 상태로 바꿉니다. |
| `data/home_assets.dart` | 홈 화면 이미지 경로 모음입니다. |
| `data/home_device_status_watcher.dart` | 기기 상태 변경 감시 역할입니다. |
| `data/home_shortcut_store.dart` | MVP용 임시 shortcut 저장소입니다. 추후 Supabase 연동 후보입니다. |
| `data/model/*` | 홈 화면에 필요한 데이터 모양입니다. |
| `ui/page/home_page.dart` | 홈 메인 화면입니다. |
| `ui/page/home_refresh_shortcut_add_page.dart` | 바로 실행할 리프레시 모드 추가 화면입니다. |
| `ui/widgets/*` | 홈 기기 상태, 추천 배너, 메뉴 카드, shortcut 카드입니다. |

### `lib/features/measure/`

측정 준비, 실행, 분석, 결과, 결과 상세를 담당합니다.

| 폴더/파일 | 역할 |
| --- | --- |
| `data/api/measure_api.dart` | 측정 결과 저장/조회 API입니다. |
| `data/api/measure_diagnosis_generator.dart` | 진단 분석용 샘플 점수 생성입니다. 현재 mock 성격이 강합니다. |
| `data/api/measure_refresh_recommend_service.dart` | 측정 결과 기반 리프레시 추천 연결입니다. |
| `data/api/measure_result_mapper.dart` | DB 기록을 화면 모델로 바꿉니다. |
| `data/api/measure_schedule_classifier_api.dart` | 캘린더 일정 기반 측정 타이밍 분류입니다. |
| `data/measure_assets.dart` | 측정 화면 이미지 경로 모음입니다. |
| `data/measure_result_store.dart` | 측정 결과 임시 저장소입니다. |
| `data/measure_result_visual_mapper.dart` | 냄새/먼지 상태 조합을 결과 이미지로 매핑합니다. |
| `data/model/*` | 측정 상태, 결과, 상세 지표, 준비 단계 모델입니다. |
| `ui/page/*` | 측정 관련 화면입니다. |
| `ui/widgets/*` | 측정 화면 전용 위젯입니다. |

미사용 의심:

- `measure_result_smell_type_row.dart`는 삭제되었습니다.

### `lib/features/refresh/`

리프레시 모드 선택, 상세, 실행 진행, 결과, 결과 상세, 커스텀 모드를 담당합니다.

| 폴더/파일 | 역할 |
| --- | --- |
| `data/api/refresh_api.dart` | 리프레시 관련 기본 API입니다. |
| `data/api/custom_mode_api.dart` | 커스텀 모드 저장/조회 API입니다. |
| `data/api/refresh_mode_mapper.dart` | API 데이터를 `RefreshMode`로 바꿉니다. |
| `data/api/refresh_recommend_api.dart` | 리프레시 추천 API입니다. |
| `data/api/refresh_recommend_fallback.dart` | 추천 실패 시 fallback입니다. |
| `data/api/refresh_session_api.dart` | 리프레시 실행 세션 저장/조회 API입니다. |
| `data/api/refresh_session_result_generator.dart` | 실행 결과 점수 생성 로직입니다. |
| `data/model/*` | 모드, 진행 세션, 오염도, 결과, 결과 상세 모델입니다. |
| `data/refresh_mode_catalog.dart` | 앱에 표시할 리프레시 모드 목록입니다. |
| `data/refresh_mode_filter.dart` | 탭/조건별 모드 필터입니다. |
| `data/refresh_result_store.dart` | 결과 임시 저장소입니다. |
| `ui/page/*` | 리프레시 관련 화면입니다. |
| `ui/widgets/*` | 리프레시 화면 전용 위젯입니다. |

### `lib/features/history/`

측정/리프레시 기록 조회와 월간/오늘/누적 리포트를 담당합니다.

| 폴더/파일 | 역할 |
| --- | --- |
| `data/api/history_api.dart` | 기록 조회 API입니다. |
| `data/api/history_measure_mapper.dart` | 측정 기록을 history 화면용으로 바꿉니다. |
| `data/api/history_session_mapper.dart` | 리프레시 세션 기록을 history 화면용으로 바꿉니다. |
| `data/api/history_report_builder.dart` | 기록을 월간/누적 리포트 구조로 가공합니다. |
| `data/refresh_history_store.dart` | 기록 상태 저장소입니다. |
| `data/model/*` | 기록, 리포트, 상태 모델입니다. |
| `ui/page/history_page.dart` | 기록 메인 화면입니다. |
| `ui/widgets/*` | 오늘 기록, 최근 기록, 월간 달력, 누적 통계 UI입니다. |

주의:

- `refresh_history_report.dart` 안에 `sample`, `emptyToday` mock 데이터가 있습니다. API 연결 전 화면 확인용이면 유지 가능하지만, 실제 데이터 연결 후에는 fallback 용도만 남길지 결정해야 합니다.

### `lib/features/settings/`

설정, 기기 관리, 로컬 캘린더 연동 화면을 담당합니다.

| 폴더/파일 | 역할 |
| --- | --- |
| `data/api/settings_api.dart` | 설정 화면 데이터 조회 API입니다. |
| `data/api/settings_device_mapper.dart` | 기기 상세 데이터를 화면 모델로 변환합니다. |
| `data/model/*` | 사용자 요약, 기기 상세 모델입니다. |
| `ui/page/settings_page.dart` | 설정 메인 화면입니다. |
| `ui/page/device_manage_page.dart` | 기기 관리 화면입니다. |
| `ui/page/local_calendar_settings_page.dart` | 캘린더 연동 설정 화면입니다. |
| `ui/widgets/*` | 설정 카드, 프로필 카드, 기기 상태 패널, 향 카트리지 안내입니다. |

### `lib/features/routine/`

AGENTS.md의 MVP 목록에는 없지만 현재 라우터와 `main.dart`에 연결된 실제 기능입니다. 루틴 목록, 루틴 등록, 알람 재등록을 담당하므로 삭제하면 앱 시작/라우팅이 깨질 수 있습니다.

| 폴더/파일 | 역할 |
| --- | --- |
| `data/model/routine.dart` | 루틴 데이터 모델입니다. |
| `data/api/routine_api.dart` | 루틴 저장/조회 API입니다. |
| `data/api/routine_local_store.dart` | 로컬 저장소입니다. |
| `data/api/routine_alarm_scheduler.dart` | 루틴 알림 예약/재등록입니다. |
| `ui/page/*` | 루틴 목록/등록 화면입니다. |
| `ui/widgets/*` | 시간 선택, 모드 선택, 요일 선택 UI입니다. |

### `lib/shared/`

여러 feature에서 공통으로 쓰는 코드입니다.

| 폴더 | 역할 |
| --- | --- |
| `models/` | 캘린더 이벤트, 로컬 캘린더 상태, 향 카트리지 상태/카테고리 모델입니다. |
| `recommendation/` | 환경/일정/측정/리프레시 기록을 모아 추천 입력과 결과를 만드는 공통 추천 로직입니다. |
| `utils/` | 향 카트리지/지표 badge 변환 헬퍼입니다. |
| `widgets/` | 앱 공통 UI 컴포넌트입니다. 버튼, 배지, 입력창, 헤더, 카드, 토글, 라디오 등입니다. |

미사용 의심 shared 위젯:

- `app_box_mini_button.dart`
- `app_calendar_top_header.dart`
- `app_page_indicator.dart`
- `app_recommend_featured_card.dart`
- `app_refresh_card.dart`
- `app_result_card.dart`
- `app_segmented_tab_bar.dart`
- `app_top_header.dart`
- `shared_widgets.dart`

위 파일들은 현재 직접 import되지 않습니다. 다만 디자인 시스템 컴포넌트 보관 목적일 수 있으므로 바로 삭제보다 “디자인 시스템에서 계속 쓸지”를 먼저 결정하는 편이 안전합니다.

## 3. `Assets/`

이미지와 폰트 리소스입니다.

| 경로 | 역할 | 상태 |
| --- | --- | --- |
| `Assets/fonts/Pretendard-*.otf` | 앱 전체 Pretendard 폰트입니다. | 유지 |
| `Assets/images/auth/Google.png` | Google 로그인 아이콘입니다. | 사용 중 |
| `Assets/images/auth/ICON.png` | auth 아이콘으로 보이나 현재 코드 직접 참조 없음. | 미사용 의심 |
| `Assets/images/common/check.png` | 공통 체크/화살표 아이콘으로 사용됩니다. | 사용 중 |
| `Assets/images/home/battery/*` | 배터리 상태별 아이콘입니다. | 사용 중 |
| `Assets/images/home/device_purihair.png` | 홈 기기 이미지입니다. | 사용 중 |
| `Assets/images/home/device_purihair_background_delete.png` | 설정 기기 관리 패널 이미지입니다. | 사용 중 |
| `Assets/images/home/filter.png` | 홈 필터 상태 아이콘입니다. | 사용 중 |
| `Assets/images/home/lg_purihair_logo.svg` | 브랜드 로고입니다. | 사용 중 |
| `Assets/images/home/recommend_sparkle.png` | 추천 배너 장식 아이콘입니다. | 사용 중 |
| `Assets/images/home/LOGO.png` | 현재 코드 직접 참조 없음. | 미사용 의심 |
| `Assets/images/home/LOGO2.png` | 현재 코드 직접 참조 없음. | 미사용 의심 |
| `Assets/images/measure/*` | 측정 준비/분석 이미지입니다. | 사용 중 |
| `Assets/images/measure/result/*` | 냄새/먼지 조합별 결과 이미지입니다. | 사용 중 |
| `Assets/images/refresh/refresh.png` | 결과 수집 화면 이미지입니다. | 사용 중 |
| `Assets/images/refresh/trash.png` | 리프레시 상세 삭제 아이콘입니다. | 사용 중 |
| `Assets/images/refresh/wifi.png` | `ImageAssets.refreshShareIcon`으로 정의되어 있으나 현재 사용처 없음. | 미사용 의심 |
| `Assets/images/history/calendar.png` | 기록 화면 달력 아이콘입니다. | 사용 중 |

중요:

- `pubspec.yaml`에는 `assets/...`로 등록되어 있으나 실제 폴더는 `Assets/...`입니다. 하나로 통일해야 합니다.
- Flutter 프로젝트 관례는 보통 소문자 `assets/`입니다. 폴더명을 `assets/`로 바꾸거나, `pubspec.yaml`을 `Assets/`로 맞춰야 합니다.

## 4. `test/`와 `tests/`

| 경로 | 역할 | 삭제 판단 |
| --- | --- | --- |
| `test/` | 실제 Flutter/Dart 테스트 코드입니다. | 유지 |
| `test/app/` | 앱 레이아웃/시스템 inset 테스트입니다. | 유지 |
| `test/core/` | core 모델, 서비스, 유틸 테스트입니다. | 유지 |
| `test/features/` | feature별 비즈니스 로직 테스트입니다. | 유지 |
| `test/shared/` | shared 모델/위젯/추천 로직 테스트입니다. | 유지 |
| `test/test_helpers.dart` | 테스트에서 공통으로 쓰는 helper입니다. | 유지 |
| `tests/README.md` | 테스트 전략 문서입니다. 실제 테스트 코드는 아닙니다. 현재 한글 깨짐 복구 필요. | 유지, 내용 복구 |

주의:

- `test/widget_test.dart` 안에도 한글 기대 문자열이 깨져 있습니다. 실제 UI 문자열과 함께 정상 한글로 복구해야 테스트 의미가 살아납니다.

## 5. 플랫폼 폴더

Flutter가 각 OS 앱을 만들 때 필요한 네이티브 프로젝트입니다.

| 폴더 | 역할 | 삭제 판단 |
| --- | --- | --- |
| `android/` | Android 앱 빌드 설정, Manifest, Kotlin MainActivity, 리소스입니다. | 유지 |
| `ios/` | iOS 앱 빌드 설정, Runner, asset catalog입니다. | 유지 |
| `web/` | Web 빌드용 index, manifest, icon입니다. | 유지 |
| `windows/` | Windows 데스크톱 빌드용 C++ runner입니다. | 유지 |
| `macos/` | macOS 데스크톱 빌드용 Runner입니다. | 유지 |
| `linux/` | Linux 데스크톱 빌드용 runner입니다. | 유지 |

정리 후보:

- `android/.gradle/`
- `android/.kotlin/`
- `android/hs_err_pid*.log`
- `android/replay_pid*.log`
- `android/local.properties`는 로컬 SDK 경로라 Git 제외 대상입니다.
- `android/lg_hair_refresher_android.iml`은 IDE 파일입니다.

이 파일들은 앱 소스가 아니라 로컬 빌드/IDE 산출물입니다.

## 6. `docs/`, `scripts/`

| 경로 | 역할 | 삭제 판단 |
| --- | --- | --- |
| `docs/decisions/` | 구조/백엔드 선택 이유를 적은 ADR 문서입니다. | 유지, 한글 복구 |
| `docs/conventions/` | Flutter 작업 규칙 문서입니다. | 유지, 한글 복구 |
| `scripts/*.mjs` | Figma export/분석 보조 스크립트입니다. 현재 앱 실행에는 직접 필요 없지만 디자인 자산 작업에는 유용합니다. | 보류 |

> `supabase/` 로컬 폴더와 `docs/sql/refresh_recommend_alarms.sql` 등 레포 SQL 스크립트는 제거되었습니다. DB 스키마·RLS는 Supabase 대시보드에서 관리합니다.

## 7. 사용하지 않는 파일 후보

### 안전하게 정리 가능한 파일/폴더

다음은 보통 삭제해도 다시 생성되거나 앱 소스가 아닙니다.

- `.dart_tool/`
- `build/`
- `android/.gradle/`
- `android/.kotlin/`
- `android/hs_err_pid*.log`
- `android/replay_pid*.log`
- `.flutter-plugins-dependencies`
- `release/build.log`

단, 삭제 전 Git 추적 여부를 확인해야 합니다. 현재 `.gitignore`에는 대부분 제외 규칙이 있습니다.

### 보류해야 하는 정리 후보

다음은 코드에서 직접 참조가 약하거나 현재 미사용이지만, 디자인 시스템/배포/기획 자산일 수 있습니다.

- `release/lg_purihair-release.apk`: 배포본 보관 목적이면 유지, 아니면 산출물이므로 Git 제외.
- `Assets/images/auth/ICON.png`
- `Assets/images/home/LOGO.png`
- `Assets/images/home/LOGO2.png`
- `Assets/images/refresh/wifi.png`
- `lib/shared/widgets/app_box_mini_button.dart`
- `lib/shared/widgets/app_calendar_top_header.dart`
- `lib/shared/widgets/app_page_indicator.dart`
- `lib/shared/widgets/app_recommend_featured_card.dart`
- `lib/shared/widgets/app_refresh_card.dart`
- `lib/shared/widgets/app_result_card.dart`
- `lib/shared/widgets/app_segmented_tab_bar.dart`
- `lib/shared/widgets/app_top_header.dart`
- `lib/shared/widgets/shared_widgets.dart`

삭제 전 확인 질문:

- Figma 디자인 시스템에 남아 있는 컴포넌트인가?
- 앞으로 다른 화면에서 재사용할 예정인가?
- 테스트에서만 검증해야 하는 공통 컴포넌트인가?
- barrel export(`shared_widgets.dart`)를 팀에서 쓰기로 한 규칙이 있는가?

## 8. 구조 규칙 위반 또는 리스크

AGENTS.md 기준으로 보면 다음 import는 구조상 재검토 대상입니다.

| 위치 | 문제 |
| --- | --- |
| `lib/app/router/app_navigation.dart` -> `features/measure/data/api/measure_result_mapper.dart` | app 계층이 feature의 `data/api`를 직접 import합니다. |
| `lib/core/services/local_calendar_service.dart` -> `features/measure/data/api/measure_schedule_classifier_api.dart` | core가 feature의 `data/api`를 직접 import합니다. |
| `lib/shared/recommendation/*` -> 여러 feature의 `data/api` | shared가 feature 구현체에 의존합니다. |

권장 방향:

- 여러 feature가 같이 쓰는 API/분류 로직이면 `shared/` 또는 `core/`로 옮깁니다.
- feature 내부 전용이면 app/core/shared에서 직접 import하지 않도록 중간 모델이나 서비스 경계를 둡니다.
- 당장 기능이 깨지는 문제는 아니지만, 구조가 커질수록 순환 의존과 테스트 난이도가 올라갑니다.

## 9. Dart 초보자용 개념 설명

### `import`

다른 파일의 클래스나 함수를 가져오는 문법입니다.

```dart
import 'package:flutter/material.dart';
```

뜻: Flutter의 기본 UI 도구들을 이 파일에서 쓰겠다는 의미입니다.

### `class`

데이터나 기능을 묶는 설계도입니다.

```dart
class UserHairProfile {
  final String hairType;
}
```

뜻: `UserHairProfile`이라는 데이터 모양을 만든 것입니다.

### `enum`

정해진 값 중 하나만 고르게 하는 타입입니다.

```dart
enum CareStatus { good, normal, bad }
```

뜻: 상태는 `good`, `normal`, `bad` 중 하나입니다.

### `StatelessWidget`

화면은 그리지만 자기 안에서 바뀌는 상태가 거의 없는 위젯입니다.

예: 단순 제목, 카드, 아이콘 버튼.

### `StatefulWidget`

사용자 입력이나 시간 흐름에 따라 화면이 바뀌는 위젯입니다.

예: 로그인 입력 화면, 측정 진행 화면, 탭 선택 화면.

### `Future`, `async`, `await`

네트워크 요청, 파일 읽기, DB 저장처럼 시간이 걸리는 작업을 기다릴 때 씁니다.

```dart
Future<void> main() async {
  await SupabaseService.initialize();
}
```

뜻: Supabase 초기화가 끝날 때까지 기다린 뒤 다음 줄을 실행합니다.

### `const`

실행 중 바뀌지 않는 값을 미리 고정할 때 씁니다. Flutter에서는 성능에도 도움이 됩니다.

```dart
const SizedBox(height: 16)
```

뜻: 높이 16짜리 빈 공간은 변하지 않는 위젯입니다.

### `final`

한 번 값이 정해지면 다시 바꾸지 않는 변수입니다.

```dart
final result = await api.fetch();
```

뜻: `result` 변수는 여기서 한 번 정해진 뒤 다른 값으로 바꾸지 않습니다.

### `model`

앱에서 다루는 데이터 모양입니다.

예: `MeasureResult`, `RefreshMode`, `Routine`.

### `api`

Supabase나 외부 서버와 통신하거나, 서버 데이터와 화면 데이터를 연결하는 코드입니다.

예: `MeasureApi`, `HistoryApi`, `WeatherApi`.

### `page`

사용자가 실제로 보는 한 화면입니다.

예: `HomePage`, `RefreshPage`, `LoginScreen`.

### `widgets`

화면을 구성하는 작은 부품입니다.

예: 버튼, 카드, 헤더, 배지, 입력창.

## 10. 추천 정리 순서

1. Git 추적 상태 확인 후 빌드 산출물/로그 정리
2. `README.md`, `docs/*`, `tests/README.md`, 테스트 문자열 한글 인코딩 복구
3. `Assets` 폴더명과 `pubspec.yaml` asset 경로 대소문자 통일
4. `.env`를 앱 asset으로 포함하는 구조의 보안성 검토
5. 미사용 의심 shared 위젯과 이미지의 Figma/기획 사용 여부 확인
6. app/core/shared가 feature `data/api`를 직접 import하는 구조 정리
7. `flutter analyze`, `flutter test`가 정상 완료되도록 원인 조사

