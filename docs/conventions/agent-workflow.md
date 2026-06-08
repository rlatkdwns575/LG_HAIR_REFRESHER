# Agent Workflow

## Before Editing

1. `AGENTS.md`를 읽습니다.
2. 관련 README 섹션을 확인합니다.
3. 관련 `docs/decisions/` 문서를 확인합니다.
4. 변경 대상 feature의 기존 패턴을 확인합니다.
5. 현재 Git 변경 상태를 확인합니다.

## While Editing

- 작은 단위로 변경합니다.
- 팀원이 작성한 파일을 임의로 되돌리지 않습니다.
- 새 의존성을 추가하면 이유와 사용 위치를 남깁니다.
- 구조 규칙이 애매하면 먼저 `docs/decisions/`에 결정 기록을 남깁니다.

## After Editing

```bash
dart format .
flutter analyze
flutter test
```

검증하지 못한 명령이 있으면 PR 또는 작업 보고에 명확히 적습니다.
