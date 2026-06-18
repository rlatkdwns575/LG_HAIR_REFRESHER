-- CALENDAR_EVENTS 테이블 및 RLS 정책
-- Supabase SQL Editor에서 실행하세요.

create table if not exists public."CALENDAR_EVENTS" (
  event_id uuid primary key,
  user_id uuid not null,
  title text not null default '',
  event_type text not null default 'none',
  starts_at timestamptz not null,
  ends_at timestamptz not null
);

create index if not exists calendar_events_user_starts_idx
  on public."CALENDAR_EVENTS" (user_id, starts_at);

alter table public."CALENDAR_EVENTS" enable row level security;

drop policy if exists "calendar_events_select_own" on public."CALENDAR_EVENTS";
create policy "calendar_events_select_own"
  on public."CALENDAR_EVENTS"
  for select
  using (auth.uid() = user_id);

drop policy if exists "calendar_events_insert_own" on public."CALENDAR_EVENTS";
create policy "calendar_events_insert_own"
  on public."CALENDAR_EVENTS"
  for insert
  with check (auth.uid() = user_id);

drop policy if exists "calendar_events_delete_own" on public."CALENDAR_EVENTS";
create policy "calendar_events_delete_own"
  on public."CALENDAR_EVENTS"
  for delete
  using (auth.uid() = user_id);
