# Sales Pipeline Lifecycle — Fluxo do Pipeline

## Fluxo Principal

```
@pre-call *brief {lead}
        ↓
  (call acontece)
        ↓
@call-analyst *analyze {transcrição}
```

## Fases e Responsáveis

| Fase | Agente | Comando | Output |
|------|--------|---------|--------|
| 1. Brief | @pre-call (Rex) | `*brief` | `data/outputs/sales-pipeline/briefs/pre-call_brief-{empresa}-YYYY-MM-DD.md` |
| 2. Análise | @call-analyst (Cal) | `*analyze` | análise + Trello + follow-up draft |

## Handoff Chain

```
pre-call → call-analyst : handoff-pre-call-to-call-analyst-{ts}.yaml
```

## Execução Parcial (permitida)

- `@pre-call *brief` sem `@call-analyst` — call agendada mas ainda não realizada
- `@call-analyst *analyze` sem brief anterior — lead chegou por canal diferente
- `@call-analyst *followup` sem nova análise — reenvio de follow-up de call já processada

## Estágios do Pipeline (Trello)

| Lista | Significado |
|-------|------------|
| Interesse | Lead respondeu, call agendada ou realizada, interesse confirmado |
| Proposta | Proposta enviada ou em elaboração |
| Negociação | Proposta recebida, negociando termos |
| Nurture | Interesse mas sem timing agora — recontato futuro |
| Fechado | Deal fechado |
| Perdido | Sem interesse ou sem fit |

## Frequência Recomendada

Sob demanda:
- `*brief`: quando call é agendada
- `*analyze`: minutos após a call (transcrição disponível no Fathom)
