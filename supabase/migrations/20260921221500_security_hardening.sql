-- Consolidated security hardening for local and hosted Supabase environments.
-- This migration is idempotent and keeps service_role available for trusted
-- server-side operations while restricting browser clients to their own rows.

CREATE TABLE IF NOT EXISTS public.bible_favorites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  content_type TEXT NOT NULL,
  content_id TEXT NOT NULL,
  title TEXT,
  content TEXT,
  url TEXT,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, content_type, content_id)
);

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bible_favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reading_marks ENABLE ROW LEVEL SECURITY;

GRANT SELECT, INSERT ON public.notifications TO authenticated;
GRANT SELECT, INSERT, DELETE ON public.bible_favorites TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.reading_marks TO authenticated;
GRANT ALL ON public.notifications, public.bible_favorites, public.reading_marks TO service_role;

DO $$
DECLARE
  policy_name TEXT;
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

DROP POLICY IF EXISTS "notifications_insert_own" ON public.notifications;
CREATE POLICY "notifications_insert_own"
  ON public.notifications
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "bible_favorites_select_own" ON public.bible_favorites;
DROP POLICY IF EXISTS "bible_favorites_insert_own" ON public.bible_favorites;
DROP POLICY IF EXISTS "bible_favorites_delete_own" ON public.bible_favorites;
DROP POLICY IF EXISTS "bible_favorites_update_own" ON public.bible_favorites;
DROP POLICY IF EXISTS "Users can view their own favorites" ON public.bible_favorites;
DROP POLICY IF EXISTS "Users can insert their own favorites" ON public.bible_favorites;
DROP POLICY IF EXISTS "Users can delete their own favorites" ON public.bible_favorites;

CREATE POLICY "bible_favorites_select_own"
  ON public.bible_favorites
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);
CREATE POLICY "bible_favorites_insert_own"
  ON public.bible_favorites
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);
CREATE POLICY "bible_favorites_delete_own"
  ON public.bible_favorites
  FOR DELETE TO authenticated
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "reading_marks_select_own" ON public.reading_marks;
DROP POLICY IF EXISTS "reading_marks_insert_own" ON public.reading_marks;
DROP POLICY IF EXISTS "reading_marks_update_own" ON public.reading_marks;
DROP POLICY IF EXISTS "reading_marks_delete_own" ON public.reading_marks;

CREATE POLICY "reading_marks_select_own"
  ON public.reading_marks FOR SELECT TO authenticated
  USING (auth.uid() = user_id);
CREATE POLICY "reading_marks_insert_own"
  ON public.reading_marks FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);
CREATE POLICY "reading_marks_update_own"
  ON public.reading_marks FOR UPDATE TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
CREATE POLICY "reading_marks_delete_own"
  ON public.reading_marks FOR DELETE TO authenticated
  USING (auth.uid() = user_id);

-- Keep one global last-read mark per user before creating the partial unique index.
WITH ranked AS (
  SELECT id,
         ROW_NUMBER() OVER (
           PARTITION BY user_id
           ORDER BY updated_at DESC NULLS LAST, created_at DESC NULLS LAST, id DESC
         ) AS rn
  FROM public.reading_marks
  WHERE is_last_read = true
)
UPDATE public.reading_marks rm
SET is_last_read = false,
    updated_at = now()
FROM ranked r
WHERE rm.id = r.id
  AND r.rn > 1;

CREATE UNIQUE INDEX IF NOT EXISTS reading_marks_one_last_read_per_user_idx
  ON public.reading_marks (user_id)
  WHERE is_last_read = true;
CREATE INDEX IF NOT EXISTS reading_marks_user_updated_idx
  ON public.reading_marks (user_id, updated_at DESC);
CREATE INDEX IF NOT EXISTS reading_marks_user_content_idx
  ON public.reading_marks (user_id, content_type, content_id);
CREATE INDEX IF NOT EXISTS bible_favorites_user_created_idx
  ON public.bible_favorites (user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS bible_favorites_user_type_id_idx
  ON public.bible_favorites (user_id, content_type, content_id);
