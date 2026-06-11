-- AUTH_USERS 프로필 컬럼 확장 (나이, 성별, 모발 정보).
-- Supabase SQL Editor에서 실행하세요.

ALTER TABLE public."AUTH_USERS"
  ADD COLUMN IF NOT EXISTS age SMALLINT,
  ADD COLUMN IF NOT EXISTS gender TEXT,
  ADD COLUMN IF NOT EXISTS hair_length TEXT,
  ADD COLUMN IF NOT EXISTS hair_type TEXT;

COMMENT ON COLUMN public."AUTH_USERS".age IS '사용자 나이 (14-80)';
COMMENT ON COLUMN public."AUTH_USERS".gender IS '성별 (남성/여성)';
COMMENT ON COLUMN public."AUTH_USERS".hair_length IS '모발 길이 (짧은머리/단발/중단발/장발)';
COMMENT ON COLUMN public."AUTH_USERS".hair_type IS '모발 유형 (직모/반곱슬/곱슬/웨이브/혼합형)';
