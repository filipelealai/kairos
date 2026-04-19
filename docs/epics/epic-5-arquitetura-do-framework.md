# Epic 5 — Arquitetura do Framework

**Status:** In Progress
**Objetivo:** Formalizar a fronteira entre o framework Kairos e o conteúdo do usuário, tornando viável atualizações seguras, instalação greenfield/brownfield e publicação do framework como repo público, sem contaminação mútua entre as duas esferas.

---

## Descrição

À medida que o Kairos evolui rumo a ser um framework público instalável (`npx install kairos`), surge uma necessidade arquitetural fundamental: separar com precisão **o que é infraestrutura do framework** (hooks, commands, rules, tasks, templates, constituição) **do que é conteúdo do usuário** (squads, agents, skills, MCPs, secrets).

Esse epic trata a implementação estrutural da Seção VI da constituição (declarada em 1.3.1) — transformando o princípio declarativo em mecanismos operacionais: um manifesto de ownership explícito, markers para arquivos mistos, relocação de conteúdo hoje mal-classificado, e preparação do repo para virar público.

---

## Critério de Conclusão

- [x] Manifesto de ownership (`.kairos-core/manifest.yaml`) criado e completo
- [x] Princípios 24+ adicionados à Seção VI da constituição
- [x] Rule `ownership.md` criada (L1) explicando o modelo
- [x] Poluição relocada: squad-specific rules, data, stories e epics movidos para `squads/cold-prospecting/`
- [x] CLAUDE.md com 3 blocos managed + imports de squad
- [x] Task `kairos-doctor.md` com checks de ownership e markers
- [x] Documento de transição para repo público criado
- [x] Versão bump para 2.0.0 (MAJOR — breaking changes arquiteturais)

---

## Stories

| Story | Título | Status |
|-------|--------|--------|
| [5.1](../stories/5.1.story.md) | Segregação Framework × Usuário via Manifesto de Ownership | Done |
| [5.2](../stories/5.2.story.md) | Transição para Repo Público + Squad ops | Done |
| [5.3](../stories/5.3.story.md) | SHA Sync Automático no `*pre-push` e `*version` | Done |
| [5.4](../stories/5.4.story.md) | Sync Completo de Arquivos Mistos no push-dual | Done |
| [5.5](../stories/5.5.story.md) | *new-squad cria rules/ e faz wiring no CLAUDE.md | Done |
| [5.6](../stories/5.6.story.md) | Manifest Guard: novos arquivos kairos-owned devem entrar no manifest | Done |
| [5.7](../stories/5.7.story.md) | push-dual Passo 2b: skip de arquivos mistos sem mudança desde o último sync | Done |
| [5.8](../stories/5.8.story.md) | SHA Auto-referencial do manifest.yaml: usar sentinel em vez de hash real | Done |
| [5.9](../stories/5.9.story.md) | push-dual Passo 2b: skip real por conteúdo managed, não por commits | Done |

---

## Stories Candidatas (não criadas ainda)

- **5.10** — Configuração de branch protection no repo público
- **5.11** — CLI `npx install kairos` / `npx kairos update` (greenfield + brownfield)
- **5.12** — Publicação de `@kairos/core` no npm
- **5.13** — Squad-scaffolding dinâmico (gerar personas em `.claude/commands/` a partir de `squads/{squad}/agents/*.yaml`)

---

## Change Log

| Data | Mudança |
|------|---------|
| 2026-04-14 | Epic criado — story 5.1 em progresso |
| 2026-04-15 | Story 5.1 Done (@kairos *review PASS, score: 90) — todos os critérios de conclusão do epic marcados |
| 2026-04-16 | Story 5.2 Done (@kairos *review PASS, score: 82) — repo público separado, squad ops, push-dual |
| 2026-04-17 | Story 5.3 Done — SHA sync automático no *pre-push e *version |
| 2026-04-18 | Story 5.4 criada — sync completo de arquivos mistos no push-dual (Draft) |
| 2026-04-18 | Story 5.5 criada — *new-squad cria rules/ e faz wiring no CLAUDE.md (Draft) |
| 2026-04-18 | Stories 5.4 e 5.5 Done — bump MINOR 3.2.1 → 3.3.0 |
| 2026-04-18 | Stories 5.6 e 5.7 criadas — manifest guard e skip de arquivos mistos no push-dual |
| 2026-04-18 | Story 5.6 concluída — In Review |
| 2026-04-18 | Story 5.7 concluída — In Review |
| 2026-04-18 | Stories 5.6 e 5.7 Done — bump MINOR 3.3.1 → 3.4.0 |
| 2026-04-19 | Stories 5.8 e 5.9 criadas — SHA sentinel e skip por conteúdo managed (Draft) |
| 2026-04-19 | Story 5.8 concluída — In Review |
| 2026-04-19 | Story 5.9 iniciada — In Progress |
| 2026-04-19 | Story 5.9 concluída — In Review |
| 2026-04-19 | Stories 5.8 e 5.9 Done — bump PATCH 3.4.0 → 3.4.1 |
