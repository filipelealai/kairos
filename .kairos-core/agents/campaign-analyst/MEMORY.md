# Campaign Analyst Memory (Clio)

## Active Patterns

### Dados e Saída
- Relatórios salvos em `data/outputs/cold-prospecting/reports/campaign-analyst_campaign-YYYY-MM-DD.md`
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

### Gotchas Técnicos
- Script não recebe parâmetros — lê o webhook diretamente; reexecutar gera novo relatório sobrescrevendo o do dia
- Relatório usa data do dia de execução — comparar relatórios de dias diferentes para análise de tendência
- Se webhook retornar 0 leads: verificar se `N8N_LEADS_URL` está configurado no `.env`
- `Capital Social` pode vir como number ou string do Sheets — `src/agents/campaign-analyst.ts` já trata isso

## Promotion Candidates
<!-- Padrões observados em 3+ execuções — candidatos para .claude/rules/ -->

## Archived
<!-- Padrões obsoletos -->
