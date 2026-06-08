# Flutter Conventions

## Naming

- Page: `{feature}_page.dart`
- Widget: `{role}_card.dart`, `{role}_button.dart`, `{role}_section.dart`
- Controller: `{feature}_controller.dart`
- Provider: `{meaningfulName}Provider`
- Model: 단수형 명사 사용

## Imports

- 같은 feature 내부 import를 우선합니다.
- 다른 feature의 내부 구현을 직접 import하지 않습니다.
- 공유가 필요하면 `shared/`로 이동하거나 domain interface를 둡니다.
- route path, table name, storage key는 하드코딩하지 않고 `core/constants/`에서 가져옵니다.

## UI

- Figma에서 정의된 색상, 폰트, 간격, 반경 값은 `lib/app/theme/`에 먼저 반영합니다.
- 여러 화면에서 재사용되는 UI는 `shared/widgets/`에 둡니다.
- feature 전용 UI는 해당 feature의 `presentation/widgets/`에 둡니다.
- 화면은 `presentation/pages/`에 둡니다.

## State

- 화면 상태와 사용자 액션은 `presentation/controllers/`에서 관리합니다.
- 앱 전역 상태는 `shared/providers/` 또는 적절한 `core/services/`와 연결합니다.
- 비즈니스 로직은 가능하면 `domain/usecases/`로 분리합니다.

## Generated Code

- Freezed와 json_serializable 생성 파일은 직접 수정하지 않습니다.
- 모델 변경 후 아래 명령을 실행합니다.

```bash
dart run build_runner build --delete-conflicting-outputs
```
