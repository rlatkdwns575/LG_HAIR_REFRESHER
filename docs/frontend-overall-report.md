# 전체 프론트엔드 보고서

작성 기준: 2026-06-22

이 문서는 LG Hair Refresher 앱의 전체 프론트엔드 구조를 Dart/Flutter 초보자 기준으로 설명합니다.

백엔드, Supabase, Gemini, 측정 알고리즘 같은 데이터 처리 로직은 별도 보고서에서 다루고, 여기서는 사용자가 보는 화면, 위젯, 라우팅, 상태 관리, 디자인 시스템을 중심으로 정리합니다.

## 1. 프론트엔드 전체 구조

이 앱은 Flutter로 만든 모바일 앱입니다.

프론트엔드 코드는 주로 아래 위치에 있습니다.

```text
lib/
 ├─ app/
 ├─ features/
 │   ├─ auth/
 │   ├─ home/
 │   ├─ measure/
 │   ├─ refresh/
 │   ├─ history/
 │   ├─ settings/
 │   ├─ device/
 │   └─ routine/
 └─ shared/
```

역할:

| 폴더 | 프론트엔드 역할 |
| --- | --- |
| `lib/app/` | 앱 전체 설정, 라우터, 테마, 공통 레이아웃, 하단 네비게이션 |
| `lib/features/` | 기능별 화면과 기능 전용 위젯 |
| `lib/shared/widgets/` | 여러 화면에서 같이 쓰는 공통 위젯 |
| `lib/app/theme/` | 색상, 글자 스타일, 간격, 모서리, 그림자 등 디자인 시스템 |
| `assets/images/` | 화면에 쓰는 이미지 asset |
| `assets/fonts/` | 앱 폰트 |

## 2. Flutter 초보자용 핵심 개념

### 2.1 Widget

Flutter 화면의 모든 UI는 `Widget`입니다.

예:

```dart
Text('hello')
Column(children: [])
Scaffold(...)
HomePage()
```

버튼, 텍스트, 화면 전체, 카드 하나까지 모두 위젯입니다.

### 2.2 StatelessWidget

값이 내부에서 바뀌지 않는 위젯입니다.

예:

```dart
class HomeRecommendBanner extends StatelessWidget {
  const HomeRecommendBanner({required this.message, super.key});

  final String message;
}
```

특징:

- 부모가 넘겨준 값을 화면에 그립니다.
- 자체적으로 로딩 상태나 선택 상태를 저장하지 않습니다.
- 공통 카드, 배너, badge, row 위젯에 많이 사용합니다.

### 2.3 StatefulWidget

화면 안에서 값이 바뀌는 위젯입니다.

예:

```dart
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}
```

사용하는 경우:

- API 데이터를 불러와야 할 때
- 로딩 중/완료 상태가 있을 때
- 탭 선택 값이 바뀔 때
- 사용자가 누른 값에 따라 화면이 바뀔 때

### 2.4 setState

`setState()`는 값을 바꾸고 화면을 다시 그리게 하는 함수입니다.

```dart
setState(() {
  _isLoading = false;
  _recommendedMode = recommendation.mode;
});
```

초보자 기준으로는 “이 안에서 값을 바꾸면 Flutter가 화면을 새로 그린다”라고 이해하면 됩니다.

### 2.5 async / await

서버 요청, Supabase 조회, 기기 상태 조회처럼 시간이 걸리는 일을 기다릴 때 씁니다.

```dart
final cartridge = await _deviceConsumableService.fetchScentCartridgeStatus();
```

`await`는 “결과가 올 때까지 기다린다”는 뜻입니다.

### 2.6 BuildContext

`BuildContext context`는 현재 위젯이 화면 트리에서 어디에 있는지 알려주는 객체입니다.

이 프로젝트에서는 주로 화면 이동에 씁니다.

```dart
context.pushRefreshDetail(mode: mode);
context.goHome();
```

## 3. 앱 공통 레이어

## 3.1 앱 시작과 전체 앱 설정

대표 파일:

| 파일 | 역할 |
| --- | --- |
| `lib/main.dart` | 앱 시작점입니다. Supabase 초기화 후 Flutter 앱을 실행합니다. |
| `lib/app/app.dart` | `MaterialApp` 또는 앱 전체 shell을 구성합니다. |
| `lib/app/router/app_router.dart` | `go_router`로 앱 route를 정의합니다. |
| `lib/app/router/app_navigation.dart` | 화면에서 route 문자열을 직접 쓰지 않도록 이동 함수를 제공합니다. |

초보자 기준 흐름:

```text
main.dart
-> app.dart
-> app_router.dart
-> 각 feature 화면
```

## 3.2 라우팅

이 프로젝트는 `go_router`를 사용합니다.

화면에서는 아래처럼 이동합니다.

```dart
context.pushMeasure();
context.pushRefresh();
context.pushRefreshDetail(mode: mode);
context.goHome();
```

직접 문자열을 쓰지 않는 이유:

```dart
context.push('/refresh/detail');
```

이런 문자열이 화면 곳곳에 흩어지면 나중에 route가 바뀔 때 수정하기 어렵습니다.

그래서 `app_navigation.dart`에서 함수로 감싸서 씁니다.

## 3.3 레이아웃

대표 파일:

| 파일 | 역할 |
| --- | --- |
| `lib/app/layout/app_layout.dart` | 큰 화면에서 앱 폭을 제한하는 shell 등을 제공합니다. |
| `lib/app/navigation/bottom_nav_shell.dart` | 하단 탭 구조를 관리합니다. |
| `lib/app/navigation/app_system_insets.dart` | 기기 하단 safe area, padding 계산을 도와줍니다. |

중요한 이유:

- iPhone 하단 홈 indicator와 버튼이 겹치지 않게 합니다.
- 태블릿/큰 화면에서 화면이 너무 넓게 퍼지지 않게 합니다.
- 여러 화면의 padding 규칙을 맞춥니다.

## 4. 디자인 시스템

프론트엔드 디자인 값은 `lib/app/theme/`에 모여 있습니다.

대표 파일:

| 파일 | 역할 |
| --- | --- |
| `app_colors.dart` | 기본 색상 |
| `app_component_colors.dart` | 컴포넌트별 색상 |
| `app_text_styles.dart` | 글자 크기, 굵기, 줄높이 |
| `app_spacing.dart` | 간격 값 |
| `app_radius.dart` | 모서리 둥글기 |
| `app_shadows.dart` | 그림자 |
| `app_theme.dart` | Flutter `ThemeData` 설정 |

예:

```dart
AppColors.gray500
AppSpacing.lg
AppRadius.md
AppTextStyles.bodyS
```

초보자 기준:

- 화면마다 색상 숫자를 직접 쓰지 않습니다.
- 공통 theme 값을 가져다 씁니다.
- 그래야 전체 앱의 디자인이 통일됩니다.

## 5. 공통 위젯

위치: `lib/shared/widgets/`

여러 화면에서 재사용하는 위젯입니다.

현재 주요 공통 위젯:

| 파일 | 역할 |
| --- | --- |
| `app_text.dart` | 공통 텍스트 위젯 |
| `app_common_top_header.dart` | 상단 header/app bar |
| `app_box_button.dart` | 큰 박스형 버튼 |
| `app_bottom_button_bar.dart` | 하단 고정 버튼 영역 |
| `app_fixed_bottom_button_area.dart` | safe area를 고려한 하단 버튼 wrapper |
| `app_capsule_button.dart` | capsule 형태 버튼 |
| `app_capsule_icon_button.dart` | 아이콘 capsule 버튼 |
| `app_text_link_button.dart` | 텍스트 링크 버튼 |
| `app_badge.dart` | 작은 상태 badge |
| `app_checkbox.dart` | 공통 checkbox |
| `app_radio.dart` | 공통 radio |
| `app_toggle.dart` | 공통 toggle |
| `app_text_field.dart` | 일반 입력창 |
| `app_search_text_field.dart` | 검색 입력창 |
| `app_confirm_dialog.dart` | 확인 dialog |
| `app_chip_tab_bar.dart` | chip 형태 tab bar |
| `app_list_item.dart` | 공통 list item |
| `app_section_title.dart` | 섹션 제목 |
| `app_section_divider.dart` | 섹션 구분선 |
| `app_metric_help_icon.dart` | 설명 tooltip 아이콘 |
| `app_recommend_card.dart` | 추천 문구 카드 |
| `app_brand_logo.dart` | 브랜드 로고 |
| `app_battery_status.dart` | 배터리 상태 표시 |
| `app_calendar_day_strip.dart` | 달력 day strip |
| `app_calendar_week_strip.dart` | 달력 week strip |
| `app_calendar_item.dart` | 달력 항목 |
| `shared_widgets.dart` | 공통 위젯을 한 번에 export하는 barrel 파일 |

### barrel export

`shared_widgets.dart` 같은 파일은 여러 위젯을 한 번에 export합니다.

```dart
export 'app_text.dart';
export 'app_box_button.dart';
```

그러면 다른 파일에서 import를 줄일 수 있습니다.

```dart
import '../../../../shared/widgets/shared_widgets.dart';
```

## 6. Feature별 프론트엔드 구조

각 feature는 대체로 아래 구조를 따릅니다.

```text
features/{feature}/
 ├─ data/
 └─ ui/
     ├─ page/
     └─ widgets/
```

프론트엔드는 주로 `ui/page`와 `ui/widgets`에 있습니다.

| 폴더 | 역할 |
| --- | --- |
| `ui/page/` | 실제 화면 단위 위젯 |
| `ui/widgets/` | 그 feature 안에서만 쓰는 작은 UI 조각 |

예:

```text
features/home/ui/page/home_page.dart
features/home/ui/widgets/home_recommend_banner.dart
```

## 7. Auth 프론트엔드

위치: `lib/features/auth/ui/`

역할:

- 로그인 화면
- 이메일 로그인 화면
- 회원가입/프로필 입력 흐름
- 개발용 인증 정보 입력 또는 자동 입력 보조

대표 파일:

| 파일 | 역할 |
| --- | --- |
| `login_screen.dart` | 로그인 진입 화면 |
| `email_login_screen.dart` | 이메일 기반 로그인 화면 |
| `auth_screen_widgets.dart` | 인증 화면에서 공통으로 쓰는 입력/버튼/레이아웃 위젯 |
| `auth_screen_styles.dart` | 인증 화면 전용 스타일 |

프론트엔드 특징:

- 로그인 UI는 feature 내부 위젯을 사용합니다.
- 인증 API 호출 자체는 `data/api` 쪽에 있어야 합니다.
- 화면은 사용자 입력과 버튼 동작을 담당합니다.

## 8. Home 프론트엔드

위치: `lib/features/home/ui/`

홈 화면은 앱의 대시보드입니다.

주요 역할:

- 기기 상태 표시
- 추천 배너 표시
- 빠른 리프레시 카드 표시
- 측정/리프레시/기록 메뉴로 이동

대표 파일:

| 파일 | 역할 |
| --- | --- |
| `home_page.dart` | 홈 메인 화면 |
| `home_device_status_section.dart` | 기기명, 배터리, 필터 상태 표시 |
| `home_recommend_banner.dart` | 추천 문구 배너 |
| `home_quick_refresh_row.dart` | 빠른 리프레시 카드 2개 영역 |
| `home_navigation_menu.dart` | 측정/리프레시/기록 이동 메뉴 |
| `home_navigation_card.dart` | 메뉴 카드 하나 |
| `home_refresh_shortcut_add_page.dart` | 빠른 실행 모드 추가/선택 화면 |
| `refresh_shortcut_select_card.dart` | 빠른 실행 선택 카드 |

화면 흐름:

```text
HomePage
-> HomeDeviceStatusSection
-> HomeRecommendBanner
-> HomeQuickRefreshRow
-> HomeNavigationMenu
```

중요 state:

| state | 의미 |
| --- | --- |
| `_dashboardData` | 홈 화면에 보여줄 전체 데이터 |
| `_isLoading` | 로딩 여부 |
| `_recommendMessage` | 추천 배너 문구 |
| `_recommendedRefreshMode` | 추천 리프레시 모드 |
| `_isScentCartridgeAttached` | 향기 카트리지 장착 여부 |

## 9. Measure 프론트엔드

위치: `lib/features/measure/ui/`

측정 feature는 사용자가 헤어 상태를 측정하고 결과를 보는 흐름입니다.

주요 화면:

| 화면 파일 | 역할 |
| --- | --- |
| `measure_prepare_page.dart` | 측정 전 준비 안내 |
| `measure_hair_profile_page.dart` | 모발 상태/프로필 입력 |
| `measure_run_page.dart` | 측정 실행 화면 |
| `measure_analyzing_page.dart` | 측정 분석 중 화면 |
| `measure_result_page.dart` | 측정 결과 요약 화면 |
| `measure_result_detail_page.dart` | 측정 결과 상세 화면 |

주요 위젯:

| 위젯 파일 | 역할 |
| --- | --- |
| `measure_prepare_bottom_bar.dart` | 측정 준비 화면 하단 버튼 |
| `measure_result_content.dart` | 측정 결과 화면 본문 |
| `measure_result_header.dart` | 측정 결과 header |
| `measure_result_headline.dart` | 결과 headline |
| `measure_result_visual.dart` | 냄새/먼지 상태 이미지 |
| `measure_result_refresh_need_summary.dart` | 리프레시 필요도 요약 |
| `measure_result_status_row.dart` | 냄새/먼지 상태 row |
| `measure_result_detail_content.dart` | 상세 결과 전체 content |
| `measure_result_detail_summary.dart` | 상세 결과 요약과 추천 카드 |
| `measure_result_detail_need_bars.dart` | 필요도 bar 그래프 |
| `measure_result_smell_type_row.dart` | 냄새 유형 row |

측정 프론트 흐름:

```text
준비
-> 측정 실행
-> 분석 중
-> 결과 요약
-> 상세 결과
-> 추천 리프레시 모드 실행
```

프론트엔드가 표시하는 핵심 값:

| 값 | 의미 |
| --- | --- |
| `refreshNeedPercent` | 리프레시 필요도 |
| `odorLevel` | 냄새 상태 |
| `dustLevel` | 먼지 상태 |
| `recommendedMode` | 추천 리프레시 모드 |
| `recommendReason` | 추천 이유 문구 |

## 10. Refresh 프론트엔드

위치: `lib/features/refresh/ui/`

리프레시 feature는 모드를 고르고 실행하고 결과를 확인하는 흐름입니다.

주요 화면:

| 화면 파일 | 역할 |
| --- | --- |
| `refresh_page.dart` | 리프레시 모드 목록/추천 모드 화면 |
| `refresh_detail_page.dart` | 특정 리프레시 모드 상세 화면 |
| `refresh_progress_page.dart` | 리프레시 실행 중 화면 |
| `refresh_result_collecting_page.dart` | 결과 수집/저장 중 화면 |
| `refresh_result_page.dart` | 리프레시 결과 요약 화면 |
| `refresh_result_detail_page.dart` | 리프레시 결과 상세 화면 |
| `refresh_custom_create_page.dart` | 커스텀 모드 생성 화면 |

주요 위젯:

| 위젯 파일 | 역할 |
| --- | --- |
| `refresh_mode_card.dart` | 리프레시 모드 카드 |
| `refresh_section_header.dart` | 리프레시 섹션 제목 |
| `refresh_progress_ring.dart` | 진행률 원형 UI |
| `refresh_result_content.dart` | 결과 화면 본문 |
| `refresh_result_header.dart` | 결과 header |
| `refresh_result_headline.dart` | 결과 headline |
| `refresh_result_change_chart.dart` | 냄새/먼지 변화 차트 |
| `refresh_result_detail_metric_bars.dart` | 상세 metric bar |

리프레시 프론트 흐름:

```text
RefreshPage
-> RefreshModeCard 선택
-> RefreshDetailPage
-> RefreshProgressPage
-> RefreshResultCollectingPage
-> RefreshResultPage
-> RefreshResultDetailPage
```

중요 UI 처리:

- 추천 모드는 `RefreshModeCardVariant.featured`로 크게 보여줍니다.
- 일반 모드는 list card로 보여줍니다.
- 향기 카트리지가 없으면 향기 모드를 비활성화합니다.
- 커스텀 모드는 별도 생성 화면으로 이동합니다.

## 11. History 프론트엔드

위치: `lib/features/history/ui/`

History는 측정/리프레시 기록을 보여주는 feature입니다.

대표 파일:

| 파일 | 역할 |
| --- | --- |
| `history_page.dart` | 사용 기록 메인 화면 |
| `history_total_section.dart` | 누적 사용 요약 |
| `history_today_section.dart` | 오늘 기록 |
| `history_recent_section.dart` | 최근 기록 |
| `history_month_calendar.dart` | 월간 달력 UI |
| `history_month_picker.dart` | 월 선택 UI |
| `history_care_badge.dart` | 기록 상태 badge |
| `history_common.dart` | history 전용 공통 UI |

프론트엔드 특징:

- 기록 데이터를 날짜/월 기준으로 나눠 보여줍니다.
- `CareStatus` 같은 상태값을 badge 색상과 label로 표시합니다.
- 기록 item을 누르면 측정 상세 또는 리프레시 상세로 이동합니다.

## 12. Settings 프론트엔드

위치: `lib/features/settings/ui/`

Settings는 앱 설정, 계정, 기기, 캘린더/권한 연동 흐름을 담당합니다.

대표 역할:

| 화면 성격 | 설명 |
| --- | --- |
| 설정 메인 | 계정/기기/알림/캘린더 메뉴 진입 |
| 기기 관리 | 연결된 기기 정보와 관리 |
| 캘린더 설정 | 로컬 캘린더 또는 일정 연동 설정 |
| 권한 안내 | 앱 권한 상태 안내 |

프론트엔드 주의점:

- 설정 화면에서 Supabase를 직접 호출하지 않아야 합니다.
- 실제 데이터 처리는 `data/api` 또는 `core/services`로 분리해야 합니다.

## 13. Device 프론트엔드

위치: `lib/features/device/ui/`

Device feature는 기기 연결과 관리 화면을 담당합니다.

주요 역할:

- 기기 검색/연결
- 연결된 기기 상태 확인
- 기기 이름, 모델, 연결 상태 표시

프론트엔드 관점:

- 사용자는 설정 또는 홈에서 기기 관리로 이동합니다.
- 기기 상태 표시는 홈의 `HomeDeviceStatusSection`과도 연결됩니다.

## 14. Routine 프론트엔드

위치: `lib/features/routine/ui/`

Routine은 리프레시 알림/루틴 등록 기능입니다.

대표 파일:

| 파일 | 역할 |
| --- | --- |
| `routine_list_page.dart` | 등록된 루틴 목록 화면 |
| `routine_register_page.dart` | 루틴 등록/수정 화면 |

프론트엔드 역할:

- 요일/시간/모드 선택 UI를 제공합니다.
- 등록된 루틴을 목록으로 보여줍니다.
- 저장 자체는 data/api 또는 local store가 담당합니다.

## 15. 화면별 공통 패턴

### 15.1 로딩 처리

많은 화면이 아래 패턴을 씁니다.

```dart
bool _isLoading = true;

body: _isLoading
    ? const Center(child: CircularProgressIndicator())
    : 실제화면()
```

의미:

- 데이터 불러오는 중이면 로딩 표시
- 완료되면 실제 화면 표시

### 15.2 에러 처리

```dart
String? _loadError;
```

에러가 있으면 화면에 안내 문구를 보여줍니다.

```dart
if (_loadError != null) {
  AppText(_loadError!)
}
```

### 15.3 mounted 확인

비동기 작업 후에는 자주 아래 코드가 나옵니다.

```dart
if (!mounted) {
  return;
}
```

의미:

- API를 기다리는 동안 화면이 사라졌을 수 있습니다.
- 사라진 화면에서 `setState()`를 하면 오류가 날 수 있습니다.
- 그래서 `mounted`로 아직 화면이 살아 있는지 확인합니다.

### 15.4 null 안전성

Dart는 null safety를 사용합니다.

자주 보이는 문법:

| 문법 | 의미 |
| --- | --- |
| `String?` | null일 수도 있는 문자열 |
| `result == null` | 값이 없는지 확인 |
| `result!` | null이 아니라고 강제로 알려줌 |
| `value ?? fallback` | value가 null이면 fallback 사용 |
| `object?.name` | object가 null이면 전체 결과도 null |

## 16. 버튼과 사용자 동작

프론트엔드에서 버튼은 보통 콜백 함수로 동작합니다.

예:

```dart
AppBoxButton(
  label: '다시 측정하기',
  onPressed: _onRediagnose,
)
```

`onPressed`는 버튼을 눌렀을 때 실행할 함수입니다.

카드도 비슷합니다.

```dart
RefreshModeCard(
  mode: mode,
  onTap: () => _onModeTap(mode),
)
```

## 17. 이미지 asset

이미지는 보통 `Image.asset()`으로 표시합니다.

```dart
Image.asset(
  HomeAssets.recommendSparkleIcon,
  width: 24,
  height: 24,
)
```

asset path는 직접 문자열로 쓰기보다 `core/constants` 또는 feature별 assets 파일에서 관리합니다.

예:

| 파일 | 역할 |
| --- | --- |
| `lib/core/constants/image_assets.dart` | 전체 이미지 path 상수 |
| `lib/features/home/data/home_assets.dart` | 홈 feature에서 쓰는 이미지 path |
| `lib/features/refresh/data/refresh_assets.dart` | 리프레시 feature에서 쓰는 이미지 path |

## 18. 프론트엔드와 백엔드의 경계

프론트엔드 화면 파일은 Supabase를 직접 호출하지 않는 것이 원칙입니다.

좋은 구조:

```text
ui/page
-> data/api 또는 core/services 호출
-> model로 받은 값 표시
```

나쁜 구조:

```text
ui/page에서 Supabase.instance.client 직접 호출
```

이 프로젝트의 원칙:

| 위치 | 역할 |
| --- | --- |
| `ui/page` | 화면 상태, 버튼, 화면 이동 |
| `ui/widgets` | UI 조각 표시 |
| `data/api` | Supabase/API/외부 연동 |
| `data/model` | 화면이나 API에서 쓰는 데이터 구조 |
| `core/services` | 여러 feature가 같이 쓰는 서비스 |

## 19. 현재 프론트엔드 리스크

| 리스크 | 설명 |
| --- | --- |
| 한글 문자열 인코딩 깨짐 | 일부 소스 주석/문자열이 터미널에서 깨져 보이며, 사용자 노출 문구도 점검이 필요합니다. |
| feature별 위젯 수 증가 | measure/refresh 위젯이 많아져 구조 파악이 어려워질 수 있습니다. |
| `catch (_) {}` 사용 | 실패 원인을 숨기는 코드가 있어 디버깅이 어렵습니다. |
| 추천/카트리지 비활성 처리 중복 | 여러 화면에서 같은 활성 여부 검사와 snackbar 처리를 반복합니다. |
| 화면별 fallback UX 차이 | 어떤 화면은 추천 실패 시 숨기고, 어떤 화면은 첫 번째 모드를 보여줍니다. |
| 일부 shared widget 관리 필요 | 실제 재사용하지 않는 위젯은 feature 내부로 옮기거나 삭제 검토가 필요합니다. |

## 20. 개선 제안

1. 사용자 노출 한글 문구 우선 복구

터미널만 깨지는 문제인지, 실제 파일 문자열도 깨졌는지 구분한 뒤 사용자에게 보이는 문구부터 정리합니다.

2. 화면별 로딩/에러 상태 공통 패턴 문서화

```text
loading / success / empty / error
```

이 네 가지 상태를 feature마다 비슷하게 맞추면 유지보수가 쉬워집니다.

3. 추천/향기 카트리지 검사 helper 만들기

현재 여러 화면에서 반복되는 아래 흐름을 공통화할 수 있습니다.

```dart
RefreshModeAvailability.isEnabled(...)
showRefreshScentUnavailableSnackBar(...)
```

4. feature 전용 위젯과 shared 위젯 기준 정리

두 개 이상의 feature에서 실제로 쓰는 경우만 `shared/widgets`에 남기고, feature 전용이면 해당 feature의 `ui/widgets`에 두는 것이 좋습니다.

5. 프론트엔드 테스트 확대

우선순위:

```text
라우팅
추천 카드 표시 여부
향기 카트리지 비활성 처리
측정 결과 화면
리프레시 결과 화면
```

6. 디자인 token 사용 점검

화면 안에 직접 숫자로 반복된 색상, spacing, radius가 있으면 `app/theme` 값으로 이동하는 것이 좋습니다.

## 21. 초보자용 요약

이 앱의 프론트엔드는 아래 방식으로 이해하면 됩니다.

```text
app/
  앱 전체 규칙

features/
  기능별 화면

shared/widgets/
  여러 화면에서 같이 쓰는 UI 부품

theme/
  색상, 글자, 간격 같은 디자인 규칙
```

화면 하나의 기본 흐름은 보통 이렇습니다.

```text
1. StatefulWidget 화면 생성
2. initState에서 데이터 요청
3. 로딩 표시
4. 데이터가 오면 setState
5. Widget tree를 다시 그림
6. 버튼/카드 클릭 시 app_navigation으로 화면 이동
```

즉, 프론트엔드의 핵심은 “데이터를 가져와서 state에 넣고, 그 state를 위젯으로 보여주고, 사용자의 클릭을 다음 화면 이동으로 연결하는 것”입니다.
