const HEADER = 'x-correlation-id';

function newCorrelationId(): string {
  const cryptoApi = (globalThis as { crypto?: { randomUUID?: () => string } }).crypto;
  if (cryptoApi?.randomUUID) return cryptoApi.randomUUID();
  return `cid-${Math.random().toString(36).slice(2)}${Date.now().toString(36)}`;
}

export function getOrCreateCorrelationId(req: Request): string {
  const incoming = req.headers.get(HEADER)?.trim();
  if (incoming && incoming.length <= 128) return incoming;
  return newCorrelationId();
}

export function correlationResponseHeader(id: string): Record<string, string> {
  return { [HEADER]: id };
}

export function correlationClientHeaders(id: string): Record<string, string> {
  return { [HEADER]: id };
}

export const CORRELATION_HEADER = HEADER;
