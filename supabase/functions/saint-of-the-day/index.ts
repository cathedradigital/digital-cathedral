import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.38.4';
import { getOrCreateCorrelationId } from '../_shared/correlation.ts';
import { makeLogger } from '../_shared/logger.ts';
import { makeResponder } from '../_shared/http-response.ts';

const supabaseUrl = Deno.env.get('SUPABASE_URL') || '';
const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || '';
const supabase = createClient(supabaseUrl, supabaseKey);

function ordinal(month: number, day: number) {
  return month * 100 + day;
}

Deno.serve(async (req) => {
  const cid = getOrCreateCorrelationId(req);
  const responder = makeResponder(cid);
  const log = makeLogger('saint-of-the-day', cid);

  if (req.method === 'OPTIONS') return responder.cors();

  try {
    const now = new Date();
    const day = now.getDate();
    const month = now.getMonth() + 1;

    const { data: dbSaint, error: dbError } = await supabase
      .from('saints')
      .select('*')
      .eq('feast_month', month)
      .eq('feast_day_num', day)
      .limit(1)
      .maybeSingle();

    if (dbSaint && !dbError) {
      return responder.raw({
        ...dbSaint,
        description: dbSaint.bio,
        fullBio: dbSaint.full_bio,
        source: dbSaint.source_name || 'Cathedra Database',
        sourceUrl: dbSaint.source_url || null,
        bioSourceUrl: dbSaint.bio_source_url || null,
        prayerSourceUrl: dbSaint.prayer_source_url || null,
        is_fallback: false,
        correlation_id: cid,
      });
    }

    const { data: all, error: allError } = await supabase
      .from('saints')
      .select('*')
      .not('feast_month', 'is', null)
      .not('feast_day_num', 'is', null);

    if (!allError && all && all.length > 0) {
      const todayOrdinal = ordinal(month, day);
      const ranked = all.map((saint: { feast_month: number; feast_day_num: number }) => {
        const saintOrdinal = ordinal(saint.feast_month, saint.feast_day_num);
        const delta = saintOrdinal > todayOrdinal
          ? saintOrdinal - todayOrdinal
          : saintOrdinal - todayOrdinal + 1231;
        return { saint, delta };
      });
      ranked.sort((a, b) => a.delta - b.delta);
      const next = ranked[0].saint as Record<string, unknown>;

      log.info('fallback_next_saint', {
        requested: { month, day },
        chosen: { month: next.feast_month, day: next.feast_day_num },
      });

      return responder.raw({
        ...next,
        description: next.bio,
        fullBio: next.full_bio,
        source: next.source_name || 'Cathedra Database',
        sourceUrl: next.source_url || null,
        bioSourceUrl: next.bio_source_url || null,
        prayerSourceUrl: next.prayer_source_url || null,
        is_fallback: true,
        fallback_reason: 'no_saint_for_today',
        requested_date: { month, day },
        correlation_id: cid,
      });
    }

    return responder.error(404, 'not_found', { message: 'Base de santos vazia.' });
  } catch (error) {
    log.error('unhandled', { err: String(error) });
    return responder.error(500, 'internal_error', { message: 'Erro interno.' });
  }
});
