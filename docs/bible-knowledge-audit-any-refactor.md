# Refatoração de `any` em `BibleKnowledgeAudit.tsx`

O componente `src/components/cathedra/BibleKnowledgeAudit.tsx` concentra 51 ocorrências de `@typescript-eslint/no-explicit-any`. A abordagem recomendada é tipar primeiro as fronteiras de dados e os parâmetros de URL, sem alterar todo o componente em um único commit.

## 1. Tipos de domínio mínimos

Crie estes tipos no início do componente ou, preferencialmente, em `src/components/cathedra/bibleKnowledgeAudit.types.ts`:

```ts
export type AuditTab =
  | "overview"
  | "dashboard"
  | "audit-logs"
  | "schedule"
  | "history"
  | "notifications"
  | "webhooks"
  | "security"
  | "a11y"
  | "i18n-audit";

export type I18nStatus = "all" | "pending" | "mapped";
export type I18nSortOrder = "recent" | "oldest";
export type NotificationType = "webhook" | "email" | "slack" | "discord" | "sms";
export type JsonObject = Record<string, unknown>;

export interface AuditRun {
  id: string;
  status: "passed" | "failed" | string;
  metadata: JsonObject | null;
  created_at: string;
}

export interface NotificationSetting {
  id: string;
  type: NotificationType;
  target: string;
  is_active: boolean;
  priority_threshold: string | null;
  created_at: string;
  updated_at: string;
  channel: string | null;
  priority: string;
  rules: JsonObject | null;
  retry_config: {
    max_retries?: number;
    backoff?: string;
    retry_window?: number;
  } | null;
  headers: JsonObject | null;
  version: number;
  is_latest: boolean;
  has_secret: boolean;
}

export interface WebhookDelivery {
  id: string;
  notification_id: string;
  idempotency_key: string | null;
  response_status: number;
  response_body: string | null;
  duration_ms: number;
  delivered_at: string;
  request_payload: JsonObject;
  verification_details: JsonObject | null;
  notification?: Pick<NotificationSetting, "target" | "type">;
}

export interface SecurityIssue {
  level: "low" | "medium" | "high" | "critical" | "warn" | string;
  message: string;
  category: string;
}

export interface SecurityScan {
  id: string;
  status: "passed" | "failed" | string;
  compliance_score: number | null;
  issues_found: SecurityIssue[] | null;
  started_at: string;
  triggered_by: string | null;
}

export interface I18nFailure {
  term: string;
  expected: string;
  context: string;
  status: Exclude<I18nStatus, "all">;
  updated_at: string;
  endpoint: string;
}
```

## 2. Eliminar casts `as any` dos parâmetros da URL

Use guardas em vez de confiar em casts:

```ts
const AUDIT_TABS = [
  "overview",
  "dashboard",
  "audit-logs",
  "schedule",
  "history",
  "notifications",
  "webhooks",
  "security",
  "a11y",
  "i18n-audit",
] as const satisfies readonly AuditTab[];

function isAuditTab(value: string | null): value is AuditTab {
  return value !== null && AUDIT_TABS.includes(value as AuditTab);
}

function parseI18nStatus(value: string | null): I18nStatus {
  return value === "pending" || value === "mapped" ? value : "all";
}

function parseI18nSortOrder(value: string | null): I18nSortOrder {
  return value === "oldest" ? "oldest" : "recent";
}
```

Substitua:

```ts
const [i18nStatusFilter, setI18nStatusFilter] = React.useState<"all" | "pending" | "mapped">(
  (searchParams.get("i_status") as any) || "all",
);
```

por:

```ts
const [i18nStatusFilter, setI18nStatusFilter] = React.useState<I18nStatus>(() =>
  parseI18nStatus(searchParams.get("i_status")),
);
```

Faça o mesmo para `i18nSortOrder` e `activeTab`:

```ts
const getTabFromUrl = (): AuditTab => {
  const tab = searchParams.get("tab");
  return isAuditTab(tab) ? tab : "overview";
};

const [activeTab, setActiveTab] = React.useState<AuditTab>(getTabFromUrl);
```

Nos handlers de `<select>`, use uma função de parsing:

```ts
onChange={(event) => setI18nStatusFilter(parseI18nStatus(event.target.value))}
```

## 3. Tipar o estado local

Substitua os estados genéricos:

```ts
const [auditRuns, setAuditRuns] = React.useState<any[]>([]);
const [notificationSettings, setNotificationSettings] = React.useState<any[]>([]);
const [securityScans, setSecurityScans] = React.useState<any[]>([]);
const [a11yConfig, setA11yConfig] = React.useState<any>(null);
```

por:

```ts
const [auditRuns, setAuditRuns] = React.useState<AuditRun[]>([]);
const [notificationSettings, setNotificationSettings] = React.useState<NotificationSetting[]>([]);
const [securityScans, setSecurityScans] = React.useState<SecurityScan[]>([]);
const [a11yConfig, setA11yConfig] = React.useState<JsonObject | null>(null);
```

Para comparações, evite `any` em objetos parciais:

```ts
const [comparison, setComparison] = React.useState<{
  run1: AuditRun;
  run2: AuditRun;
} | null>(null);

const [scanComparison, setScanComparison] = React.useState<{
  s1: SecurityScan;
  s2: SecurityScan;
} | null>(null);
```

## 4. Tipar erros capturados

Erros capturados são `unknown` em vez de `any`:

```ts
function getErrorMessage(error: unknown): string {
  return error instanceof Error ? error.message : "Erro desconhecido";
}
```

Uso:

```ts
} catch (error: unknown) {
  toast.error(`Erro na auditoria: ${getErrorMessage(error)}`);
}
```

## 5. Tipar headers e payloads do webhook

```ts
interface WebhookTestResult {
  notification_id: string;
  request_payload: JsonObject;
  response_status: number;
  response_body: string;
  duration_ms: number;
  delivered_at: string;
  idempotency_key: string;
  verification_details: JsonObject | null;
}

const headers: HeadersInit = {
  "Content-Type": "application/json",
  "X-Idempotency-Key": idempotencyKey ?? crypto.randomUUID(),
};

let verificationDetails: JsonObject | null = null;
```

Em vez de `insert([result] as any)`, use uma fronteira tipada para o insert. O tipo final deve vir de `src/integrations/supabase/types.ts` depois que as tabelas `bible_audit_*` forem incluídas no schema gerado:

```ts
type WebhookDeliveryInsert = Omit<WebhookTestResult, "response_body"> & {
  response_body: string;
};

const delivery: WebhookDeliveryInsert = {
  notification_id: notificationId,
  request_payload: payload,
  response_status: response.status,
  response_body: await response.text(),
  duration_ms: duration,
  delivered_at: new Date().toISOString(),
  idempotency_key: String(headers["X-Idempotency-Key"]),
  verification_details: verificationDetails,
};

await supabase.from("bible_audit_webhook_deliveries").insert(delivery);
```

Se o cliente Supabase ainda não conhece a tabela, o ajuste correto é regenerar os tipos, não adicionar `as any`:

```bash
supabase gen types typescript \
  --project-id "$SUPABASE_PROJECT_ID" \
  > src/integrations/supabase/types.ts
```

## 6. Ordem segura de implementação

1. Aplicar os tipos de URL e remover os casts `as any` das linhas 42, 49, 70, 241, 246, 249, 1005, 1061, 1758, 2041 e 2054.
2. Tipar estados com interfaces locais.
3. Tipar `catch` como `unknown`.
4. Tipar payloads de webhook e configurações de notificação.
5. Regenerar os tipos Supabase antes de corrigir os inserts e updates.
6. Executar o lint somente no arquivo:

```bash
npx eslint src/components/cathedra/BibleKnowledgeAudit.tsx
npm run typecheck
npm run build
```

A expectativa é remover primeiro os erros mecânicos e de fronteira, sem alterar a lógica de auditoria, notificações ou segurança.
