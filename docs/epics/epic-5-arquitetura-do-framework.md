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
| [5.10](../stories/5.10.story.md) | Manifest owned_sections: SHA por bloco para suporte a updates | Done |
| [5.11](../stories/5.11.story.md) | Manifest yaml_keys: campo sha_method como especificação canônica de serialização | Done |
| [5.12](../stories/5.12.story.md) | Manifest sync_files: categoria para arquivos sincronizados sem ownership de update | Done |
| [5.13](../stories/5.13.story.md) | ownership.md: documentar sync_files como terceira categoria do manifesto | Done |
| [5.14](../stories/5.14.story.md) | push-dual Passo 3: commit para main usa mensagem do commit em filipe-instance | Done |
| [5.15](../stories/5.15.story.md) | CONTRIBUTING.md (Governança de Contribuição ao Repo Público) | Done |
| [5.16](../stories/5.16.story.md) | CODE_OF_CONDUCT.md (Código de Conduta) | Done |
| [5.17](../stories/5.17.story.md) | `.github/` Scaffold (Templates de PR/Issue e CODEOWNERS) | Done |
| [5.18](../stories/5.18.story.md) | Configurar Branch Protection no Repo Público | Done |
| [5.19](../stories/5.19.story.md) | CI: Validação de Manifest em PRs (GitHub Actions) | Done |
| [5.20](../stories/5.20.story.md) | README.md: Limpeza de Hardcodes, Versão e Falsos Positivos | Done |
| [5.21](../stories/5.21.story.md) | CLAUDE.md: Limpar Hardcodes TypeScript dos Blocos Managed | Done |
| [5.22](../stories/5.22.story.md) | Expurgar package.json/package-lock.json/tsconfig.json do Repo Público | Done |
| [5.23](../stories/5.23.story.md) | Expurgar ANTHROPIC_API_KEY como Pré-requisito Universal do Framework | Done |
| [5.24](../stories/5.24.story.md) | Documentar Posição Stack-Agnóstica do Kairos | Done |
| [5.25](../stories/5.25.story.md) | Fix Arquitetural (L1): src/ É User-Owned — Corrigir Documentação de Fundação | Done |
| [5.26](../stories/5.26.story.md) | *architecture Stack-Agnóstico e Gestão Simétrica de agent-standards.md | Done |
| [5.27](../stories/5.27.story.md) | Depurar Conteúdo Instance-Specific de *architecture e *prd | Done |
| [5.28](../stories/5.28.story.md) | Integrar `*doctor` no `*pre-push` como Passo 0 Universal | Done |
| [5.29](../stories/5.29.story.md) | Expurgar Exemplos de Instância e Hardcodes de Stack das Tasks e Templates do Framework | Done |
| [5.30](../stories/5.30.story.md) | Expurgar Hardcodes de Ferramentas Específicas das Tasks e Templates do Framework | Done |
| [5.31](../stories/5.31.story.md) | Atualizar scope.md para Refletir o Estado Atual do Framework | Done |
| [5.32](../stories/5.32.story.md) | Squad-scaffolding Dinâmico — Gerar Personas a partir de `squads/{squad}/agents/*.yaml` | Draft |
| [5.33](../stories/5.33.story.md) | Regeneração Incremental de Personas — `*regenerate-squad` e Integração ao `*pre-push` | Draft |

---

## Stories Candidatas (não criadas ainda)
- **5.34** — CLI `npx install kairos` / `npx kairos update` (greenfield + brownfield)
- **5.35** — Publicação de `@kairos/core` no npm

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
| 2026-04-19 | Story 5.10 criada — SHA por bloco em owned_sections (Draft) |
| 2026-04-19 | Story 5.10 iniciada — In Progress |
| 2026-04-19 | Story 5.10 concluída — In Review |
| 2026-04-19 | Story 5.11 criada — sha_method canônico para yaml_keys (Draft) |
| 2026-04-19 | Story 5.12 criada — sync_files: README.md sem ownership de update (Draft) |
| 2026-04-19 | Story 5.11 iniciada — In Progress |
| 2026-04-19 | Story 5.11 concluída — In Review |
| 2026-04-19 | Story 5.12 iniciada — In Progress |
| 2026-04-19 | Stories 5.10, 5.11 e 5.12 Done — bump MINOR 3.4.1 → 3.5.0 |
| 2026-04-23 | Story 5.13 criada — ownership.md: sync_files como terceira categoria (recomendação gate 5.12) |
| 2026-04-23 | Story 5.13 concluída — In Review |
| 2026-04-23 | Story 5.14 criada — push-dual Passo 3: commit para main com mensagem de filipe-instance |
| 2026-04-23 | Stories 5.13 e 5.14 Done — bump PATCH 3.5.0 → 3.5.1 |
| 2026-04-23 | Stories 5.15, 5.16, 5.17 e 5.19 criadas — governança do repo público (CONTRIBUTING, CODE_OF_CONDUCT, .github/ scaffold, CI validate-manifest). Candidata "branch protection" renumerada 5.15 → 5.18; demais candidatas renumeradas (5.16→5.20, 5.17→5.21, 5.18→5.22) |
| 2026-04-23 | Story 5.15 iniciada — In Progress |
| 2026-04-23 | Story 5.15 concluída — In Review |
| 2026-04-23 | Story 5.16 iniciada — In Progress |
| 2026-04-23 | Story 5.16 concluída — In Review |
| 2026-04-23 | Story 5.17 iniciada — In Progress |
| 2026-04-23 | Story 5.17 concluída — In Review |
| 2026-04-23 | Story 5.17 Done — gate RESSALVA confirmado (*pre-push) |
| 2026-04-23 | Stories 5.15 e 5.16 Done — gates PASS/RESSALVA confirmados (pós-push) |
| 2026-04-23 | Stories 5.20–5.25 criadas — limpeza de hardcodes TS, expurgamento de artefatos de instância do público, fix L1 de ownership de src/; candidatas antigas 5.20–5.22 renumeradas para 5.26–5.28 |
| 2026-04-24 | Story 5.20 iniciada — In Progress |
| 2026-04-24 | Story 5.20 concluída — In Review |
| 2026-04-24 | Story 5.21 iniciada — In Progress |
| 2026-04-24 | Story 5.21 concluída — In Review |
| 2026-04-24 | Stories 5.20 e 5.21 Done — bump PATCH 3.6.0 → 3.6.1 |
| 2026-04-24 | Story 5.22 iniciada — In Progress |
| 2026-04-24 | Story 5.22 concluída — In Review |
| 2026-04-24 | Story 5.23 iniciada — In Progress |
| 2026-04-24 | Story 5.23 concluída — In Review |
| 2026-04-24 | Story 5.24 iniciada — In Progress |
| 2026-04-24 | Story 5.24 concluída — In Review |
| 2026-04-24 | Story 5.22: gate PASS (93/100) — @kairos *review |
| 2026-04-24 | Story 5.23: gate PASS (91/100) — @kairos *review |
| 2026-04-24 | Story 5.24: gate PASS (93/100) — @kairos *review; hardcodes Passo 3 corrigidos pelo usuário |
| 2026-04-24 | *pre-push: Stories 5.22, 5.23, 5.24 → Done; bump MINOR 3.6.1 → 3.7.0 |
| 2026-04-24 | Story 5.25 iniciada — In Progress |
| 2026-04-24 | Story 5.25 concluída — In Review |
| 2026-04-24 | Story 5.27 criada — Depurar Conteúdo Instance-Specific de *architecture e *prd (Draft); candidatas antigas 5.27–5.29 renumeradas 5.28–5.30 |
| 2026-04-25 | Story 5.26 iniciada — In Progress |
| 2026-04-25 | Story 5.26 concluída — In Review |
| 2026-04-25 | Story 5.27 iniciada — In Progress |
| 2026-04-25 | Story 5.27 concluída — In Review |
| 2026-04-25 | Story 5.18 criada — Branch Protection no Repo Público (Draft) |
| 2026-04-25 | Story 5.28 criada — *ci: Gate de Validação para Contribuidores (Draft); candidatas antigas 5.28–5.30 renumeradas 5.29–5.31 |
| 2026-04-25 | Story 5.18 iniciada e concluída via *implement — In Review |
| 2026-04-25 | Story 5.28 reescrita por @kairos — `*ci` eliminado; integrar `*doctor` no `*pre-push` como Passo 0 |
| 2026-04-25 | Story 5.28 iniciada — In Progress |
| 2026-04-25 | Story 5.28 concluída — In Review; bump MINOR 3.7.0 → 3.8.0 |
| 2026-04-25 | Story 5.19 iniciada — In Progress |
| 2026-04-25 | Story 5.19 concluída — In Review; bump MINOR 3.8.0 → 3.9.0 |
| 2026-04-25 | Story 5.18 Done — *pre-push: bump PATCH 3.9.0 → 3.9.1 |
| 2026-04-25 | Stories 5.19, 5.25, 5.26, 5.27, 5.28 Done — *pre-push: gate confirmado |
| 2026-04-25 | Story 5.29 criada — expurgar exemplos de instância e hardcodes de stack das tasks e templates |
| 2026-04-26 | Story 5.29 iniciada — In Progress |
| 2026-04-26 | Story 5.29 concluída — In Review |
| 2026-04-26 | Story 5.30 criada — Expurgar Hardcodes de Ferramentas Específicas (complementar à 5.29) |
| 2026-04-26 | Story 5.31 criada — Atualizar scope.md (PRD do framework defasado em v3.1.0); candidatas 5.31–5.33 renumeradas 5.32–5.34 |
| 2026-04-26 | Story 5.31 iniciada — In Progress |
| 2026-04-26 | Story 5.31 concluída — In Review |
| 2026-04-26 | *pre-push: stories 5.29, 5.30, 5.31 → Done (v3.10.0) |
| 2026-04-26 | Story 5.32 criada — Squad-scaffolding dinâmico (Draft); candidatas 5.33–5.34 renumeradas 5.34–5.35; nova 5.33 adicionada (regeneração incremental) |
| 2026-04-26 | Story 5.33 criada — Regeneração incremental de personas via *regenerate-squad (Draft) |
