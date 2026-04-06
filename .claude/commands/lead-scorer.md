Rode o agente de pontuação de leads e exiba o resumo.

Execute: `npx tsx src/agents/lead-scorer.ts`

O CSV ranqueado é salvo em `data/reports/scored-leads-YYYY-MM-DD.csv`. Após rodar, exiba:
- A distribuição de scores
- Os top 20 leads (leia as primeiras linhas do CSV)
- Qualquer padrão interessante que observar nos dados (nicho, cidade, capital social)
