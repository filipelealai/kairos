# Kairos — Escopo e Objetivos

**Versão:** 1.1
**Atualizado em:** 2026-04-14

---

## O que é o Kairos

Kairos é um framework de orquestração de agentes de IA construído sobre o Claude Code. Organiza o trabalho em **squads** — grupos de agentes especializados que executam domínios específicos — e fornece a infraestrutura para criar, operar e evoluir esses squads ao longo do tempo.

**Arquitetura:** desenhada para múltiplos squads, múltiplas integrações externas, uso individual ou em equipe.

O Kairos não é um agente único, nem é dependente de uma ferramenta específica. n8n é a integração do squad atual — não uma parte estrutural do framework.

---

## Arquitetura do Framework

```
┌─────────────────────────────────────────────────────────┐
│  Kairos Framework                                        │
│                                                          │
│  @kairos — governança, versionamento, criação de squads  │
│                                                          │
│  squads/                                                 │
│    cold-prospecting/    → integra com n8n, Sheets        │
│    {próximo-squad}/     → integra com {outra ferramenta} │
│    {squad-N}/           → integra com {outra ferramenta} │
│                                                          │
│  .kairos-core/ — memória, tasks, KB, workers, templates  │
│  .claude/      — personas, hooks, rules                  │
└─────────────────────────────────────────────────────────┘
```

Cada squad define suas próprias fontes de dados, integrações externas e pipeline. O framework fornece a infraestrutura comum.

---

## Squads

### Squad 1 — cold-prospecting (ativo)

Prospecção fria de pequenas e médias empresas brasileiras via e-mail.

**Integração externa:** n8n + Google Sheets

```
n8n (operacional)  ↔  Kairos/cold-prospecting  ↔  Google Sheets (dados)
```

**Fluxo:**
1. n8n raspa CNPJs da Receita Federal e popula Google Sheets
2. Kairos analisa, pontua, classifica e gera e-mails personalizados
3. n8n lê os e-mails gerados e realiza os disparos
4. n8n atualiza o status na planilha após envio

**Squad responsável:** `cold-prospecting` (Clio, Lex, Nix, Eva)

**Dados:**
- `data/outputs/cold-prospecting/reports/` — relatórios de campanha, scoring, nicho
- `data/outputs/cold-prospecting/emails/` — e-mails gerados, prontos para o n8n

**Objetivos:**

| Objetivo | Métrica |
|----------|---------|
| E-mails que pareçam escritos por pessoa | Taxa de resposta > baseline de templates genéricos |
| Priorizar leads com maior chance de conversão | Score tier A/B nos primeiros disparos |
| Manter cobertura de nichos atualizada | < 10% leads sem classificação |
| Detectar emails suspeitos antes do disparo | 0 disparos para endereços suspeitos |

---

### Squad 2+ — (planejados)

Novos squads são criados via `@kairos *new-squad`. Cada um define suas próprias integrações, agentes e pipeline. Ver `docs/epics/epic-4-novos-escopos.md` para candidatos planejados.

---

## Restrições do Framework

- **Kairos não age sobre sistemas externos** — envio, escrita, disparo são delegados a sistemas especializados de cada squad
- **Kairos não assume operacional** — scraping, autenticação, rate limiting pertencem às integrações externas
- **Novos squads precisam de validação** — criados via `@kairos *new-squad` com elicitação guiada

---

## Stack

- **Runtime:** Node.js (ESM), TypeScript
- **AI:** `@anthropic-ai/sdk`, modelo `claude-sonnet-4-6`
- **Runner:** `tsx` (sem compilação)
- **Integrações externas:** definidas por squad (atualmente: n8n webhook → Google Sheets)

---

## Change Log

| Versão | Data | Mudança |
|--------|------|---------|
| 1.0 | 2026-04-06 | Escopo inicial — cold prospecting com 4 agentes |
| 1.1 | 2026-04-14 | Reframing: Kairos como framework de orquestração, não sistema pessoal n8n-driven |
