-- ==========================================================
-- 1. ESTRUTURA
-- ==========================================================
CREATE TABLE IF NOT EXISTS public.user_history (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  route TEXT NOT NULL,
  title TEXT NOT NULL,
  image_url TEXT,
  visited_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.user_notes (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  content_type TEXT NOT NULL,
  content_id TEXT NOT NULL,
  note_text TEXT NOT NULL DEFAULT '',
  highlight_color TEXT DEFAULT 'yellow',
  book_abbr TEXT,
  chapter INTEGER,
  paragraph INTEGER,
  verse INTEGER,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  source_user_id UUID,
  type TEXT NOT NULL DEFAULT 'reply',
  title TEXT NOT NULL,
  message TEXT NOT NULL DEFAULT '',
  link TEXT,
  is_read BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.journeys (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  subtitle TEXT,
  description TEXT NOT NULL DEFAULT '',
  icon TEXT NOT NULL DEFAULT 'compass',
  cover_url TEXT,
  category TEXT NOT NULL DEFAULT 'formacao',
  difficulty TEXT NOT NULL DEFAULT 'iniciante',
  estimated_days INTEGER NOT NULL DEFAULT 7,
  is_premium BOOLEAN NOT NULL DEFAULT false,
  is_active BOOLEAN NOT NULL DEFAULT true,
  sort_order INTEGER NOT NULL DEFAULT 0,
  tags TEXT[] DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.journey_steps (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  journey_id UUID NOT NULL REFERENCES public.journeys(id) ON DELETE CASCADE,
  step_order INTEGER NOT NULL DEFAULT 0,
  title TEXT NOT NULL,
  subtitle TEXT,
  step_type TEXT NOT NULL DEFAULT 'reading',
  content JSONB NOT NULL DEFAULT '{}',
  duration_minutes INTEGER NOT NULL DEFAULT 10,
  is_free BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.journey_progress (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  journey_id UUID NOT NULL REFERENCES public.journeys(id) ON DELETE CASCADE,
  step_id UUID NOT NULL REFERENCES public.journey_steps(id) ON DELETE CASCADE,
  completed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  reflection TEXT,
  UNIQUE(user_id, step_id)
);

CREATE TABLE IF NOT EXISTS public.spiritual_journal (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  entry_date DATE NOT NULL DEFAULT CURRENT_DATE,
  content TEXT NOT NULL DEFAULT '',
  mood TEXT,
  journey_id UUID REFERENCES public.journeys(id) ON DELETE SET NULL,
  step_id UUID REFERENCES public.journey_steps(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.glossary (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  term TEXT NOT NULL,
  slug TEXT,
  definition TEXT NOT NULL,
  short_definition TEXT,
  category TEXT,
  language TEXT NOT NULL DEFAULT 'pt',
  reference TEXT,
  etymology TEXT,
  historical_context TEXT,
  interpretation TEXT,
  deep_interpretation TEXT,
  practical_application TEXT,
  logos_meditation TEXT,
  bible_verses TEXT[] DEFAULT '{}'::text[],
  catechism_references TEXT[] DEFAULT '{}'::text[],
  magisterium_references TEXT[] DEFAULT '{}'::text[],
  saints_refs TEXT[] DEFAULT '{}'::text[],
  fathers_refs TEXT[] DEFAULT '{}'::text[],
  prayer_refs TEXT[] DEFAULT '{}'::text[],
  liturgy_refs TEXT[] DEFAULT '{}'::text[],
  journey_refs UUID[] DEFAULT '{}'::uuid[],
  nexus_refs JSONB DEFAULT '[]'::jsonb,
  faq JSONB DEFAULT '[]'::jsonb,
  next_steps JSONB DEFAULT '[]'::jsonb,
  bibliography JSONB DEFAULT '[]'::jsonb,
  editorial_closure JSONB,
  editorial_completeness TEXT NOT NULL DEFAULT 'expanding',
  doctrinal_weight SMALLINT NOT NULL DEFAULT 5 CHECK (doctrinal_weight BETWEEN 1 AND 10),
  version INTEGER NOT NULL DEFAULT 1,
  reviewed_by UUID,
  reviewed_at TIMESTAMPTZ,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS glossary_slug_key ON public.glossary(slug) WHERE slug IS NOT NULL;

CREATE TABLE IF NOT EXISTS public.saints (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  title TEXT,
  feast_day TEXT,
  feast_month INTEGER,
  feast_day_num INTEGER,
  born TEXT,
  died TEXT,
  patron_of TEXT[],
  bio TEXT,
  full_bio TEXT,
  works JSONB,
  quotes TEXT[],
  category TEXT,
  image TEXT,
  prayer TEXT,
  virtues TEXT[],
  bible_refs JSONB,
  catechism_refs INTEGER[],
  church_doc_refs JSONB,
  country TEXT,
  vocation TEXT,
  religious_order TEXT,
  birthplace TEXT,
  alternate_names TEXT[] NOT NULL DEFAULT ARRAY[]::text[],
  conversion_story TEXT,
  mission TEXT,
  legacy TEXT,
  spirituality_summary TEXT,
  key_events JSONB NOT NULL DEFAULT '[]'::jsonb,
  ai_reflection JSONB,
  editorial_closure JSONB,
  editorial_score INTEGER NOT NULL DEFAULT 0 CHECK (editorial_score BETWEEN 0 AND 100),
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active','merged','archived')),
  source_name TEXT,
  source_url TEXT,
  bio_source_url TEXT,
  prayer_source_url TEXT,
  image_source_url TEXT,
  image_license TEXT,
  image_attribution TEXT,
  source_metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  content_hash TEXT,
  last_scraped_at TIMESTAMPTZ,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.themes (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  slug TEXT NOT NULL UNIQUE,
  description TEXT,
  emoji TEXT,
  category TEXT,
  image_url TEXT,
  order_index INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.theme_contents (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  theme_id UUID NOT NULL REFERENCES public.themes(id) ON DELETE CASCADE,
  content_type TEXT NOT NULL CHECK (content_type IN ('bible', 'catechism', 'magisterium')),
  reference TEXT NOT NULL,
  title TEXT,
  text_content TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.spiritual_contents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  content_text TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('bible', 'catechism', 'magisterium', 'journey')),
  reference_id TEXT,
  metadata JSONB DEFAULT '{}'::jsonb,
  tags TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.collections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug TEXT NOT NULL UNIQUE,
  title TEXT NOT NULL,
  subtitle TEXT,
  description TEXT,
  cover TEXT,
  category TEXT NOT NULL DEFAULT 'sacramentos',
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','published','archived')),
  featured BOOLEAN NOT NULL DEFAULT false,
  nexus_refs JSONB NOT NULL DEFAULT '[]'::jsonb,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  estimated_reading_time_minutes INT,
  difficulty_level TEXT CHECK (difficulty_level IN ('iniciante','intermediario','avancado')),
  recommended_for TEXT[] NOT NULL DEFAULT '{}',
  hero_quote TEXT,
  hero_quote_author TEXT,
  learning_objectives TEXT[] NOT NULL DEFAULT '{}',
  prerequisites UUID[] NOT NULL DEFAULT '{}',
  completion_message TEXT,
  certificate_eligible BOOLEAN NOT NULL DEFAULT false,
  program_slug TEXT,
  track TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.collection_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  collection_id UUID NOT NULL REFERENCES public.collections(id) ON DELETE CASCADE,
  item_type TEXT NOT NULL CHECK (item_type IN ('glossary','prayer','saint','bible','liturgy','catechism','journey')),
  item_slug TEXT NOT NULL,
  order_index INT NOT NULL DEFAULT 0,
  title_override TEXT,
  description_override TEXT,
  is_locked_until_prev BOOLEAN NOT NULL DEFAULT false,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(collection_id, item_type, item_slug)
);

CREATE TABLE IF NOT EXISTS public.reading_marks (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  content_type TEXT NOT NULL,
  content_id TEXT NOT NULL,
  chapter INTEGER,
  paragraph INTEGER,
  position FLOAT,
  label TEXT,
  url TEXT,
  is_last_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.ritual_progress (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  date DATE NOT NULL DEFAULT CURRENT_DATE,
  progress_percent INTEGER NOT NULL DEFAULT 0,
  completed BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE(user_id, date)
);

CREATE TABLE IF NOT EXISTS public.bible_chapters_read (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  book_abbr text NOT NULL,
  chapter integer NOT NULL,
  read_at timestamp with time zone NOT NULL DEFAULT now(),
  UNIQUE (user_id, book_abbr, chapter)
);

CREATE TABLE IF NOT EXISTS public.catechism_paragraphs_read (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  paragraph INTEGER NOT NULL,
  read_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  UNIQUE(user_id, paragraph)
);

CREATE TABLE IF NOT EXISTS public.prayer_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  prayer_id uuid NOT NULL REFERENCES public.prayers(id) ON DELETE CASCADE,
  current_block_id text,
  current_block_index integer NOT NULL DEFAULT 0,
  current_section_id uuid,
  current_mystery_id uuid,
  current_block_uuid uuid,
  completed_block_ids uuid[] NOT NULL DEFAULT ARRAY[]::uuid[],
  completed_mystery_ids uuid[] NOT NULL DEFAULT '{}'::uuid[],
  completed_section_ids uuid[] NOT NULL DEFAULT '{}'::uuid[],
  bookmarks jsonb NOT NULL DEFAULT '[]'::jsonb,
  elapsed_seconds integer NOT NULL DEFAULT 0,
  completed_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, prayer_id)
);

CREATE TABLE IF NOT EXISTS public.saved_filters (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  name TEXT NOT NULL,
  query TEXT,
  filter_by TEXT DEFAULT 'all',
  project_id TEXT DEFAULT 'global',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.user_reminder_settings (
  user_id UUID NOT NULL PRIMARY KEY,
  push_enabled BOOLEAN NOT NULL DEFAULT true,
  email_enabled BOOLEAN NOT NULL DEFAULT true,
  reminder_frequency TEXT NOT NULL DEFAULT 'daily',
  reminder_time TIME NOT NULL DEFAULT '09:00:00',
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.app_feature_flags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  feature_key TEXT UNIQUE NOT NULL,
  is_enabled BOOLEAN DEFAULT false,
  description TEXT,
  metadata JSONB DEFAULT '{}'::jsonb,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.telemetry_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  key TEXT UNIQUE NOT NULL,
  value JSONB NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_by UUID
);

-- ==========================================================
-- 2. GRANTS
-- ==========================================================
GRANT SELECT ON public.journeys, public.journey_steps, public.glossary, public.saints,
  public.themes, public.theme_contents, public.spiritual_contents, public.collections,
  public.collection_items, public.app_feature_flags, public.telemetry_settings TO anon;

GRANT SELECT, INSERT, UPDATE, DELETE ON
  public.user_history, public.user_notes, public.notifications, public.journey_progress,
  public.spiritual_journal, public.reading_marks, public.ritual_progress,
  public.bible_chapters_read, public.catechism_paragraphs_read, public.prayer_sessions,
  public.saved_filters, public.user_reminder_settings, public.journeys, public.journey_steps,
  public.glossary, public.saints, public.themes, public.theme_contents,
  public.spiritual_contents, public.collections, public.collection_items,
  public.app_feature_flags, public.telemetry_settings TO authenticated;

GRANT ALL ON
  public.user_history, public.user_notes, public.notifications, public.journeys,
  public.journey_steps, public.journey_progress, public.spiritual_journal, public.glossary,
  public.saints, public.themes, public.theme_contents, public.spiritual_contents,
  public.collections, public.collection_items, public.reading_marks, public.ritual_progress,
  public.bible_chapters_read, public.catechism_paragraphs_read, public.prayer_sessions,
  public.saved_filters, public.user_reminder_settings, public.app_feature_flags,
  public.telemetry_settings TO service_role;

-- ==========================================================
-- 3. RLS
-- ==========================================================
ALTER TABLE public.user_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.journeys ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.journey_steps ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.journey_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.spiritual_journal ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.glossary ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.saints ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.themes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.theme_contents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.spiritual_contents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.collections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.collection_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reading_marks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ritual_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bible_chapters_read ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.catechism_paragraphs_read ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.prayer_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.saved_filters ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_reminder_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_feature_flags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.telemetry_settings ENABLE ROW LEVEL SECURITY;

-- Conteúdo público: leitura para todos, escrita só admin
DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY['journeys','journey_steps','glossary','saints','themes',
                           'theme_contents','spiritual_contents','collections',
                           'collection_items','app_feature_flags','telemetry_settings']
  LOOP
    EXECUTE format('CREATE POLICY %I ON public.%I FOR SELECT USING (true)', t||'_public_read', t);
    EXECUTE format('CREATE POLICY %I ON public.%I FOR ALL TO authenticated USING (auth_internal.has_role(auth.uid(), ''admin''::app_role)) WITH CHECK (auth_internal.has_role(auth.uid(), ''admin''::app_role))', t||'_admin_all', t);
  END LOOP;
END $$;

-- Dados do usuário: apenas o próprio dono
DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY['user_history','user_notes','notifications','journey_progress',
                           'spiritual_journal','reading_marks','ritual_progress',
                           'bible_chapters_read','catechism_paragraphs_read',
                           'prayer_sessions','saved_filters','user_reminder_settings']
  LOOP
    EXECUTE format('CREATE POLICY %I ON public.%I FOR ALL TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id)', t||'_own', t);
  END LOOP;
END $$;

-- ==========================================================
-- 4. TRIGGERS updated_at
-- ==========================================================
DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY['user_notes','journeys','journey_steps','spiritual_journal',
                           'glossary','saints','themes','theme_contents','collections',
                           'collection_items','reading_marks','ritual_progress',
                           'prayer_sessions','saved_filters']
  LOOP
    EXECUTE format('CREATE TRIGGER %I BEFORE UPDATE ON public.%I FOR EACH ROW EXECUTE FUNCTION public.set_updated_at()', 'trg_'||t||'_updated_at', t);
  END LOOP;
END $$;

-- ==========================================================
-- 5. CONTEÚDO: 73 livros da Bíblia
-- ==========================================================
INSERT INTO public.bible_books (abbrev, name, testament, canonical_type, chapters_count) VALUES
  ('Gn','Gênesis','antigo','protocanonico',50),
  ('Ex','Êxodo','antigo','protocanonico',40),
  ('Lv','Levítico','antigo','protocanonico',27),
  ('Nm','Números','antigo','protocanonico',36),
  ('Dt','Deuteronômio','antigo','protocanonico',34),
  ('Js','Josué','antigo','protocanonico',24),
  ('Jz','Juízes','antigo','protocanonico',21),
  ('Rt','Rute','antigo','protocanonico',4),
  ('1Sm','1 Samuel','antigo','protocanonico',31),
  ('2Sm','2 Samuel','antigo','protocanonico',24),
  ('1Rs','1 Reis','antigo','protocanonico',22),
  ('2Rs','2 Reis','antigo','protocanonico',25),
  ('1Cr','1 Crônicas','antigo','protocanonico',29),
  ('2Cr','2 Crônicas','antigo','protocanonico',36),
  ('Ed','Esdras','antigo','protocanonico',10),
  ('Ne','Neemias','antigo','protocanonico',13),
  ('Tb','Tobias','antigo','deuterocanonico',14),
  ('Jt','Judite','antigo','deuterocanonico',16),
  ('Et','Ester','antigo','protocanonico',10),
  ('1Mc','1 Macabeus','antigo','deuterocanonico',16),
  ('2Mc','2 Macabeus','antigo','deuterocanonico',15),
  ('Jó','Jó','antigo','protocanonico',42),
  ('Sl','Salmos','antigo','protocanonico',150),
  ('Pr','Provérbios','antigo','protocanonico',31),
  ('Ecl','Eclesiastes','antigo','protocanonico',12),
  ('Ct','Cântico dos Cânticos','antigo','protocanonico',8),
  ('Sb','Sabedoria','antigo','deuterocanonico',19),
  ('Eclo','Eclesiástico','antigo','deuterocanonico',51),
  ('Is','Isaías','antigo','protocanonico',66),
  ('Jr','Jeremias','antigo','protocanonico',52),
  ('Lm','Lamentações','antigo','protocanonico',5),
  ('Br','Baruc','antigo','deuterocanonico',6),
  ('Ez','Ezequiel','antigo','protocanonico',48),
  ('Dn','Daniel','antigo','protocanonico',14),
  ('Os','Oseias','antigo','protocanonico',14),
  ('Jl','Joel','antigo','protocanonico',4),
  ('Am','Amós','antigo','protocanonico',9),
  ('Ob','Obadias','antigo','protocanonico',1),
  ('Jn','Jonas','antigo','protocanonico',4),
  ('Mq','Miqueias','antigo','protocanonico',7),
  ('Na','Naum','antigo','protocanonico',3),
  ('Hab','Habacuc','antigo','protocanonico',3),
  ('Sf','Sofonias','antigo','protocanonico',3),
  ('Ag','Ageu','antigo','protocanonico',2),
  ('Zc','Zacarias','antigo','protocanonico',14),
  ('Ml','Malaquias','antigo','protocanonico',3),
  ('Mt','Mateus','novo','protocanonico',28),
  ('Mc','Marcos','novo','protocanonico',16),
  ('Lc','Lucas','novo','protocanonico',24),
  ('Jo','João','novo','protocanonico',21),
  ('At','Atos dos Apóstolos','novo','protocanonico',28),
  ('Rm','Romanos','novo','protocanonico',16),
  ('1Cor','1 Coríntios','novo','protocanonico',16),
  ('2Cor','2 Coríntios','novo','protocanonico',13),
  ('Gl','Gálatas','novo','protocanonico',6),
  ('Ef','Efésios','novo','protocanonico',6),
  ('Fp','Filipenses','novo','protocanonico',4),
  ('Cl','Colossenses','novo','protocanonico',4),
  ('1Ts','1 Tessalonicenses','novo','protocanonico',5),
  ('2Ts','2 Tessalonicenses','novo','protocanonico',3),
  ('1Tm','1 Timóteo','novo','protocanonico',6),
  ('2Tm','2 Timóteo','novo','protocanonico',4),
  ('Tt','Tito','novo','protocanonico',3),
  ('Fm','Filêmon','novo','protocanonico',1),
  ('Hb','Hebreus','novo','protocanonico',13),
  ('Tg','Tiago','novo','protocanonico',5),
  ('1Pd','1 Pedro','novo','protocanonico',5),
  ('2Pd','2 Pedro','novo','protocanonico',3),
  ('1Jo','1 João','novo','protocanonico',5),
  ('2Jo','2 João','novo','protocanonico',1),
  ('3Jo','3 João','novo','protocanonico',1),
  ('Jd','Judas','novo','protocanonico',1),
  ('Ap','Apocalipse','novo','protocanonico',22)
ON CONFLICT DO NOTHING;

-- ==========================================================
-- 6. CONTEÚDO: orações tradicionais
-- ==========================================================
DO $$
DECLARE
  v_id uuid;
  r record;
BEGIN
  FOR r IN
    SELECT * FROM (VALUES
      ('pai-nosso','Pai-Nosso','A oração que o Senhor ensinou','Pater Noster','fundamentais',
       E'Pai nosso, que estais nos céus, santificado seja o vosso nome; venha a nós o vosso reino; seja feita a vossa vontade, assim na terra como no céu.\n\nO pão nosso de cada dia nos dai hoje; perdoai-nos as nossas ofensas, assim como nós perdoamos a quem nos tem ofendido; e não nos deixeis cair em tentação, mas livrai-nos do mal. Amém.',
       'Pater noster, qui es in caelis, sanctificetur nomen tuum; adveniat regnum tuum; fiat voluntas tua, sicut in caelo et in terra. Panem nostrum quotidianum da nobis hodie; et dimitte nobis debita nostra, sicut et nos dimittimus debitoribus nostris; et ne nos inducas in tentationem, sed libera nos a malo. Amen.',
       'A oração dominical, ensinada por Jesus aos discípulos, é chamada pelos Padres a síntese de todo o Evangelho.',60,1),
      ('ave-maria','Ave-Maria','Saudação à Mãe de Deus','Ave Maria','marianas',
       E'Ave Maria, cheia de graça, o Senhor é convosco. Bendita sois vós entre as mulheres e bendito é o fruto do vosso ventre, Jesus.\n\nSanta Maria, Mãe de Deus, rogai por nós, pecadores, agora e na hora da nossa morte. Amém.',
       'Ave Maria, gratia plena, Dominus tecum. Benedicta tu in mulieribus, et benedictus fructus ventris tui, Iesus. Sancta Maria, Mater Dei, ora pro nobis peccatoribus, nunc et in hora mortis nostrae. Amen.',
       'Une a saudação do anjo Gabriel e as palavras de Isabel à súplica da Igreja pela intercessão de Maria.',40,2),
      ('gloria-ao-pai','Glória ao Pai','Doxologia trinitária','Gloria Patri','fundamentais',
       'Glória ao Pai, ao Filho e ao Espírito Santo. Como era no princípio, agora e sempre. Amém.',
       'Gloria Patri, et Filio, et Spiritui Sancto. Sicut erat in principio, et nunc, et semper, et in saecula saeculorum. Amen.',
       'Breve louvor à Santíssima Trindade que encerra os salmos e as dezenas do Rosário.',20,3),
      ('credo-apostolos','Credo dos Apóstolos','A fé professada pela Igreja','Symbolum Apostolorum','fundamentais',
       E'Creio em Deus Pai todo-poderoso, criador do céu e da terra; e em Jesus Cristo, seu único Filho, nosso Senhor, que foi concebido pelo poder do Espírito Santo, nasceu da Virgem Maria, padeceu sob Pôncio Pilatos, foi crucificado, morto e sepultado; desceu à mansão dos mortos, ressuscitou ao terceiro dia, subiu aos céus, está sentado à direita de Deus Pai todo-poderoso, donde há de vir a julgar os vivos e os mortos.\n\nCreio no Espírito Santo, na santa Igreja católica, na comunhão dos santos, na remissão dos pecados, na ressurreição da carne, na vida eterna. Amém.',
       NULL,
       'Símbolo batismal da Igreja de Roma, resumo dos artigos essenciais da fé.',90,4),
      ('salve-rainha','Salve-Rainha','Antífona mariana','Salve Regina','marianas',
       E'Salve, Rainha, Mãe de misericórdia, vida, doçura e esperança nossa, salve!\n\nA vós clamamos, os degredados filhos de Eva; a vós suspiramos, gemendo e chorando neste vale de lágrimas. Eia, pois, advogada nossa, esses vossos olhos misericordiosos a nós volvei; e depois deste desterro nos mostrai Jesus Cristo, bendito fruto do vosso ventre. Ó clemente, ó piedosa, ó doce sempre Virgem Maria. Amém.',
       'Salve, Regina, Mater misericordiae, vita, dulcedo et spes nostra, salve.',
       'Antífona cantada desde o século XI, tradicionalmente ao fim do Rosário e das Completas.',60,5),
      ('anjo-da-guarda','Santo Anjo','Oração de proteção','Angele Dei','protecao',
       'Santo Anjo do Senhor, meu zeloso guardador, se a ti me confiou a piedade divina, sempre me rege, me guarda, me governa, me ilumina. Amém.',
       'Angele Dei, qui custos es mei, me tibi commissum pietate superna, hodie illumina, custodi, rege et guberna. Amen.',
       'Oração simples à guarda angélica, tradicionalmente ensinada às crianças.',20,6),
      ('ato-de-contricao','Ato de Contrição','Arrependimento e propósito','Actus Contritionis','confissao_defuntos',
       'Meu Deus, eu me arrependo de todo o coração de vos ter ofendido, porque sois infinitamente bom e o pecado vos desagrada. Prometo, com a vossa graça, emendar-me e evitar as ocasiões de pecar. Senhor, tende misericórdia de mim. Amém.',
       NULL,
       'Expressa a dor dos pecados e o propósito de emenda, especialmente antes da Confissão.',40,7),
      ('vinde-espirito-santo','Vinde, Espírito Santo','Invocação ao Paráclito','Veni, Sancte Spiritus','espirito_santo',
       E'Vinde, Espírito Santo, enchei os corações dos vossos fiéis e acendei neles o fogo do vosso amor.\n\nEnviai o vosso Espírito e tudo será criado, e renovareis a face da terra.\n\nÓ Deus, que instruístes os corações dos vossos fiéis com a luz do Espírito Santo, concedei-nos que, no mesmo Espírito, amemos sempre o bem e gozemos de sua consolação. Por Cristo, nosso Senhor. Amém.',
       'Veni, Sancte Spiritus, reple tuorum corda fidelium, et tui amoris in eis ignem accende.',
       'Invocação usada antes do estudo, das reuniões e de toda obra apostólica.',60,8),
      ('angelus','Angelus','A Encarnação recordada três vezes ao dia','Angelus Domini','momentos_do_dia',
       E'V. O Anjo do Senhor anunciou a Maria.\nR. E ela concebeu do Espírito Santo.\n\nAve Maria...\n\nV. Eis aqui a serva do Senhor.\nR. Faça-se em mim segundo a vossa palavra.\n\nAve Maria...\n\nV. E o Verbo divino se fez carne.\nR. E habitou entre nós.\n\nAve Maria...\n\nV. Rogai por nós, santa Mãe de Deus.\nR. Para que sejamos dignos das promessas de Cristo.\n\nOremos: Infundi, Senhor, a vossa graça em nossas almas, para que nós, que conhecemos pela mensagem do Anjo a Encarnação do vosso Filho Jesus Cristo, cheguemos, por sua Paixão e Cruz, à glória da ressurreição. Por Cristo, nosso Senhor. Amém.',
       'Angelus Domini nuntiavit Mariae, et concepit de Spiritu Sancto.',
       'Rezado às 6h, 12h e 18h; no Tempo Pascal é substituído pelo Regina Caeli.',120,9),
      ('sao-miguel','Oração a São Miguel Arcanjo','Defesa no combate espiritual','Sancte Michael','protecao',
       'São Miguel Arcanjo, defendei-nos no combate; sede o nosso refúgio contra as maldades e ciladas do demônio. Que Deus manifeste sobre ele o seu poder, é o que humildemente pedimos. E vós, Príncipe da milícia celeste, pelo poder divino, lançai no inferno a Satanás e aos outros espíritos malignos que vagueiam pelo mundo para perdição das almas. Amém.',
       'Sancte Michael Archangele, defende nos in proelio.',
       'Composta no século XIX e amplamente rezada ao fim da Missa por muitos anos.',40,10)
    ) AS x(slug,title,subtitle,kicker,category,content,content_latin,explanation,secs,ord)
  LOOP
    INSERT INTO public.prayers (slug,title,subtitle,kicker,category,content,content_latin,explanation,estimated_seconds,order_index,is_published)
    VALUES (r.slug,r.title,r.subtitle,r.kicker,r.category::public.prayer_category,r.content,r.content_latin,r.explanation,r.secs,r.ord,true)
    ON CONFLICT (slug) DO NOTHING
    RETURNING id INTO v_id;

    IF v_id IS NOT NULL THEN
      INSERT INTO public.prayer_blocks (prayer_id, type, title, content, repeat_count, order_index)
      VALUES (v_id, 'prayer', r.title, jsonb_build_object('text', r.content, 'latin', r.content_latin), 1, 1);
    END IF;
    v_id := NULL;
  END LOOP;
END $$;

-- ==========================================================
-- 7. CONTEÚDO: temas, glossário, jornadas, flags
-- ==========================================================
INSERT INTO public.themes (name, slug, description, emoji, category, order_index) VALUES
  ('Esperança','esperanca','A virtude que sustenta o coração na promessa de Deus.','⚓','virtudes',1),
  ('Eucaristia','eucaristia','Fonte e ápice da vida cristã.','🍞','sacramentos',2),
  ('Graça','graca','O dom gratuito pelo qual Deus nos associa à sua vida.','✨','doutrina',3),
  ('Misericórdia','misericordia','O amor de Deus que se inclina sobre a miséria humana.','🕊️','doutrina',4),
  ('Oração','oracao','A elevação da alma a Deus.','🙏','vida-espiritual',5),
  ('Maria','maria','A Mãe de Deus e figura da Igreja.','🌹','mariologia',6)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.glossary (term, slug, definition, short_definition, category, editorial_completeness) VALUES
  ('Graça','graca','Dom gratuito e sobrenatural pelo qual Deus nos concede participar da sua própria vida, capacitando o ser humano a responder ao seu chamado.','Dom gratuito da vida divina.','doutrina','expanding'),
  ('Eucaristia','eucaristia','Sacramento no qual, sob as espécies do pão e do vinho, a Igreja professa a presença real de Jesus Cristo, memorial do seu sacrifício e alimento do povo de Deus.','Sacramento da presença real de Cristo.','sacramentos','expanding'),
  ('Liturgia','liturgia','Culto público e oficial da Igreja, no qual a obra da redenção é celebrada e atualizada por meio de ritos, palavras e sinais sagrados.','Culto público da Igreja.','liturgia','expanding'),
  ('Fé','fe','Virtude sobrenatural pela qual o ser humano adere livremente a Deus que se revela e ao que Ele revelou.','Adesão livre a Deus que se revela.','virtudes','expanding'),
  ('Esperança','esperanca','Virtude pela qual desejamos a vida eterna como nossa felicidade, confiando nas promessas de Cristo e no auxílio da graça.','Confiança nas promessas de Cristo.','virtudes','expanding'),
  ('Caridade','caridade','Virtude pela qual amamos Deus por Ele mesmo e o próximo por amor de Deus; é a forma de todas as virtudes.','Amor a Deus e ao próximo.','virtudes','expanding'),
  ('Magistério','magisterio','Ofício de ensinar autenticamente a Palavra de Deus, confiado ao Papa e aos bispos em comunhão com ele.','Ofício de ensino da Igreja.','doutrina','expanding'),
  ('Contemplação','contemplacao','Forma de oração silenciosa em que a alma permanece atenta e amorosa diante do mistério de Deus.','Oração silenciosa e amorosa.','vida-espiritual','expanding')
ON CONFLICT DO NOTHING;

DO $$
DECLARE j uuid;
BEGIN
  INSERT INTO public.journeys (title, subtitle, description, icon, category, difficulty, estimated_days, sort_order, tags)
  VALUES ('Primeiros Passos na Oração','Sete dias para começar','Uma introdução simples e firme à vida de oração, um passo por dia.','sparkles','vida-espiritual','iniciante',7,1,ARRAY['oracao','iniciante'])
  RETURNING id INTO j;
  INSERT INTO public.journey_steps (journey_id, step_order, title, subtitle, step_type, duration_minutes, is_free, content) VALUES
    (j,1,'O desejo de rezar','Reconhecer a sede de Deus','reading',10,true,jsonb_build_object('text','Toda oração começa como resposta: Deus chama primeiro, e o coração desperta.')),
    (j,2,'O Pai-Nosso','A oração que o Senhor ensinou','prayer',10,true,jsonb_build_object('prayer_slug','pai-nosso')),
    (j,3,'O silêncio','Aprender a escutar','reading',10,true,jsonb_build_object('text','Sem silêncio, as palavras da oração ficam vazias.')),
    (j,4,'A Ave-Maria','Rezar com a Mãe','prayer',10,true,jsonb_build_object('prayer_slug','ave-maria')),
    (j,5,'A Palavra','Ler a Escritura orando','reading',15,true,jsonb_build_object('text','A Lectio Divina lê, medita, reza e contempla a mesma Palavra.')),
    (j,6,'O exame do dia','Rever o dia diante de Deus','reflection',10,true,jsonb_build_object('text','Onde vi a graça hoje? Onde resisti a ela?')),
    (j,7,'A perseverança','Fazer da oração hábito','reading',10,true,jsonb_build_object('text','A fidelidade nas coisas pequenas sustenta a vida espiritual.'));

  INSERT INTO public.journeys (title, subtitle, description, icon, category, difficulty, estimated_days, sort_order, tags)
  VALUES ('Introdução ao Credo','A fé em doze artigos','Percorra os artigos do Símbolo dos Apóstolos e compreenda o que a Igreja professa.','scroll','doutrina','iniciante',6,2,ARRAY['fe','doutrina'])
  RETURNING id INTO j;
  INSERT INTO public.journey_steps (journey_id, step_order, title, step_type, duration_minutes, is_free, content) VALUES
    (j,1,'Creio em Deus Pai','reading',12,true,jsonb_build_object('text','A criação como primeiro gesto do amor de Deus.')),
    (j,2,'Jesus Cristo, seu Filho','reading',12,true,jsonb_build_object('text','A Encarnação: Deus assume a nossa carne.')),
    (j,3,'Paixão, morte e ressurreição','reading',12,true,jsonb_build_object('text','O centro do anúncio cristão.')),
    (j,4,'O Espírito Santo','reading',12,true,jsonb_build_object('text','O Senhor que dá a vida e habita na Igreja.')),
    (j,5,'A Igreja e a comunhão dos santos','reading',12,true,jsonb_build_object('text','Uma, santa, católica e apostólica.')),
    (j,6,'A vida eterna','reading',12,true,jsonb_build_object('text','A esperança que não decepciona.'));
END $$;

INSERT INTO public.app_feature_flags (feature_key, is_enabled, description) VALUES
  ('logos_ai', true, 'Assistente Logos IA'),
  ('community', false, 'Comunidade'),
  ('premium', false, 'Recursos premium')
ON CONFLICT (feature_key) DO NOTHING;

INSERT INTO public.telemetry_settings (key, value) VALUES
  ('thresholds', '{"lcp":2500,"inp":200,"cls":0.1}'::jsonb)
ON CONFLICT (key) DO NOTHING;