# Changelog — Kairos

Todas as mudanças relevantes no framework Kairos são documentadas aqui.

Formato: [Semver](https://semver.org/). Gerenciado por `@kairos *version`.

---

## [1.3.1] — 2026-04-14

### Adicionado

- `.kairos-core/constitution.md` — **Seção VI: Fronteira Framework / Usuário** (princípios 18–23, L1): codifica a distinção entre infraestrutura do framework (`.kairos-core/`, rules, tasks, hooks) e artefatos do usuário (squads, agents, skills, integrações); proíbe que revisões futuras recategorizem conteúdo do usuário como conteúdo de framework

### Modificado

**Despersonalização dos docs de framework**
- `README.md` — referências pessoais removidas; "Squad ativo: cold-prospecting" → "Como funciona" (exemplo genérico); "Como rodar um agente" generalizado (`{nome-do-agente}.ts`); "Pipeline completo" → "Pipeline de squad (exemplo)" com cold-prospecting rotulado explicitamente; estrutura do repositório sem filenames específicos de squad, `{squad}/` genérico, skills descritas como "configuradas pelo usuário/equipe"
- `CLAUDE.md` — "Filipe Leal" removido; agentes de squad rotulados como "exemplo dos squads ativos neste projeto"; pipeline e diagrama de governança genéricos (`squads/*`); seção "Restrições Operacionais" agora espaço configurável pelo usuário com exemplos genéricos
- `.claude/rules/external-integrations.md` — tabela de skills dividida em nativas (sempre disponíveis) vs. de projeto (configuradas pelo usuário/equipe); exemplos rotulados como "stack Supabase/GitHub — não específicos do Kairos"
- `.kairos-core/constitution.md` — Seção I reescrita como princípio positivo sobre como usar ferramentas externas, sem menção a squads específicos
- `.env.example` — reescrito com 7 categorias abrangentes (AI Providers, Automation, Database, Communication, Search, Version Control, Squad-specific); todos opcionais exceto `ANTHROPIC_API_KEY`; exemplo de squad-specific comentado no final

---

## [1.3.0] — 2026-04-14

### Adicionado

**Fundação do Framework (L1)**
- `.kairos-core/constitution.md` — 17 princípios não-negociáveis em 5 seções
- `.claude/rules/ids-principles.md` — REUTILIZAR > ADAPTAR > CRIAR: hierarquia de criação de artefatos (L1)
- `.claude/rules/framework-layers.md` — camadas L1–L4 de imutabilidade com protocolo de mudança por camada (L1)
- `.claude/rules/external-integrations.md` — hierarquia skills → CLI → MCP → scripts, com diretrizes por tipo de operação

**Novas Capacidades do @kairos**
- `*kb` — base de conhecimento curada: leitura por tópico e adição guiada (`kairos-kb.md`)
- `*doctor` — health check do framework: fundação, agentes registrados, tasks, hooks, stories (`kairos-doctor.md`)
- `*workers` — agentes agendados: registry YAML + `*workers new|schedule|run|delete` + integração com `/schedule` do Claude Code (`kairos-workers.md`)

**Hooks do Claude Code**
- `.claude/hooks/kairos-precompact.cjs` — PreCompact: injeta versão, stories abertas, último gate e handoffs pendentes antes da compactação de contexto
- `.claude/hooks/kairos-code-intel.cjs` — PreToolUse (Write|Edit): injeta contexto relevante por padrão de path (exports do claude.ts, formato de task, YAML de persona, story template)
- Hooks registrados em `.claude/settings.json`

**Infraestrutura**
- `.kairos-core/templates/` — 6 templates: `story-template.md`, `agent-template.md`, `squad-template/` (squad.yaml, README, agents/, workflows/)
- `.kairos-core/data/kairos-kb.md` — KB inicial: decisões arquiteturais, gotchas do webhook, convenções de naming, erros comuns, padrões validados
- `.kairos-core/data/workers.yaml` — registry de workers agendados (inicialmente vazio, com exemplos comentados)

### Modificado

**Identidade do Framework**
- `README.md`, `CLAUDE.md`, `docs/scope.md` — reframing: Kairos como framework de orquestração de agentes de IA, não "sistema pessoal de automação n8n-driven"; n8n movido para contexto do squad cold-prospecting
- `core-config.yaml` — `type: personal-automation` → `type: claude-code-orchestrator`; adicionados campos `scope`, `description`, `templatesLocation`, `hooksLocation`, `constitutionFile`, `kbFile`, `workersFile`
- `constitution.md` — Seção I reescrita: princípio genérico de separação orquestração/ação, sem lock-in em n8n
- `kairos.md` — `identity` e `focus` refletem papel de orquestrador agnóstico a ferramenta
- `CLAUDE.md` — seção "Restrições Operacionais" agora é espaço explicitamente do usuário; regras de integração externa movidas para rule de framework

**Memória dos Agentes**
- `.kairos-core/agents/campaign-analyst/MEMORY.md` — seção `### Gotchas Técnicos` adicionada
- `.kairos-core/agents/email-writer/MEMORY.md` — seção `### Gotchas Técnicos` adicionada
- `.kairos-core/agents/niche-classifier/MEMORY.md` — seção `### Gotchas Técnicos` adicionada

**Protocolo de Desenvolvimento**
- `.claude/rules/story-lifecycle.md` — seção "Decision Log" adicionada: critérios de promoção de decisões para o KB e formato recomendado no Execution Log
- `docs/framework/agent-standards.md` — regras de Gotchas e promoção ao KB no padrão de MEMORY.md

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
