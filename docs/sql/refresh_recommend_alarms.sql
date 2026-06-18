-- REFRESH_RECOMMEND_ALARMS: 리프레시 추천 알림(루틴).
--
-- ⚠️ 저장이 안 되고 "row-level security" 오류가 나면
--    아래 RLS 정책 블록을 Supabase SQL Editor에서 실행하세요.
--    앱은 auth.uid()와 동일한 user_id로만 insert/select/update/delete 합니다.
--    → 반드시 이메일 로그인 후 저장해야 합니다 (DEV_USER_ID만으로는 RLS 통과 불가).

create table if not exists "REFRESH_RECOMMEND_ALARMS" (
  alarm_id    uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users (id) on delete cascade,
  mode_id     uuid not null references "REFRESH_MODE" (mode_id),
  alarm_time  time not null,
  repeat_days int2[] not null default '{}',   -- 1=월 ~ 7=일 (DateTime.weekday)
  is_enabled  boolean not null default true,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index if not exists refresh_recommend_alarms_user_id_idx
  on "REFRESH_RECOMMEND_ALARMS" (user_id);

alter table "REFRESH_RECOMMEND_ALARMS" enable row level security;

create policy "refresh_recommend_alarms_select_own"
  on "REFRESH_RECOMMEND_ALARMS" for select
  using (auth.uid() = user_id);

create policy "refresh_recommend_alarms_insert_own"
  on "REFRESH_RECOMMEND_ALARMS" for insert
  with check (auth.uid() = user_id);

create policy "refresh_recommend_alarms_update_own"
  on "REFRESH_RECOMMEND_ALARMS" for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "refresh_recommend_alarms_delete_own"
  on "REFRESH_RECOMMEND_ALARMS" for delete
  using (auth.uid() = user_id);
