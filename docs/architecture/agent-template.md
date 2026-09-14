# Template de Agentes — Digital Cathedral

Este documento adapta ideias do ECC ao projeto sem copiar sua implementação. A referência externa foi usada como modelo de organização de agentes, skills, loops de verificação, memória operacional e segurança.

## Princípio operacional

`plan -> inspect -> implement -> review -> verify -> remember -> improve`

Cada etapa deve deixar evidência suficiente para que outro agente consiga continuar sem repetir trabalho desnecessariamente.

## Catálogo inicial

| Agente | Responsabilidade | Quando executar |
|---|---|---|
| `cathedra-orchestrator` | Coordenação e quality gate | Trabalho amplo/repositório inteiro |
| `cathedra-security` | OWASP, segredos, dependências, trust boundaries | Sempre após mudanças sensíveis |
| `cathedra-auth-rls` | Auth, autorização, RLS, migrations, Edge Functions | Auth/dados/backend |
| `cathedra-code-review` | Revisão independente | Toda alteração de código |
| `cathedra-ci-build` | CI, typecheck, lint, testes, build | Falha de pipeline ou pré-merge |
| `cathedra-qa` | Fluxos críticos, mobile e a11y | Mudanças de UI/produto |
| `cathedra-architect` | Arquitetura e ADRs | Mudanças estruturais |

## O que adotamos da referência

- agentes especializados em vez de um agente genérico para tudo;
- revisão independente após implementação;
- loops explícitos de verificação;
- regras de segurança contra prompt injection e conteúdo externo não confiável;
- classificação de findings por severidade e confiança;
- documentação de decisões arquiteturais;
- separação entre planejamento, execução e validação;
- memória operacional por artefatos versionados, evitando depender apenas do contexto da conversa.

## O que NÃO adotamos automaticamente

- instalação de código externo no projeto;
- execução de scripts de terceiros sem revisão;
- permissões amplas de GitHub Actions;
- cópia integral de agents/skills do ECC;
- afirmações de paridade funcional com o ECC;
- alteração de `main` ou reescrita de histórico.

## Quality Gate

Uma tarefa só pode ser marcada como concluída quando os gates relevantes tiverem evidência:

- [ ] escopo e risco identificados
- [ ] implementação revisada
- [ ] typecheck
- [ ] lint
- [ ] testes
- [ ] build
- [ ] segurança
- [ ] RLS/Edge Functions, quando aplicável
- [ ] QA de fluxos críticos/mobile/a11y, quando aplicável
- [ ] deploy/preview verificado, quando aplicável

`UNKNOWN` não é `PASS`.
