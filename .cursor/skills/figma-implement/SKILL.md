---
name: figma-implement
description: >-
  Figma 디자인 노드를 보고 Flutter 코드로 옮긴다. 디자인 토큰/위젯 카탈로그가
  정의되어 있으면 따르고, 없으면 Material 기본 위젯과 raw 값으로 구현한다.
  사용자가 'Figma로 ~~ 화면 만들어줘', 'design 구현', '/figma-implement
  <figma url>' 라고 말하면 호출.
disable-model-invocation: true
---

# figma-implement — Figma → Flutter

Figma 디자인을 Flutter 코드로 옮기는 작업의 **반복 부분만** 자동화한다. 디자인 토큰·위젯 카탈로그·디렉토리 구조는 **현장 감지**해 따르고, 없으면 기본값으로 간다.

## 입력 인자

`$ARGUMENTS` 자유 텍스트에서 다음을 추출:

1. **Figma URL** (필수, 1개 이상) — `figma.com/...`을 모두 잡는다.
2. **대상 파일 경로** (선택) — `lib/`를 포함하는 경로. 없으면 새 파일을 생성한다.

추출이 모호하면 진행 전에 사용자에게 한 문장으로 확인.

## 워크플로우

### Step 0 — 프로젝트 현장 감지 (LG Hair Refresher)

코드베이스를 먼저 읽고 아래가 있으면 **반드시** 따른다.

| 감지 대상 | 경로 |
|-----------|------|
| Color Style | `lib/app/theme/app_colors.dart` |
| Text Style | `lib/app/theme/app_text_styles.dart` |
| Spacing / Radius / Shadow | `lib/app/theme/app_spacing.dart`, `app_radius.dart`, `app_shadows.dart` |
| Component hex | `lib/app/theme/app_component_colors.dart` |
| 공용 위젯 카탈로그 | `lib/shared/widgets/` + `shared_widgets.dart` |
| 위젯 프리뷰 | `lib/shared/widgets/shared_widget_gallery_page.dart` (`/dev/widgets`) |
| Feature page 위치 | `lib/features/{feature}/ui/page/{feature}_page.dart` |
| Feature 전용 위젯 | `lib/features/{feature}/ui/widgets/` |
| 구조·금지 규칙 | `AGENTS.md`, `.cursor/rules/flutter-guidelines.mdc` |

**색상 규칙 (이 프로젝트)**

- 공용 컴포넌트 내부·Figma Component 매칭: `AppComponentColors`
- 일반 화면 배경·레이아웃: `AppColors`
- 화면에서 `Color(0xFF...)` 직접 사용 금지 — 토큰 없으면 raw 값 + 반복 시 `const` 추출

**위젯 우선순위**

1. `shared/widgets/app_*.dart` 기존 컴포넌트
2. feature `ui/widgets/` 조합 위젯
3. 없을 때만 새 위젯 추가 (Component 섹션이면 `shared/widgets/`, 화면 전용이면 feature `ui/widgets/`)

### Step 1 — Figma 디자인 가져오기

각 URL에 대해 (가능하면 병렬로):

1. Figma MCP의 `get_design_context`로 노드의 React+Tailwind 코드+힌트 받기. **참고용**.
2. `get_screenshot`로 시각 참조.
3. 노드 구조가 복잡하면 `get_metadata`.

Talk to Figma MCP가 연결되어 있으면 `read_my_design`, `get_node_info`, `get_styles`로 보조 확인.

받은 결과에서 **시각적 핵심 값들을 즉시 메모**: 색상 hex, 폰트 크기·굵기, padding/gap 픽셀, border radius, 그림자.

### Step 2 — Flutter 코드 작성

- **단일 책임 화면**: 큰 build는 `_buildHeader()`, `_buildBody()` 등으로 쪼개기.
- **재사용 위젯 우선**: Step 0·1에서 발견한 카탈로그 위젯이 있으면 우선 사용.
- **토큰 매핑**: 토큰이 있으면 raw hex 대신 토큰. 없으면 hex 그대로 + 자주 반복되는 색·간격은 `const`로 추출.
- **Page 스캐폴드**: `StatefulWidget` + `setState` (Riverpod 금지).
- **Supabase**: UI 구현 단계에서 `data/api` 호출·연동 추가하지 않음.
- **라우트**: 사용자가 명시하지 않으면 path 등록·`go_router` 변경하지 않음.

새 공용 컴포넌트가 필요할 때만:

1. Component hex → `app_component_colors.dart` (Color Style과 구분)
2. `lib/shared/widgets/app_{name}.dart` 구현
3. `shared_widgets.dart` export
4. 필요 시 `SharedWidgetGalleryPage`에 프리뷰 추가

### Step 3 — 셀프 체크

코드 작성 후 아래 내용 빠르게 점검:

1. trailing comma (2+ args)
2. spread-if 패턴 (`if (x) ...[ ... ]`)
3. `const` 생성자 가능한 곳마다
4. `_build...` 메서드 분리
5. raw hex가 너무 흔해져 있지 않은지
6. `ui/page/`에 Supabase import 없음
7. route path 하드코딩 없음 (`AppRoutePaths` 사용은 라우트 작업 시에만)

더 깊은 리뷰가 필요하면 사용자가 `/multi-review`를 호출하게 둔다.

### Step 4 — 검증

```powershell
dart format .
flutter analyze
flutter test
```

UI만 변경했어도 analyze는 실행. 의미 있는 동작 변경 시 관련 widget test 추가 검토.

### Step 5 — 최종 보고

3줄로 끝낸다:

1. 만든/수정한 파일 (markdown link)
2. Figma에서 발견됐지만 처리하지 못한 것 (빠진 자산, 매칭 안 된 색 등)
3. 다음 추천 액션

## 하지 말 것

- **디자인 토큰 파일을 임의로 새로 만들지 말 것**. 없으면 raw 값 그대로.
- **새 디렉토리/네이밍 컨벤션을 들여오지 말 것**.
- **빠진 자산을 추측해 더미로 채우지 말 것**. 보고하고 멈춘다.
- **상태관리/라우팅을 바꾸지 말 것**. 이 스킬은 UI 구현 한정.
- **`domain/`, `repository/`, `usecase/` 계층을 기본으로 추가하지 말 것**.
- **`freezed`, `build_runner` 기반 모델 생성을 도입하지 말 것**.

## 관련 스킬

- 프로젝트 전반 워크플로: [../skills.md](../skills.md)
- 구현 후 다중 리뷰: [../multi-review/SKILL.md](../multi-review/SKILL.md)
