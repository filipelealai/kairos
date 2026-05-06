# Epic 3 — Governança e Versionamento

**Status:** In Progress
**Objetivo:** Garantir que o Kairos evolui de forma controlada, rastreável e reversível — com versão semântica, changelog, histórico de decisões e modelo claro de quem governa o quê.

---

## Descrição

À medida que o Kairos cresce (novos squads, novos agentes, integrações), é necessário ter um sistema que mantenha o controle: quem pode mudar o quê, como as mudanças são registradas, e como o estado do sistema pode ser inspecionado a qualquer momento.

Este epic cobre a camada de meta-governança: o `@kairos`, o sistema de versão semântica, o CHANGELOG, e as stories como mecanismo de rastreamento do desenvolvimento do próprio Kairos.

---

## Critério de Conclusão

- [x] `@kairos` operacional com autoridade de framework
- [x] `.kairos-core/core-config.yaml` com versão semântica
- [x] `CHANGELOG.md` com histórico desde v1.0.0
- [x] `docs/stories/` com distinção clara entre stories de desenvolvimento vs outputs operacionais
- [x] `docs/epics/` com arquivos dedicados por epic
- [x] Tasks de governança implementadas: `kairos-new-story.md`, `kairos-new-squad.md`, `kairos-version-bump.md`, `kairos-status.md`
- [x] `*status` do `@kairos` funcional (lê core-config + stories abertas + último changelog)

---

## Stories

| Story | Título | Status |
|-------|--------|--------|
| [3.1](../stories/3.1.story.md) | Tasks de Governança do @kairos | Done |
| [3.2](../stories/3.2.story.md) | Commit Integrado ao Fluxo de Review e Pre-Push | Done |
| [3.3](../stories/3.3.story.md) | Refinamentos de UX: *new-story, *version no Pre-Push e *help | Done |
| [3.4](../stories/3.4.story.md) | *review-squad: Validação de Coerência de Squad | Done |
| [3.5](../stories/3.5.story.md) | Modelo de Stories para Instâncias: type, *update-squad, Framing e Avisos | Done |
| [3.6](../stories/3.6.story.md) | Executor @kairos para Instâncias: *implement, src/ e Modelo de Autoridade | Done |
| [3.7](../stories/3.7.story.md) | scope.md do Framework em .kairos-core/docs/ e *architecture {squad} | Done |
| [3.8](../stories/3.8.story.md) | Workers: Listagem Dinâmica de Agentes na Elicitação | Done |
| [3.9](../stories/3.9.story.md) | Pre-Push: Prompt Opcional de Bump para Stories PATCH | Done |
| [3.10](../stories/3.10.story.md) | Pre-Push: Atualizar `kairos-version` nos Arquivos Modificados | Done |
| [3.11](../stories/3.11.story.md) | Renomear `*review-squad` → `*validate-squad` | Done |
| [3.12](../stories/3.12.story.md) | self_reviewed Automático em *review para Stories Implementadas via *implement | Done |
| [3.13](../stories/3.13.story.md) | *prd: Elicitação Conversacional para o Escopo da Instância | Done |
| [3.14](../stories/3.14.story.md) | Pre-Push Step 4: Comparação por Timestamp de Commit para Bump PATCH | Done |
| [3.15](../stories/3.15.story.md) | CHANGELOG: Entradas Neutras sem Referências de Instância | Done |
| [3.16](../stories/3.16.story.md) | *validate-story: Verificar Ordem do Cabeçalho e Estrutura dos ACs | Done |
| [3.17](../stories/3.17.story.md) | Pre-Push Step 4: Corrigir Fallback de Epoch para Gate Não Commitado | Done |
| [3.18](../stories/3.18.story.md) | CHANGELOG: Descrição Derivada do Git, Sem Prompt ao Usuário | Done |
| [3.19](../stories/3.19.story.md) | Pre-Push PATCH: Bump Consolidado e Descrição Semântica no CHANGELOG | Done |
| [3.20](../stories/3.20.story.md) | fix: README.md não atualizado no bump de versão do *pre-push | Done |
| [3.21](../stories/3.21.story.md) | *yolo: Sessão Autônoma Ponta-a-Ponta para kairos-core | Done |
| [3.22](../stories/3.22.story.md) | *implement all: Implementação em Massa de Stories type: instance | Done |
| [3.23](../stories/3.23.story.md) | *validate-story all: Validação em Massa de Stories | Done |
| [3.24](../stories/3.24.story.md) | Pre-Push: Mensagem de Commit sem Referência a Story | Done |
| [3.25](../stories/3.25.story.md) | Executor e *review: Sincronizar Status no Epic em Cada Transição | Done |
| [3.26](../stories/3.26.story.md) | *validate-story: Remover Check de README em docs/stories/ | Done |
| [3.27](../stories/3.27.story.md) | *review: Remover Autoridade de Transição para Done | Done |
| [3.28](../stories/3.28.story.md) | Refatoração de data-flow.md e agent-standards.md | Done |
| [3.29](../stories/3.29.story.md) | Elicitação Propósito-First em *new-squad, *update-squad, *new-story e *new-epic | Done |
| [3.30](../stories/3.30.story.md) | Pre-Push Passo 4: Corrigir Resolução de Path e Reordenar Antes do Commit | Done |
| [3.31](../stories/3.31.story.md) | Refatoração: Separação de Responsabilidades entre *pre-push, *push e *version | Draft |

---

## Stories Candidatas (não criadas ainda)

- **3.x** — `*status` Completo: agrega versão, squads ativos, stories abertas, último disparo

---

## Change Log

| Data | Mudança |
|------|---------|
| 2026-04-06 | Epic criado — governança parcialmente implementada (v1.1.0) |
| 2026-04-15 | Stories 3.2, 3.3, 3.4 criadas — epic reaberto (In Progress) |
| 2026-04-15 | Stories 3.5 e 3.6 criadas; 3.5 revisada (type: squad → type: instance) |
| 2026-04-15 | Stories 3.7 e 3.8 criadas |
| 2026-04-16 | Story 3.9 criada |
| 2026-04-16 | Story 3.10 criada |
| 2026-04-16 | Story 3.11 criada — rename *review-squad → *validate-squad |
| 2026-04-16 | Story 3.5 implementada — status → In Review |
| 2026-04-16 | Story 3.6 implementada — status → In Review (gate RESSALVA) |
| 2026-04-16 | Story 3.12 criada — self_reviewed automático em *review |
| 2026-04-16 | Story 3.7 implementada — status → Done (gate PASS, v3.1.0) |
| 2026-04-16 | Story 3.13 criada — *prd elicitação conversacional |
| 2026-04-17 | Story 3.16 criada — gap em *validate-story identificado na revisão de 3.13 |
| 2026-04-17 | Story 3.18 criada — correção da abordagem da 3.15 (prompt manual → derivação automática do git) |
| 2026-04-17 | Story 3.18 implementada — status → In Review |
| 2026-04-17 | Story 3.19 criada — bump consolidado e descrição semântica no CHANGELOG |
| 2026-04-17 | Story 3.20 criada — investigação de README.md ausente no bump de versão |
| 2026-04-18 | Stories 3.21, 3.22, 3.23 criadas — *yolo, *implement all, *validate-story all |
| 2026-04-18 | Story 3.21 reescrita — *yolo redesenhado como estado de sessão (liga/desliga), escopo restrito a instanciado |
| 2026-04-18 | Stories 3.24, 3.25 criadas — commit sem referência a story, sincronização de status no epic |
| 2026-04-18 | Story 3.24 iniciada — In Progress |
| 2026-04-18 | Story 3.24 concluída — In Review |
| 2026-04-18 | Story 3.25 iniciada — In Progress |
| 2026-04-18 | Story 3.25 concluída — In Review |
| 2026-04-18 | Story 3.26 criada — remover check de README em *validate-story (falso positivo) |
| 2026-04-18 | Story 3.26 concluída — In Review |
| 2026-04-18 | Story 3.27 iniciada — In Progress |
| 2026-04-18 | Story 3.27 concluída — In Review |
| 2026-04-18 | *pre-push: stories 3.24, 3.25, 3.26, 3.27 → Done (v3.3.1) |
| 2026-04-25 | Story 3.28 criada — refatoração de data-flow.md e agent-standards.md |
| 2026-04-26 | Story 3.28 iniciada — In Progress |
| 2026-04-26 | Story 3.28 concluída — In Review |
| 2026-04-26 | Story 3.29 criada — elicitação propósito-first em *new-squad, *update-squad, *new-story e *new-epic |
| 2026-04-26 | Story 3.29 concluída — In Review |
| 2026-04-26 | *pre-push: stories 3.28, 3.29 → Done (v3.10.0) |
| 2026-04-26 | Story 3.30 criada — falso positivo no Passo 4 e reordenação antes do commit |
| 2026-04-26 | Story 3.30 concluída — In Review |
| 2026-04-26 | Story 3.30 Done — gate PASS, *pre-push v3.11.0 |
| 2026-05-05 | Story 3.31 criada — separação de responsabilidades entre *pre-push, *push e *version |
