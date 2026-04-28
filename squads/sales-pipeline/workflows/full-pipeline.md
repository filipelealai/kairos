# Pipeline Completo — Sales Pipeline

## Fluxo

```
@pre-call *brief {lead}
        ↓
  (call acontece)
        ↓
@call-analyst *analyze {transcrição}
```

## Fases

| Fase | Agente | Comando | Output |
|------|--------|---------|--------|
| 1. Preparação | @pre-call (Rex) | `*brief {lead}` | `data/outputs/sales-pipeline/briefs/pre-call_brief-{empresa}-YYYY-MM-DD.md` |
| 2. Análise pós-call | @call-analyst (Cal) | `*analyze {transcrição}` | `data/outputs/sales-pipeline/analyses/call-analyst_analysis-{empresa}-YYYY-MM-DD.md` + Trello + follow-up |

## Handoff Chain

```
pre-call → call-analyst : handoff-pre-call-to-call-analyst-{ts}.yaml
```

Diretório: `.kairos-core/runtime/handoffs/`

## Execução Parcial (permitida)

- **Só brief:** `@pre-call *brief {lead}` — quando a call ainda não aconteceu
- **Só análise:** `@call-analyst *analyze {transcrição}` — quando não houve brief ou lead veio por outro canal
- **Só follow-up:** `@call-analyst *followup {empresa}` — para call já analisada

## Frequência Recomendada

Sob demanda, triggered por eventos:
- Brief: quando call é agendada
- Análise: quando transcrição do Fathom está disponível (geralmente minutos após a call)
