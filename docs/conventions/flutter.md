# Flutter Conventions

## Naming

- Page: `{feature}_page.dart`
- Widget: `{role}_card.dart`, `{role}_button.dart`, `{role}_section.dart`
- Model: 명확한 명사 사용
- API: `{feature}_api.dart` 또는 역할이 드러나는 이름 사용

## Imports

- 같은 feature 내부 import를 우선합니다.
- 다른 feature의 `data/api/` 구현체를 직접 import하지 않습니다.
- 공유가 필요하면 `shared/`로 이동합니다.
- route path, table name, storage key는 하드코딩하지 않고 `app/router` 또는 `core/constants/`에서 가져옵니다.

## UI

- Figma에서 정의한 색상, 폰트, 간격, 반경 값은 `lib/app/theme/`에 먼저 반영합니다.
- 여러 화면에서 재사용되는 UI는 `shared/widgets/`에 둡니다.
- feature 전용 UI는 해당 feature의 `ui/widgets/`에 둡니다.
- 화면은 `ui/page/`에 둡니다.

## State

- 화면 상태는 기본적으로 `StatefulWidget`에서 관리합니다.
- 단순한 탭, 필터, 선택 상태는 해당 page의 `State` 안에 둡니다.
- 여러 위젯에서 공유해야 하는 상태는 필요한 범위까지 끌어올립니다.
- 앱 전역 서비스 상태는 `core/services/`에서 명확한 API로 제공합니다.
- Riverpod provider와 controller 폴더를 기본 구조로 만들지 않습니다.

## Models

- 모델은 직접 Dart 클래스로 작성합니다.
- `fromJson`, `toJson`, `copyWith`가 필요하면 직접 구현합니다.
- `freezed`, `freezed_annotation`, `json_serializable`, `build_runner` 기반 생성 코드를 사용하지 않습니다.
