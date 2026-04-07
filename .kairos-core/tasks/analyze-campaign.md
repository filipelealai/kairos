---
task: Analyze Campaign
responsavel: "@campaign-analyst"
responsavel_type: agent
atomic_layer: report
elicit: false
Entrada: |
  - webhook_url: URL do webhook n8n (ENV N8N_LEADS_URL)
Saida: |
  - report_file: data/reports/campaign-YYYY-MM-DD.md
  - handoff: .kairos/handoffs/handoff-campaign-analyst-to-lead-scorer-{ts}.yaml
Checklist:
  - "[ ] Executar npx tsx src/agents/campaign-analyst.ts"
  - "[ ] Verificar que o arquivo de relatório foi gerado"
  - "[ ] Ler e interpretar o relatório gerado"
  - "[ ] Apresentar resumo executivo (3 bullets)"
  - "[ ] Exibir distribuição por nicho ordenada por volume"
  - "[ ] Exibir top 5 cidades com mais leads pendentes"
  - "[ ] Exibir distribuição de capital social"
  - "[ ] Identificar insight de ação (nicho/cidade a priorizar)"
  - "[ ] Gerar handoff para @lead-scorer"
---

# Analyze Campaign Task

## Propósito

Executar a análise completa da campanha de prospecção e interpretar os resultados para decisão de próxima ação.

---

## Execução

### Passo 1 — Rodar o agente TypeScript

```bash
npx tsx src/agents/campaign-analyst.ts
```

Aguarde a conclusão. O agente:
- Busca todos os leads via webhook
- Computa métricas localmente (sem chamadas de AI)
- Salva relatório em `data/reports/campaign-YYYY-MM-DD.md`

### Passo 2 — Ler e interpretar o relatório

Leia o arquivo gerado em `data/reports/` com a data de hoje.

### Passo 3 — Exibir com análise

Apresente o relatório com os seguintes destaques:

**Seções obrigatórias na apresentação:**
1. Resumo executivo (3 bullets: total de leads, pendentes, taxa de cobertura)
2. Distribuição por nicho — ordenada por volume
3. Top 5 cidades com mais leads pendentes
4. Distribuição de capital social (MEI / pequeno / estabelecido)
5. Insight de ação: qual nicho/cidade priorizar

### Passo 4 — Gerar handoff

Salve em `.kairos/handoffs/handoff-campaign-analyst-to-lead-scorer-{timestamp}.yaml`:

```yaml
handoff:
  from_agent: campaign-analyst
  to_agent: lead-scorer
  last_command: analyze
  timestamp: "{ISO timestamp}"
  consumed: false
  context:
    report_file: "data/reports/campaign-YYYY-MM-DD.md"
    total_leads_pendentes: N
    top_nicho: "{nicho com mais leads}"
    top_cidade: "{cidade com mais leads}"
  next_action: "Pontuar os leads pendentes com *score"
```

---

## Blocking

- Webhook retornar erro HTTP → HALT, informe o usuário
- Relatório não gerado após execução → HALT, exiba stdout/stderr do script
- Leads = 0 → HALT, verifique webhook e filtros no script
