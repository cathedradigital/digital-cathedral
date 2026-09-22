\set ON_ERROR_STOP on
\pset pager off

-- Run from the repository root with:
-- psql "$DATABASE_URL" -f scripts/apply-and-test-supabase-local.sql
-- On a blank database, pass -v APPLY_MIGRATIONS=1.
-- After `supabase db reset`, omit APPLY_MIGRATIONS to run assertions only.

\if :{?APPLY_MIGRATIONS}
\echo 'Applying repository migrations to a blank database...'
\ir ../supabase/migrations/20260901004147_3fadf7e6-eec4-42e9-9018-e9a3be825980.sql
\ir ../supabase/migrations/20260903022723_add_lte_numen_check.sql
\ir ../supabase/migrations/20260907041947_ac027b40-de37-42fc-ab22-bbafeec9c9e3.sql
\ir ../supabase/migrations/20260907042138_d837bcb4-0cac-40e4-8198-640b5491947c.sql
\ir ../supabase/migrations/20260909213548_2e8e8ab8-d3cc-41d5-a30e-8a5dcfc79971.sql

\echo 'Applying consolidated security hardening...'
\ir ../supabase/migrations/20260921221500_security_hardening.sql
\else
\echo 'Skipping migration application; checking the schema created by supabase db reset...'
\endif

DO $$
DECLARE
  required_table TEXT;
  required_tables CONSTANT TEXT[] := ARRAY[
    'notifications', 'bible_favorites', 'reading_marks'
  ];
BEGIN
  FOREACH required_table IN ARRAY required_tables LOOP
    IF to_regclass(format('public.%s', required_table)) IS NULL THEN
      RAISE EXCEPTION 'Required table public.% does not exist', required_table;
    END IF;
  END LOOP;
END
$$;

DO $$
DECLARE
  table_name TEXT;
BEGIN
  FOREACH table_name IN ARRAY ARRAY['notifications', 'bible_favorites', 'reading_marks'] LOOP
    IF NOT EXISTS (
      SELECT 1
      FROM pg_class c
      JOIN pg_namespace n ON n.oid = c.relnamespace
      WHERE n.nspname = 'public'
        AND c.relname = table_name
        AND c.relrowsecurity
    ) THEN
      RAISE EXCEPTION 'RLS is not enabled on public.%', table_name;
    END IF;
  END LOOP;
END
$$;

DO $$
DECLARE
  policy_name TEXT;
  policy_table TEXT;
  required_policies CONSTANT TEXT[][] := ARRAY[
    ARRAY['notifications', 'notifications_insert_own'],
    ARRAY['bible_favorites', 'bible_favorites_select_own'],
    ARRAY['bible_favorites', 'bible_favorites_insert_own'],
    ARRAY['bible_favorites', 'bible_favorites_delete_own'],
    ARRAY['reading_marks', 'reading_marks_select_own'],
    ARRAY['reading_marks', 'reading_marks_insert_own'],
    ARRAY['reading_marks', 'reading_marks_update_own'],
    ARRAY['reading_marks', 'reading_marks_delete_own']
  ];
  item TEXT[];
BEGIN
  FOREACH item SLICE 1 IN ARRAY required_policies LOOP
    policy_table := item[1];
    policy_name := item[2];
    IF NOT EXISTS (
      SELECT 1
      FROM pg_policies
      WHERE schemaname = 'public'
        AND tablename = policy_table
        AND policyname = policy_name
    ) THEN
      RAISE EXCEPTION 'Missing policy %.%', policy_table, policy_name;
    END IF;
  END LOOP;
END
$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes
    WHERE schemaname = 'public'
      AND tablename = 'reading_marks'
      AND indexname = 'reading_marks_one_last_read_per_user_idx'
  ) THEN
    RAISE EXCEPTION 'Missing unique last-read index';
  END IF;

  IF EXISTS (
    SELECT user_id
    FROM public.reading_marks
    WHERE is_last_read = true
    GROUP BY user_id
    HAVING count(*) > 1
  ) THEN
    RAISE EXCEPTION 'Duplicate last-read marks remain';
  END IF;
END
$$;

DO $$
BEGIN
  IF NOT has_table_privilege('authenticated', 'public.bible_favorites', 'SELECT')
     OR NOT has_table_privilege('authenticated', 'public.bible_favorites', 'INSERT')
     OR NOT has_table_privilege('authenticated', 'public.bible_favorites', 'DELETE') THEN
    RAISE EXCEPTION 'authenticated does not have the expected bible_favorites privileges';
  END IF;

  IF has_table_privilege('anon', 'public.bible_favorites', 'SELECT') THEN
    RAISE EXCEPTION 'anon unexpectedly has SELECT on bible_favorites';
  END IF;
END
$$;

\echo 'PASS: migrations applied and security assertions passed.'
