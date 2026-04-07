---
task: Classify Niches
responsavel: "@niche-classifier"
responsavel_type: agent
atomic_layer: taxonomy
elicit: false
Entrada: |
  - webhook_url: URL do webhook n8n (ENV N8N_LEADS_URL)
  - filtro: Pode disparar = SIM
  - keywords_de_cobertura: ver seção keyword-coverage-reference no agente
Saida: |
  - niche_map_file: data/outputs/cold-prospecting/reports/niche-classifier_niche-map-YYYY-MM-DD.json
  - recomendacoes: lista de keywords novas por nicho
  - handoff: .kairos-core/runtime/handoffs/handoff-niche-classifier-to-email-writer-{ts}.yaml
Checklist:
  - "[ ] Executar npx tsx src/agents/niche-classifier.ts"
  - "[ ] Verificar que niche-map foi gerado"
  - "[ ] Exibir contagem por nicho em ordem decrescente"
  - "[ ] Listar atividades mais comuns por nicho (top 5 por nicho com > 50 leads)"
  - "[ ] Gerar recomendações de keywords para nichos com > 30 leads sem cobertura"
  - "[ ] Formatar recomendações como expansões prontas para o n8n"
  - "[ ] Gerar handoff para @email-writer"
---

# Classify Niches Task

## Propósito

Identificar atividades empresariais dos leads sem cobertura de nicho, classificá-las e recomendar keywords para expandir o workflow do n8n.

---

## Execução

### Passo 1 — Rodar o agente TypeScript

```bash
npx tsx src/agents/niche-classifier.ts
```

O agente:
- Busca leads com `Pode disparar = SIM`
- Identifica atividades únicas sem match nas keywords de cobertura
- Usa Claude API para classificar em lotes de 30 por um dos 9 nichos
- Salva `data/outputs/cold-prospecting/reports/niche-classifier_niche-map-YYYY-MM-DD.json`

### Passo 2 — Ler e interpretar o niche-map

**Contagem por nicho** (nichos com mais atividades sem cobertura):
```
estetica_bem_estar    → N atividades, representando X leads
saude_clinicas        → N atividades
manutencao_tecnica    → N atividades
```

**Lista de atividades por nicho** (as mais representadas):
Para cada nicho com > 50 leads, liste as 5 atividades mais comuns.

### Passo 3 — Gerar recomendações de keywords

Para cada nicho com volume relevante (> 30 leads sem cobertura), recomende keywords em formato de expansão do n8n:

```
NICHOS SEM COBERTURA ADEQUADA — RECOMENDAÇÕES

estetica_bem_estar (280 leads descobertos):
  Adicionar keywords: podolog, estetica_unhas, design_sobrancelha, laser_depil

saude_clinicas (180 leads):
  Adicionar keywords: quiroprax, homeop, acupunt, terapia_ocupac
```

### Passo 4 — Gerar handoff

Salve em `.kairos-core/runtime/handoffs/handoff-niche-classifier-to-email-writer-{timestamp}.yaml`:

```yaml
handoff:
  from_agent: niche-classifier
  to_agent: email-writer
  last_command: classify
  timestamp: "{ISO timestamp}"
  consumed: false
  context:
    niche_map_file: "data/outputs/cold-prospecting/reports/niche-classifier_niche-map-YYYY-MM-DD.json"
    total_atividades_sem_cobertura: N
    nichos_com_mais_leads: ["{nicho1}", "{nicho2}"]
  next_action: "Gerar e-mails para os top leads com *write 20"
```

---

## Blocking

- Webhook retornar erro → HALT
- 0 leads com `Pode disparar = SIM` → HALT
- niche-map não gerado → HALT, exiba stderr do script
- 0 atividades sem cobertura → informar que cobertura está completa, não gerar handoff
