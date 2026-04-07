# Workflow: Full Cold Prospecting Pipeline

## Descrição

Pipeline completo do escopo de prospecção fria. Pode ser executado integralmente ou em subset.

## Sequência

```
Passo 1 — @campaign-analyst *analyze
  Input:  webhook n8n
  Output: data/reports/campaign-YYYY-MM-DD.md
  Gate:   relatório gerado + insights identificados

Passo 2 — @lead-scorer *score
  Input:  webhook n8n (filtra pendentes)
  Output: data/reports/scored-leads-YYYY-MM-DD.csv
  Gate:   CSV com score + distribuição de tiers exibida

Passo 3 — @niche-classifier *classify
  Input:  webhook n8n (atividades sem cobertura)
  Output: data/reports/niche-map-YYYY-MM-DD.json
  Gate:   classificação completa + recomendações geradas

Passo 4 — @email-writer *write N
  Input:  webhook n8n (filtra pendentes)
  Output: data/emails/emails-YYYY-MM-DD.json
  Gate:   todos e-mails passam no self-check do 1º parágrafo

Passo 5 — (n8n, automático)
  Input:  data/emails/emails-YYYY-MM-DD.json
  Action: disparo via Gmail/SMTP
  Output: atualização de "Status do Envio" na planilha
```

## Execução Parcial

Qualquer subset é válido. Exemplos comuns:

| Caso | Comandos |
|------|----------|
| Ver status da campanha | `@campaign-analyst *analyze` |
| Gerar e-mails sem re-puntuar | `@email-writer *write 20` |
| Score + emails (sem classify) | `@lead-scorer *score` → `@email-writer *write 20` |
| Pipeline completo | Todos os 4 passos em sequência |

## Frequência Recomendada

| Ação | Frequência |
|------|-----------|
| `*analyze` | A qualquer momento (status) |
| `*score` | Quando houver novo lote de leads (> 500 novos) |
| `*classify` | Semanal ou quando cobertura cair (> 10% sem nicho) |
| `*write N` | Diário ou conforme volume desejado de disparos |
