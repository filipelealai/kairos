# Instância Kairos — Escopo e Objetivos da Instância

**Versão:** 1.2
**Atualizado em:** 2026-04-16

---

## O que é esta instância

Esta instância do Kairos é de uso pessoal e de agência, projetada para suportar múltiplas funções ao longo do tempo. O foco inicial é **prospecção B2B de empresas no Brasil** — identificar, qualificar e abordar leads via e-mail personalizado.

---

## Arquitetura desta instância

```
Google Sheets (dados)  ←→  n8n (operacional)  ←→  Kairos (inteligência)
```

- **Google Sheets** — fonte de leads (CNPJs, dados da Receita Federal) e destino de status pós-envio
- **n8n** — raspa dados, aciona o Kairos via webhook, dispara os e-mails gerados, atualiza a planilha
- **Kairos** — analisa, pontua, classifica leads e gera e-mails personalizados

Comunicação: webhooks (por enquanto).

---

## Squads

### Squad 1 — cold-prospecting (ativo)

Prospecção fria de pequenas e médias empresas brasileiras via e-mail.

**Integração externa:** n8n + Google Sheets

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
| Detectar e-mails suspeitos antes do disparo | 0 disparos para endereços suspeitos |

---

### Squads futuros

Novos escopos serão criados via `@kairos *new-squad` conforme a agência expande para novas funções. Ver `docs/epics/epic-4-novos-escopos.md` para candidatos planejados.

---

## Restrições desta instância

- **Kairos não envia e-mails** — envio é responsabilidade do n8n
- **Kairos não escreve na planilha** — atualizações de status são feitas pelo n8n após o disparo
- **Kairos não faz scraping** — coleta de CNPJs e dados da Receita Federal é responsabilidade do n8n

---

## Stack

- **Runtime:** Node.js (ESM), TypeScript
- **AI:** `@anthropic-ai/sdk`, modelo `claude-sonnet-4-6`
- **Runner:** `tsx` (sem compilação)
- **Integrações externas:** n8n webhook → Google Sheets

---

## Change Log

| Versão | Data | Mudança |
|--------|------|---------|
| 1.0 | 2026-04-06 | Escopo inicial — cold prospecting com 4 agentes |
| 1.1 | 2026-04-14 | Reframing: Kairos como framework de orquestração, não sistema pessoal n8n-driven |
| 1.2 | 2026-04-16 | Revisão completa: foco na instância (uso pessoal/agência), não no framework genérico |
