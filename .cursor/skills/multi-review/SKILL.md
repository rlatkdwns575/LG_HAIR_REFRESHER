---
name: multi-review
description: >-
  여러 독립적인 관점에서 병렬 리뷰를 수행합니다. 화면을 만들거나 여러 파일을
  동시에 수정한 직후에 호출하세요.
disable-model-invocation: true
---

# Multi-Review (다중 리뷰)

여러 독립적인 관점에서 병렬 리뷰를 수행하고, 결과를 사용자가 **빠르게 훑어보고 결정 가능한 형태**로 정리합니다.

## Parameters

- `$ARGUMENTS` — 첫 번째 숫자는 리뷰어 수 (없으면 default 3), 나머지는 리뷰 주제/대상

## Instructions

1. `$ARGUMENTS` 해석:
   - 첫 토큰이 숫자면 리뷰어 수 (N), 아니면 N=3
   - 나머지 전체를 리뷰 주제(focus topic)로 사용
   - 리뷰 대상은 주제에서 파악하거나, 직전 대화 컨텍스트에서 추론

2. 서로 다른 페르소나를 가진 리뷰어 N 명을 **병렬로** 실행합니다.

   기본 3명 구성:
   - Reviewer 1: **정확성 (Accuracy)** — 사실 관계, 기술적 정확성, 논리적 오류, 검증 가능한 주장 확인
   - Reviewer 2: **완전성 (Completeness)** — 누락된 정보, 빠진 엣지 케이스, 추가 필요 항목
   - Reviewer 3: **명확성 & 규칙 준수 (Clarity & Compliance)** — 구조, 가독성, 톤, 대상 독자 적합성. Flutter/Dart 코드인 경우 `.cursor/rules/flutter-guidelines.mdc` Rule 준수 여부도 검토

   4명 이상이면 주제에 맞게 추가 관점 할당 (예: 보안, 성능, UX, 비용, 리스크)

3. 각 리뷰어는 **이슈마다** 다음을 산출:
   - 구체적 위치(파일/라인/섹션) 참조
   - 심각도: HIGH / MEDIUM / LOW
   - **confidence (0~100)**: 이 이슈가 실제 문제일 자신감
   - **영향도 (0~100)**: 발생 시 사용자/시스템에 미치는 임팩트
   - 한 줄 요지 + 구체적 수정 방안 (단순 수정은 diff 스니펫 첨부)
   - 간결하게. 불필요한 반복이나 서론 없이

4. 모든 리뷰어 완료 후 결과 종합:
   - 명백한 false positive(다른 reviewer가 명시적으로 반박했거나 코드 근거상 안전한 항목)는 본문에서 제거하거나 `### 종합 단계에서 제거된 이슈` 섹션에 한 줄씩만 기록 (제거 이유 포함).
   - **결정 가치가 있는 이슈만** 남긴다.
   - 동일 이슈가 여러 리뷰어에서 나오면 하나로 병합하고, 가장 높은 confidence·영향도를 유지한다.
   - HIGH 이슈를 먼저, 그다음 MEDIUM, LOW 순으로 정렬한다.
   - 각 이슈에 **권장 조치**: `fix now` / `fix later` / `optional` 중 하나를 붙인다.

## 출력 형식

```markdown
# Multi-Review: {주제}

리뷰어 {N}명 · 대상: {파일/범위 요약}

## 요약 (3줄 이내)
- HIGH {n} · MEDIUM {n} · LOW {n}
- 가장 먼저 처리할 항목 1~2개

## 이슈

### [HIGH] {한 줄 제목}
- **위치**: `path:line` 또는 섹션명
- **confidence** {0-100} · **영향도** {0-100} · **권장**: fix now | fix later | optional
- **관점**: Accuracy | Completeness | Clarity & Compliance | …
- **요지**: …
- **수정**: …
- (선택) diff 스니펫

### 종합 단계에서 제거된 이슈
- {이슈 한 줄} — 제거 이유: …

## 다음 액션
1. …
2. …
```

## 실행 팁

- 리뷰 대상이 크면 `git diff` 또는 변경 파일 목록을 먼저 확정한 뒤 리뷰어를 돌린다.
- Flutter UI 작업이면 `shared/widgets/` 재사용 여부, theme 토큰 사용, Supabase 호출 위치를 Compliance 관점에서 반드시 본다.
- 구현 직후 품질 점검이 필요하면 `figma-implement` Step 3 셀프 체크 이후 이 스킬을 호출한다.
