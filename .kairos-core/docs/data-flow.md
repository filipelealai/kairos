---
kairos-owned: true
kairos-version: 2.0.0
---

# Fluxo de Dados — Kairos

> Referência para entender como dados entram, transitam e saem de um squad Kairos.
> Documentação genérica. Para fluxo específico de um squad ativo, ver `squads/{squad}/docs/data-flow.md`.

---

## Visão Geral

```
┌─────────────────────────────────────────────────────────┐
│                    FONTES EXTERNAS                       │
│  (API, webhook, banco, planilha — definidas por squad)  │
└─────────────────────────┬───────────────────────────────┘
                          │ entrada
                          ▼
┌─────────────────────────────────────────────────────────┐
│                   KAIROS (Claude Code)                   │
│                                                          │
│  Pipeline de agentes do squad (sequência definida em    │
│  squads/{squad}/workflows/ e workflow-chains.yaml)       │
│                                                          │
│  Outputs em data/outputs/{squad}/{tipo}/                 │
└─────────────────────────┬───────────────────────────────┘
                          │ outputs consumidos por
                          ▼
┌─────────────────────────────────────────────────────────┐
│                    DESTINOS EXTERNOS                     │
│  (sistemas de ação — e-mail, CRM, automação, etc.)       │
└─────────────────────────────────────────────────────────┘
```

---

## Padrões de Fluxo

### Entrada

Squads definem suas fontes de entrada em `squads/{squad}/squad.yaml` (campo `integrations`). Fontes típicas: webhook HTTP, arquivos locais, APIs externas, banco de dados.

Leitura é **read-only** do ponto de vista do Kairos — escrita em sistemas externos é delegada a ferramentas especializadas fora do Kairos (automação, workflows, integrações específicas).

### Outputs de Agente

Outputs seguem o padrão:

```
data/outputs/{squad}/{tipo}/{agent-id}_{descricao}-YYYY-MM-DD.{ext}
```

**Tipos comuns por convenção:**
- `reports/` — análises, métricas, scores
- `emails/` — conteúdo pronto para envio externo
- `data/` — datasets processados

Idempotência por data: regerar no mesmo dia sobrescreve o arquivo anterior (comportamento intencional para permitir re-runs).

### Handoffs (Runtime)

**Local:** `.kairos-core/runtime/handoffs/` (conteúdo gitignored)

**Formato:** `handoff-{from}-to-{to}-{timestamp}.yaml`

```yaml
handoff:
  from_agent: {id-do-agente-que-terminou}
  to_agent: {id-do-proximo-agente}
  last_command: {comando-executado}
  timestamp: "{ISO 8601}"
  consumed: false
  context:
    {campos-relevantes-para-o-proximo-agente}
  next_action: "{o-que-o-proximo-agente-deve-fazer}"
```

**Lifecycle:** criado pelo agente que termina uma fase → lido e marcado `consumed: true` pelo próximo agente na ativação. Ver `.claude/rules/agent-handoff.md` para o protocolo completo.

---

## Limites e Restrições Genéricas

| Restrição | Motivo |
|-----------|--------|
| Kairos não escreve em fontes de dados autoritativas | Risco de corrupção — sistemas externos mantêm controle |
| Outputs são idempotentes por data | Regerar no mesmo dia sobrescreve (permite re-runs seguros) |
| Ações com side effects em sistemas externos exigem confirmação | Ver constituição I.2 e `external-integrations.md` |
| Autoridade de agente é escopada ao squad | Ver `agent-authority.md` |

Restrições específicas de squad (quem pode acionar qual sistema externo, quais campos são read-only) vivem em `squads/{squad}/` — não aqui.

---

## Referências

- `.claude/rules/agent-handoff.md` — protocolo de handoff em detalhe
- `.claude/rules/agent-authority.md` — matriz de autoridade por agente
- `.claude/rules/external-integrations.md` — hierarquia de integrações externas
- `squads/{squad}/docs/data-flow.md` — fluxo específico do squad ativo
