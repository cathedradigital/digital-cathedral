-- Security hardening: consolidate role checks and protect sensitive user data.
-- Additive migration: preserves published migration history.

CREATE OR REPLACE FUNCTION auth_internal.has_role(_user_id uuid, _role public.app_role)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.user_roles
    WHERE user_id = _user_id
      AND role = _role
  );
$$;

-- Keep the legacy text overload compatible, but use the same source of truth.
CREATE OR REPLACE FUNCTION auth_internal.has_role(_user_id uuid, required_role text)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT CASE
    WHEN required_role IS NULL THEN false
    WHEN required_role NOT IN ('admin', 'moderator', 'user', 'editor', 'reviewer') THEN false
    ELSE auth_internal.has_role(_user_id, required_role::public.app_role)
  END;
$$;

CREATE OR REPLACE FUNCTION auth_internal.is_admin()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT auth_internal.has_role(auth.uid(), 'admin'::public.app_role);
$$;

REVOKE EXECUTE ON FUNCTION auth_internal.has_role(uuid, public.app_role) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION auth_internal.has_role(uuid, text) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION auth_internal.is_admin() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION auth_internal.has_role(uuid, public.app_role) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION auth_internal.has_role(uuid, text) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION auth_internal.is_admin() TO authenticated, service_role;

DO $$
BEGIN
  IF to_regclass('public.user_sensitive_data') IS NOT NULL THEN
    EXECUTE 'REVOKE ALL ON public.user_sensitive_data FROM anon';
    EXECUTE 'GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_sensitive_data TO authenticated';
    EXECUTE 'ALTER TABLE public.user_sensitive_data ENABLE ROW LEVEL SECURITY';

    EXECUTE 'DROP POLICY IF EXISTS user_sensitive_data_select_own ON public.user_sensitive_data';
    EXECUTE 'DROP POLICY IF EXISTS user_sensitive_data_insert_own ON public.user_sensitive_data';
    EXECUTE 'DROP POLICY IF EXISTS user_sensitive_data_update_own ON public.user_sensitive_data';
    EXECUTE 'DROP POLICY IF EXISTS user_sensitive_data_delete_own ON public.user_sensitive_data';

    EXECUTE 'CREATE POLICY user_sensitive_data_select_own ON public.user_sensitive_data FOR SELECT TO authenticated USING (auth.uid() = user_id)';
    EXECUTE 'CREATE POLICY user_sensitive_data_insert_own ON public.user_sensitive_data FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id)';
    EXECUTE 'CREATE POLICY user_sensitive_data_update_own ON public.user_sensitive_data FOR UPDATE TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id)';
    EXECUTE 'CREATE POLICY user_sensitive_data_delete_own ON public.user_sensitive_data FOR DELETE TO authenticated USING (auth.uid() = user_id)';
  END IF;
END $$;

DO $$
BEGIN
  IF to_regclass('public.telemetry_settings') IS NOT NULL THEN
    EXECUTE 'REVOKE ALL ON public.telemetry_settings FROM anon';
    EXECUTE 'GRANT SELECT, INSERT, UPDATE, DELETE ON public.telemetry_settings TO authenticated';

    EXECUTE 'DROP POLICY IF EXISTS telemetry_settings_public_read ON public.telemetry_settings';
    EXECUTE 'DROP POLICY IF EXISTS telemetry_settings_admin_all ON public.telemetry_settings';
    EXECUTE 'DROP POLICY IF EXISTS telemetry_settings_public_read_public ON public.telemetry_settings';
    EXECUTE 'DROP POLICY IF EXISTS telemetry_settings_admin_all_public ON public.telemetry_settings';

    EXECUTE 'CREATE POLICY telemetry_settings_admin_select ON public.telemetry_settings FOR SELECT TO authenticated USING (auth_internal.is_admin())';
    EXECUTE 'CREATE POLICY telemetry_settings_admin_insert ON public.telemetry_settings FOR INSERT TO authenticated WITH CHECK (auth_internal.is_admin())';
    EXECUTE 'CREATE POLICY telemetry_settings_admin_update ON public.telemetry_settings FOR UPDATE TO authenticated USING (auth_internal.is_admin()) WITH CHECK (auth_internal.is_admin())';
    EXECUTE 'CREATE POLICY telemetry_settings_admin_delete ON public.telemetry_settings FOR DELETE TO authenticated USING (auth_internal.is_admin())';
  END IF;
END $$;
