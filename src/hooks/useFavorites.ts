import { useState, useEffect, useCallback } from 'react';
import { supabase } from '@/lib/db';
import { useAuth } from '@/hooks/useAuth';

export interface FavoriteItem {
  id: string;
  type: string;
  title: string;
  content: string;
  timestamp: string;
}

type FavoriteInput = Omit<FavoriteItem, 'id' | 'timestamp'> & {
  /** Optional stable content identifier supplied by a caller. */
  contentId?: string;
};

const STORAGE_KEY = 'cathedra_favorites_v2';

function loadLocalFavorites(projectId: string): FavoriteItem[] {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    const allFavorites = raw ? JSON.parse(raw) : {};
    return (allFavorites[projectId] || []) as FavoriteItem[];
  } catch {
    return [];
  }
}

function saveLocalFavorites(favorites: FavoriteItem[], projectId: string) {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    const allFavorites = raw ? JSON.parse(raw) : {};
    allFavorites[projectId] = favorites;
    localStorage.setItem(STORAGE_KEY, JSON.stringify(allFavorites));
  } catch (e) {
    console.error('Error saving favorites:', e);
  }
}

/**
 * Favorites are persisted in Supabase for authenticated users and remain
 * local-only for guests. `projectId` keeps the legacy module-level separation
 * while the database stores the same scope in metadata.project_id.
 */
export function useFavorites(projectId: string = 'global') {
  const { user, authenticated } = useAuth();
  const [favorites, setFavorites] = useState<FavoriteItem[]>([]);

  useEffect(() => {
    let cancelled = false;

    async function load() {
      if (!authenticated || !user) {
        setFavorites(loadLocalFavorites(projectId));
        return;
      }

      const { data, error } = await supabase
        .from('bible_favorites')
        .select('id, content_type, content_id, title, content, created_at, metadata')
        .eq('user_id', user.id)
        .eq('metadata->>project_id', projectId)
        .order('created_at', { ascending: false });

      if (cancelled) return;

      if (error) {
        console.error('Error loading favorites:', error);
        setFavorites([]);
        return;
      }

      setFavorites(
        (data ?? []).map((item: any) => ({
          id: item.id,
          type: item.content_type,
          title: item.title ?? item.content_id ?? 'Favorito',
          content: item.content ?? '',
          timestamp: item.created_at,
        })),
      );
    }

    void load();
    return () => {
      cancelled = true;
    };
  }, [projectId, user?.id, authenticated]);

  useEffect(() => {
    if (!authenticated) saveLocalFavorites(favorites, projectId);
  }, [favorites, projectId, authenticated]);

  const addFavorite = useCallback(
    (item: FavoriteInput) => {
      if (!authenticated || !user) {
        setFavorites((prev) => {
          if (prev.some((f) => f.type === item.type && f.title === item.title)) return prev;
          return [
            { ...item, id: crypto.randomUUID(), timestamp: new Date().toISOString() },
            ...prev,
          ];
        });
        return;
      }

      void (async () => {
        const contentId = item.contentId ?? item.title;
        const { data, error } = await supabase
          .from('bible_favorites')
          .insert({
            user_id: user.id,
            content_type: item.type,
            content_id: contentId,
            title: item.title,
            content: item.content,
            metadata: { project_id: projectId },
          })
          .select('id, content_type, content_id, title, content, created_at')
          .single();

        if (error) {
          if (String(error.message).toLowerCase().includes('duplicate')) return;
          console.error('Error adding favorite:', error);
          return;
        }

        setFavorites((prev) => [
          {
            id: data.id,
            type: data.content_type,
            title: data.title ?? data.content_id ?? item.title,
            content: data.content ?? item.content,
            timestamp: data.created_at,
          },
          ...prev.filter((f) => !(f.type === item.type && f.title === item.title)),
        ]);
      })();
    },
    [authenticated, user, projectId],
  );

  const removeFavorite = useCallback(
    (id: string) => {
      if (!authenticated || !user) {
        setFavorites((prev) => prev.filter((f) => f.id !== id));
        return;
      }

      setFavorites((prev) => prev.filter((f) => f.id !== id));
      void supabase
        .from('bible_favorites')
        .delete()
        .eq('user_id', user.id)
        .eq('id', id)
        .then(({ error }) => {
          if (error) console.error('Error removing favorite:', error);
        });
    },
    [authenticated, user],
  );

  const isFavorite = useCallback(
    (type: string, title: string) => favorites.some((f) => f.type === type && f.title === title),
    [favorites],
  );

  const toggleFavorite = useCallback(
    (item: FavoriteInput) => {
      const existing = favorites.find((f) => f.type === item.type && f.title === item.title);
      if (existing) removeFavorite(existing.id);
      else addFavorite(item);
    },
    [favorites, addFavorite, removeFavorite],
  );

  return { favorites, addFavorite, removeFavorite, isFavorite, toggleFavorite };
}
