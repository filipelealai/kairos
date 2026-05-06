# Squad: Cold Prospecting

**Escopo:** Prospecção fria B2B via e-mail para pequenas e médias empresas brasileiras
**Agentes:** Clio (📊), Lex (🎯), Nix (🗂️), Eva (✉️)
**Pipeline:** análise → scoring → classificação → e-mails

---

## Ativação

| Agente | Ativar com | Comando principal |
|--------|-----------|-------------------|
| Clio — Analista | `@campaign-analyst` | `*analyze` |
| Lex — Scorer | `@lead-scorer` | `*score` |
| Nix — Classificador | `@niche-classifier` | `*classify` |
| Eva — Redatora | `@email-writer` | `*write 20` |

---

## Pipeline Completo

```bash
@campaign-analyst *analyze
@lead-scorer *score
@niche-classifier *classify
@email-writer *write 20
```

Após cada fase, o agente gera um handoff em `.kairos-core/runtime/handoffs/`. O próximo agente detecta e sugere o próximo passo automaticamente ao ser ativado.

---

## Saídas Geradas

| Fase | Arquivo |
|------|---------|
| Análise | `data/outputs/cold-prospecting/reports/campaign-analyst_campaign-{INSTANCE}-YYYY-MM-DD.md` |
| Scoring | `data/outputs/cold-prospecting/reports/lead-scorer_scored-leads-{INSTANCE}-YYYY-MM-DD.csv` |
| Nichos | `data/outputs/cold-prospecting/reports/niche-classifier_niche-map-{INSTANCE}-YYYY-MM-DD.json` |
| E-mails | `data/outputs/cold-prospecting/emails/email-writer_emails-{INSTANCE}-YYYY-MM-DD.json` |

---

## Estrutura do Squad

```
squads/cold-prospecting/
├── squad.yaml              # Manifesto
├── README.md               # Este arquivo
├── agents/                 # Definições leves (referências às personas completas)
│   ├── campaign-analyst.md
│   ├── lead-scorer.md
│   ├── niche-classifier.md
│   └── email-writer.md
├── tasks/                  # Referências às tasks em .kairos-core/tasks/
└── workflows/
    └── full-pipeline.md    # Sequência completa documentada
```

---

## Documentação de Referência

- [Escopo do Kairos](../../docs/scope.md)
- [Padrões de Agentes](../../.kairos-core/docs/agent-standards.md)
- [Fluxo de Dados](../../.kairos-core/docs/data-flow.md)
- [Pipeline Lifecycle](.claude/rules/campaign-lifecycle.md)
