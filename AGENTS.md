# AGENTS.md

LG Hair Refresher 프로젝트에서 Cursor, ChatGPT, Copilot 등 AI Agent가 작업하기 전에 반드시 읽는 공용 지침입니다.

이 문서는 사람을 위한 제품 설명서가 아니라, Agent가 코드 생성, 수정, 리팩터링, 문서 작업을 할 때 지켜야 하는 행동 규칙입니다.

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
- 상태 관리는 Riverpod을 사용합니다.
- 라우팅은 go_router를 사용합니다.
- 백엔드는 Supabase를 기준으로 설계합니다.
- 데이터 모델 생성은 freezed, json_serializable, build_runner를 사용합니다.

핵심 사용자 흐름:

```text
측정 -> 상태 분석 -> 모드 추천 -> 리프레시 실행 -> 결과 확인 -> 사용기록 관리
```

## 3. 아키텍처

이 프로젝트는 feature-first 구조를 사용합니다.

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
- `lib/core/`: 전역 상수, 공통 예외, 공통 서비스, 유틸
- `lib/features/`: 기능별 코드
- `lib/shared/`: 여러 feature에서 재사용하는 모델, 위젯, provider

## 4. Feature 내부 구조

각 feature는 아래 구조를 기본으로 합니다.

```text
features/{feature_name}/
 ├─ data/
 │   ├─ datasources/
 │   ├─ models/
 │   └─ repositories/
 ├─ domain/
 │   ├─ entities/
 │   ├─ repositories/
 │   └─ usecases/
 └─ presentation/
     ├─ pages/
     ├─ widgets/
     └─ controllers/
```

계층 규칙:

- `presentation`: 화면, 위젯, 화면 상태 관리
- `domain`: entity, repository interface, usecase
- `data`: datasource, DTO/model, repository 구현체

호출 방향:

```text
Widget -> Controller/Provider -> UseCase -> Repository Interface -> Repository Implementation -> Datasource -> Supabase/API/Device
```

금지:

```text
Widget -> Supabase Client 직접 호출
Widget -> 외부 API 직접 호출
Widget -> 디바이스 통신 직접 호출
```

## 5. Feature 책임

- `auth`: 로그인, 회원가입, 로그아웃, 인증 상태
- `home`: 홈 대시보드, 최근 결과, 추천 정보
- `measure`: 측정 시작, 진행, 결과 저장
- `refresh`: 리프레시 모드 선택, 실행, 결과 저장
- `history`: 측정/리프레시 사용 기록 조회
- `settings`: 계정, 알림, 권한, 외부 연동
- `device`: 디바이스 검색, 연결, 상태, 명령 전송
- `recommendation`: 오염도 예측, 모드 추천, 환경/캘린더 분석
- `notification`: 알림 목록, 읽음 처리, 추천 알림 UI
- `consumable`: 필터, 향 카트리지, 배터리 상태 관리

특정 feature에만 필요한 코드는 해당 feature 안에 둡니다. 두 개 이상의 feature에서 실제로 재사용될 때만 `shared/` 이동을 검토합니다.

## 6. Import 규칙

- 다른 feature의 `data/` 구현체를 직접 import하지 않습니다.
- 다른 feature의 `presentation/controllers/`를 직접 import하지 않습니다.
- feature 간 공유가 필요하면 `shared/` 또는 `domain` interface를 사용합니다.
- 라우트 path는 `app/router` 또는 `core/constants`에서 관리합니다.
- Supabase table name, storage key는 `core/constants`에서 관리합니다.

## 7. Supabase 규칙

Supabase Client는 아래 위치에서만 사용합니다.

```text
features/{feature}/data/datasources/
core/services/supabase_service.dart
```

금지 위치:

```text
features/{feature}/presentation/
features/{feature}/domain/
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
- 화면은 `presentation/pages/`에 둡니다.
- feature 전용 위젯은 `presentation/widgets/`에 둡니다.
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

예시:

```text
home_page.dart
measure_result_page.dart
refresh_mode_card.dart
notification_settings_page.dart
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

- 라우팅은 go_router를 사용합니다.
- route string을 화면 위젯 안에서 직접 반복하지 않습니다.
- 공통 route path는 `app/router/app_router.dart` 또는 `core/constants/`에서 관리합니다.
- 하단 탭 구조는 `app/navigation/bottom_nav_shell.dart`에서 관리합니다.

## 11. 생성 코드 규칙

아래 파일은 직접 수정하지 않습니다.

```text
*.g.dart
*.freezed.dart
```

모델 변경 후 필요한 경우 아래 명령을 실행합니다.

```bash
dart run build_runner build --delete-conflicting-outputs
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

규칙:

- 화면 테스트는 `test/features/{feature}/presentation/`에 둡니다.
- 순수 비즈니스 로직 테스트는 `test/features/{feature}/domain/`에 둡니다.
- Supabase, 외부 API, 디바이스 통신은 fake 또는 mock을 사용합니다.

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

권장 브랜치명:

```text
feature/{issue-number}-{feature}-{summary}
fix/{issue-number}-{summary}
refactor/{issue-number}-{summary}
docs/{summary}
chore/{summary}
```

예시:

```text
feature/31-refresh-mode-list
fix/42-history-empty-state
docs/agent-guidelines
```

## 16. 커밋 메시지

Conventional Commits를 사용합니다.

형식:

```text
type(scope): summary
```

type:

- `feat`: 새로운 기능
- `fix`: 버그 수정
- `refactor`: 구조 개선
- `style`: UI 스타일 또는 포맷 수정
- `docs`: 문서 수정
- `test`: 테스트 추가/수정
- `chore`: 설정, 빌드, 패키지 작업

예시:

```bash
git commit -m "feat(home): add recent refresh card"
git commit -m "fix(history): handle empty refresh sessions"
git commit -m "docs: update agent workflow"
```

## 17. PR 규칙

PR에는 아래 내용을 포함합니다.

```md
## 작업 내용
- 

## 변경 화면
- 

## 확인 사항
- [ ] dart format .
- [ ] flutter analyze
- [ ] flutter test
- [ ] 라우팅 확인
- [ ] 에러 로그 없음
- [ ] Supabase 접근 위치 확인

## 관련 이슈
close #
```

권장:

- 하나의 PR은 하나의 기능 또는 하나의 수정만 포함합니다.
- 가능하면 300~500 changed lines 이하로 유지합니다.
- UI 변경이 있으면 스크린샷 또는 녹화를 첨부합니다.

## 18. 문서화 규칙

새로운 결정은 `docs/decisions/`에 기록합니다.

예시:

```text
docs/decisions/0003-refresh-mode-types.md
```

새로운 컨벤션은 `docs/conventions/`에 기록합니다.

예시:

```text
docs/conventions/supabase.md
docs/conventions/testing.md
```

결정 문서에는 최소한 아래 항목을 포함합니다.

```text
Status
Context
Decision
Consequences
```

## 19. Agent 작업 전 체크리스트

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

## 20. Agent 금지 사항

- 사용자 요청 없이 대규모 리팩터링하지 않습니다.
- 사용자 요청 없이 브랜치를 강제로 되돌리지 않습니다.
- 사용자 요청 없이 `pubspec.yaml`에 패키지를 추가하지 않습니다.
- Widget에서 Supabase를 직접 호출하지 않습니다.
- route string을 화면 곳곳에 하드코딩하지 않습니다.
- 생성 코드를 직접 수정하지 않습니다.
- secret, API key, service role key를 커밋하지 않습니다.
- 깨진 인코딩 문서를 그대로 두지 않습니다.

## 21. 기본 실행 명령

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart format .
flutter analyze
flutter test
flutter run
```

## 22. 최종 원칙

이 프로젝트의 목표는 기능 구현 속도보다 유지 가능한 공동 개발 구조를 우선하는 것입니다.

Agent는 다음 원칙을 지킵니다.

- Feature-First Architecture
- Small Pull Requests
- Centralized Routing
- Shared Design System
- Repository Pattern
- RLS-Based Data Security
- Consistent Naming
- Figma-Based UI Implementation
- Fast Feedback Loop
