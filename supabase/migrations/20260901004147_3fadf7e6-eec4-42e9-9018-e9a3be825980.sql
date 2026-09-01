SET check_function_bodies = false;
SET row_security = off;
CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;
CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA extensions;
CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA extensions;
CREATE EXTENSION IF NOT EXISTS btree_gin WITH SCHEMA extensions;
CREATE EXTENSION IF NOT EXISTS pg_net WITH SCHEMA extensions;
CREATE EXTENSION IF NOT EXISTS pg_cron;

CREATE TYPE public.app_role AS ENUM (
    'admin',
    'moderator',
    'user',
    'editor',
    'reviewer'
);

CREATE TYPE public.bible_import_phase AS ENUM (
    'A_pentateuco',
    'B_historicos',
    'C_sapienciais',
    'D_profetas',
    'E_novo_testamento'
);

CREATE TYPE public.bible_phase_status AS ENUM (
    'pending',
    'importing',
    'imported',
    'certified',
    'rejected'
);

CREATE TYPE public.bible_translation_pipeline_stage AS ENUM (
    'draft',
    'importing',
    'integrity_check',
    'editorial_review',
    'ice',
    'certified',
    'primary',
    'archived'
);

CREATE TYPE public.content_curation_status AS ENUM (
    'stub',
    'partial',
    'complete'
);

CREATE TYPE public.editorial_status_enum AS ENUM (
    'draft',
    'doctrinal_review',
    'editorial_review',
    'ice_pending',
    'published',
    'archived'
);

CREATE TYPE public.library_kind AS ENUM (
    'saint_work',
    'patristic',
    'doctor',
    'classic',
    'magisterium'
);

CREATE TYPE public.prayer_category AS ENUM (
    'fundamentais',
    'marianas',
    'espirito_santo',
    'santos',
    'antes_depois',
    'protecao',
    'momentos_do_dia',
    'eucaristica',
    'confissao_defuntos'
);

CREATE TYPE public.saint_content_status AS ENUM (
    'stub',
    'partial',
    'complete'
);

CREATE TYPE public.saint_work_access_type AS ENUM (
    'internal',
    'official_external',
    'public_domain',
    'licensed'
);

CREATE TYPE public.saint_work_category AS ENUM (
    'patristica',
    'escolastica',
    'mistica',
    'monastica',
    'carmelita',
    'franciscana',
    'dominicana',
    'doutor',
    'espiritualidade',
    'apologetica',
    'liturgica',
    'classic',
    'magisterio'
);

CREATE TYPE public.saint_work_ficha_completeness AS ENUM (
    'stub',
    'minimal',
    'complete'
);

CREATE TYPE public.saint_work_reading_level AS ENUM (
    'beginner',
    'intermediate',
    'advanced'
);

CREATE TYPE public.saint_work_status AS ENUM (
    'draft',
    'in_review',
    'published',
    'archived'
);

CREATE TYPE public.search_result_type AS ENUM (
    'bible',
    'catechism',
    'saint',
    'patristic',
    'magisterium',
    'prayer',
    'journey',
    'glossary'
);


CREATE SCHEMA IF NOT EXISTS auth_internal;

CREATE FUNCTION auth_internal.can_update_own_profile(_profile_id uuid, _role text, _is_premium boolean, _email text) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
  SELECT
    _profile_id = auth.uid()
    AND (
      auth_internal.has_role(auth.uid(), 'admin'::app_role)
      OR (
        _role IS NOT DISTINCT FROM (SELECT role FROM public.profiles WHERE id = _profile_id)
        AND _is_premium IS NOT DISTINCT FROM (SELECT is_premium FROM public.profiles WHERE id = _profile_id)
      )
    )
$$;

CREATE FUNCTION auth_internal.enforce_profile_security() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  IF NOT auth_internal.has_role(auth.uid(), 'admin') THEN
    IF NEW.role IS DISTINCT FROM OLD.role THEN
      NEW.role := OLD.role;
    END IF;
    IF NEW.is_premium IS DISTINCT FROM OLD.is_premium THEN
      NEW.is_premium := OLD.is_premium;
    END IF;
    IF NEW.id IS DISTINCT FROM OLD.id THEN
      NEW.id := OLD.id;
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

CREATE FUNCTION auth_internal.handle_new_user() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  INSERT INTO public.profiles (id, name)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'name', '')
  );
  INSERT INTO public.user_sensitive_data (user_id, email)
  VALUES (
    NEW.id,
    COALESCE(NEW.email, '')
  );
  RETURN NEW;
END;
$$;

CREATE FUNCTION auth_internal.has_role(user_id uuid, required_role text) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  -- Verifica se o usuário tem a role no metadados do JWT (app_metadata)
  -- Assumindo que o sistema de roles usa o padrão do Supabase no app_metadata
  RETURN (
    SELECT (auth.jwt() -> 'app_metadata' ->> 'role') = required_role
  );
END;
$$;

CREATE FUNCTION auth_internal.has_role(_user_id uuid, _role public.app_role) RETURNS boolean
    LANGUAGE sql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.user_roles
    WHERE user_id = _user_id
      AND role = _role
  );
$$;

CREATE FUNCTION auth_internal.is_admin() RETURNS boolean
    LANGUAGE plpgsql
    SET search_path TO 'public'
    AS $$
BEGIN
  RETURN (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );
END;
$$;

CREATE FUNCTION auth_internal.prevent_role_escalation() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  IF (OLD.role IS DISTINCT FROM NEW.role OR OLD.is_premium IS DISTINCT FROM NEW.is_premium) THEN
    IF NOT auth_internal.has_role(auth.uid(), 'admin') THEN
      NEW.role := OLD.role;
      NEW.is_premium := OLD.is_premium;
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

CREATE FUNCTION auth_internal.sync_admin_role_from_profile() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  IF NEW.role = 'admin' THEN
    INSERT INTO public.user_roles (user_id, role)
    VALUES (NEW.id, 'admin')
    ON CONFLICT (user_id, role) DO NOTHING;
  ELSE
    DELETE FROM public.user_roles
    WHERE user_id = NEW.id
      AND role = 'admin';
  END IF;
  RETURN NEW;
END;
$$;

CREATE FUNCTION auth_internal.sync_content_tags_to_array() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
    UPDATE public.spiritual_contents
    SET tags = (
      SELECT array_agg(t.label)
      FROM public.content_tags ct
      JOIN public.tags t ON ct.tag_id = t.id
      WHERE ct.content_id = NEW.content_id
    )
    WHERE id = NEW.content_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.spiritual_contents
    SET tags = (
      SELECT COALESCE(array_agg(t.label), '{}')
      FROM public.content_tags ct
      JOIN public.tags t ON ct.tag_id = t.id
      WHERE ct.content_id = OLD.content_id
    )
    WHERE id = OLD.content_id;
  END IF;
  RETURN NULL;
END;
$$;

CREATE FUNCTION auth_internal.update_last_action_at() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  UPDATE public.profiles
  SET last_action_at = now()
  WHERE id = NEW.user_id;
  RETURN NEW;
END;
$$;

CREATE FUNCTION auth_internal.update_last_action_at_from_metrics() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  IF (NEW.metadata->>'user_id') IS NOT NULL THEN
    UPDATE public.profiles
    SET last_action_at = now()
    WHERE id = (NEW.metadata->>'user_id')::uuid;
  END IF;
  RETURN NEW;
END;
$$;