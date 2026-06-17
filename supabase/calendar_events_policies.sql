-- CALENDAR_EVENTS RLS policies for LG Hair Refresher MVP
-- Run in Supabase SQL Editor after table creation.

alter table public."CALENDAR_EVENTS" enable row level security;

drop policy if exists "calendar_events_select_own" on public."CALENDAR_EVENTS";
create policy "calendar_events_select_own"
  on public."CALENDAR_EVENTS"
  for select
  to authenticated
  using (auth.uid() = user_id);

drop policy if exists "calendar_events_insert_own" on public."CALENDAR_EVENTS";
create policy "calendar_events_insert_own"
  on public."CALENDAR_EVENTS"
  for insert
  to authenticated
  with check (auth.uid() = user_id);

drop policy if exists "calendar_events_delete_own" on public."CALENDAR_EVENTS";
create policy "calendar_events_delete_own"
  on public."CALENDAR_EVENTS"
  for delete
  to authenticated
  using (auth.uid() = user_id);
