-- Development-only read policies for LG Hair Refresher MVP.
-- Run in Supabase Dashboard → SQL Editor when the app sees 0 rows via publishable key.
--
-- Symptom in app logs:
--   AUTH_USERS=missing, USER_DEVICES(any visible)=0
-- Cause: RLS enabled without SELECT policy for anon/authenticated roles.

-- AUTH_USERS
ALTER TABLE public."AUTH_USERS" ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS dev_read_auth_users ON public."AUTH_USERS";
CREATE POLICY dev_read_auth_users ON public."AUTH_USERS"
  FOR SELECT TO anon, authenticated
  USING (true);

-- USER_DEVICES
ALTER TABLE public."USER_DEVICES" ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS dev_read_user_devices ON public."USER_DEVICES";
CREATE POLICY dev_read_user_devices ON public."USER_DEVICES"
  FOR SELECT TO anon, authenticated
  USING (true);

-- DEVICES
ALTER TABLE public."DEVICES" ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS dev_read_devices ON public."DEVICES";
CREATE POLICY dev_read_devices ON public."DEVICES"
  FOR SELECT TO anon, authenticated
  USING (true);

-- CONSUMABLE_STATUS
ALTER TABLE public."CONSUMABLE_STATUS" ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS dev_read_consumable_status ON public."CONSUMABLE_STATUS";
CREATE POLICY dev_read_consumable_status ON public."CONSUMABLE_STATUS"
  FOR SELECT TO anon, authenticated
  USING (true);

-- REFRESH_SESSIONS (usage history / frequent mode)
ALTER TABLE public."REFRESH_SESSIONS" ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS dev_read_refresh_sessions ON public."REFRESH_SESSIONS";
CREATE POLICY dev_read_refresh_sessions ON public."REFRESH_SESSIONS"
  FOR SELECT TO anon, authenticated
  USING (true);

-- REFRESH_MODE
ALTER TABLE public."REFRESH_MODE" ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS dev_read_refresh_mode ON public."REFRESH_MODE";
CREATE POLICY dev_read_refresh_mode ON public."REFRESH_MODE"
  FOR SELECT TO anon, authenticated
  USING (true);

-- CUSTOM_MODES
ALTER TABLE public."CUSTOM_MODES" ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS dev_read_custom_modes ON public."CUSTOM_MODES";
CREATE POLICY dev_read_custom_modes ON public."CUSTOM_MODES"
  FOR SELECT TO anon, authenticated
  USING (true);
