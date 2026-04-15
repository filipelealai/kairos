# cold-prospecting — Knowledge Base

> Base de conhecimento específica do squad cold-prospecting: decisões de negócio, integrações particulares (n8n + Google Sheets), gotchas do webhook de leads e padrões validados em campanhas reais.

> Conteúdo genérico do framework Kairos vive em `.kairos-core/data/kairos-kb.md`.

---

## Índice

- [Webhook de Leads](#webhook-de-leads)
- [Gotchas de Negócio](#gotchas-de-negocio)
- [Padrões Validados de Campanha](#padroes-validados-de-campanha)
- [Pipeline do Squad](#pipeline-do-squad)

---

## Webhook de Leads

### Campos e Gotchas

**URL:** `https://n8n.vendoteca.com/webhook/kairos-leads`
**Método:** GET | **Autenticação:** nenhuma | **Resposta:** `{ leads: Lead[] }`

| Campo | Gotcha | Solução |
|-------|--------|---------|
| `Capital Social` | Pode retornar como number ou string | `parseFloat(String(v))` |
| `Nome Fantasia` | Frequentemente vazio | Fallback para `Nome` |
| `Cidade` | Vem em UPPERCASE | `.toLowerCase()` + capitalize |
| `Status do Envio` | Pode ser `""`, `"NÃO ENVIADO"` ou `"ENVIADO"` | Verificar explicitamente |
| Qualquer campo string | Pode ser null ou number vindo do Sheets | `String(value || "")` |

### Filtro de Elegibilidade

Lead elegível para disparo:
```
Pode disparar === "SIM"
AND (Status do Envio === "" OR Status do Envio === "NÃO ENVIADO")
AND Situação === "ATIVA"
```

---

## Gotchas de Negócio

### Score 0 em muitos leads

**Causa:** Atividade Principal do lead não match com nenhum nicho do algoritmo do `@lead-scorer`.
**Solução:** Rodar `@niche-classifier *classify` para atualizar o mapa de nichos, depois re-score.

---

## Padrões Validados de Campanha

### Abertura de e-mail por nicho

| Nicho | Abertura que funciona |
|-------|----------------------|
| Barbearia | Perspectiva do cliente que não volta |
| Salão | Volume de perguntas no WhatsApp |
| Clínica estética médica | Tempo perdido em triagem |
| Odontologia | Paciente que marca e não comparece |

*Preencher com padrões validados após feedback de campanha real.*

---

### Tiers de leads e tom de e-mail

| Tier | Score | Capital Social | Tom recomendado |
|------|-------|----------------|-----------------|
| A | ≥55 | Variado | Direto, foco em resultado |
| B | 35–54 | R$10k–100k | Empático, foco em crescimento |
| C | 15–34 | R$1k–10k | Simples, foco em economia de tempo |
| D | <15 | MEI baixo | Muito breve, foco em praticidade |

---

## Pipeline do Squad

```
@campaign-analyst *analyze → @lead-scorer *score
→ @niche-classifier *classify → @email-writer *write 20
→ n8n dispara → @campaign-analyst *analyze (novo ciclo)
```

---

*Última atualização: 2026-04-14*
