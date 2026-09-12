# Agent System

This directory defines the execution roles coordinated by the **Digital Cathedral Master Agent**.

## Master
- `master.md` — orchestration contract and acceptance gates.

## Roles

| Agent | Scope | Primary gate |
|---|---|---|
| Repository | GitHub, branches, imports, commits, PRs | clean traceable change |
| Frontend | React, TypeScript, routes, UX | typecheck + browser flows |
| Backend | Edge Functions/APIs | function tests + integration |
| Database | Supabase schema/RLS/migrations | migration + RLS tests |
| Security | auth, authorization, secrets, attack surface | security regression gate |
| CI/Test | install, lint, tests, build | GitHub Actions green |
| Vercel | Preview/Production deployment | deployment evidence |
| Browser QA | end-user behavior | real browser validation |
| Integration | cross-layer behavior | end-to-end acceptance |

## Standard handoff

Every agent handoff must contain:

1. objective;
2. findings;
3. files/areas affected;
4. implementation or recommended change;
5. tests executed;
6. evidence/results;
7. blockers;
8. next recommended owner.

The Master decides whether the handoff is accepted or reopens the task.
