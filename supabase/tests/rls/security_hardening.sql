-- Behavioral RLS regression tests for the security hardening migration.
-- Run with a Supabase/pgTAP test database (for example: supabase test db).

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgtap;

SELECT plan(8);

SELECT ok(
  to_regclass('public.user_sensitive_data') IS NOT NULL,
  'user_sensitive_data exists'
);
SELECT ok(
  to_regclass('public.telemetry_settings') IS NOT NULL,
  'telemetry_settings exists'
);

-- Seed rows as the database owner; RLS is enabled on both tables.
INSERT INTO public.user_sensitive_data (user_id, email, diagnosis_result)
VALUES
  ('00000000-0000-0000-0000-000000000001', 'owner@example.invalid', '{"source":"rls-test"}'::jsonb),
  ('00000000-0000-0000-0000-000000000002', 'other@example.invalid', '{"source":"other"}'::jsonb)
ON CONFLICT (user_id) DO UPDATE
SET email = EXCLUDED.email, diagnosis_result = EXCLUDED.diagnosis_result;

INSERT INTO public.telemetry_settings (key, value)
VALUES ('rls-test', '{"internal":true}'::jsonb)
ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;

-- Non-admin authenticated user: only the owner's sensitive row is visible.
SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claim.sub', '00000000-0000-0000-0000-000000000001', true);

SELECT is(
  (SELECT count(*)::integer FROM public.user_sensitive_data),
  1,
  'authenticated user can only SELECT own sensitive data'
);

SELECT ok(
  NOT EXISTS (
    SELECT 1 FROM public.telemetry_settings WHERE key = 'rls-test'
  ),
  'non-admin authenticated user cannot SELECT telemetry settings'
);

SELECT throws_ok(
  $$INSERT INTO public.user_sensitive_data (user_id, email, diagnosis_result)
    VALUES ('00000000-0000-0000-0000-000000000002', 'forbidden@example.invalid', '{}'::jsonb)$$,
  '42501',
  NULL,
  'authenticated user cannot INSERT sensitive data for another user'
);

-- Admin user: telemetry settings become available, while sensitive data remains owner-scoped.
RESET ROLE;
INSERT INTO public.user_roles (user_id, role)
VALUES ('00000000-0000-0000-0000-000000000001', 'admin')
ON CONFLICT (user_id, role) DO NOTHING;
SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claim.sub', '00000000-0000-0000-0000-000000000001', true);

SELECT is(
  (SELECT count(*)::integer FROM public.telemetry_settings WHERE key = 'rls-test'),
  1,
  'admin can SELECT telemetry settings'
);

SELECT is(
  (SELECT count(*)::integer FROM public.user_sensitive_data),
  1,
  'admin still cannot bypass owner RLS on sensitive data'
);

SELECT ok(
  has_schema_privilege(current_user, 'public', 'USAGE'),
  'authenticated role has schema access needed for RLS evaluation'
);

SELECT ok(
  EXISTS (
    SELECT 1
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'auth_internal'
      AND p.proname = 'is_admin'
  ),
  'auth_internal.is_admin exists'
);

SELECT * FROM finish();
ROLLBACK;
