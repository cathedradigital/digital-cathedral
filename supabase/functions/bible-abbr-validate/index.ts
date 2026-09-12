/**
 * Valida e normaliza abreviações bíblicas usadas pela aplicação.
 * GET ?abbrev=2%20Cr e POST { "abbrev": "2 Cr" } são suportados.
 */
import { findBookByAbbr, normalizeAbbr } from '../_shared/bibleCanon.ts';
import { getOrCreateCorrelationId, correlationResponseHeader } from '../_shared/correlation.ts';
import { makeResponder } from '../_shared/http-response.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-correlation-id',
  'Access-Control-Expose-Headers': 'x-correlation-id',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
};

Deno.serve(async (req) => {
  const cid = getOrCreateCorrelationId(req);
  const cidH = correlationResponseHeader(cid);
  const responder = makeResponder(cid);

  const json = (body: unknown, status = 200): Response =>
    new Response(JSON.stringify(body), {
      status,
      headers: { ...corsHeaders, ...cidH, 'Content-Type': 'application/json' },
    });

  if (req.method === 'OPTIONS') return new Response('ok', { headers: { ...corsHeaders, ...cidH } });

  let abbrev: string | null = null;
  try {
    if (req.method === 'GET') {
      const url = new URL(req.url);
      abbrev = url.searchParams.get('abbrev') ?? url.searchParams.get('abbr');
    } else if (req.method === 'POST') {
      const body = await req.json().catch(() => ({} as Record<string, unknown>));
      const value = (body as Record<string, unknown>).abbrev ?? (body as Record<string, unknown>).abbr;
      abbrev = typeof value === 'string' ? value : null;
    } else {
      return responder.error(405, 'method_not_allowed');
    }
  } catch {
    return responder.error(400, 'invalid_body', { reason: 'malformed_request' });
  }

  if (!abbrev || abbrev.trim().length === 0) {
    return responder.error(400, 'invalid_body', {
      reason: 'missing_abbrev',
      hint: 'Parâmetro `abbrev` obrigatório (string não vazia).',
    });
  }

  if (abbrev.length > 64) {
    return responder.error(400, 'invalid_body', { reason: 'abbrev_too_long', max_length: 64 });
  }

  const normalized = normalizeAbbr(abbrev);
  const book = findBookByAbbr(abbrev);

  if (!book) {
    return json(
      {
        input: abbrev,
        normalized,
        canonical_abbr: null,
        book_name: null,
        bollsId: null,
        testament: null,
        deuterocanonical: null,
        resolved: false,
      },
      404,
    );
  }

  return json({
    input: abbrev,
    normalized,
    canonical_abbr: book.abbr,
    book_name: book.name,
    bollsId: book.bollsId,
    testament: book.testament,
    deuterocanonical: book.deuterocanonical ?? false,
    resolved: true,
  });
});
