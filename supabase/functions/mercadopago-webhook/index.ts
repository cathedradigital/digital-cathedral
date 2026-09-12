import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { getOrCreateCorrelationId } from "../_shared/correlation.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.38.4";
import { logSecurityEvent } from '../_shared/security-logs.ts'

const _corsBase = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type, x-supabase-client-platform, x-supabase-client-platform-version, x-supabase-client-runtime, x-supabase-client-runtime-version, x-correlation-id",
  "Access-Control-Expose-Headers": "x-correlation-id",
};
const corsHeaders = _corsBase;

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });

function normalizeMercadoPagoAccessToken(rawToken: string) {
  const trimmedToken = rawToken.trim().replace(/^Bearer\s+/i, "");
  const tokenMatch = trimmedToken.match(/(APP_USR-[A-Za-z0-9_-]+(?:-[A-Za-z0-9_-]+)*)|(TEST-[A-Za-z0-9_-]+(?:-[A-Za-z0-9_-]+)*)/);
  return tokenMatch?.[0] ?? trimmedToken;
}

function resolveMercadoPagoAccessToken() {
  const secretCandidates = [
    { name: "MERCADO_PAGO_ACCESS_TOKEN", value: Deno.env.get("MERCADO_PAGO_ACCESS_TOKEN") },
    { name: "MERCADOPAGO_ACCESS_TOKEN", value: Deno.env.get("MERCADOPAGO_ACCESS_TOKEN") },
  ];

  console.log(
    "[mercadopago-webhook] secret availability",
    secretCandidates.map(({ name, value }) => ({ name, present: Boolean(value?.trim()) })),
  );

  const selectedSecret = secretCandidates.find(({ value }) => Boolean(value?.trim()));
  if (!selectedSecret) return { source: null, token: "" };

  return {
    source: selectedSecret.name,
    token: normalizeMercadoPagoAccessToken(selectedSecret.value!),
  };
}

function hexToBytes(hex: string): Uint8Array | null {
  if (!/^[0-9a-f]{64}$/i.test(hex)) return null;
  const bytes = new Uint8Array(32);
  for (let i = 0; i < 32; i += 1) bytes[i] = Number.parseInt(hex.slice(i * 2, i * 2 + 2), 16);
  return bytes;
}

async function verifyMercadoPagoSignature(
  req: Request,
  rawBody: string,
  dataId: string | null,
): Promise<boolean> {
  const secret = Deno.env.get("MERCADO_PAGO_WEBHOOK_SECRET");
  if (!secret) {
    console.error("[mercadopago-webhook] MERCADO_PAGO_WEBHOOK_SECRET not configured — rejecting webhook");
    return false;
  }

  const signatureHeader = req.headers.get("x-signature") || "";
  const requestIdHeader = req.headers.get("x-request-id") || "";
  if (!signatureHeader || !requestIdHeader) return false;

  const parts = Object.fromEntries(
    signatureHeader.split(",").map((p) => {
      const [k, ...v] = p.trim().split("=");
      return [k, v.join("=")];
    }),
  ) as Record<string, string>;

  const ts = parts.ts;
  const v1 = parts.v1;
  const expectedBytes = hexToBytes(v1 ?? "");
  if (!ts || !expectedBytes) return false;

  const manifest = `id:${dataId ?? ""};request-id:${requestIdHeader};ts:${ts};`;
  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["verify"],
  );
  return crypto.subtle.verify("HMAC", key, expectedBytes, new TextEncoder().encode(manifest));
}

serve(async (req) => {
  const _cid = getOrCreateCorrelationId(req);
  const corsHeaders = { ..._corsBase, 'x-correlation-id': _cid };
  const json = (body: unknown, status = 200) =>
    new Response(JSON.stringify(body), { status, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });

  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST" && req.method !== "GET") return json({ error: "Método não permitido." }, 405);

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL") || "";
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || "";
    const { source: tokenSource, token: mercadoPagoAccessToken } = resolveMercadoPagoAccessToken();

    console.log("[mercadopago-webhook] runtime env", {
      hasServiceRoleKey: Boolean(serviceRoleKey),
      hasSupabaseUrl: Boolean(supabaseUrl),
      tokenSource,
    });

    if (!supabaseUrl || !serviceRoleKey) return json({ error: "Configuração do backend incompleta." }, 500);
    if (!mercadoPagoAccessToken) return json({ error: "Mercado Pago ainda não configurado no backend." }, 500);

    const adminClient = createClient(supabaseUrl, serviceRoleKey);
    const url = new URL(req.url);
    const rawBody = req.method === "POST" ? await req.text() : "";
    const body = rawBody
      ? (() => {
          try { return JSON.parse(rawBody); } catch { return null; }
        })()
      : null;

    const eventType =
      url.searchParams.get("type") || url.searchParams.get("topic") || body?.type || body?.topic || null;
    const rawPaymentId =
      body?.data?.id || url.searchParams.get("data.id") || body?.id || url.searchParams.get("id") ||
      (typeof body?.resource === "string" ? body.resource.split("/").pop() : null);

    const signatureValid = await verifyMercadoPagoSignature(req, rawBody, rawPaymentId ? String(rawPaymentId) : null);
    if (!signatureValid) {
      console.warn("[mercadopago-webhook] invalid signature");
      await logSecurityEvent(
        Deno.env.get('SUPABASE_URL') || '',
        Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || '',
        'invalid_signature',
        'mercadopago-webhook: invalid webhook signature',
        'critical',
        {
          eventType: typeof eventType === 'string' ? eventType : null,
          paymentId: rawPaymentId ? String(rawPaymentId).slice(0, 64) : null,
          requestId: req.headers.get('x-request-id'),
        }
      );
      return json({ error: "Assinatura inválida." }, 401);
    }

    if (eventType && eventType !== "payment") return json({ ok: true, ignored: true });
    if (!rawPaymentId) return json({ ok: true, ignored: true });

    const paymentResponse = await fetch(`https://api.mercadopago.com/v1/payments/${rawPaymentId}`, {
      headers: { Authorization: `Bearer ${mercadoPagoAccessToken}`, "Content-Type": "application/json" },
    });

    if (!paymentResponse.ok) {
      const errorText = await paymentResponse.text();
      console.error("Mercado Pago webhook payment lookup error:", errorText.slice(0, 1000));
      return json({ error: "Falha ao consultar o pagamento." }, 502);
    }

    const payment = await paymentResponse.json();
    const transactionId = payment.external_reference ?? payment.metadata?.transaction_id;
    if (!transactionId) return json({ ok: true, ignored: true });

    const normalizedStatus = typeof payment.status === "string" ? payment.status : "pending";
    const normalizedAmount = Number(payment.transaction_amount ?? 0) || 19.9;
    const normalizedDescription =
      typeof payment.description === "string" && payment.description.trim().length > 0
        ? payment.description
        : "Cathedra PRO";

    const { data: transaction, error: updateError } = await adminClient
      .from("transactions")
      .update({
        status: normalizedStatus,
        amount: normalizedAmount,
        description: normalizedDescription,
        payment_id: String(rawPaymentId),
        webhook_payload: payment,
      })
      .eq("id", transactionId)
      .select("user_id")
      .maybeSingle();

    if (updateError) {
      console.error("Mercado Pago webhook transaction update error:", updateError);
      await adminClient.from("transactions").update({ error_message: JSON.stringify(updateError) }).eq("id", transactionId);
      return json({ error: "Falha ao atualizar a transação." }, 500);
    }

    if (normalizedStatus === "approved" && transaction?.user_id) {
      const { error: profileError } = await adminClient
        .from("profiles")
        .update({ is_premium: true })
        .eq("id", transaction.user_id);

      if (profileError) {
        console.error("Mercado Pago webhook profile update error:", profileError);
      } else {
        console.log(`PRO activated for user ${transaction.user_id}`);
        await adminClient.from("notifications").insert({
          user_id: transaction.user_id,
          title: "Doação Recebida! ❤️",
          message: `Obrigado! Sua contribuição de ${new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(normalizedAmount)} foi confirmada.`,
          type: "payment",
          link: "/transactions/my"
        });
      }
    } else if ((normalizedStatus === "rejected" || normalizedStatus === "cancelled") && transaction?.user_id) {
      await adminClient.from("notifications").insert({
        user_id: transaction.user_id,
        title: "Problema no Pagamento ⚠️",
        message: "Não conseguimos confirmar sua doação. Tente novamente ou use outro método.",
        type: "payment",
        link: "/checkout"
      });
    }

    return json({ ok: true, transactionId, status: normalizedStatus, premium: normalizedStatus === "approved" });
  } catch (error) {
    console.error("mercadopago-webhook error:", error);
    return json({ error: "Erro interno. Tente novamente." }, 500);
  }
});