# AGENTS.md

LG Hair Refresher 프로젝트에서 AI Agent가 작업하기 전에 반드시 읽는 공용 지침입니다.

이 문서는 제품 설명서가 아니라 코드 생성, 수정, 리팩터링, 문서 작업 시 지켜야 하는 작업 규칙입니다.

## 1. 우선순위

Agent는 아래 순서로 기준을 적용합니다.

```text
1. 현재 코드베이스
2. AGENTS.md
3. README.md
4. docs/decisions/
5. docs/conventions/
6. Figma 또는 기획 자료
```

코드와 문서가 충돌하면 먼저 현재 코드 구조를 확인하고, 필요한 경우 문서를 함께 수정합니다.

## 2. 프로젝트 기본

- Flutter 기반 모바일 앱입니다.
- Dart를 사용합니다.
- 화면 상태는 기본적으로 `StatefulWidget`과 Flutter 기본 상태 관리로 처리합니다.
- Riverpod은 사용하지 않습니다.
- 라우팅은 `go_router`를 사용합니다.
- 백엔드는 Supabase를 기준으로 설계합니다.
- 모델은 직접 Dart 클래스로 작성합니다.
- `freezed`, `freezed_annotation`, `build_runner` 기반 모델 생성은 사용하지 않습니다.

핵심 사용자 흐름:

```text
측정 -> 상태 분석 -> 모드 추천 -> 리프레시 실행 -> 결과 확인 -> 사용기록 관리
```

MVP 범위:

```text
home, measure, refresh, history, settings
```

MVP 이후 확장 후보:

```text
auth, device, recommendation, notification, consumable
```

## 3. 기본 구조

프로젝트는 feature-first를 유지하되, 과한 계층 분리를 피합니다.

```text
lib/
 ├─ main.dart
 ├─ app/
 ├─ core/
 ├─ features/
 └─ shared/
```

역할:

- `lib/main.dart`: 앱 시작점
- `lib/app/`: 앱 설정, 라우터, 테마, 하단 네비게이션
- `lib/core/`: 전역 상수, 공통 서비스, 공통 유틸
- `lib/features/`: MVP 기능별 코드
- `lib/shared/`: 여러 feature에서 실제로 재사용하는 모델과 위젯

## 4. Feature 내부 구조

각 feature는 아래 구조를 기본으로 합니다.

```text
features/{feature_name}/
 ├─ data/
 │   ├─ model/
 │   └─ api/
 └─ ui/
     ├─ page/
     └─ widgets/
```

역할:

- `data/model/`: 해당 feature에서 사용하는 요청/응답/화면 데이터 모델
- `data/api/`: Supabase, 외부 API, 디바이스 통신 코드
- `ui/page/`: 실제 화면 단위 위젯
- `ui/widgets/`: 해당 feature 안에서만 사용하는 UI 컴포넌트

복잡한 domain/usecase/repository 계층은 기본으로 만들지 않습니다. 실제 복잡도가 생긴 경우에만 필요한 만큼 추가하고, 추가 이유를 문서나 PR 설명에 남깁니다.

## 5. MVP Feature 책임

- `home`: 홈 대시보드, 최근 결과, 추천 정보
- `measure`: 측정 시작, 진행, 결과 저장
- `refresh`: 리프레시 모드 선택, 실행, 결과 저장
- `history`: 측정/리프레시 사용 기록 조회
- `settings`: 계정, 알림, 권한, 외부 연동

특정 feature에만 필요한 코드는 해당 feature 안에 둡니다. 두 개 이상의 feature에서 실제로 재사용될 때만 `shared/` 이동을 검토합니다.

MVP 이후 확장 feature는 실제 구현 시점에 새로 추가합니다. 빈 feature 폴더를 미리 만들지 않습니다.

## 6. Import 규칙

- 다른 feature의 `data/api/` 구현체를 직접 import하지 않습니다.
- feature 간 공유가 필요하면 `shared/`로 이동하거나 명확한 공통 모델을 둡니다.
- route path는 `app/router` 또는 `core/constants`에서 관리합니다.
- Supabase table name, storage key는 `core/constants`에서 관리합니다.

## 7. Supabase 규칙

Supabase Client는 아래 위치에서만 사용합니다.

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

보안 규칙:

- `.env`는 커밋하지 않습니다.
- Supabase service role key는 Flutter 앱에 넣지 않습니다.
- production secret은 클라이언트 코드에 노출하지 않습니다.
- 사용자 데이터 테이블은 RLS 적용을 전제로 설계합니다.

## 8. UI와 디자인 시스템

- Figma 기준 색상, 폰트, 간격, 반경, 그림자는 `lib/app/theme/`에 먼저 반영합니다.
- 화면은 `ui/page/`에 둡니다.
- feature 전용 위젯은 `ui/widgets/`에 둡니다.
- 여러 feature에서 재사용하는 위젯은 `shared/widgets/`에 둡니다.
- 색상, spacing, radius, shadow 값을 화면에서 반복 하드코딩하지 않습니다.

기본 theme 파일:

```text
lib/app/theme/app_colors.dart
lib/app/theme/app_text_styles.dart
lib/app/theme/app_spacing.dart
lib/app/theme/app_radius.dart
lib/app/theme/app_shadows.dart
```

## 9. 네이밍 규칙

Dart 파일명:

```text
lower_snake_case.dart
```

클래스명:

```text
PascalCase
```

변수명, 함수명, enum 값:

```text
lowerCamelCase
```

Supabase:

```text
table: snake_case plural
column: snake_case
```

## 10. 라우팅 규칙

- 라우팅은 `go_router`를 사용합니다.
- route string을 화면 위젯 안에서 직접 반복하지 않습니다.
- 공통 route path는 `app/router/app_router.dart` 또는 `core/constants/`에서 관리합니다.
- 하단 탭 구조는 `app/navigation/bottom_nav_shell.dart`에서 관리합니다.

## 11. 생성 코드 규칙

이 프로젝트는 `freezed`, `json_serializable`, `build_runner` 기반 생성 코드를 사용하지 않습니다.

아래 파일이 생기면 직접 수정하지 말고, 생성 의존성이 필요한지 먼저 검토합니다.

```text
*.g.dart
*.freezed.dart
```

## 12. 절대 주의할 파일과 디렉토리

명시 요청 없이 삭제하거나 되돌리지 않습니다.

```text
.git/
.metadata
pubspec.lock
android/
ios/
web/
windows/
macos/
linux/
```

커밋 대상이 아닌 산출물:

```text
build/
.dart_tool/
```

## 13. 패키지 추가 규칙

`pubspec.yaml`에 패키지를 추가할 때는 아래 내용을 함께 설명합니다.

- 패키지명
- 추가 이유
- 기존 패키지로 대체할 수 없는 이유
- 영향을 받는 feature
- 플랫폼 설정 필요 여부

패키지 추가 후 실행:

```bash
flutter pub get
flutter analyze
flutter test
```

## 14. 테스트와 피드백 루프

실제 Flutter 테스트 파일은 루트 `test/` 폴더에 둡니다.

`tests/` 폴더는 테스트 전략, 체크리스트, CI 기준을 문서화하는 지식 저장소입니다.

작업 후 기본 검증:

```bash
dart format .
flutter analyze
flutter test
```

테스트 배치:

```text
test/
 ├─ app/
 ├─ core/
 ├─ features/
 └─ shared/
```

## 15. Git 브랜치 규칙

기본 전략:

```text
GitHub Flow + Issue 단위 Feature Branch + Pull Request
```

금지:

- `main` 직접 작업
- `main` 직접 push
- 리뷰 없는 merge
- `git push --force`

## 16. 커밋 메시지

Conventional Commits를 사용합니다.

```text
type(scope): summary
```

예시:

```bash
git commit -m "feat(home): add recent refresh card"
git commit -m "fix(history): handle empty refresh sessions"
git commit -m "docs: update agent workflow"
```

## 17. Agent 작업 체크리스트

작업 시작 전:

- 현재 Git 상태 확인
- 관련 파일과 폴더 구조 확인
- `README.md` 확인
- `AGENTS.md` 확인
- 관련 `docs/decisions/` 확인
- 관련 `docs/conventions/` 확인

작업 중:

- 작은 단위로 수정
- 기존 코드 스타일 유지
- 팀원이 작업한 변경 되돌리지 않기
- feature 책임을 넘는 변경은 문서화

작업 후:

- `dart format .`
- `flutter analyze`
- `flutter test`
- 변경 내용 요약
- 검증하지 못한 항목 명시

## 18. Agent 금지 사항

- 사용자 요청 없이 대규모 리팩터링하지 않습니다.
- 사용자 요청 없이 브랜치를 강제로 되돌리지 않습니다.
- 사용자 요청 없이 `pubspec.yaml`에 패키지를 추가하지 않습니다.
- Widget에서 Supabase를 직접 호출하지 않습니다.
- route string을 화면 곳곳에 하드코딩하지 않습니다.
- 생성 코드를 직접 수정하지 않습니다.
- secret, API key, service role key를 커밋하지 않습니다.
- 깨진 인코딩 문서를 그대로 두지 않습니다.

## 19. 기본 실행 명령

```bash
flutter pub get
dart format .
flutter analyze
flutter test
flutter run
```

## 20. 최종 원칙

이 프로젝트는 유지 가능한 공동 개발 구조를 우선합니다. 다만 현재 단계에서는 과한 계층 분리보다 단순한 feature-first 구조와 빠른 피드백 루프를 우선합니다.

Agent는 다음 원칙을 지킵니다.

- Simple Feature-First Structure
- StatefulWidget First
- Centralized Routing
- Shared Design System
- Supabase Access in data/api
- RLS-Based Data Security
- Consistent Naming
- Figma-Based UI Implementation
- Fast Feedback Loop
