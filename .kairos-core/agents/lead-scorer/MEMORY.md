# Lead Scorer Memory (Lex)

## Active Patterns

### Dados e Saída
- CSV ranqueado: `data/outputs/cold-prospecting/reports/lead-scorer_scored-leads-YYYY-MM-DD.csv`
- Script TypeScript: `src/agents/lead-scorer.ts`
- Filtro: `Pode disparar = SIM` AND (`Status do Envio` vazio OR `NÃO ENVIADO`)

### Algoritmo de Score (referência)
- Nicho odontologia: +30 | clínica/saúde: +25 | estética médica: +25 | barbearia/salão: +20
- Capital social ≥ R$100k: +30 | ≥ R$50k: +20 | ≥ R$10k: +10 | ≥ R$1k: +5
- Cidade capital de estado: +15
- Situação ATIVA: +10
- Tiers: A (≥55), B (35-54), C (15-34), D (<15)

### Gotchas Técnicos
- Campos do Sheets podem não ser strings (números, null) — usar `String(value || "")`
- Capital Social vem como string com vírgula decimal do Sheets — usar `parseFloat`

## Promotion Candidates
<!-- Padrões vistos em 3+ execuções -->

## Archived
