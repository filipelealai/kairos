# Fluxo de Dados — Kairos

> Referência para entender como os dados entram, transitam e saem do sistema.

---

## Visão Geral

```
┌─────────────────────────────────────────────────────────┐
│                    FONTES EXTERNAS                       │
│  Google Sheets (leads) ←→ n8n ←→ Receita Federal CNPJ  │
└─────────────────────────┬───────────────────────────────┘
                          │ GET /webhook/kairos-leads
                          ▼
┌─────────────────────────────────────────────────────────┐
│                   KAIROS (Claude Code)                   │
│                                                          │
│  @campaign-analyst ──▶ data/outputs/cold-prospecting/reports/campaign-analyst_campaign-*.md       │
│          │                                               │
│          ▼                                               │
│  @lead-scorer ──────▶ data/outputs/cold-prospecting/reports/lead-scorer_scored-leads-*.csv   │
│          │                                               │
│          ▼                                               │
│  @niche-classifier ─▶ data/outputs/cold-prospecting/reports/niche-classifier_niche-map-*.json     │
│          │                                               │
│          ▼                                               │
│  @email-writer ─────▶ data/outputs/cold-prospecting/emails/email-writer_emails-*.json         │
└─────────────────────────┬───────────────────────────────┘
                          │ n8n lê data/outputs/cold-prospecting/emails/
                          ▼
┌─────────────────────────────────────────────────────────┐
│                    DESTINOS EXTERNOS                     │
│  Gmail/SMTP (disparo) ──▶ Google Sheets (status update)  │
└─────────────────────────────────────────────────────────┘
```

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

**Gotchas:**
- `Capital Social` pode retornar como number ou string — sempre usar `parseFloat(String(v))`
- `Nome Fantasia` frequentemente vazio — fallback para `Nome`
- `Cidade` vem em uppercase — normalizar com `.toLowerCase()` + capitalize

---

## Dados Gerados por Agente

### @campaign-analyst

**Output:** `data/outputs/cold-prospecting/reports/campaign-analyst_campaign-YYYY-MM-DD.md`

Conteúdo: métricas agregadas — total de leads, pendentes, distribuição por nicho, por cidade, por capital social, taxa de cobertura.

**Não persiste:** dados individuais de leads.

---

### @lead-scorer

**Output:** `data/outputs/cold-prospecting/reports/lead-scorer_scored-leads-YYYY-MM-DD.csv`

**Colunas:** `row_number, cnpj, nome, atividade, cidade, estado, capital_social, score, tier`

**Algoritmo:** ver `.claude/commands/kairos/agents/lead-scorer.md` (seção `scoring-algorithm`)

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

## Handoffs (Runtime)

**Local:** `.kairos-core/runtime/handoffs/` (conteúdo gitignored)

**Formato:** `handoff-{from}-to-{to}-{timestamp}.yaml`

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

**Lifecycle:** criado pelo agente que termina uma fase → lido e marcado `consumed: true` pelo próximo agente na ativação.

---

## Limites e Restrições

| Restrição | Motivo |
|-----------|--------|
| Kairos nunca escreve na planilha | Risco de corrupção de dados — n8n tem controle exclusivo |
| Kairos nunca envia e-mails | n8n tem autenticação, rate limiting e controle de bounce |
| Emails gerados são idempotentes por data | Regenar no mesmo dia sobrescreve — comportamento intencional |
| Webhook é read-only para Kairos | Segurança — sem side effects no acesso aos dados |
