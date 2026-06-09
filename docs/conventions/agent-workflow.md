# Agent Workflow

## Before Editing

1. 현재 Git 상태를 확인합니다.
2. `AGENTS.md`를 읽습니다.
3. 관련 README 섹션을 확인합니다.
4. 관련 `docs/decisions/` 문서를 확인합니다.
5. 변경 대상 feature의 기존 패턴을 확인합니다.

## While Editing

- 작은 단위로 변경합니다.
- 기존 사용자 변경을 되돌리지 않습니다.
- feature 내부 기본 구조는 `data/model`, `data/api`, `ui/page`, `ui/widgets`를 따릅니다.
- MVP feature는 `home`, `measure`, `refresh`, `history`, `settings`만 유지합니다.
- MVP 이후 feature는 실제 구현 요청이 있을 때 새로 추가합니다.
- Riverpod, freezed, build_runner 기반 생성 구조를 새로 추가하지 않습니다.
- Supabase 접근은 `data/api` 또는 `core/services`에 둡니다.
- 구조 규칙을 벗어나야 하면 먼저 이유를 문서화합니다.

## After Editing

```bash
dart format .
flutter analyze
flutter test
```

검증하지 못한 명령이 있으면 작업 보고에 명확히 적습니다.
