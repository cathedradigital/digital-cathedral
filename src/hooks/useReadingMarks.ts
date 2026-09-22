import { useState, useEffect, useCallback } from 'react';
import { supabase } from '@/lib/db';
import { useAuth } from './useAuth';

export interface ReadingMark {
  id: string;
  user_id?: string;
  content_type: string;
  content_id: string;
  chapter?: number;
  paragraph?: number;
  position?: number;
  label?: string;
  url?: string;
  is_last_read: boolean;
  created_at: string;
  updated_at: string;
}

export function useReadingMarks() {
  const { user } = useAuth();
  const [marks, setMarks] = useState<ReadingMark[]>([]);
  const [loading, setLoading] = useState(false);

  const fetchMarks = useCallback(async () => {
    if (!user) {
      setMarks([]);
      return;
    }
    setLoading(true);
    const { data, error } = await supabase
      .from('reading_marks')
      .select('*')
      .eq('user_id', user.id)
      .order('updated_at', { ascending: false });

    if (!error && data) setMarks(data as ReadingMark[]);
    if (error) console.error('Error loading reading marks:', error);
    setLoading(false);
  }, [user]);

  useEffect(() => {
    void fetchMarks();
  }, [fetchMarks]);

  useEffect(() => {
    if (!user) return;
    const channel = supabase
      .channel(`reading_marks_realtime:${user.id}:${Math.random().toString(36).slice(2, 10)}`)
      .on(
        'postgres_changes',
        { event: '*', schema: 'public', table: 'reading_marks', filter: `user_id=eq.${user.id}` },
        () => void fetchMarks(),
      )
      .subscribe();

    return () => {
      void supabase.removeChannel(channel);
    };
  }, [user, fetchMarks]);

  const unsetLastRead = useCallback(async () => {
    if (!user) return null;
    return supabase
      .from('reading_marks')
      .update({ is_last_read: false })
      .eq('user_id', user.id)
      .eq('is_last_read', true);
  }, [user]);

  const addMark = useCallback(async (mark: Partial<ReadingMark>) => {
    if (!user || !mark.content_type || !mark.content_id) return null;

    if (mark.is_last_read) {
      const { error } = await unsetLastRead();
      if (error) {
        console.error('Error clearing previous last-read mark:', error);
        return null;
      }
    }

    const { data, error } = await supabase
      .from('reading_marks')
      .insert({
        user_id: user.id,
        content_type: mark.content_type,
        content_id: mark.content_id,
        chapter: mark.chapter,
        paragraph: mark.paragraph,
        position: mark.position,
        label: mark.label,
        url: mark.url,
        is_last_read: mark.is_last_read === true,
      })
      .select()
      .single();

    if (error) {
      console.error('Error adding reading mark:', error);
      return null;
    }
    if (data) setMarks(prev => [data as ReadingMark, ...prev.filter(m => m.id !== data.id)]);
    return data as ReadingMark;
  }, [user, unsetLastRead]);

  const updateMark = useCallback(async (id: string, updates: Partial<ReadingMark>) => {
    if (!user) return null;

    if (updates.is_last_read === true) {
      const { error } = await unsetLastRead();
      if (error) {
        console.error('Error clearing previous last-read mark:', error);
        return null;
      }
    }

    const safeUpdates = { ...updates };
    delete (safeUpdates as Partial<ReadingMark>).user_id;
    delete (safeUpdates as Partial<ReadingMark>).id;
    delete (safeUpdates as Partial<ReadingMark>).created_at;
    delete (safeUpdates as Partial<ReadingMark>).updated_at;

    const { data, error } = await supabase
      .from('reading_marks')
      .update(safeUpdates)
      .eq('id', id)
      .eq('user_id', user.id)
      .select()
      .single();

    if (error) {
      console.error('Error updating reading mark:', error);
      return null;
    }
    if (data) setMarks(prev => prev.map(m => m.id === id ? data as ReadingMark : m));
    return data as ReadingMark;
  }, [user, unsetLastRead]);

  const deleteMark = useCallback(async (id: string) => {
    if (!user) return false;
    const { error } = await supabase
      .from('reading_marks')
      .delete()
      .eq('id', id)
      .eq('user_id', user.id);

    if (error) {
      console.error('Error deleting reading mark:', error);
      return false;
    }
    setMarks(prev => prev.filter(m => m.id !== id));
    return true;
  }, [user]);

  const saveLastRead = useCallback(async (mark: Partial<ReadingMark>) => {
    if (!user || !mark.content_type || !mark.content_id) return null;
    return addMark({ ...mark, is_last_read: true });
  }, [user, addMark]);

  const getLastRead = useCallback(async () => {
    if (!user) return null;
    const { data, error } = await supabase
      .from('reading_marks')
      .select('*')
      .eq('user_id', user.id)
      .eq('is_last_read', true)
      .order('updated_at', { ascending: false })
      .limit(1)
      .maybeSingle();

    if (error) {
      console.error('Error loading last reading position:', error);
      return null;
    }
    return data as ReadingMark | null;
  }, [user]);

  return { marks, loading, addMark, updateMark, deleteMark, saveLastRead, getLastRead, refetch: fetchMarks };
}
