---
name: lg-hair-refresher
description: >-
  LG Hair Refresher Flutter 프로젝트 전용 Agent 워크플로. feature 화면 구현,
  Figma→Flutter UI, Supabase data/api, 공용 위젯, 검증 루프, Git/PR 작업 시
  사용. 사용자가 measure, refresh, history, home, settings, Figma, Supabase,
  shared widget, theme, go_router 관련 작업을 요청할 때 적용.
---

# LG Hair Refresher — Project Skills

이 디렉터리는 **작업 절차(skill)** 를 정의합니다. 구조·규칙 상세는 `AGENTS.md`와 `.cursor/rules/flutter-guidelines.mdc`를 따릅니다.

## 전용 스킬 (명시 호출)

| 스킬 | 경로 | 언제 |
|------|------|------|
| **multi-review** | [multi-review/SKILL.md](multi-review/SKILL.md) | 화면·다중 파일 수정 직후 병렬 리뷰 (`/multi-review`, `/multi-review 4 홈 화면`) |
| **figma-implement** | [figma-implement/SKILL.md](figma-implement/SKILL.md) | Figma URL·디자인을 Flutter 코드로 구현 (`/figma-implement <url>`) |

Figma → 코드 작업은 **figma-implement**를 우선 로드한다. 구현 후 품질 점검이 필요하면 **multi-review**를 이어서 호출한다.

---

## Skill 1: 작업 시작 (Context Load)

**언제**: 모든 코드·UI·문서 작업 시작 시

### 체크리스트

```
- [ ] git status로 현재 변경 범위 확인
- [ ] 대상 feature 폴더와 기존 page/api/model 패턴 읽기
- [ ] AGENTS.md + flutter-guidelines.mdc 확인
- [ ] 관련 docs/decisions/ (0001, 0002) 확인
- [ ] Figma 작업이면 figma-implement/SKILL.md 로드
```

### 우선순위

```text
현재 코드베이스 > AGENTS.md > flutter-guidelines.mdc > README > docs/ > Figma
```

코드와 문서가 충돌하면 **코드를 먼저 확인**하고, 필요 시 문서를 함께 수정.

---

## Skill 2: Feature 화면 구현

**언제**: `home`, `measure`, `refresh`, `history`, `settings` 화면 추가·수정

### 절차

1. **위치 결정**
   - Page: `features/{feature}/ui/page/{feature}_page.dart`
   - Feature 전용 위젯: `features/{feature}/ui/widgets/`
   - 2개 이상 feature 재사용 예정이면 `shared/widgets/` 검토

2. **Page 스캐폴드**

```dart
class XxxPage extends StatefulWidget {
  const XxxPage({super.key});
  @override
  State<XxxPage> createState() => _XxxPageState();
}

class _XxxPageState extends State<XxxPage> {
  // 로딩, 에러, 폼 상태는 여기서 관리
  @override
  Widget build(BuildContext context) { /* ... */ }
}
```

3. **데이터 필요 시**
   - `features/{feature}/data/model/`에 모델 추가
   - `features/{feature}/data/api/`에 API 클래스 추가
   - Page의 `State`에서 API 호출 → 결과를 state에 반영

4. **라우트 연결** (새 화면일 때만)
   - `AppRoutePaths`에 상수 추가
   - `app_router.dart`에 `GoRoute` 등록
   - `app_navigation.dart`에 `pushXxx` extension 추가

5. **검증**: Skill 6 실행. 다중 파일·UI 변경이면 multi-review 고려

### 하지 말 것

- `domain/`, `repository/`, `usecase/` 계층 기본 생성
- Page 안에서 `Supabase.instance.client` 직접 호출
- `'/feature'` 경로 문자열 하드코딩

---

## Skill 3: Figma → Flutter UI

**언제**: Figma 디자인을 코드로 옮기거나, 색상·타이포·컴포넌트 동기화

**상세 워크플로는 [figma-implement/SKILL.md](figma-implement/SKILL.md)를 따른다.**

### 요약 (프로젝트 정본)

| Figma | 코드 위치 |
|-------|-----------|
| Color Style | `lib/app/theme/app_colors.dart` |
| Text Style | `lib/app/theme/app_text_styles.dart` |
| Spacing / Radius / Shadow | `app_spacing.dart`, `app_radius.dart`, `app_shadows.dart` |
| Component hex | `lib/app/theme/app_component_colors.dart` |
| Component 위젯 | `lib/shared/widgets/app_{name}.dart` |
| 위젯 프리뷰 | `SharedWidgetGalleryPage` (`/dev/widgets`) |

- 공용 위젯: `AppComponentColors` · 일반 화면: `AppColors`
- Canvas 시각화는 보조; **Flutter 실제 위젯이 정본**

---

## Skill 4: Supabase Data Layer

**언제**: CRUD, 인증 연동, Storage, Realtime 추가

### 절차

1. **상수**: `core/constants/`에 테이블·버킷 이름 정의

```dart
class SupabaseTables {
  const SupabaseTables._();
  static const refreshSessions = 'refresh_sessions';
}
```

2. **API 클래스**: `features/{feature}/data/api/{feature}_api.dart`

```dart
class RefreshApi {
  const RefreshApi();

  Future<void> saveSession(RefreshSession session) async {
    await SupabaseService.client
        .from(SupabaseTables.refreshSessions)
        .insert(session.toJson());
  }
}
```

3. **모델**: `data/model/` — `fromJson`/`toJson` 수동 구현, snake_case ↔ camelCase 매핑

4. **Page 연동**: API 인스턴스를 page state에서 호출, loading/error UI 처리

### 보안 체크

- [ ] `.env` 미커밋
- [ ] publishable key만 클라이언트 사용
- [ ] service role key 미포함
- [ ] RLS 정책 전제로 쿼리 설계
- [ ] `ui/widgets/`에 Supabase import 없음

---

## Skill 5: 공용 위젯 추가·수정

**언제**: `shared/widgets/` 컴포넌트 생성 또는 Figma Component 동기화

### 구현 규칙

- `StatelessWidget` 기본 (내부 상태 불필요 시)
- variant·size는 `enum`으로 정의 (`AppBoxButtonVariant` 패턴)
- 테마 import: `app_component_colors`, `app_text_styles`, `app_radius`
- feature 로직·Supabase 의존 금지
- props로 `onPressed`, `onChanged`, `controller` 등 콜백만 노출

### 파일 구조 예시

```text
lib/shared/widgets/
 ├─ app_box_button.dart
 ├─ app_text_field.dart
 ├─ shared_widgets.dart      # export barrel
 └─ shared_widget_gallery_page.dart  # dev 프리뷰 (선택)
```

### 수정 후

- 갤러리 페이지에 variant 추가 (있을 경우)
- `flutter analyze`로 import cycle 없는지 확인

---

## Skill 6: 작업 완료 검증 (Feedback Loop)

**언제**: 모든 코드 변경 후

### 필수 명령 (PowerShell)

```powershell
cd d:\lg_hair_refresher
dart format .
flutter analyze
flutter test
```

### 보고 형식

작업 요약에 아래를 포함:

- 변경 파일·feature 범위
- 실행한 검증 명령과 결과
- **검증하지 못한 항목** (예: 실기기 미연결, Supabase 스테이징 미확인)
- 사용자 요청 없이 커밋·push 하지 않음

### 테스트 추가 기준

- 사용자 요청 시 또는 의미 있는 동작(라우팅, API 변환, 위젯 상호작용) 변경 시
- `test/features/{feature}/` 또는 `test/shared/widgets/`에 배치
- trivial assert(test widget exists) 는 추가하지 않음

---

## Skill 7: Git · PR · 커밋

**언제**: 사용자가 커밋·PR 생성을 **명시적으로** 요청할 때만

### 커밋 메시지 (Conventional Commits)

```text
type(scope): summary
```

| type | 용도 |
|------|------|
| feat | 새 기능 |
| fix | 버그 수정 |
| docs | 문서만 |
| refactor | 동작 동일 리팩터 |
| test | 테스트만 |

예: `feat(measure): add measurement progress indicator`

### 브랜치 규칙

- GitHub Flow + Issue 단위 feature branch
- `main` 직접 작업·push 금지
- `git push --force` 금지 (특히 main)

### PR 생성 시

1. `git status`, `git diff`, `git log`, base branch 대비 diff 확인
2. 모든 커밋 포함하여 요약 작성
3. `gh pr create` — Summary + Test plan

---

## Skill 8: 범위 제어 · 금지 작업

**언제**: 요청이 모호하거나 범위가 커질 때

### 자동 확장 금지

| 요청 | 하지 말 것 |
|------|-----------|
| 버튼 색 수정 | 전체 theme 리팩터 |
| 한 화면 구현 | domain/repository 계층 추가 |
| 패키지 언급 없음 | pubspec.yaml 의존성 추가 |
| MVP feature 하나 | auth/device 등 빈 폴더 생성 |

### 사용자 확인이 필요한 경우

- 아키텍처 계층 추가 (repository, usecase 등)
- 새 패키지 도입 (Riverpod, freezed, bloc 등)
- `android/`/`ios/` 네이티브 설정 변경
- `main` 외 브랜치 전략 변경

---

## 빠른 참조

### MVP Feature 책임

| Feature | 책임 |
|---------|------|
| home | 대시보드, 최근 결과, 추천 |
| measure | 측정 시작·진행·결과 저장 |
| refresh | 모드 선택·실행·결과 저장 |
| history | 측정/리프레시 기록 조회 |
| settings | 계정, 알림, 권한, 외부 연동 |

### 핵심 흐름

```text
측정 → 상태 분석 → 모드 추천 → 리프레시 실행 → 결과 확인 → 사용기록 관리
```

### 관련 문서

| 문서 | 경로 |
|------|------|
| Agent 공용 지침 | `AGENTS.md` |
| Flutter 규칙 (Cursor Rule) | `.cursor/rules/flutter-guidelines.mdc` |
| Flutter 컨벤션 | `docs/conventions/flutter.md` |
| Agent 워크플로 | `docs/conventions/agent-workflow.md` |
| 아키텍처 결정 | `docs/decisions/0001-feature-first-architecture.md` |
| Supabase 결정 | `docs/decisions/0002-supabase-backend.md` |
| 테스트 전략 | `tests/README.md` |
