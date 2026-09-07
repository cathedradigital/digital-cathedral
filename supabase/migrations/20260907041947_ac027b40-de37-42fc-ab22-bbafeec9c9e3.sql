-- =========================================================
-- Lote essencial: perfis, papéis, Bíblia, catecismo, orações
-- =========================================================

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA extensions;

CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

-- ---------------- profiles ----------------
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY,
  name TEXT NOT NULL DEFAULT '',
  email TEXT NOT NULL DEFAULT '',
  avatar_url TEXT,
  is_premium BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

GRANT SELECT, INSERT, UPDATE ON public.profiles TO authenticated;
GRANT ALL ON public.profiles TO service_role;

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "profiles_select_own" ON public.profiles
  FOR SELECT TO authenticated USING (auth.uid() = id);
CREATE POLICY "profiles_insert_own" ON public.profiles
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = id);
CREATE POLICY "profiles_update_own" ON public.profiles
  FOR UPDATE TO authenticated USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

CREATE TRIGGER trg_profiles_updated_at BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ---------------- user_roles ----------------
CREATE TABLE public.user_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  role public.app_role NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, role)
);

GRANT SELECT ON public.user_roles TO authenticated;
GRANT ALL ON public.user_roles TO service_role;

ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "user_roles_select_own" ON public.user_roles
  FOR SELECT TO authenticated USING (auth.uid() = user_id);

CREATE OR REPLACE FUNCTION public.has_role(_user_id UUID, _role public.app_role)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.user_roles
    WHERE user_id = _user_id AND role = _role
  );
$$;

REVOKE EXECUTE ON FUNCTION public.has_role(uuid, public.app_role) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.has_role(uuid, public.app_role) TO authenticated, service_role;

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.user_roles
    WHERE user_id = auth.uid() AND role = 'admin'::public.app_role
  );
$$;

REVOKE EXECUTE ON FUNCTION public.is_admin() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.is_admin() TO authenticated, service_role;

CREATE TRIGGER trg_user_roles_updated_at BEFORE UPDATE ON public.user_roles
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ---------------- Bíblia ----------------
CREATE TABLE public.bible_books (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  abbrev TEXT NOT NULL UNIQUE,
  testament TEXT CHECK (testament IN ('antigo', 'novo')),
  canonical_type TEXT CHECK (canonical_type IN ('protocanonico', 'deuterocanonico')),
  chapters_count INTEGER NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.bible_chapters (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  book_id UUID NOT NULL REFERENCES public.bible_books(id) ON DELETE CASCADE,
  number INTEGER NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (book_id, number)
);

CREATE TABLE public.bible_verses (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  chapter_id UUID NOT NULL REFERENCES public.bible_chapters(id) ON DELETE CASCADE,
  number INTEGER NOT NULL,
  text TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (chapter_id, number)
);

GRANT SELECT ON public.bible_books, public.bible_chapters, public.bible_verses TO anon, authenticated;
GRANT ALL ON public.bible_books, public.bible_chapters, public.bible_verses TO service_role;

ALTER TABLE public.bible_books ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bible_chapters ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bible_verses ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public can read bible_books" ON public.bible_books FOR SELECT USING (true);
CREATE POLICY "Public can read bible_chapters" ON public.bible_chapters FOR SELECT USING (true);
CREATE POLICY "Public can read bible_verses" ON public.bible_verses FOR SELECT USING (true);

CREATE POLICY "bible_books_admin_all" ON public.bible_books FOR ALL TO authenticated
  USING (auth_internal.has_role(auth.uid(), 'admin'::public.app_role))
  WITH CHECK (auth_internal.has_role(auth.uid(), 'admin'::public.app_role));
CREATE POLICY "bible_chapters_admin_all" ON public.bible_chapters FOR ALL TO authenticated
  USING (auth_internal.has_role(auth.uid(), 'admin'::public.app_role))
  WITH CHECK (auth_internal.has_role(auth.uid(), 'admin'::public.app_role));
CREATE POLICY "bible_verses_admin_all" ON public.bible_verses FOR ALL TO authenticated
  USING (auth_internal.has_role(auth.uid(), 'admin'::public.app_role))
  WITH CHECK (auth_internal.has_role(auth.uid(), 'admin'::public.app_role));

CREATE INDEX idx_bible_verses_chapter_id ON public.bible_verses(chapter_id);
CREATE INDEX idx_bible_chapters_book_id ON public.bible_chapters(book_id);
CREATE INDEX idx_bible_books_abbrev ON public.bible_books(abbrev);

CREATE TRIGGER update_bible_books_updated_at BEFORE UPDATE ON public.bible_books
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_bible_chapters_updated_at BEFORE UPDATE ON public.bible_chapters
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_bible_verses_updated_at BEFORE UPDATE ON public.bible_verses
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ---------------- Catecismo ----------------
CREATE TABLE public.catechism_official (
  paragraph INTEGER PRIMARY KEY,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

GRANT SELECT ON public.catechism_official TO anon, authenticated;
GRANT ALL ON public.catechism_official TO service_role;

ALTER TABLE public.catechism_official ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public can view official texts" ON public.catechism_official
  FOR SELECT USING (true);
CREATE POLICY "catechism_official_admin_all" ON public.catechism_official FOR ALL TO authenticated
  USING (auth_internal.has_role(auth.uid(), 'admin'::public.app_role))
  WITH CHECK (auth_internal.has_role(auth.uid(), 'admin'::public.app_role));

CREATE TRIGGER trg_catechism_official_updated_at BEFORE UPDATE ON public.catechism_official
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ---------------- Orações ----------------
CREATE TABLE public.prayers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug text NOT NULL UNIQUE,
  title text NOT NULL,
  subtitle text,
  kicker text,
  category public.prayer_category NOT NULL,
  content text NOT NULL,
  content_latin text,
  explanation text,
  meditation text,
  estimated_seconds integer NOT NULL DEFAULT 60,
  order_index integer NOT NULL DEFAULT 0,
  tags text[] NOT NULL DEFAULT '{}',
  source_ref text,
  related_bible text[] NOT NULL DEFAULT '{}',
  related_catechism integer[] NOT NULL DEFAULT '{}',
  related_saints text[] NOT NULL DEFAULT '{}',
  related_glossary text[] NOT NULL DEFAULT '{}',
  engine_version integer NOT NULL DEFAULT 1,
  is_published boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX prayers_category_idx ON public.prayers (category, order_index);
CREATE INDEX prayers_published_idx ON public.prayers (is_published);
CREATE INDEX prayers_tags_gin_idx ON public.prayers USING gin (tags);
CREATE INDEX prayers_title_trgm_idx ON public.prayers USING gin (title extensions.gin_trgm_ops);

GRANT SELECT ON public.prayers TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.prayers TO authenticated;
GRANT ALL ON public.prayers TO service_role;

ALTER TABLE public.prayers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "prayers_public_read_published" ON public.prayers
  FOR SELECT USING (is_published = true);
CREATE POLICY "prayers_admin_all" ON public.prayers FOR ALL TO authenticated
  USING (auth_internal.has_role(auth.uid(), 'admin'::public.app_role))
  WITH CHECK (auth_internal.has_role(auth.uid(), 'admin'::public.app_role));

CREATE TRIGGER prayers_set_updated_at BEFORE UPDATE ON public.prayers
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE public.prayer_sections (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  prayer_id uuid NOT NULL REFERENCES public.prayers(id) ON DELETE CASCADE,
  slug text NOT NULL,
  title text NOT NULL,
  subtitle text,
  order_index integer NOT NULL DEFAULT 0,
  weekdays integer[] NOT NULL DEFAULT ARRAY[]::integer[],
  meta jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (prayer_id, slug)
);

CREATE INDEX idx_prayer_sections_prayer ON public.prayer_sections(prayer_id, order_index);
GRANT SELECT ON public.prayer_sections TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.prayer_sections TO authenticated;
GRANT ALL ON public.prayer_sections TO service_role;
ALTER TABLE public.prayer_sections ENABLE ROW LEVEL SECURITY;
CREATE POLICY "prayer_sections_public_read" ON public.prayer_sections FOR SELECT USING (true);
CREATE POLICY "prayer_sections_admin_all" ON public.prayer_sections FOR ALL TO authenticated
  USING (auth_internal.has_role(auth.uid(), 'admin'::public.app_role))
  WITH CHECK (auth_internal.has_role(auth.uid(), 'admin'::public.app_role));
CREATE TRIGGER trg_prayer_sections_updated_at BEFORE UPDATE ON public.prayer_sections
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE public.prayer_mysteries (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  section_id uuid NOT NULL REFERENCES public.prayer_sections(id) ON DELETE CASCADE,
  slug text NOT NULL,
  title text NOT NULL,
  subtitle text,
  order_index integer NOT NULL DEFAULT 0,
  image_key text,
  gospel_ref text,
  gospel_text text,
  meditation text,
  fruit text,
  meta jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (section_id, slug)
);

CREATE INDEX idx_prayer_mysteries_section ON public.prayer_mysteries(section_id, order_index);
GRANT SELECT ON public.prayer_mysteries TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.prayer_mysteries TO authenticated;
GRANT ALL ON public.prayer_mysteries TO service_role;
ALTER TABLE public.prayer_mysteries ENABLE ROW LEVEL SECURITY;
CREATE POLICY "prayer_mysteries_public_read" ON public.prayer_mysteries FOR SELECT USING (true);
CREATE POLICY "prayer_mysteries_admin_all" ON public.prayer_mysteries FOR ALL TO authenticated
  USING (auth_internal.has_role(auth.uid(), 'admin'::public.app_role))
  WITH CHECK (auth_internal.has_role(auth.uid(), 'admin'::public.app_role));
CREATE TRIGGER trg_prayer_mysteries_updated_at BEFORE UPDATE ON public.prayer_mysteries
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE public.prayer_blocks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  prayer_id uuid NOT NULL REFERENCES public.prayers(id) ON DELETE CASCADE,
  section_id uuid REFERENCES public.prayer_sections(id) ON DELETE CASCADE,
  mystery_id uuid REFERENCES public.prayer_mysteries(id) ON DELETE CASCADE,
  slug text,
  type text NOT NULL,
  title text,
  content jsonb NOT NULL DEFAULT '{}'::jsonb,
  repeat_count integer NOT NULL DEFAULT 1,
  audio_key text,
  order_index integer NOT NULL DEFAULT 0,
  meta jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_prayer_blocks_prayer ON public.prayer_blocks(prayer_id, order_index);
CREATE INDEX idx_prayer_blocks_section ON public.prayer_blocks(section_id, order_index);
CREATE INDEX idx_prayer_blocks_mystery ON public.prayer_blocks(mystery_id, order_index);
GRANT SELECT ON public.prayer_blocks TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.prayer_blocks TO authenticated;
GRANT ALL ON public.prayer_blocks TO service_role;
ALTER TABLE public.prayer_blocks ENABLE ROW LEVEL SECURITY;
CREATE POLICY "prayer_blocks_public_read" ON public.prayer_blocks FOR SELECT USING (true);
CREATE POLICY "prayer_blocks_admin_all" ON public.prayer_blocks FOR ALL TO authenticated
  USING (auth_internal.has_role(auth.uid(), 'admin'::public.app_role))
  WITH CHECK (auth_internal.has_role(auth.uid(), 'admin'::public.app_role));
CREATE TRIGGER trg_prayer_blocks_updated_at BEFORE UPDATE ON public.prayer_blocks
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();