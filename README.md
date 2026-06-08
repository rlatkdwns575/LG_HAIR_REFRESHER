# LG Hair Refresher

> 향으로 덮지 않고, 공기로 비워내는 헤어 리프레시 경험

**LG Hair Refresher**는 헤어 리프레셔 디바이스와 연동하여 사용자의 모발·두피 상태를 측정하고, 먼지·냄새·오염도 데이터를 기반으로 적절한 리프레시 모드를 추천하며, 실행 결과와 사용 기록을 관리하는 Flutter 기반 모바일 앱입니다.

---

## 0. 팀원 및 담당 역할

| 이름 | 담당 역할 | 주요 업무 |
| --- | --- | --- |
| 김상준 | 개발 | Flutter 앱 구조 설계, 홈·측정 기능 구현, Supabase 연동 구조 설계 |
| 지소명 | 개발 | Flutter 앱 화면 구현, 측정·리프레시·사용기록 기능 개발 |
| 염혜인 | 디자인 / 기획 | 서비스 기획, 사용자 흐름 설계, UI/UX 디자인, Figma 화면 설계 |
| 이지우 | 딥러닝 모델 및 모델링 | 측정 데이터 기반 분석 모델 설계 및 모델링 |
| 한정민 | 딥러닝 모델 및 모델링 | 딥러닝 모델 학습, 결과 분석 및 모델 개선 |

---

## 1. 프로젝트 목적

일상생활에서 머리를 바로 감기 어렵거나, 감기에는 애매하지만 냄새·먼지·찝찝함이 남는 상황을 해결하는 것이 목적입니다.

이 앱은 다음 흐름을 하나의 제품 경험으로 연결합니다.

```text
측정 → 상태 분석 → 모드 추천 → 리프레시 실행 → 결과 확인 → 사용기록 관리
```

사용자는 앱을 통해 현재 모발·두피 상태를 확인하고, 상황에 맞는 리프레시 모드를 선택하거나 추천받을 수 있습니다. 실행 후에는 케어 전후의 오염도 차이를 확인하고, 누적된 사용 기록을 기반으로 개인화된 추천을 받을 수 있습니다.

---

## 2. 핵심 기능

### 2.1 홈

사용자의 현재 상태와 추천 행동을 빠르게 확인하는 대시보드입니다.

```text
홈
 ├─ 최근 리프레시 결과
 ├─ 최근 측정 결과
 ├─ 측정 가능 추천
 ├─ 외부 환경 기반 추천
 └─ 자주 사용하는 모드 기반 추천
```

주요 기능:

- 최근 리프레시 전후 오염도 차이 표시
- 최근 측정 결과 요약 표시
- 오늘의 외부 환경 기반 헤어 오염도 예측
- 사용 패턴 기반 자주 사용하는 모드 추천
- 현재 상태에 따른 측정 또는 리프레시 추천

---

### 2.2 측정

모발·두피 상태를 측정하고 결과를 확인합니다.

```text
측정
 ├─ 현재 헤어 상태 측정
 ├─ 측정 진행
 └─ 측정 결과 확인
```

측정 항목:

```text
- 종합 오염도
- 헤어 냄새
- 헤어 먼지
- 헤어 손상도
- 헤어 길이
- 헤어 굵기
```

측정 결과는 Supabase에 저장되며, 홈 화면 추천과 사용기록 화면에서 활용됩니다.

---

### 2.3 리프레시

추천 모드 또는 전체 모드 중 하나를 선택하여 디바이스 케어를 실행합니다.

```text
리프레시
 ├─ 추천 모드 확인
 ├─ 전체 모드 선택
 ├─ 실행 확인
 ├─ 리프레시 진행
 └─ 결과 확인
```

#### 기본 리프레시 모드

| 모드명 | 코드명 | 권장 시간 | 풍량 / 강도 | 주요 목적 |
| --- | --- | ---: | --- | --- |
| 퀵 리프레시 | `quickRefresh` | 1분 | 강 | 짧은 시간 안에 냄새와 답답함을 빠르게 완화 |
| 만남 전 케어 | `meetingCare` | 2분 | 중 | 사람을 만나기 전 냄새 완화와 헤어 정돈 |
| 취침 전 케어 | `sleepCare` | 3분 | 약 ~ 중 | 취침 전 저자극 두피·모발 정돈 |
| 외출 후 케어 | `outdoorCare` | 5분 | 강 ~ 중 | 외부 활동 후 먼지, 땀, 음식 냄새 집중 제거 |

#### 모드별 케어 단계

| 모드명 | 케어 단계 |
| --- | --- |
| 퀵 리프레시 | 흡입 20초 → 고속 송풍 30초 → 마무리 송풍 10초 |
| 만남 전 케어 | 표면 먼지 제거 30초 → 냄새 완화 60초 → 볼륨 정돈 30초 |
| 취침 전 케어 | 저자극 송풍 60초 → 두피 진정 케어 90초 → 잔여 냄새 제거 30초 |
| 외출 후 케어 | 강력 흡입 60초 → 이물질 제거 90초 → 탈취 송풍 90초 → 마무리 건조 60초 |

---

### 2.4 사용기록

측정 결과와 리프레시 결과를 날짜별로 확인합니다.

```text
사용기록
 ├─ 측정 결과 기록
 ├─ 리프레시 결과 기록
 ├─ 사용 이력
 └─ 자주 사용한 모드
```

주요 기능:

- 날짜별 측정 기록 조회
- 날짜별 리프레시 기록 조회
- 리프레시 전후 오염도 변화 확인
- 자주 사용한 모드 분석
- 주간 / 월간 사용 추이 확인

---

### 2.5 설정 / 연동

디바이스, 캘린더, 외부 환경 데이터, 알림, 소모품 상태를 관리합니다.

```text
설정 / 연동
 ├─ 디바이스 연동
 ├─ 캘린더 연동
 ├─ 외부 환경 데이터 연동
 ├─ 알림 설정
 └─ 소모품 관리
```

주요 기능:

- 헤어 리프레셔 디바이스 연결 관리
- Google Calendar 연동 설정
- 날씨 / 환경 데이터 기반 추천 설정
- 추천 알림 및 소모품 교체 알림 설정
- 필터, 향 카트리지, 배터리 상태 관리

---

## 3. 기술 스택

### 3.1 Frontend

| 기술 | 역할 |
| --- | --- |
| Flutter | 크로스 플랫폼 모바일 앱 개발 프레임워크 |
| Dart | Flutter 앱 개발 언어 |
| go_router | 홈, 측정, 리프레시, 기록, 설정 등 화면 이동 및 라우팅 관리 |
| flutter_riverpod | 앱 상태 관리, 화면 상태 관리, 의존성 주입 |
| freezed | 불변 데이터 모델, 상태 클래스, union/sealed class 생성 |
| freezed_annotation | Freezed 코드 생성을 위한 annotation 패키지 |
| json_serializable | Supabase 및 외부 API JSON 직렬화 / 역직렬화 |
| json_annotation | JSON 변환 코드 생성을 위한 annotation 패키지 |
| build_runner | Freezed, json_serializable 코드 생성 실행 도구 |

Frontend 주요 목적:

```text
- Figma 디자인 기반 Flutter UI 구현
- 하단 탭 기반 화면 구조 구현
- 측정 / 리프레시 / 기록 / 설정 화면 개발
- Supabase 데이터 연동
- 디바이스 및 외부 API 연동 결과 표시
```

---

### 3.2 Backend

이 프로젝트의 백엔드는 **Supabase로 고정**합니다.

| 기술 | 역할 |
| --- | --- |
| Supabase Auth | 사용자 인증, 로그인, 회원가입, 세션 관리 |
| Supabase PostgreSQL | 사용자 정보, 측정 기록, 리프레시 기록, 소모품 상태 저장 |
| Supabase Storage | 리포트 이미지, 프로필 이미지 등 파일 저장 |
| Supabase Realtime | 디바이스 상태, 측정 진행 상태 등 실시간 데이터 반영 |
| Supabase Edge Functions | 추천 로직, 외부 API 중계, 서버 측 처리 |
| Supabase RLS | 사용자별 데이터 접근 제어 및 보안 정책 관리 |

---

### 3.3 External Integration

| 연동 대상 | 역할 |
| --- | --- |
| Hair Refresher Device | 측정 실행, 센서 데이터 수집, 리프레시 모드 실행 |
| Weather / Environment API | 기온, 습도, 강수확률, 풍속 등 외부 환경 데이터 수집 |
| Google Calendar API | 일정 기반 헤어 오염도 예측 및 추천 |
| Notification Service | 추천 알림, 소모품 교체 알림, 사용 시간대 알림 |
| LG Official Store Link | 필터, 향 카트리지 등 소모품 구매 연결 |

---

### 3.4 Design & AI-assisted Development

| 도구 | 역할 |
| --- | --- |
| Figma | 화면 설계, 디자인 시스템, UI 컴포넌트 관리 |
| Figma MCP | Figma 디자인 정보를 Cursor 또는 AI Agent가 읽을 수 있도록 연결 |
| Cursor | Figma MCP 기반 Flutter UI 코드 생성 및 리팩토링 보조 |

Figma MCP는 Flutter 내부 라이브러리가 아니라, 디자인을 코드로 옮기는 과정을 보조하는 개발 워크플로우 도구입니다. 따라서 Frontend 기술 스택과 분리하여 관리합니다.

---

## 4. 개발 방식

### 4.1 브랜치 전략

이 프로젝트는 **GitHub Flow 기반 브랜치 전략**을 사용합니다.

```text
main
 ├─ feature/home
 ├─ feature/measure
 ├─ feature/refresh
 ├─ feature/history
 ├─ feature/settings
 └─ feature/device
```

기본 규칙:

- `main` 브랜치는 항상 실행 가능한 상태로 유지합니다.
- 모든 기능 개발은 `feature/{기능명}` 브랜치에서 진행합니다.
- Pull Request를 통해 코드 리뷰 후 `main`에 병합합니다.
- 병합 전에는 충돌 해결, 포맷팅, 기본 실행 테스트를 완료합니다.
- 기능 브랜치는 가능하면 작게 유지하고, 장기간 방치하지 않습니다.

---

### 4.2 커밋 메시지 규칙

```text
feat: 새로운 기능 추가
fix: 버그 수정
refactor: 코드 구조 개선
style: 코드 포맷팅, UI 스타일 수정
docs: 문서 수정
test: 테스트 코드 추가 및 수정
chore: 설정, 패키지, 빌드 관련 작업
```

예시:

```text
feat: add refresh mode selection page
fix: resolve bottom navigation route issue
docs: update README folder structure
```

---

## 5. 폴더 구조

이 프로젝트는 **feature-first 구조**를 사용합니다. 기능 단위로 코드를 분리하여 팀원별 개발 범위를 명확히 하고, Git 충돌을 줄이는 것을 목표로 합니다.

```text
lib/
 ├─ main.dart
 │
 ├─ app/
 │   ├─ app.dart
 │   ├─ router/
 │   │   └─ app_router.dart
 │   ├─ theme/
 │   │   ├─ app_colors.dart
 │   │   ├─ app_text_styles.dart
 │   │   ├─ app_spacing.dart
 │   │   ├─ app_radius.dart
 │   │   └─ app_shadows.dart
 │   └─ navigation/
 │       └─ bottom_nav_shell.dart
 │
 ├─ core/
 │   ├─ constants/
 │   ├─ errors/
 │   ├─ exceptions/
 │   ├─ extensions/
 │   ├─ utils/
 │   └─ services/
 │       ├─ supabase_service.dart
 │       └─ notification_service.dart
 │
 ├─ features/
 │   ├─ auth/
 │   ├─ home/
 │   ├─ measure/
 │   ├─ refresh/
 │   ├─ history/
 │   ├─ settings/
 │   ├─ device/
 │   ├─ recommendation/
 │   ├─ notification/
 │   └─ consumable/
 │
 └─ shared/
     ├─ models/
     ├─ widgets/
     └─ providers/
```

---

## 6. 폴더별 역할

### 6.1 `main.dart`

앱의 시작점입니다.

주요 역할:

```text
- Flutter 앱 실행
- Supabase 초기화
- 알림 서비스 초기화
- Riverpod ProviderScope 설정
```

---

### 6.2 `app/`

앱 전체의 뼈대를 관리합니다.

```text
app/
 ├─ app.dart
 ├─ router/
 ├─ theme/
 └─ navigation/
```

| 폴더 / 파일 | 역할 |
| --- | --- |
| `app.dart` | `MaterialApp.router` 설정, 앱 테마 적용, 전역 앱 설정 |
| `router/` | go_router 기반 화면 이동 경로 관리 |
| `theme/` | 색상, 폰트, 간격, 반경, 그림자 등 디자인 시스템 관리 |
| `navigation/` | 하단 탭 네비게이션 구조 관리 |

---

### 6.3 `core/`

앱 전체에서 공통으로 사용하는 기반 코드를 관리합니다.

```text
core/
 ├─ constants/
 ├─ errors/
 ├─ exceptions/
 ├─ extensions/
 ├─ utils/
 └─ services/
```

| 폴더 | 역할 |
| --- | --- |
| `constants/` | 앱 전역 상수, Supabase 테이블명, route path, storage key 관리 |
| `errors/` | 앱에서 처리할 실패 상태 정의 |
| `exceptions/` | 실제 코드 실행 중 발생하는 예외 정의 |
| `extensions/` | DateTime, String, BuildContext 등 확장 메서드 관리 |
| `utils/` | 날짜 포맷터, 검증 함수, 공통 계산 함수 관리 |
| `services/` | Supabase, 알림 등 전역 서비스 초기화 관리 |

주의 사항:

```text
특정 기능에만 속하는 로직은 core에 넣지 않습니다.
예: 디바이스 연결 로직 → features/device
예: 캘린더 분석 로직 → features/recommendation
예: 소모품 구매 연결 → features/consumable 또는 features/settings
```

---

### 6.4 `features/`

앱의 주요 기능을 feature 단위로 관리합니다.

```text
features/
 ├─ auth/
 ├─ home/
 ├─ measure/
 ├─ refresh/
 ├─ history/
 ├─ settings/
 ├─ device/
 ├─ recommendation/
 ├─ notification/
 └─ consumable/
```

| Feature | 역할 |
| --- | --- |
| `auth/` | 로그인, 회원가입, 로그아웃, 인증 상태 관리 |
| `home/` | 홈 대시보드, 최근 결과, 추천 정보 표시 |
| `measure/` | 모발·두피 측정, 측정 진행, 측정 결과 저장 |
| `refresh/` | 리프레시 모드 선택, 실행, 진행률 표시, 결과 저장 |
| `history/` | 측정 기록, 리프레시 기록, 사용 이력 조회 |
| `settings/` | 계정, 알림, 권한, 외부 연동, 앱 설정 관리 |
| `device/` | 헤어 리프레셔 디바이스 검색, 연결, 상태 관리, 명령 전송 |
| `recommendation/` | 헤어 오염도 예측, 모드 추천, 외부 환경·캘린더 데이터 분석 |
| `notification/` | 알림 목록, 알림 읽음 처리, 추천 알림 UI 관리 |
| `consumable/` | 필터, 향 카트리지, 배터리 등 소모품 상태 관리 |

---

### 6.5 `shared/`

여러 feature에서 재사용하는 공통 요소를 관리합니다.

```text
shared/
 ├─ models/
 ├─ widgets/
 └─ providers/
```

| 폴더 | 역할 |
| --- | --- |
| `models/` | 여러 feature에서 함께 사용하는 공통 모델 |
| `widgets/` | 공통 버튼, 카드, 로딩, 에러, 빈 상태 화면 등 UI 컴포넌트 |
| `providers/` | 여러 feature에서 공유하는 Riverpod Provider |

---

## 7. Feature 내부 구조

각 feature는 아래 구조를 기본으로 사용합니다.

```text
features/{feature_name}/
 ├─ data/
 │   ├─ datasources/
 │   ├─ models/
 │   └─ repositories/
 │
 ├─ domain/
 │   ├─ entities/
 │   ├─ repositories/
 │   └─ usecases/
 │
 └─ presentation/
     ├─ pages/
     ├─ widgets/
     └─ controllers/
```

| 폴더 | 역할 |
| --- | --- |
| `data/datasources/` | Supabase, 외부 API, 디바이스 등 실제 데이터 출처와 통신 |
| `data/models/` | DB/API 응답 구조와 매칭되는 데이터 모델 정의 |
| `data/repositories/` | datasource를 통해 가져온 데이터를 앱에서 쓰기 좋게 변환 |
| `domain/entities/` | 앱 내부 비즈니스 로직에서 사용하는 핵심 객체 정의 |
| `domain/repositories/` | 데이터 접근 규칙을 추상화한 repository interface 정의 |
| `domain/usecases/` | 사용자의 행동 단위에 해당하는 기능 로직 정의 |
| `presentation/pages/` | 실제 화면 단위 위젯 관리 |
| `presentation/widgets/` | 해당 feature 안에서만 사용하는 UI 컴포넌트 관리 |
| `presentation/controllers/` | Riverpod 기반 화면 상태 및 사용자 액션 관리 |

---

## 8. 주요 Feature 책임

### 8.1 `features/home`

홈 대시보드 화면을 담당합니다.

```text
- 최근 리프레시 결과 표시
- 최근 측정 결과 표시
- 측정 가능 추천
- 외부 환경 기반 추천
- 자주 사용하는 모드 기반 추천
```

---

### 8.2 `features/measure`

측정 시작, 진행, 결과 확인을 담당합니다.

```text
- 측정 가이드
- 측정 실행
- 측정 진행 상태 관리
- 측정 결과 저장
- 측정 결과 기반 추천 연결
```

---

### 8.3 `features/refresh`

리프레시 모드 선택, 실행, 결과 확인을 담당합니다.

```text
- 추천 모드 표시
- 전체 모드 표시
- 리프레시 모드별 권장 시간 / 풍량 / 케어 단계 표시
- 리프레시 실행
- 일시 정지 / 재개 / 중단
- 리프레시 결과 저장
```

---

### 8.4 `features/history`

사용자의 기록 조회를 담당합니다.

```text
- 측정 기록 조회
- 리프레시 기록 조회
- 사용 이력 조회
- 자주 사용한 모드 분석
- 날짜별 기록 필터링
```

---

### 8.5 `features/settings`

설정과 외부 연동을 담당합니다.

```text
- 디바이스 연동 설정
- 캘린더 연동 설정
- 외부 환경 데이터 연동 설정
- 계정 관리
- 알림 설정
- 소모품 관리
```

---

### 8.6 `features/device`

디바이스 연결과 명령 전송을 담당합니다.

```text
- 디바이스 검색
- 디바이스 연결
- 연결 상태 관리
- 센서 데이터 수신
- 측정 시작 명령 전송
- 리프레시 시작 / 중단 명령 전송
```

---

### 8.7 `features/recommendation`

추천 및 예측 로직을 담당합니다.

```text
- 오늘의 헤어 오염도 예측
- 리프레시 모드 추천
- 사용 패턴 분석
- 외부 환경 데이터 분석
- 캘린더 일정 기반 상황 분석
```

---

### 8.8 `features/notification`

사용자 알림 기능을 담당합니다.

```text
- 추천 알림 표시
- 오염도 예측 알림 표시
- 소모품 교체 알림 표시
- 알림 기록 조회
- 알림 읽음 처리
```

---

### 8.9 `features/consumable`

소모품 상태 관리를 담당합니다.

```text
- 필터 상태 관리
- 향 카트리지 상태 관리
- 배터리 상태 관리
- 교체 시점 예측
- 소모품 구매 연결
```

---

## 9. 실행 및 코드 생성

### 9.1 패키지 설치

```bash
flutter pub get
```

### 9.2 코드 생성

Freezed와 json_serializable을 사용하는 경우 아래 명령어를 실행합니다.

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 9.3 앱 실행

```bash
flutter run
```

---

## 10. 개발 시 주의 사항

- Figma에서 정의된 색상, 폰트, 간격, 반경 값은 `app/theme/`에 먼저 반영합니다.
- Figma MCP로 생성된 화면 코드는 `features/{feature_name}/presentation/pages/` 또는 `widgets/`에 배치합니다.
- 여러 화면에서 재사용되는 UI는 `shared/widgets/`로 이동합니다.
- 특정 feature에서만 사용하는 UI는 해당 feature의 `presentation/widgets/`에 둡니다.
- Supabase 테이블명, route path, storage key 등은 `core/constants/`에서 관리합니다.
- 디바이스 연결, 추천 로직, 소모품 로직은 `core`가 아니라 해당 feature 내부에서 관리합니다.
- `main` 브랜치에는 실행 가능한 코드만 병합합니다.

## 11. 기대 효과

- 머리를 감기 어려운 상황에서도 빠르게 위생감을 회복할 수 있습니다.
- 냄새를 향으로 덮는 방식이 아니라, 공기 기반 리프레시 경험을 제공합니다.
- 측정 결과와 사용 기록을 통해 사용자가 자신의 헤어 상태를 지속적으로 관리할 수 있습니다.
- 디바이스와 앱을 연결하여 퍼스널 케어 데이터를 축적할 수 있습니다.
- LG 생활가전 생태계 안에서 개인 맞춤형 케어 경험으로 확장할 수 있습니다.
