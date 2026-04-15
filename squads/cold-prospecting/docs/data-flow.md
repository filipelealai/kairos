# cold-prospecting — Fluxo de Dados

> Fluxo específico do squad cold-prospecting. Padrões genéricos do framework vivem em `.kairos-core/docs/data-flow.md`.

---

## Visão Geral

```
┌─────────────────────────────────────────────────────────┐
│                    FONTES EXTERNAS                       │
│  Google Sheets (leads) ←→ n8n ←→ Receita Federal CNPJ   │
└─────────────────────────┬───────────────────────────────┘
                          │ GET /webhook/kairos-leads
                          ▼
┌─────────────────────────────────────────────────────────┐
│                   KAIROS (Claude Code)                   │
│                                                          │
│  @campaign-analyst ──▶ reports/campaign-analyst_*.md     │
│          │                                               │
│          ▼                                               │
│  @lead-scorer ──────▶ reports/lead-scorer_*.csv          │
│          │                                               │
│          ▼                                               │
│  @niche-classifier ─▶ reports/niche-classifier_*.json    │
│          │                                               │
│          ▼                                               │
│  @email-writer ─────▶ emails/email-writer_*.json         │
└─────────────────────────┬───────────────────────────────┘
                          │ n8n lê data/outputs/cold-prospecting/emails/
                          ▼
┌─────────────────────────────────────────────────────────┐
│                    DESTINOS EXTERNOS                     │
│  Gmail/SMTP (disparo) ──▶ Google Sheets (status update) │
└─────────────────────────────────────────────────────────┘
```

Todos os outputs ficam em `data/outputs/cold-prospecting/{tipo}/`.

---

## Fontes de Dados

### Webhook de Leads

**URL:** `https://n8n.vendoteca.com/webhook/kairos-leads`
**Método:** GET
**Autenticação:** nenhuma (interno)
**Resposta:** `{ leads: Lead[] }`

**Campos do Lead:**

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `row_number` | number | Linha na planilha |
| `CNPJ` | string | CNPJ formatado |
| `Nome` | string | Razão social |
| `Nome Fantasia` | string | Nome fantasia (pode ser vazio) |
| `Email` | string | E-mail principal |
| `Atividade Principal` | string | Descrição da atividade CNAE |
| `Status do Envio` | string | `""`, `"NÃO ENVIADO"`, `"ENVIADO"` |
| `Pode disparar` | string | `"SIM"` ou `"NÃO"` |
| `Cidade` | string | Cidade (uppercase) |
| `Estado` | string | UF |
| `Capital Social` | string | Valor em reais (pode vir como número ou string) |
| `Situação` | string | `"ATIVA"` ou outras |

Gotchas de campos → ver `squads/cold-prospecting/data/kb.md` (seção Webhook de Leads).

---

## Outputs por Agente

### @campaign-analyst

**Output:** `data/outputs/cold-prospecting/reports/campaign-analyst_campaign-YYYY-MM-DD.md`

Métricas agregadas — total de leads, pendentes, distribuição por nicho, por cidade, por capital social, taxa de cobertura. Não persiste dados individuais.

---

### @lead-scorer

**Output:** `data/outputs/cold-prospecting/reports/lead-scorer_scored-leads-YYYY-MM-DD.csv`

**Colunas:** `row_number, cnpj, nome, atividade, cidade, estado, capital_social, score, tier`

**Algoritmo:** ver `.claude/commands/kairos/agents/lead-scorer.md` (seção `scoring-algorithm`).

---

### @niche-classifier

**Output:** `data/outputs/cold-prospecting/reports/niche-classifier_niche-map-YYYY-MM-DD.json`

```json
{
  "geradoEm": "2026-04-06T...",
  "totalAtividades": 142,
  "nichoMap": { "Atividade Descrita": "estetica_bem_estar" },
  "contagemLeads": { "estetica_bem_estar": 280 }
}
```

---

### @email-writer

**Output:** `data/outputs/cold-prospecting/emails/email-writer_emails-YYYY-MM-DD.json`

```json
[
  {
    "row_number": 123,
    "cnpj": "XX.XXX.XXX/0001-XX",
    "email": "contato@empresa.com",
    "nome": "Nome da Empresa",
    "email_suspeito": false,
    "assunto": "Assunto do e-mail",
    "corpo": "<p>...</p>"
  }
]
```

---

## Handoff Típico do Pipeline

```yaml
handoff:
  from_agent: email-writer
  to_agent: campaign-analyst
  last_command: write
  timestamp: "2026-04-06T15:30:00.000Z"
  consumed: false
  context:
    emails_file: "data/outputs/cold-prospecting/emails/email-writer_emails-2026-04-06.json"
    total_gerados: 20
    total_suspeitos: 3
  next_action: "Analisar métricas após o disparo com *analyze"
```

Protocolo completo de handoff → `.claude/rules/agent-handoff.md`.

---

## Limites e Restrições do Squad

| Restrição | Motivo |
|-----------|--------|
| Kairos nunca escreve na planilha | n8n tem controle exclusivo — risco de corrupção |
| Kairos nunca envia e-mails | n8n tem autenticação, rate limiting e controle de bounce |
| Emails gerados são idempotentes por data | Regenerar no mesmo dia sobrescreve (intencional) |
| Webhook é read-only para Kairos | Segurança — sem side effects no acesso |

---

## Referências

- `squads/cold-prospecting/data/kb.md` — knowledge base do squad (gotchas, padrões validados)
- `squads/cold-prospecting/rules/campaign-lifecycle.md` — pipeline e gates de qualidade
- `.kairos-core/docs/data-flow.md` — padrões genéricos de fluxo (framework)
