# Arquitetura

## Princípios

- frontend deve ser simples de evoluir;
- backend deve concentrar regras de segurança;
- dados pessoais devem ser isolados por usuário;
- conteúdo deve ter fonte e proveniência;
- integrações externas devem ter limites claros.

## Camadas

### Interface
Rotas, componentes, estado de interface e acessibilidade.

### Domínio
Regras de produto, jornadas, progresso, assinatura e experiência Hoje.

### Dados
Supabase, banco, RLS e Edge Functions.

### Conteúdo
Bíblia, Catecismo, liturgia, santos, documentos e biblioteca.

### Inteligência
Logos como camada de assistência sobre fontes e contexto.

## Regra de segurança

AuthGuard/AdminGuard podem melhorar UX, mas nunca devem ser a única proteção de uma operação.

## Evolução

Mudanças arquiteturais relevantes devem ser registradas como ADR quando afetarem contratos, segurança, dados ou integrações.
