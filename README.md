# LG Hair Refresher

LG Hair Refresher는 헤어 리프레셔 디바이스와 연동해 모발/두피 상태를 측정하고, 상태와 환경 정보를 기반으로 리프레시 모드를 추천하며, 실행 결과와 사용 기록을 관리하는 Flutter 모바일 앱입니다.

## 핵심 흐름

```text
측정 -> 상태 분석 -> 모드 추천 -> 리프레시 실행 -> 결과 확인 -> 사용기록 관리
```

## 기술 스택

| 영역 | 기술 |
| --- | --- |
| App | Flutter, Dart |
| 화면 상태 | StatefulWidget |
| Routing | go_router |
| Backend | Supabase |
| Design | Figma 기반 디자인 시스템 |

## 폴더 구조

```text
lg_hair_refresher/
 ├─ lib/
 │  ├─ main.dart                 # Supabase 초기화 후 runApp
 │  ├─ app/
 │  │  ├─ app.dart              # MaterialApp, safe area builder
 │  │  ├─ layout/               # 540dp max-width shell, page backgrounds
 │  │  ├─ navigation/           # AppSystemInsets 등 레이아웃 inset
 │  │  ├─ router/               # go_router, AppNavigation 확장
 │  │  └─ theme/                # Figma 디자인 토큰, ThemeData
 │  ├─ core/
 │  │  ├─ constants/            # route path, image asset, Supabase table
 │  │  ├─ models/               # feature 공통 모델 (예: user_hair_profile)
 │  │  ├─ services/             # Supabase, 캘린더, auth session 등
 │  │  ├─ utils/
 │  │  ├─ extensions/
 │  │  ├─ errors/
 │  │  └─ exceptions/
 │  ├─ features/
 │  │  ├─ auth/                 # 로그인·회원가입 (data/api, ui/page)
 │  │  ├─ home/                 # 홈 대시보드, 추천, 바로가기
 │  │  ├─ measure/              # 측정·진단·결과
 │  │  ├─ refresh/             # 리프레시 모드·실행·결과
 │  │  ├─ history/              # 사용 기록·캘린더 리포트
 │  │  └─ settings/             # 계정·디바이스·캘린더 연동
 │  └─ shared/
 │     ├─ models/                # 2개 이상 feature에서 쓰는 모델
 │     ├─ utils/
 │     └─ widgets/              # AppBoxButton, AppConfirmDialog 등
 ├─ assets/
 │  ├─ fonts/
 │  └─ images/                  # auth, common, home, measure, refresh, history
 ├─ test/                       # Flutter 단위·위젯 테스트
 │  ├─ app/
 │  ├─ core/
 │  ├─ features/
 │  └─ shared/
 ├─ docs/
 │  ├─ conventions/
 │  └─ decisions/
 ├─ tests/                      # 테스트 전략·체크리스트 문서
 └─ scripts/                    # Figma·에셋 보조 스크립트
```

## Feature 구조

각 feature는 기본적으로 아래처럼 단순하게 구성합니다.

```text
features/{feature_name}/
 ├─ data/
 │  ├─ model/
 │  └─ api/
 └─ ui/
    ├─ page/
    └─ widgets/
```

역할:

- `data/model/`: 해당 feature의 데이터 모델
- `data/api/`: Supabase, 외부 API, 디바이스 통신 코드
- `ui/page/`: 화면 단위 위젯
- `ui/widgets/`: feature 전용 UI 컴포넌트

복잡한 domain/usecase/repository 계층은 기본으로 만들지 않습니다. 실제로 복잡도가 커진 feature에서만 필요한 만큼 추가합니다.

## 주요 기능

- `auth`: 로그인, 이메일 로그인, 회원가입
- `home`: 디바이스 상태, 추천 배너, 퀵 리프레시, 최근 진단
- `measure`: 모발/두피 상태 측정과 결과 저장
- `refresh`: 리프레시 모드 선택, 실행, 결과 저장
- `history`: 측정/리프레시 사용 기록 조회
- `settings`: 계정, 디바이스, 로컬 캘린더, 알림 설정

MVP 이후 확장 후보:

- `device`: 디바이스 검색, 연결, BLE 명령 전송
- `recommendation`: 오염도 예측, 환경/캘린더 기반 추천 고도화
- `notification`: 알림 목록과 푸시 연동
- `consumable`: 필터, 향 카트리지, 배터리 상태 관리

## 개발 규칙

- 화면 상태는 우선 `StatefulWidget`으로 관리합니다.
- Supabase 접근은 `features/{feature}/data/api/` 또는 `core/services/`에 둡니다.
- 화면 위젯에서 Supabase Client를 직접 호출하지 않습니다.
- route path는 `app/router` 또는 `core/constants`에서 관리합니다.
- Figma 기준 색상, 폰트, 간격, 반경, 그림자는 `lib/app/theme/`에 먼저 반영합니다.
- 여러 feature에서 실제로 재사용하는 위젯만 `shared/widgets/`로 이동합니다.

## 실행

```bash
flutter pub get
flutter run
```

## 검증

```bash
dart format .
flutter analyze
flutter test
```

## 문서

- 아키텍처 결정: `docs/decisions/`
- 개발 컨벤션: `docs/conventions/`
- Agent 작업 규칙: `AGENTS.md`
