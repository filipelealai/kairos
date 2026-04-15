# cold-prospecting — Matriz de Autoridade

Matriz de autoridade dos agentes do squad cold-prospecting. Autoridade do @kairos e regras universais vivem em `.claude/rules/agent-authority.md`.

---

## @campaign-analyst (Clio) — Análise Exclusiva

| Operação | Autoridade |
|----------|-----------|
| Executar `npx tsx src/agents/campaign-analyst.ts` | EXCLUSIVA |
| Ler e interpretar relatórios de campanha | EXCLUSIVA |
| Comparar relatórios entre períodos (`*trend`) | EXCLUSIVA |
| Modificar dados de leads | BLOQUEADA |
| Gerar e-mails | BLOQUEADA |

---

## @lead-scorer (Lex) — Pontuação Exclusiva

| Operação | Autoridade |
|----------|-----------|
| Executar `npx tsx src/agents/lead-scorer.ts` | EXCLUSIVA |
| Interpretar e exibir scores e tiers | EXCLUSIVA |
| Modificar o algoritmo de scoring | BLOQUEADA (requer mudança no TS) |
| Modificar dados de leads | BLOQUEADA |
| Gerar e-mails | BLOQUEADA |

---

## @niche-classifier (Nix) — Classificação Exclusiva

| Operação | Autoridade |
|----------|-----------|
| Executar `npx tsx src/agents/niche-classifier.ts` | EXCLUSIVA |
| Recomendar keywords novas para o n8n | EXCLUSIVA |
| Adicionar keywords diretamente ao workflow n8n | BLOQUEADA (requer confirmação do usuário) |
| Modificar dados de leads | BLOQUEADA |

---

## @email-writer (Eva) — Geração Exclusiva

| Operação | Autoridade |
|----------|-----------|
| Gerar e-mails personalizados via Claude Code | EXCLUSIVA |
| Salvar JSON em `data/outputs/cold-prospecting/emails/` | EXCLUSIVA |
| Revisar e reescrever e-mails do batch (*review) | EXCLUSIVA |
| Enviar e-mails | BLOQUEADA (responsabilidade do n8n) |
| Marcar Status do Envio no Google Sheets | BLOQUEADA (responsabilidade do n8n) |
| Modificar dados de leads | BLOQUEADA |

---

## Operações Universalmente Proibidas no Squad

- Enviar e-mails diretamente (SEMPRE via n8n)
- Modificar a planilha do Google Sheets (SEMPRE via n8n)
- Modificar o webhook de leads em `https://n8n.vendoteca.com/webhook/kairos-leads`

---

## Escalação Específica do Squad

| Situação | Ação |
|----------|------|
| Webhook indisponível | HALT em qualquer agente — informar usuário |
| 0 leads pendentes | HALT em @lead-scorer e @email-writer |
| Dúvida sobre se enviar um e-mail | HALT — consultar o usuário antes |
| Keyword nova que deve ir para o n8n | HALT — apresentar ao usuário para confirmar antes de editar workflow |
