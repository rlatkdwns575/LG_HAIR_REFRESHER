-- 개발용 AUTH_USERS 더미 프로필.
-- UID는 .env DEV_USER_ID 와 동일하게 맞춥니다.
--
-- 실행 순서:
-- 1) auth_users_profile_columns.sql
-- 2) dev_read_policies.sql
-- 3) 이 파일

INSERT INTO public."AUTH_USERS" (
  user_id,
  email,
  nickname,
  age,
  gender,
  hair_length,
  hair_type
) VALUES (
  '3fa85f64-5717-4562-b3fc-2c963f66afa6',
  'dev.user@example.com',
  '테스트유저',
  24,
  '여성',
  '중단발',
  '웨이브'
)
ON CONFLICT (user_id) DO UPDATE SET
  email = EXCLUDED.email,
  nickname = EXCLUDED.nickname,
  age = EXCLUDED.age,
  gender = EXCLUDED.gender,
  hair_length = EXCLUDED.hair_length,
  hair_type = EXCLUDED.hair_type;
