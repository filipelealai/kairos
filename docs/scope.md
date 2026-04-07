# Kairos — Escopo e Objetivos

**Versão:** 1.0
**Atualizado em:** 2026-04-06

---

## O que é o Kairos

Kairos é o agente pessoal de Filipe Leal para automação, análise e gestão de tarefas. O nome vem do grego καιρός — o tempo certo, o momento oportuno. Cada ação acontece no momento em que faz mais sentido.

O Kairos não é uma plataforma genérica. É um sistema construído em torno dos fluxos de trabalho reais de Filipe — atualmente focado em prospecção B2B para a Agência Vendoteca, com espaço para crescer em novos escopos.

---

## Arquitetura Geral

```
n8n (automação)     ↔    Kairos (inteligência)    ↔    Google Sheets (dados)
     ↑                          ↑
  disparo de                 agentes Claude Code
  e-mails                    (análise, scoring, geração)
```

**n8n** cuida do operacional: scraping de CNPJs, triagem de leads, disparo de e-mails, atualização da planilha.

**Kairos** cuida da inteligência: análise de campanha, pontuação de leads, classificação de nichos, geração de e-mails personalizados.

A comunicação entre os dois se dá via webhook (`https://n8n.vendoteca.com/webhook/kairos-leads`).

---

## Escopos

### Escopo 1 — Cold Prospecting (ativo)

Prospecção fria de pequenas e médias empresas brasileiras via e-mail.

**Fluxo:**
1. n8n raspa CNPJs da Receita Federal e popula Google Sheets
2. Kairos analisa, pontua, classifica e gera e-mails personalizados
3. n8n lê os e-mails gerados e realiza os disparos
4. n8n atualiza o status na planilha após envio

**Squad responsável:** `cold-prospecting` (Clio, Lex, Nix, Eva)

**Dados gerenciados:**
- Google Sheets: planilha de leads com 22k+ registros
- `data/outputs/cold-prospecting/reports/` — relatórios de campanha, scoring, nicho
- `data/outputs/cold-prospecting/emails/` — e-mails gerados, prontos para o n8n

### Escopo 2 — (futuro)

Reservado para próximos fluxos de trabalho de Filipe.

---

## Objetivos por Escopo

### Cold Prospecting

| Objetivo | Métrica |
|----------|---------|
| Gerar e-mails que pareçam escritos por uma pessoa | Taxa de resposta > baseline de templates genéricos |
| Priorizar leads com maior probabilidade de conversão | Score tier A/B nos primeiros disparos |
| Manter cobertura de nichos atualizada | < 10% leads sem classificação |
| Detectar emails suspeitos antes do disparo | 0 disparos para endereços de contabilidade/consultoria |

---

## Restrições

- **Kairos não envia e-mails** — isso é responsabilidade exclusiva do n8n
- **Kairos não modifica a planilha** — apenas lê via webhook
- **Kairos não escala sem decisão de Filipe** — novos escopos precisam de validação manual

---

## Stack

- **Runtime:** Node.js (ESM), TypeScript
- **AI:** `@anthropic-ai/sdk`, modelo `claude-sonnet-4-6`
- **Runner:** `tsx` (sem compilação)
- **Dados externos:** n8n webhook → Google Sheets

---

## Change Log

| Versão | Data | Mudança |
|--------|------|---------|
| 1.0 | 2026-04-06 | Escopo inicial — cold prospecting com 4 agentes |
