# Workflow: Pipeline Completo — {Squad Name}

## Diagrama

```
@{agent-id-1} *{comando}
        ↓  gera: {agent-id-1}_{filename}-YYYY-MM-DD.{ext}
@{agent-id-2} *{comando}
        ↓  gera: {agent-id-2}_{filename}-YYYY-MM-DD.{ext}
{sistema externo ou próxima ação}
```

---

## Fases

| Fase | Agente | Comando | Input | Output |
|------|--------|---------|-------|--------|
| 1 | `@{agent-id-1}` | `*{cmd}` | {fonte de dados} | `data/outputs/{squad}/{tipo}/{agent-id-1}_*` |
| 2 | `@{agent-id-2}` | `*{cmd}` | output da fase 1 | `data/outputs/{squad}/{tipo}/{agent-id-2}_*` |

---

## Handoffs

```
{agent-id-1} → {agent-id-2}: handoff-{agent-id-1}-to-{agent-id-2}-{ts}.yaml
{agent-id-2} → {agent-id-1}: handoff-{agent-id-2}-to-{agent-id-1}-{ts}.yaml  # ciclo
```

Diretório: `.kairos-core/runtime/handoffs/`

---

## Execução Parcial

Não é obrigatório rodar o pipeline completo. Exemplos válidos:

- **Só {fase 1}:** `@{agent-id-1} *{cmd}` (independente)
- **Só {fase 2}:** `@{agent-id-2} *{cmd}` (usa output existente)

---

## Frequência Recomendada

- **Pipeline completo:** {quando executar}
- **Fase isolada:** {quando executar fase individualmente}
