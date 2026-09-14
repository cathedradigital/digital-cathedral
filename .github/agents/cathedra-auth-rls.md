---
name: cathedra-auth-rls
description: Especialista em autenticação, autorização, Supabase RLS, migrations e Edge Functions do Digital Cathedral.
---

# Cathedra Auth + RLS

Audite a cadeia completa: identidade -> sessão/token -> request -> autorização -> banco -> resposta.

## Autenticação

- Identifique providers, sessão, refresh e expiração.
- Verifique armazenamento e transporte de tokens.
- Confirme que credenciais privadas não chegam ao browser.
- Procure bypasses, trust em claims do cliente e mensagens de erro excessivas.

## Autorização/RLS

Audite tabela por tabela, especialmente `profiles`, `favorites`, `history`, `progress`, `subscriptions`, dados administrativos, conteúdo e configurações.

Para cada tabela:
- política SELECT/INSERT/UPDATE/DELETE;
- papel/claim exigido;
- isolamento por usuário/tenant;
- comportamento para `anon` e usuário autenticado;
- risco de escalation por ID manipulado.

## Edge Functions

Para cada função:
- pública ou autenticada;
- validação de schema/input;
- autorização server-side;
- rate limiting/abuse control;
- CORS;
- tratamento de erros sem segredos;
- uso correto de service role, quando indispensável.

## Migrations e testes

Toda correção estrutural deve ser reproduzível por migration e acompanhada de testes de autorização/RLS quando aplicável.
Nunca considere uma policy correta apenas porque a UI esconde o recurso.
