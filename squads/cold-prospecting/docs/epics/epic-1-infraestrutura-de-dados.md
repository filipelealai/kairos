# Epic 1 — Infraestrutura de Dados

**Status:** Done
**Objetivo:** Conectar o Kairos aos dados de leads e construir os agentes fundamentais do pipeline de prospecção.

---

## Descrição

Sem acesso aos dados e sem agentes para processá-los, o Kairos não faz nada. Este epic cobre a fundação: o canal de entrada de dados (webhook n8n → Google Sheets) e os quatro agentes do squad `cold-prospecting`.

---

## Critério de Conclusão

- [x] Webhook de leads funcional e retornando dados completos
- [x] Os quatro agentes do squad `cold-prospecting` operacionais
- [x] Pipeline completo executável end-to-end (análise → scoring → nichos → e-mails)
- [x] Outputs salvos em `data/` com formato estável

---

## Stories

| Story | Título | Status |
|-------|--------|--------|
| [1.1](../stories/1.1.story.md) | Webhook de Leads — Acesso aos Dados via n8n | Done |
| [1.2](../stories/1.2.story.md) | Pipeline de Agentes — Análise, Scoring, Nichos e E-mails | Done |

---

## Change Log

| Data | Mudança |
|------|---------|
| 2026-04-06 | Epic concluído no bootstrap inicial do Kairos (v1.0.0 → v1.1.0) |
