# Feedback Loop

이 폴더는 Agent와 팀원이 작업 결과를 빠르게 검증하기 위한 피드백 루프 문서 저장소입니다.

Flutter의 실제 테스트 파일은 프레임워크 규칙에 따라 루트 `test/` 폴더에 둡니다. 이 `tests/` 폴더는 테스트 전략, 체크리스트, CI 센서 기준을 문서화합니다.

## Guide

올바른 방향을 안내하는 장치입니다.

- `test/widget_test.dart`: 앱 기본 shell이 정상적으로 렌더링되는지 확인
- feature별 예제 테스트: 새 기능을 만들 때 `test/features/{feature_name}/`에 추가
- README의 사용자 흐름: 측정 -> 상태 분석 -> 모드 추천 -> 리프레시 실행 -> 결과 확인

## Sensor

잘못된 행동을 감지하는 장치입니다.

- `flutter analyze`
- `flutter test`
- `dart format .`
- PR 리뷰
- 향후 GitHub Actions CI

## Local Check

작업 완료 전 아래 명령을 실행합니다.

```bash
dart format .
flutter analyze
flutter test
```

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

- 화면 동작 테스트는 `test/features/{feature_name}/presentation/`에 둡니다.
- 순수 비즈니스 로직 테스트는 `test/features/{feature_name}/domain/`에 둡니다.
- 공통 유틸 테스트는 `test/core/` 또는 `test/shared/`에 둡니다.
- 외부 API, Supabase, 디바이스 통신은 테스트에서 직접 호출하지 않고 fake 또는 mock을 사용합니다.
