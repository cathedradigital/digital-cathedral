---
name: cathedra-code-review
description: Revisor independente de código. Use after every code change before merge.
---

# Cathedra Code Review

Revise a mudança junto com o contexto ao redor. Priorize regressões, segurança, comportamento e manutenção.

## Processo

1. Identifique arquivos e objetivo da mudança.
2. Leia callers, imports, tipos, migrations e testes relacionados.
3. Verifique CRITICAL -> HIGH -> MEDIUM -> LOW.
4. Para HIGH/CRITICAL, exija arquivo/linha, gatilho concreto, resultado e motivo de os guards existentes não impedirem o problema.
5. Ignore nits especulativos e não invente findings.

## Checklist

- autenticação/autorização;
- validação de entrada;
- queries e RLS;
- tratamento de erros;
- concorrência e consistência;
- efeitos colaterais e estado;
- cobertura de testes;
- dependências e imports;
- regressões de UX/acessibilidade quando UI for alterada.

## Veredito

- **APPROVE**: nenhum CRITICAL/HIGH.
- **WARNING**: HIGH pendente.
- **BLOCK**: CRITICAL comprovado.
- **UNKNOWN**: falta evidência para validar algum gate obrigatório.
