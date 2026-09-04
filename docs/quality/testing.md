# Estratégia de qualidade

## Pirâmide

1. typecheck;
2. lint;
3. testes unitários;
4. testes de integração;
5. E2E crítico;
6. E2E amplo/nightly.

## E2E crítico

Cobrir pelo menos:
- home/Hoje;
- menu;
- Bíblia;
- Catecismo;
- biblioteca;
- busca;
- login/logout;
- voltar/avançar;
- deep links;
- refresh;
- jornadas;
- diário;
- paywall quando existir.

## Mobile

Validar especialmente 320, 360, 390 e 412 px.

P0:
- overflow horizontal;
- elementos fora da viewport;
- botões não clicáveis;
- modal sem scroll lock;
- sobreposição do header;
- foco invisível.

## CI

Falhas reais devem falhar o pipeline. Evitar `|| true` em testes de certificação, salvo quando o objetivo for explicitamente não bloqueante e isso estiver documentado.

## Definition of Done

Uma funcionalidade só está pronta quando comportamento, segurança, acessibilidade, mobile e testes relevantes estiverem considerados.
