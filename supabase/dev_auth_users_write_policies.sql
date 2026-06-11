-- 회원가입 시 AUTH_USERS INSERT/UPDATE 정책 (authenticated).
-- dev_read_policies.sql 실행 후 함께 적용하세요.

ALTER TABLE public."AUTH_USERS" ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS dev_insert_auth_users ON public."AUTH_USERS";
CREATE POLICY dev_insert_auth_users ON public."AUTH_USERS"
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS dev_update_auth_users ON public."AUTH_USERS";
CREATE POLICY dev_update_auth_users ON public."AUTH_USERS"
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
