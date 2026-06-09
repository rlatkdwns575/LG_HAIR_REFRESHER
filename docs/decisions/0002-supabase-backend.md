# 0002. Supabase Backend

## Status

Accepted

## Context

앱은 사용자 인증, 측정 기록, 리프레시 기록, 소모품 상태, 파일 저장, 실시간 디바이스 상태 반영이 필요합니다.

## Decision

백엔드는 Supabase를 기준으로 설계합니다.

- Auth: 로그인, 회원가입, 세션 관리
- PostgreSQL: 사용자 정보, 측정 기록, 리프레시 기록, 소모품 상태
- Storage: 프로필 이미지, 리포트 이미지
- Realtime: 디바이스 상태와 측정 진행 상태
- Edge Functions: 추천 로직, 외부 API 중계
- RLS: 사용자별 데이터 접근 제어

## Consequences

- Supabase 초기화는 `core/services/supabase_service.dart`에서 시작합니다.
- table name과 storage key는 `core/constants/`에서 관리합니다.
- feature별 쿼리와 변환 로직은 `features/{feature}/data/api/`에 둡니다.
- 화면 위젯과 `ui/widgets/`에서는 Supabase Client를 직접 호출하지 않습니다.
