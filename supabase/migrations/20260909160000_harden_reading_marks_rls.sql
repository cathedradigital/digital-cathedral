-- Reading marks: ownership, least privilege and one global last-read mark
DO $$
BEGIN
  IF to_regclass('public.reading_marks') IS NULL THEN
    RAISE NOTICE 'public.reading_marks does not exist; skipping hardening';
    RETURN;
  END IF;

  ALTER TABLE public.reading_marks ENABLE ROW LEVEL SECURITY;
  GRANT SELECT, INSERT, UPDATE, DELETE ON public.reading_marks TO authenticated;
  GRANT ALL ON public.reading_marks TO service_role;

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
  SET is_last_read = false, updated_at = now()
  FROM ranked r
  WHERE rm.id = r.id AND r.rn > 1;

  CREATE UNIQUE INDEX IF NOT EXISTS reading_marks_one_last_read_per_user_idx
    ON public.reading_marks (user_id)
    WHERE is_last_read = true;
  CREATE INDEX IF NOT EXISTS reading_marks_user_updated_idx
    ON public.reading_marks (user_id, updated_at DESC);
  CREATE INDEX IF NOT EXISTS reading_marks_user_content_idx
    ON public.reading_marks (user_id, content_type, content_id);
END $$;
