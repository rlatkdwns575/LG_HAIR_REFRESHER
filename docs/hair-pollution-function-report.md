# 헤어 오염도 함수 보고서

작성 기준: 2026-06-22

이 문서는 LG Hair Refresher 앱에서 냄새, 먼지, 종합 오염도, 모발 상태가 어떻게 계산되고 화면에 표시되는지 정리합니다.

## 1. 전체 구조

헤어 오염도 로직은 크게 두 흐름입니다.

| 흐름 | 역할 | 대표 파일 |
| --- | --- | --- |
| 측정 오염도 | 측정 결과를 만들고, 냄새/먼지/종합 점수를 화면 상태로 바꿉니다. | `measure_diagnosis_generator.dart`, `measure_api.dart`, `measure_result_mapper.dart` |
| 리프레시 개선도 | 리프레시 실행 전후 점수를 만들고, 제거율/개선율을 계산합니다. | `refresh_session_result_generator.dart`, `history_session_mapper.dart` |

앱에서 쓰는 주요 점수:

| 점수 | DB/모델 필드 | 의미 |
| --- | --- | --- |
| 냄새 점수 | `hair_odor_score`, `hairOdorScore` | 머리카락에 남은 외부 냄새 정도입니다. 높을수록 케어 필요도가 큽니다. |
| 먼지 점수 | `hair_dust_score`, `hairDustScore` | 머리카락에 남은 먼지 정도입니다. 높을수록 케어 필요도가 큽니다. |
| 종합 오염 점수 | `total_pollution_score`, `totalPollutionScore` | 리프레시 필요도 기준 점수입니다. 현재는 냄새/먼지 중 더 높은 값을 기준으로 쓰는 구조입니다. |
| 모발 손상도 | `hair_damage_score`, `hairDamageScore` | 모발 상태가 오염 잔류 영향에 얼마나 영향을 주는지 계산할 때 씁니다. |
| 모발 유분량 | `hair_sebum`, `hairSebum` | 모발 상태 상세 badge 표시용입니다. |
| 모발 굵기 | `hair_thickness`, `hairThickness` | 모발 상태 상세 badge 표시용입니다. |
| 냄새 유형 | `smell_type`, `smellType` | 냄새 상세 섹션에서 태그/badge로 표시합니다. |

## 2. 관련 파일

### 측정 쪽

| 파일 | 역할 |
| --- | --- |
| `lib/features/measure/data/api/measure_diagnosis_generator.dart` | 현재 측정 분석 단계에서 고오염 샘플 점수를 생성합니다. 실제 센서/AI 결과가 붙기 전 mock 성격이 있습니다. |
| `lib/features/measure/data/api/measure_api.dart` | 측정 결과를 `MEASURE_RESULTS`에 저장하고, 최신 측정 결과를 조회합니다. |
| `lib/features/measure/data/model/measure_result_record.dart` | Supabase row를 Dart 모델로 바꿉니다. 오염도 원본 데이터 모델입니다. |
| `lib/features/measure/data/api/measure_result_mapper.dart` | 오염 점수를 케어 단계, badge, 설명 문구, 상세 화면 데이터로 바꿉니다. |
| `lib/features/measure/data/model/measure_care_level.dart` | 냄새/먼지 케어 필요도 enum입니다. |
| `lib/features/measure/data/model/measure_result_detail.dart` | 측정 상세 화면에서 쓸 냄새/먼지/모발 섹션을 조립합니다. |
| `lib/features/measure/data/measure_result_visual_mapper.dart` | 냄새/먼지 상태 조합에 맞는 결과 이미지를 고릅니다. |
| `lib/shared/utils/metric_badge_mapper.dart` | 오염도 점수와 모발 상태를 badge label/variant로 바꿉니다. |

### 리프레시/기록 쪽

| 파일 | 역할 |
| --- | --- |
| `lib/features/refresh/data/api/refresh_session_result_generator.dart` | 리프레시 전후 냄새/먼지 점수, 제거율, 종합 개선율을 생성합니다. |
| `lib/features/refresh/data/model/refresh_pollution_level.dart` | 리프레시 결과 차트에서 쓰는 오염도 단계입니다. |
| `lib/features/history/data/api/history_session_mapper.dart` | 리프레시 세션 row의 before/after 점수를 기록 화면 상태로 변환합니다. |

## 3. 측정 오염도 생성 함수

파일: `lib/features/measure/data/api/measure_diagnosis_generator.dart`

현재 측정 분석 단계는 실제 센서 결과가 아니라 `generateHighPollution()`으로 샘플 고오염 점수를 만듭니다.

```dart
final hairOdorScore = 66 + rng.nextInt(20);
final hairDustScore = 66 + rng.nextInt(20);
final totalPollutionScore = max(hairOdorScore, hairDustScore).clamp(60, 100);
```

의미:

| 값 | 범위/계산 | 설명 |
| --- | --- | --- |
| `hairOdorScore` | 66~85 | 냄새 점수입니다. 항상 높은 편으로 생성됩니다. |
| `hairDustScore` | 66~85 | 먼지 점수입니다. 항상 높은 편으로 생성됩니다. |
| `totalPollutionScore` | `max(냄새, 먼지)` 후 60~100 제한 | 냄새와 먼지 중 더 심한 값을 종합 오염 점수로 씁니다. |
| `hairDamageScore` | `Low`, `Medium`, `High` 중 랜덤 | 모발 손상도입니다. |
| `hairThickness` | 얇음/중간/굵음 성격의 값 중 랜덤 | 모발 굵기입니다. 일부 문자열은 현재 인코딩 깨짐이 있습니다. |
| `hairSebum` | `Low`, `Medium`, `High` 중 랜덤 | 모발 유분량입니다. |
| `smellType` | 냄새 유형 pool에서 1~2개 | 쉼표로 연결되어 저장됩니다. |

주의:

- 이 함수는 실제 측정 알고리즘이라기보다 MVP용 샘플 데이터 생성기에 가깝습니다.
- 항상 고오염 점수를 만들기 때문에, 실제 센서/AI 연동 시 교체 대상입니다.

## 4. 측정 결과 저장/조회

파일: `lib/features/measure/data/api/measure_api.dart`

저장 컬럼:

```text
measure_id
user_device_id
hair_dust_score
hair_odor_score
total_pollution_score
hair_damage_score
hair_thickness
hair_sebum
smell_type
created_at
```

주요 함수:

| 함수 | 역할 |
| --- | --- |
| `insertDiagnosisResult` | 생성된 오염도 payload를 Supabase `MEASURE_RESULTS`에 저장합니다. |
| `fetchLatestResult` | 사용자의 연결 기기 기준 가장 최근 측정 결과를 가져옵니다. |
| `hasRecentResult` | 최근 2시간 안에 측정 결과가 있는지 확인합니다. |
| `_fetchUserDeviceLink` | 로그인 사용자와 연결된 `user_device_id`를 찾습니다. |

초보자 기준 흐름:

1. 측정 분석 화면에서 오염도 payload 생성
2. `MeasureApi.insertDiagnosisResult` 호출
3. Supabase `MEASURE_RESULTS`에 저장
4. 저장된 row를 `MeasureResultRecord.fromJson`으로 Dart 객체로 변환
5. 이후 mapper가 화면용 상태로 변환

## 5. 오염도 점수 -> 케어 단계

핵심 파일:

- `lib/features/measure/data/api/measure_result_mapper.dart`
- `lib/features/history/data/api/history_session_mapper.dart`
- `lib/features/measure/data/model/measure_care_level.dart`

점수는 0~100입니다. 높을수록 오염/케어 필요도가 큽니다.

### 5.1 점수 기준표

`HistorySessionMapper.fromPollutionScore()` 기준:

| 점수 | `CareStatus` | `MeasureCareLevel` | 쉬운 의미 |
| --- | --- | --- | --- |
| `0~25` | `good` | `notRequired` | 좋음, 케어 거의 필요 없음 |
| `26~45` | `normal` | `normal` | 보통 |
| `46~65` | `recommend` | `recommended` | 케어 권장 |
| `66~85` | `focusedRecommend` | `intensiveRecommended` | 집중 케어 권장 |
| `86~100` | `focusedRequired` | `intensiveRequired` | 집중 케어 필요 |

관련 함수:

```dart
MeasureResultMapper.careLevelFromPollutionScore(score)
MeasureResultMapper.odorLevel(record)
MeasureResultMapper.dustLevel(record)
```

### 5.2 화면용 간단 badge

`MeasureCareLevel.simpleViewBadgeLabel` 기준:

| 단계 | 화면 badge 의미 |
| --- | --- |
| `notRequired` | 좋음 |
| `normal` | 보통 |
| `recommended` | 약간나쁨 |
| `intensiveRecommended` | 나쁨 |
| `intensiveRequired` | 매우나쁨 |

현재 코드 일부 한글 문자열은 인코딩이 깨져 있으나, 테스트와 의도상 위 5단계 구조입니다.

## 6. 오염도 점수 -> badge label

파일: `lib/shared/utils/metric_badge_mapper.dart`

`MetricBadgeMapper.pollutionScoreLabel(score)` 기준:

| 점수 | label | variant |
| --- | --- | --- |
| `0~25` | 매우낮음 | `low` |
| `26~45` | 낮음 | `low` |
| `46~65` | 보통 | `medium` |
| `66~85` | 높음 | `high` |
| `86~100` | 매우높음 | `veryHigh` |

관련 함수:

| 함수 | 역할 |
| --- | --- |
| `pollutionScoreLabel` | 숫자 점수를 텍스트 label로 바꿉니다. |
| `pollutionScoreVariant` | 숫자 점수를 badge 색상 variant로 바꿉니다. |
| `pollutionScoreStepUp` | 점수에 `+12`를 더하고 0~100으로 제한합니다. 냄새 인지 가능도 계산에 사용됩니다. |

예시:

```text
10 -> 매우낮음
35 -> 낮음
55 -> 보통
75 -> 높음
90 -> 매우높음
```

## 7. 리프레시 필요도 계산

파일: `lib/features/measure/data/api/measure_result_mapper.dart`

### 7.1 실제 측정 record가 있을 때

```dart
static int refreshNeedPercent(MeasureResultRecord record) {
  return record.totalPollutionScore.clamp(0, 100);
}
```

의미:

- 리프레시 필요도는 `totalPollutionScore`를 그대로 씁니다.
- 0보다 작거나 100보다 큰 값은 0~100 안으로 제한합니다.
- 권장 기준선은 `recommendedThresholdPercent = 60`입니다.

### 7.2 측정 record가 없고 단계만 있을 때

```dart
notRequired -> 15
normal -> 45
recommended -> 55
intensiveRecommended -> 68
intensiveRequired -> 82
```

냄새와 먼지 중 더 높은 추정 점수를 리프레시 필요도로 씁니다.

```dart
return odorScore > dustScore ? odorScore : dustScore;
```

## 8. 냄새/먼지/모발 상세 섹션

파일: `lib/features/measure/data/model/measure_result_detail.dart`

`MeasureResultDetail.fromMeasureResult()`가 측정 record를 화면 상세 데이터로 바꿉니다.

### 8.1 요약 값

| 화면 값 | 계산 |
| --- | --- |
| `refreshNeedPercent` | `record.totalPollutionScore.clamp(0, 100)` |
| `odorNeedPercent` | `record.hairOdorScore.clamp(0, 100)` |
| `dustNeedPercent` | `record.hairDustScore.clamp(0, 100)` |
| `hairImpactPercent` | `MeasureResultMapper.hairImpactPercent(record)` |
| `refreshFocusLabel` | `MeasureResultMapper.focusLabel(record)` |

### 8.2 냄새 섹션

사용 값:

- `hairOdorScore`
- `pollutionScoreLabel(hairOdorScore)`
- `pollutionScoreVariant(hairOdorScore)`
- `pollutionScoreStepUp(hairOdorScore)` for 냄새 인지 가능도
- `smellType`

냄새 인지 가능도:

```dart
odorPerceptionScore = (hairOdorScore + 12).clamp(0, 100)
```

예시:

```text
냄새 점수 66 -> 인지 가능도 78
```

### 8.3 먼지 섹션

사용 값:

- `hairDustScore`
- `pollutionScoreLabel(hairDustScore)`
- `pollutionScoreVariant(hairDustScore)`

먼지 섹션에서는 현재 먼지량과 분포 범위가 같은 `hairDustScore` 기준으로 표시됩니다.

### 8.4 모발 섹션

사용 값:

- `hairDamageScore`
- `hairSebum`
- `hairThickness`
- `totalPollutionScore`

모발 오염 잔류 영향:

```dart
MeasureResultMapper.pollutionRetentionBadge(record)
```

내부적으로 `hairImpactPercent(record)`를 사용합니다.

## 9. 모발 영향도 계산

파일: `lib/features/measure/data/api/measure_result_mapper.dart`

함수:

```dart
static int hairImpactPercent(MeasureResultRecord record)
```

계산 기준:

| `hairDamageScore` | 반환값 |
| --- | --- |
| `low` | 15 |
| `medium` | 30 |
| `high` | 45 |
| 그 외/없음 | `totalPollutionScore * 0.3`, 반올림 후 0~100 제한 |

예시:

```text
hairDamageScore = Low -> 15%
hairDamageScore = Medium -> 30%
hairDamageScore = High -> 45%
totalPollutionScore = 76, damage 없음 -> round(76 * 0.3) = 23%
```

오염 잔류 영향 badge:

| `hairImpactPercent` | label |
| --- | --- |
| `0~20` | 낮음 |
| `21~35` | 보통 |
| `36~100` | 높음 |

## 10. 집중 리프레시 방향 계산

파일: `lib/features/measure/data/api/measure_result_mapper.dart`

함수:

```dart
static String focusLabel(MeasureResultRecord record)
```

계산:

| 조건 | 결과 |
| --- | --- |
| `hairDustScore > hairOdorScore + 5` | 먼지 중심의 집중 리프레시 |
| `hairOdorScore > hairDustScore + 5` | 냄새 중심의 집중 리프레시 |
| 그 외 | 균형 맞춤 리프레시 |

예시:

```text
냄새 66, 먼지 76 -> 먼지가 10점 높음 -> 먼지 중심
냄새 80, 먼지 70 -> 냄새가 10점 높음 -> 냄새 중심
냄새 70, 먼지 73 -> 차이가 5 이하 -> 균형
```

## 11. 냄새 유형 파싱

파일: `lib/features/measure/data/api/measure_result_mapper.dart`

함수:

```dart
parseSmellTypes(String? raw)
```

구분자:

```text
쉼표 ,
슬래시 /
파이프 |
```

예시:

```text
"음식,땀" -> ["음식", "땀"]
"음식/담배" -> ["음식", "담배"]
"음식|기타" -> ["음식", "기타"]
```

`smellTypeMetric(record)`는 냄새 유형이 1개면 badge 하나로 표시하고, 여러 개면 앞쪽은 tag, 마지막은 badge로 표시합니다.

## 12. 측정 결과 이미지 선택

파일: `lib/features/measure/data/measure_result_visual_mapper.dart`

냄새 단계와 먼지 단계 조합으로 결과 이미지를 고릅니다.

핵심 함수:

```dart
MeasureResultVisualMapper.assetPath({
  required MeasureCareLevel odorLevel,
  required MeasureCareLevel dustLevel,
})
```

동작:

1. `odorLevel.simpleViewBadgeLabel|dustLevel.simpleViewBadgeLabel` 조합 key 생성
2. 정확히 매칭되는 이미지가 있으면 사용
3. 없으면 심각도 index 기준 fallback 이미지 사용

심각도 index:

| 단계 | index |
| --- | --- |
| `notRequired` | 0 |
| `normal` | 1 |
| `recommended` | 2 |
| `intensiveRecommended` | 3 |
| `intensiveRequired` | 4 |

## 13. 리프레시 전후 오염도 계산

파일: `lib/features/refresh/data/api/refresh_session_result_generator.dart`

리프레시 실행 결과는 측정 baseline이 있으면 그 점수를 before로 사용하고, 없으면 랜덤 기본 범위를 사용합니다.

### 13.1 before 점수

| 항목 | baseline 있음 | baseline 없음 |
| --- | --- | --- |
| 냄새 before | `baseline.hairOdorScore` | 60~80 랜덤 |
| 먼지 before | `baseline.hairDustScore` | 55~75 랜덤 |
| 향기 전용 모드 | `baseline.totalPollutionScore` | 20 |

### 13.2 제거율

```dart
sampleRemoval(random)
```

범위:

```text
30.0% ~ 40.0%
0.1 단위
```

코드 기준:

```dart
minRemovalTenths = 300
maxRemovalTenths = 400
return tenths / 10.0
```

### 13.3 after 점수

```dart
after = before * (1 - removalPercent / 100)
```

코드:

```dart
return (before * (1 - removalPercent / 100)).round().clamp(18, 100);
```

특징:

- 최소 after 점수는 18입니다.
- 제거율이 커도 18 아래로 내려가지 않습니다.

예시:

```text
before = 72
removal = 35.0%
after = round(72 * 0.65) = 47
```

### 13.4 전체 개선율

```dart
overall = average(odorRemoval, dustRemoval)
```

동작:

- 냄새만 관리하는 모드면 냄새 제거율이 전체 개선율입니다.
- 먼지만 관리하는 모드면 먼지 제거율이 전체 개선율입니다.
- 냄새+먼지 모드면 두 제거율 평균입니다.
- 소수점 한 자리로 반올림합니다.

### 13.5 종합 오염 점수

```dart
computePollutionScore({int? odor, int? dust, int? fallback})
```

계산:

| 조건 | 결과 |
| --- | --- |
| 냄새/먼지 값 있음 | 둘 중 최댓값 |
| 둘 다 없음 | fallback |
| fallback도 없음 | 기본값 20 |

예시:

```text
odor 72, dust 61 -> 72
odor 40, dust 55 -> 55
```

## 14. 리프레시 차트 오염도 단계

파일: `lib/features/refresh/data/api/refresh_session_result_generator.dart`

함수:

```dart
pollutionLevelFromScore(int score)
```

| 점수 | `RefreshPollutionLevel` | 의미 |
| --- | --- | --- |
| `0~25` | `good` | 좋음 |
| `26~45` | `normal` | 보통 |
| `46~85` | `high` | 나쁨 |
| `86~100` | `veryHigh` | 매우 나쁨 |

주의:

- 측정 상세 badge는 5단계입니다.
- 리프레시 결과 차트는 4단계입니다.
- 즉, `66~85`는 측정에서는 “높음/집중 권장”, 리프레시 차트에서는 “나쁨”으로 묶입니다.

## 15. 기록 화면의 개선율 계산

파일: `lib/features/history/data/api/history_session_mapper.dart`

리프레시 기록에서 before/after 점수로 필요도 감소율을 계산합니다.

```dart
delta = ((before - after) / before) * 100
```

조건:

- before 또는 after가 없으면 계산하지 않습니다.
- before가 0 이하이면 계산하지 않습니다.
- 결과는 0~100으로 제한합니다.
- 냄새와 먼지 둘 다 있으면 평균을 냅니다.

예시:

```text
냄새 before 78, after 24 -> 약 69.2%
먼지 before 52, after 20 -> 약 61.5%
평균 -> 약 65.4%
```

## 16. 현재 테스트로 확인되는 기준

관련 테스트:

| 테스트 파일 | 확인 내용 |
| --- | --- |
| `test/features/measure/measure_result_db_mapper_test.dart` | 오염 점수 -> 케어 단계, badge label, 모발 영향도, focus label |
| `test/features/measure/measure_result_detail_test.dart` | 상세 화면의 냄새/먼지/모발 섹션 값 |
| `test/features/measure/measure_result_visual_mapper_test.dart` | 냄새/먼지 조합별 결과 이미지 선택 |
| `test/features/measure/measure_diagnosis_generator_test.dart` | 샘플 진단 payload에 smell_type 포함 여부 |
| `test/features/refresh/refresh_session_result_generator_test.dart` | 리프레시 제거율 30~40%, after 점수, 종합 오염 점수 |
| `test/features/history/history_session_mapper_test.dart` | 오염 점수 -> 기록 상태, before/after 개선율 |

## 17. 리스크와 개선 제안

### 리스크

| 항목 | 내용 |
| --- | --- |
| 실제 측정 알고리즘 부재 | 현재 `generateHighPollution()`은 랜덤 고오염 mock 데이터입니다. 실제 기기/센서 연동이 필요합니다. |
| 한글 인코딩 깨짐 | 일부 코드와 테스트 문자열이 깨져 있어 라벨 의미 파악과 유지보수가 어렵습니다. |
| 단계 기준 중복 | 측정 5단계, 리프레시 차트 4단계, history 상태 변환이 각각 흩어져 있습니다. |
| 종합 점수 공식 단순함 | 현재 종합 오염도는 사실상 냄새/먼지 중 최댓값입니다. 가중 평균, 사용자 민감도, 일정/날씨 반영은 별도 추천 로직에서 보조적으로 처리됩니다. |
| 모발 영향도 단순함 | 손상도가 있으면 15/30/45로 고정되고, 없을 때만 `total * 0.3`을 씁니다. |

### 개선 제안

1. 오염도 단계 기준을 `core` 또는 `shared`의 단일 정책 파일로 모으기
2. `generateHighPollution()`을 `MockMeasureDiagnosisGenerator`처럼 이름을 바꿔 실제 알고리즘과 구분하기
3. 실제 센서/AI 연동 시 입력/출력 계약 문서화하기
4. `totalPollutionScore` 공식 결정하기: `max`, 가중 평균, 사용자 프로필 반영 중 선택
5. 깨진 한글 라벨 복구 후 테스트 기대값도 정상 한글로 정리하기

