---
task: Score Leads
responsavel: "@lead-scorer"
responsavel_type: agent
atomic_layer: ranking
elicit: false
Entrada: |
  - webhook_url: URL do webhook n8n (ENV N8N_LEADS_URL)
  - filtro: Pode disparar = SIM AND Status do Envio IN ("", "NÃO ENVIADO")
Saida: |
  - csv_file: data/outputs/cold-prospecting/reports/lead-scorer_scored-leads-YYYY-MM-DD.csv
  - handoff: .kairos-core/runtime/handoffs/handoff-lead-scorer-to-niche-classifier-{ts}.yaml
Checklist:
  - "[ ] Executar npx tsx src/agents/lead-scorer.ts"
  - "[ ] Verificar que o CSV foi gerado"
  - "[ ] Exibir distribuição de scores por tier (A/B/C/D)"
  - "[ ] Listar top 20 leads com nome, nicho, cidade, score"
  - "[ ] Identificar nicho dominante nos tier A"
  - "[ ] Identificar padrão de capital social no tier A"
  - "[ ] Gerar handoff para @niche-classifier"
---

# Score Leads Task

## Propósito

Pontuar e ranquear todos os leads pendentes segundo critérios de relevância, gerando um CSV ordenado por prioridade.

---

## Execução

### Passo 1 — Rodar o agente TypeScript

```bash
npx tsx src/agents/lead-scorer.ts
```

O agente:
- Busca leads com `Pode disparar = SIM` e `Status do Envio` vazio ou `NÃO ENVIADO`
- Aplica scoring multidimensional (nicho, capital social, cidade, situação)
- Salva CSV ranqueado em `data/outputs/cold-prospecting/reports/lead-scorer_scored-leads-YYYY-MM-DD.csv`

### Passo 2 — Ler o CSV e exibir análise

Leia as primeiras linhas do CSV gerado e apresente:

**Distribuição de scores (tiers):**
| Tier | Score | Quantidade |
|------|-------|------------|
| A | ≥ 55 | N |
| B | 35–54 | N |
| C | 15–34 | N |
| D | < 15 | N |

**Top 20 leads** (nome, nicho inferido da atividade, cidade, capital social, score)

**Padrões identificados:**
- Nicho dominante nos top leads
- Faixa de capital social mais comum no tier A
- Cidades mais representadas

### Passo 3 — Gerar handoff

Salve em `.kairos-core/runtime/handoffs/handoff-lead-scorer-to-niche-classifier-{timestamp}.yaml`:

```yaml
handoff:
  from_agent: lead-scorer
  to_agent: niche-classifier
  last_command: score
  timestamp: "{ISO timestamp}"
  consumed: false
  context:
    csv_file: "data/outputs/cold-prospecting/reports/lead-scorer_scored-leads-YYYY-MM-DD.csv"
    total_pontuados: N
    tier_a_count: N
    top_nicho: "{nicho dominante}"
  next_action: "Classificar atividades sem cobertura de nicho com *classify"
```

---

## Blocking

- Webhook retornar erro → HALT
- CSV não gerado → HALT, exiba stderr do script
- 0 leads pendentes → HALT, informe que não há leads para pontuar
