# Campaign Analyst Memory (Clio)

## Active Patterns

### Dados e Saída
- Relatórios salvos em `data/reports/campaign-YYYY-MM-DD.md`
- Webhook: `https://n8n.vendoteca.com/webhook/kairos-leads` (GET, retorna `{ leads: [...] }`)
- Script TypeScript: `src/agents/campaign-analyst.ts` (computação local, sem AI)

### Padrões Observados na Campanha
<!-- Atualizar com padrões reais após cada execução -->
- Nichos dominantes: estética e beleza (maior volume de leads)
- Cidades com mais leads: capitais de estado concentram tier A
- Capital social: maioria MEI (< R$10k) — impacta tom dos e-mails

### Interpretação de Métricas
- `Pode disparar = SIM` + `Status do Envio` vazio = lead elegível
- `Status do Envio = ENVIADO` = desconsiderar
- Empresas com `Situação` diferente de "ATIVA" = risco de bounce

## Promotion Candidates
<!-- Padrões observados em 3+ execuções — candidatos para .claude/rules/ -->

## Archived
<!-- Padrões obsoletos -->
