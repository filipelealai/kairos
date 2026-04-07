# Changelog — Kairos

Todas as mudanças relevantes no framework Kairos são documentadas aqui.

Formato: [Semver](https://semver.org/). Gerenciado por `@kairos *version`.

---

## [1.2.0] — 2026-04-06

### Adicionado
- `@kairos` — renomeado de `@kairos-master`; agora inclui sistema de review com gates PASS/BLOCK e controle exclusivo de git push
- `kairos-review.md` — task de validação de stories com `quality_score` determinístico e gate YAML em `docs/qa/gates/`
- `kairos-pre-push.md` — task de pre-push: consistência de versão, gates ativos, referências quebradas
- `kairos-push.md` — task de push exclusiva do `@kairos`, com guard de sessão (`pre_push_passed=true`)
- `kairos-status.md` — agregação de versão, squads, stories, gates, handoffs
- `kairos-new-story.md` — criação guiada de stories com elicitação sequencial
- `kairos-new-squad.md` — scaffolding de novos squads com atualização de core-config
- `kairos-version-bump.md` — bump de versão com validação de story para MINOR/MAJOR
- `docs/epics/` — arquivos dedicados por epic (epic-1 a epic-4)
- `docs/qa/gates/` — diretório para armazenar gates de review
- `docs/stories/3.1.story.md` — tasks de governança do @kairos (Done)

### Mudado
- Todas as referências a `@kairos-master` atualizadas para `@kairos`
- Epic 3 marcado como Done (todos os critérios de conclusão atingidos)

---

## [1.1.0] — 2026-04-06

### Adicionado
- `@kairos` (então `@kairos-master`) — meta-agente orquestrador com autoridade de framework
- `.kairos-core/core-config.yaml` — configuração central e versão semântica do sistema
- `docs/` — estrutura de documentação com `scope.md` e `docs/framework/`
  - `docs/scope.md` — escopo, arquitetura, objetivos e restrições do Kairos
  - `docs/framework/agent-standards.md` — padrões obrigatórios para criação de agentes
  - `docs/framework/data-flow.md` — fluxo completo de dados pelo sistema
- `docs/stories/` — rastreamento do desenvolvimento do Kairos
  - `1.1.story.md` — webhook de leads (retrospectiva)
  - `1.2.story.md` — pipeline de agentes (retrospectiva)
  - `2.1.story.md` — loop de disparo (Draft)
- `squads/cold-prospecting/` — squad com manifesto, agents leves e workflow documentado
- Tasks refatoradas com frontmatter YAML completo (`elicit`, `Entrada`, `Saida`, `Checklist`)
- `.kairos-core/agents/{id}/MEMORY.md` para cada agente do squad
- `.claude/rules/` — 4 rules cross-cutting (lifecycle, handoff, authority, memory-imports)
- `.kairos-core/runtime/` — diretório de runtime para handoffs (conteúdo gitignored)

### Mudado
- Agentes migrados de `.claude/commands/` (slash commands simples) para `.claude/commands/kairos/agents/` (personas YAML completas com activation-instructions, greeting estruturado, blocking/completion explícitos)

### Removido
- `.claude/commands/campaign-analyst.md`, `lead-scorer.md`, `niche-classifier.md`, `email-writer.md` (substituídos pelas personas completas)

---

## [1.0.0] — 2026-04-06

### Adicionado
- Infraestrutura inicial do Kairos
- Webhook n8n `GET /kairos-leads` apontando para Google Sheets (22k+ leads)
- `src/agents/campaign-analyst.ts` — análise de campanha sem AI
- `src/agents/lead-scorer.ts` — scoring multidimensional sem AI
- `src/agents/niche-classifier.ts` — classificação de nichos com Claude API
- `src/agents/email-writer.ts` — geração de e-mails com Claude API
- `src/tools/claude.ts` — wrapper da Anthropic SDK
- `.env.example` com `N8N_LEADS_URL`

---

## Como versionar

```
@kairos *version patch "descrição curta"
@kairos *version minor "descrição curta"
@kairos *version major "descrição curta"
```

Regras:
- **PATCH**: correção de bug, ajuste de instrução, atualização de memória
- **MINOR**: novo agente, nova task, nova rule, nova capacidade
- **MAJOR**: novo squad/escopo, breaking change em agente existente
