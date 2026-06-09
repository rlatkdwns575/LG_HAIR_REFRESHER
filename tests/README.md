# Feedback Loop

이 폴더는 테스트 전략, 체크리스트, CI 기준을 문서화하는 지식 저장소입니다.

실제 Flutter 테스트 파일은 루트 `test/` 폴더에 둡니다.

## Guide

- `test/widget_test.dart`: 앱 기본 shell이 정상적으로 렌더링되는지 확인합니다.
- feature별 테스트는 기능이 생길 때 `test/features/{feature_name}/` 아래에 추가합니다.
- 핵심 사용자 흐름: 측정 -> 상태 분석 -> 모드 추천 -> 리프레시 실행 -> 결과 확인

## Sensor

- `dart format .`
- `flutter analyze`
- `flutter test`
- PR 리뷰
- 향후 GitHub Actions CI

## Test Placement

```text
test/
 ├─ widget_test.dart
 ├─ app/
 ├─ core/
 ├─ features/
 └─ shared/
```

규칙:

- 화면 동작 테스트는 `test/features/{feature_name}/ui/`에 둡니다.
- 순수 비즈니스 로직 테스트는 해당 feature의 실제 구조에 맞춰 배치합니다.
- 공통 유틸 테스트는 `test/core/` 또는 `test/shared/`에 둡니다.
- 외부 API, Supabase, 디바이스 통신은 테스트에서 직접 호출하지 않고 fake 또는 mock을 사용합니다.
