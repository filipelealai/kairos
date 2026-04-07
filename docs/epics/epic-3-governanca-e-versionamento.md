# Epic 3 — Governança e Versionamento

**Status:** Done
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

---

## Stories Candidatas (não criadas ainda)

- **3.2** — Hook de Pré-Commit: valida que mudanças estruturais têm story e bump de versão
- **3.3** — `*status` Completo: comando que agrega versão, squads ativos, stories abertas, último disparo

---

## Change Log

| Data | Mudança |
|------|---------|
| 2026-04-06 | Epic criado — governança parcialmente implementada (v1.1.0) |
