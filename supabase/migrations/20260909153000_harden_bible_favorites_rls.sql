-- =========================================================
-- Favorites: ownership, least privilege and query support
-- =========================================================
-- This migration is intentionally defensive because bible_favorites may be
-- created by an earlier schema revision in existing environments.

DO $$
BEGIN
  IF to_regclass('public.bible_favorites') IS NULL THEN
    RAISE NOTICE 'public.bible_favorites does not exist; skipping favorites hardening';
    RETURN;
  END IF;

  EXECUTE 'ALTER TABLE public.bible_favorites ENABLE ROW LEVEL SECURITY';

  EXECUTE 'GRANT SELECT, INSERT, DELETE ON public.bible_favorites TO authenticated';
  EXECUTE 'GRANT ALL ON public.bible_favorites TO service_role';

  EXECUTE 'DROP POLICY IF EXISTS "bible_favorites_select_own" ON public.bible_favorites';
  EXECUTE 'DROP POLICY IF EXISTS "bible_favorites_insert_own" ON public.bible_favorites';
  EXECUTE 'DROP POLICY IF EXISTS "bible_favorites_delete_own" ON public.bible_favorites';
  EXECUTE 'DROP POLICY IF EXISTS "Users can view their own favorites" ON public.bible_favorites';
  EXECUTE 'DROP POLICY IF EXISTS "Users can insert their own favorites" ON public.bible_favorites';
  EXECUTE 'DROP POLICY IF EXISTS "Users can delete their own favorites" ON public.bible_favorites';

  EXECUTE $policy$
    CREATE POLICY "bible_favorites_select_own"
      ON public.bible_favorites
      FOR SELECT TO authenticated
      USING (auth.uid() = user_id)
  $policy$;

  EXECUTE $policy$
    CREATE POLICY "bible_favorites_insert_own"
      ON public.bible_favorites
      FOR INSERT TO authenticated
      WITH CHECK (auth.uid() = user_id)
  $policy$;

  EXECUTE $policy$
    CREATE POLICY "bible_favorites_delete_own"
      ON public.bible_favorites
      FOR DELETE TO authenticated
      USING (auth.uid() = user_id)
  $policy$;

  EXECUTE 'CREATE INDEX IF NOT EXISTS bible_favorites_user_created_idx ON public.bible_favorites (user_id, created_at DESC)';
  EXECUTE 'CREATE INDEX IF NOT EXISTS bible_favorites_user_type_id_idx ON public.bible_favorites (user_id, content_type, content_id)';
END $$;
