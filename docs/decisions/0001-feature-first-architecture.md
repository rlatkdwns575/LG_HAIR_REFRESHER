# 0001. Simple Feature-first Architecture

## Status

Accepted

## Context

초기 구조는 `data`, `domain`, `presentation` 안에 `datasources`, `models`, `repositories`, `entities`, `usecases`, `controllers`까지 미리 만드는 방식이었습니다. 현재 프로젝트 규모에서는 이 구조가 실제 구현보다 먼저 복잡도를 만들고, 팀원이 화면을 빠르게 이해하기 어렵게 만든다는 평가가 있었습니다.

또한 상태 관리는 Riverpod 대신 Flutter 기본 `StatefulWidget`을 사용하기로 했고, 모델 생성도 freezed 계열을 사용하지 않기로 했습니다.

## Decision

feature-first는 유지하되 각 feature 내부 구조를 아래처럼 단순화합니다.

```text
features/{feature_name}/
 ├─ data/
 │  ├─ model/
 │  └─ api/
 └─ ui/
    ├─ page/
    └─ widgets/
```

복잡한 domain/usecase/repository 계층은 기본으로 만들지 않습니다. 특정 feature가 커져서 분리가 필요해진 경우에만 해당 feature 안에서 필요한 만큼 추가합니다.

MVP에서는 아래 feature만 실제 폴더로 유지합니다.

```text
features/
 ├─ home/
 ├─ measure/
 ├─ refresh/
 ├─ history/
 └─ settings/
```

`auth`, `device`, `recommendation`, `notification`, `consumable`은 MVP 이후 확장 후보로 두고, 실제 구현 시점에 추가합니다.

## Consequences

- 새 기능의 초기 파일 수가 줄어듭니다.
- 화면과 데이터 연동 위치가 더 직관적으로 보입니다.
- 작은 팀과 초기 구현 단계에서 개발 속도가 빨라집니다.
- 복잡한 비즈니스 로직이 생긴 feature는 별도 문서화 후 구조를 확장해야 합니다.
- 구현하지 않는 feature의 빈 폴더가 줄어 MVP 범위가 더 명확해집니다.
