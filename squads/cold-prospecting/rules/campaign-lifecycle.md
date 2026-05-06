# Campaign Lifecycle — Fluxo do Pipeline de Prospecção

## Fluxo Principal

```
@campaign-analyst *analyze
        ↓
@lead-scorer *score
        ↓
@niche-classifier *classify
        ↓
@email-writer *write N
        ↓
(n8n dispara os e-mails)
        ↓
@campaign-analyst *analyze  ← novo ciclo
```

> **Nomenclatura de outputs:** todos os arquivos seguem o padrão canônico
> `{agente}_{tipo}-{INSTANCE}-YYYY-MM-DD.{ext}`, onde `{INSTANCE}` vem de
> `KAIROS_INSTANCE_NAME` (fallback `default`). Ver `.claude/rules/output-naming.md`.

## Fases e Responsáveis

| Fase | Agente | Comando | Output |
|------|--------|---------|--------|
| 1. Análise | @campaign-analyst (Clio) | `*analyze` | `data/outputs/cold-prospecting/reports/campaign-analyst_campaign-{INSTANCE}-YYYY-MM-DD.md` |
| 2. Pontuação | @lead-scorer (Lex) | `*score` | `data/outputs/cold-prospecting/reports/lead-scorer_scored-leads-{INSTANCE}-YYYY-MM-DD.csv` |
| 3. Classificação | @niche-classifier (Nix) | `*classify` | `data/outputs/cold-prospecting/reports/niche-classifier_niche-map-{INSTANCE}-YYYY-MM-DD.json` |
| 4. Geração | @email-writer (Eva) | `*write N` | `data/outputs/cold-prospecting/emails/email-writer_emails-{INSTANCE}-YYYY-MM-DD.json` |
| 5. Disparo | n8n (automático) | — | e-mails enviados, planilha atualizada |

## Handoff Chain

Cada agente gera um handoff ao completar sua fase:

```
campaign-analyst → lead-scorer   : handoff-campaign-analyst-to-lead-scorer-{ts}.yaml
lead-scorer      → niche-classifier : handoff-lead-scorer-to-niche-classifier-{ts}.yaml
niche-classifier → email-writer  : handoff-niche-classifier-to-email-writer-{ts}.yaml
email-writer     → campaign-analyst : handoff-email-writer-to-campaign-analyst-{ts}.yaml
```

Diretório: `.kairos-core/runtime/handoffs/`

## Execução Parcial (permitido)

Não é obrigatório rodar o pipeline completo. Exemplos válidos:

- **Só e-mails:** `@email-writer *write 20` (sem executar scorer antes)
- **Só análise:** `@campaign-analyst *analyze` (independente)
- **Score + emails:** `@lead-scorer *score` → `@email-writer *write 20`

## Gates de Qualidade

### @email-writer — Gate obrigatório antes de salvar

Antes de salvar qualquer batch:
1. Primeiro parágrafo cria reconhecimento? → Se não, reescrever
2. Tem mais de um travessão? → Remover
3. Tem abertura genérica "Oi, [nome]! + pitch"? → Reescrever
4. CTA é idêntica a outros e-mails do batch? → Variar

### @lead-scorer — Gate de cobertura

Se > 30% dos leads tiver score = 0 (nicho não reconhecido), sugerir `@niche-classifier *classify` antes de pontuar.

## Frequência Recomendada de Ciclo

- Pipeline completo: a cada novo lote de leads (quando volume de pendentes > 500)
- Só `*write`: pode rodar diariamente sobre leads já pontuados
- `*analyze`: pode rodar a qualquer momento para status
