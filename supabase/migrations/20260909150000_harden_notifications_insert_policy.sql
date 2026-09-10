-- Security hardening: an authenticated client must never be able to
-- create a notification for another user. Trusted server-side code using
-- service_role is intentionally unaffected because service_role bypasses RLS.

DO $$
DECLARE
  policy_name text;
BEGIN
  FOR policy_name IN
    SELECT pol.polname
    FROM pg_policy pol
    JOIN pg_class rel ON rel.oid = pol.polrelid
    JOIN pg_namespace nsp ON nsp.oid = rel.relnamespace
    WHERE nsp.nspname = 'public'
      AND rel.relname = 'notifications'
      AND pol.polcmd = 'a'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.notifications', policy_name);
  END LOOP;
END
$$;

CREATE POLICY "notifications_insert_own"
  ON public.notifications
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

COMMENT ON POLICY "notifications_insert_own" ON public.notifications IS
  'Authenticated clients may only create notifications addressed to themselves; trusted service_role code may create system notifications.';
