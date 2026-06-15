-- LG Hair Refresher — 개발용 Supabase 권한/RLS
-- Supabase Dashboard → SQL Editor에서 한 번 실행하세요.
-- home_page.dart 안내와 동일 경로입니다.

-- MEASURE_RESULTS: 진단 결과 저장·조회
GRANT SELECT, INSERT ON public."MEASURE_RESULTS" TO anon;
GRANT SELECT, INSERT ON public."MEASURE_RESULTS" TO authenticated;

ALTER TABLE public."MEASURE_RESULTS" ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS dev_read_measure_results ON public."MEASURE_RESULTS";
CREATE POLICY dev_read_measure_results
  ON public."MEASURE_RESULTS"
  FOR SELECT
  TO anon, authenticated
  USING (true);

DROP POLICY IF EXISTS dev_insert_measure_results ON public."MEASURE_RESULTS";
CREATE POLICY dev_insert_measure_results
  ON public."MEASURE_RESULTS"
  FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

-- 확인용 (선택)
-- SELECT grantee, privilege_type
-- FROM information_schema.role_table_grants
-- WHERE table_name = 'MEASURE_RESULTS';
