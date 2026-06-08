# 0001. Feature-first Architecture

## Status

Accepted

## Context

LG Hair Refresher는 홈, 측정, 리프레시, 기록, 설정, 디바이스, 추천, 알림, 소모품처럼 기능 경계가 뚜렷합니다. 4인 이상이 동시에 개발할 예정이므로 기능별 작업 범위를 분리하고 Git 충돌을 줄이는 구조가 필요합니다.

## Decision

`lib/features/{feature_name}/` 중심의 feature-first 구조를 사용합니다. 각 feature 내부는 `data`, `domain`, `presentation` 계층으로 나눕니다.

공통 앱 설정은 `lib/app/`, 전역 기반 코드는 `lib/core/`, 여러 feature에서 재사용되는 요소는 `lib/shared/`에 둡니다.

## Consequences

- 팀원별 feature 브랜치 작업 범위가 명확해집니다.
- 특정 feature에만 필요한 코드가 전역 폴더로 퍼지는 것을 줄입니다.
- 공통화가 필요한 코드는 실제 재사용이 확인된 뒤 `shared/`로 이동합니다.
- feature 간 직접 참조를 남발하면 구조가 흐려지므로 PR에서 import 방향을 확인해야 합니다.
