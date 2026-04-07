# Agent Authority — Matriz de Autoridade

## Matriz de Delegação

### @campaign-analyst (Clio) — Análise Exclusiva

| Operação | Autoridade |
|----------|-----------|
| Executar `npx tsx src/agents/campaign-analyst.ts` | EXCLUSIVA |
| Ler e interpretar relatórios de campanha | EXCLUSIVA |
| Comparar relatórios entre períodos (`*trend`) | EXCLUSIVA |
| Modificar dados de leads | BLOQUEADA |
| Gerar e-mails | BLOQUEADA |

### @lead-scorer (Lex) — Pontuação Exclusiva

| Operação | Autoridade |
|----------|-----------|
| Executar `npx tsx src/agents/lead-scorer.ts` | EXCLUSIVA |
| Interpretar e exibir scores e tiers | EXCLUSIVA |
| Modificar o algoritmo de scoring | BLOQUEADA (requer mudança no TS) |
| Modificar dados de leads | BLOQUEADA |
| Gerar e-mails | BLOQUEADA |

### @niche-classifier (Nix) — Classificação Exclusiva

| Operação | Autoridade |
|----------|-----------|
| Executar `npx tsx src/agents/niche-classifier.ts` | EXCLUSIVA |
| Recomendar keywords novas para o n8n | EXCLUSIVA |
| Adicionar keywords diretamente ao workflow n8n | BLOQUEADA (requer @usuário confirmar) |
| Modificar dados de leads | BLOQUEADA |

### @email-writer (Eva) — Geração Exclusiva

| Operação | Autoridade |
|----------|-----------|
| Gerar e-mails personalizados via Claude Code | EXCLUSIVA |
| Salvar JSON em `data/emails/` | EXCLUSIVA |
| Revisar e reescrever e-mails do batch (*review) | EXCLUSIVA |
| Enviar e-mails | BLOQUEADA (responsabilidade do n8n) |
| Marcar Status do Envio no Google Sheets | BLOQUEADA (responsabilidade do n8n) |
| Modificar dados de leads | BLOQUEADA |

### @kairos — Autoridade Total

| Operação | Autoridade |
|----------|-----------|
| Versionar o Kairos (`*version`) | EXCLUSIVA |
| Criar novos squads (`*new-squad`) | EXCLUSIVA |
| Criar stories de desenvolvimento do Kairos (`*new-story`) | EXCLUSIVA |
| Modificar `.claude/rules/agent-authority.md` | EXCLUSIVA |
| Modificar seções KAIROS-MANAGED no `CLAUDE.md` | EXCLUSIVA |
| Deprecar agentes | EXCLUSIVA |
| Executar qualquer operação de qualquer squad | AUTORIZADO |

## Quem Constrói o Kairos

- **@kairos** — planeja, versiona, cria stories, decide o roadmap
- **Claude Code (conversa principal)** — executa: escreve código, cria arquivos, modifica tasks/agents
- **Não existe `@dev` no Kairos** — o executor é o próprio Claude Code em modo normal

## Operações que Nenhum Agente Pode Fazer

- Enviar e-mails diretamente (SEMPRE via n8n)
- Modificar a planilha do Google Sheets (SEMPRE via n8n)
- Commitar ou fazer push no repositório
- Modificar arquivos `.kairos-core/` (são artefatos do framework, não do projeto)

## Escalação

| Situação | Ação |
|----------|------|
| Webhook indisponível | HALT em qualquer agente — informar usuário |
| 0 leads pendentes | HALT em @lead-scorer e @email-writer |
| Erro no script TS | HALT — exibir stderr e sugerir debug |
| Dúvida sobre se enviar um e-mail | HALT — consultar o usuário antes |
| Keyword nova que deve ir para o n8n | HALT — apresentar ao usuário para confirmar antes de editar workflow |
