# Changelog — Kairos

Todas as mudanças relevantes no framework Kairos são documentadas aqui.

Formato: [Semver](https://semver.org/). Gerenciado por `@kairos *version`.

---

## [3.12.0] — 2026-04-29

### Adicionado
- kairos-regenerate-squad.md: preservação de blocos kairos-custom durante regeneração

---

## [3.11.1] — 2026-04-28

### Corrigido
- ajuste de instrução em kairos-regenerate-squad e correções menores no framework

---

## [3.11.0] — 2026-04-26

### Adicionado
- Criado template agent-id.yaml com schema canônico rico; adicionado *regenerate-squad com detecção de drift e integração ao *pre-push

---

## [3.10.0] — 2026-04-26

### Adicionado
- docs e tasks de scaffolding refatorados: data-flow.md e agent-standards.md com separação de camadas; elicitação propósito-first em new-squad/update-squad/new-story/new-epic; expurgo de hardcodes de stack e ferramentas; scope.md v2.0

---

## [3.9.1] — 2026-04-25

### Adicionado
- branch protection habilitada na branch `main` de `filipelealweb/kairos` via `gh api PUT`

---

## [3.9.0] — 2026-04-25

### Adicionado
- `.github/workflows/validate-manifest.yml` e `.github/scripts/validate-manifest.sh`: primeiro workflow de CI do Kairos — valida owned_files (existência + sha256), frontmatter kairos-owned, KAIROS-MANAGED markers e sync_files em PRs contra main; stack bash + yq + sha256sum, zero Node

---

## [3.8.0] — 2026-04-25

### Adicionado
- `*doctor` integrado ao `*pre-push` como Passo 0 universal; referências a `*ci` substituídas por `*pre-push` em CONTRIBUTING.md, PULL_REQUEST_TEMPLATE.md e story 5.19

---

## [3.7.0] — 2026-04-24

### Adicionado
- package.json/package-lock.json/tsconfig.json expurgados de origin/main; ANTHROPIC_API_KEY declarada opcional no .env.example e CONTRIBUTING.md; posição stack-agnóstica do Kairos documentada em CONTRIBUTING.md, kairos-kb.md e kairos-architecture.md

---

## [3.6.1] — 2026-04-24

### Corrigido
- README.md: hardcodes de stack e versão corrigidos; CLAUDE.md: TypeScript removido dos blocos managed

---

## [3.6.0] — 2026-04-23

### Adicionado
- `.github/` scaffold: CODEOWNERS, PULL_REQUEST_TEMPLATE.md, ISSUE_TEMPLATE/bug_report.md, ISSUE_TEMPLATE/feature_request.md; 4 entries em manifest owned_files (L3); push-dual Passo 2a atualizado; CONTRIBUTING.md atualizado com menção aos templates

---

## [3.5.3] — 2026-04-23

### Adicionado
- CODE_OF_CONDUCT.md: código de conduta baseado no Contributor Covenant v2.1

---

## [3.5.2] — 2026-04-23

### Adicionado
- CONTRIBUTING.md: governança de contribuição ao repo público (stack-agnóstico, ownership, *doctor)

---

## [3.5.1] — 2026-04-23

### Adicionado
- sync_files documentado em ownership.md (terceira categoria do manifesto); COMMIT_MSG via git log no push-dual Passo 3

---

## [3.5.0] — 2026-04-19

### Adicionado
- manifest: sha256 por bloco em owned_sections, sha_method canônico em yaml_keys, categoria sync_files

---

## [3.4.1] — 2026-04-19

### Corrigido
- sha256 sentinel `self-referential` no manifest.yaml: *pre-push e *doctor ignoram entrada auto-referencial sem calcular hash; skip do push-dual Passo 2b por comparação de conteúdo managed (em vez de git log)

---

## [3.4.0] — 2026-04-18

### Adicionado
- Manifest Guard no *pre-push (Passo 0): detecta arquivos `kairos-owned: true` fora do manifesto antes de qualquer outro check; manifest.yaml adicionado a owned_files e ao push-dual Passo 2a
- Skip de arquivos mistos no push-dual Passo 2b: `git log origin/main..filipe-instance` detecta ausência de mudança e pula reprocessamento; resumo ao final do passo

---

## [3.3.1] — 2026-04-18

### Corrigido
- kairos-pre-push: mensagem de commit derivada do git sem referência a story; story-lifecycle e kairos-review: sync de status no epic em cada transição; kairos-validate-story: removido falso positivo do check de README; kairos-review: guard explícito — *review nunca transita para Done

---

## [3.3.0] — 2026-04-18

### Adicionado
- manifest.yaml: adicionados CHANGELOG.md e README.md em owned_files; kairos-new-squad.md: new-squad cria rules/ e faz wiring no CLAUDE.md

---

## [3.2.1] — 2026-04-18

### Corrigido
- investigado o git log para rastrear o patch anterior relacionado ao README.md no bump de versão

---

## [3.2.0] — 2026-04-18

### Adicionado
- *yolo (modo autônomo de sessão) adicionado à persona kairos.md; Modo All adicionado a kairos-implement.md; kairos-validate-story.md estendido com modo all

---

## [3.1.8] — 2026-04-17

### Corrigido
- Passo 2 de kairos-validate-story.md: adicionado bloco — se ⚠️ ATENÇÃO estiver presente, verifica que **Criada por:** e **Data:** aparecem antes dele; caso contrário, ❌ FALHA; Invertida a prioridade de derivação de descrição no step 2.d: Execution Log agora é prioridade 1, git diff × manifest passou para prioridade 2

---

## [3.1.7] — 2026-04-17

### Corrigido
- kairos-pre-push.md, CHANGELOG.md, core-config.yaml: atualizado

---

## [3.1.6] — 2026-04-17

### Corrigido
- kairos-pre-push.md, CHANGELOG.md: atualizado

---

## [3.1.5] — 2026-04-17

### Corrigido
- Pre-push step 4: fallback de epoch_gate corrigido de 0 para 99999999999 — sentinel alto garante que prompt PATCH sempre aparece quando gate não foi commitado

---

## [3.1.4] — 2026-04-17

### Corrigido
- Pre-push step 4: comparação por timestamp de commit (epoch unix) para bump PATCH — substitui comparação por data-dia que causava falso positivo

---

## [3.1.3] — 2026-04-17

### Alterado

- Comando `*review-squad` renomeado para `*validate-squad` — alinha nomenclatura com `*validate-story`; prefixo `validate` é semanticamente correto para validação de artefato estático

---

## [3.1.2] — 2026-04-16

### Adicionado

- Transição para repo público + squad ops com push-dual dual-remote

---

## [3.1.1] — 2026-04-16

### Alterado

- Workers: listagem dinâmica de agentes na elicitação
- Pre-Push: prompt opcional de bump para stories PATCH

---

## [3.1.0] — 2026-04-16

### Adicionado

- `.kairos-core/docs/scope.md` — escopo e arquitetura do Kairos como framework (genérico, kairos-owned, L3); registrado no manifest
- `*architecture {squad}` — novo modo da task kairos-architecture.md: gera/atualiza `squads/{squad}/workflows/data-flow.md`, valida consistência (CONSISTENTE/DRIFT/INCOMPLETO)

### Alterado

- `kairos-architecture.md` — Passo 1 lê `.kairos-core/docs/scope.md` para stack do framework; Passo 4 usa descoberta dinâmica de agentes via `core-config.yaml` (sem hardcodes)
- `core-config.yaml` — `scopeFile` renomeado para `frameworkScopeFile`; nova chave `instanceScopeFile: docs/scope.md`
- `kairos-prd.md` — clarificado como gestão do escopo da instância; Pergunta 1 reframeada
- `docs/scope.md` — título atualizado para "Instância Kairos — Escopo e Objetivos da Instância"
- `kairos-help.md` e `kairos.md` — assinatura `*architecture [{squad}]` atualizada

---

## [3.0.1] — 2026-04-16

### Corrigido

- Aviso kairos-core: quebras de linha removidas do parágrafo na exibição em chat (`kairos.md` e `kairos-new-story.md`); templates de story intactos

---

## [3.0.0] — 2026-04-16

### Fundação — Extensão do Modelo de Autoridade

- `agent-authority.md` (L1): nova seção "Quem Implementa Instâncias" — @kairos formalizado como executor exclusivo de stories `type: instance` via `*implement`; Claude Code plain reservado para `type: kairos-core`; todo `src/` (tools e agents) declarado domínio de @kairos
- `story-lifecycle.md` (L3): nova seção "Executor por Tipo de Story" — clarifica os dois executores, seus modos de operação e assinatura do Execution Log
- Nova task `kairos-implement.md`: executor de stories `type: instance` — elicitação interativa, recusa explícita de `kairos-core`, Execution Log assinado "@kairos via *implement", campo `self_reviewed` no gate de `*review`
- `kairos-new-squad.md`: oferta inline de `*implement` após criação de story de scaffolding
- `kairos-workers.md`: oferta inline de `*implement` quando worker new gera story `type: instance`
- Persona `kairos.md`: comando `*implement [{story-id}]` adicionado (visibility: key); REQUEST-RESOLUTION, Guia e dependências atualizados
- `kairos-help.md`: `*implement` na Seção 2 (comandos); fluxos ④ e ⑤ atualizados; Seção 4 revisada ("@kairos não faz trabalho operacional dos squads, mas implementa instâncias"); Seção 5 e cheat sheet atualizados

---

## [2.3.0] — 2026-04-16

### Adicionado

- Campo `type: kairos-core | instance` no template de stories e em todas as stories existentes
- Comando `*update-squad {squad}`: rastreia edições de squad via story com `type: instance` e prefixo `update:`
- `*new-squad` auto-cria story de implementação (`type: instance`) ao final do scaffolding — sem necessidade de `*new-story` manual
- Aviso canônico para stories `type: kairos-core` em `@kairos`, `*new-story` e template
- `*new-story` elicita `type` com default `instance`; framing orientado a instâncias
- `*new-epic` com nota orientadora para instâncias e exemplos atualizados
- `*status` exibe prefixos `[core]` / `[instance]` nas stories

---

## [2.2.0] — 2026-04-16

### Adicionado

- Comando `*review-squad {squad}`: validação de coerência de squad instanciado — personas, tasks, pipeline e MEMORY

---

## [2.1.1] — 2026-04-16

### Mudado

- `*new-story` sem argumento: elicitação lista epics disponíveis e gera ID automático
- `kairos-new-story.md`: formato de saída alinhado ao `story-template.md`
- `kairos-help.md`: assinaturas, descrições e fluxos atualizados para `*new-story`, `*version` e `*pre-push`

---

## [2.1.0] — 2026-04-15

### Mudado

- `*pre-push` expandido como pré-voo completo: gate de review, versionamento interativo, commit e transição de story para Done

---

## [2.0.0] — 2026-04-15

**Breaking:** segregação operacional framework × usuário via manifesto de ownership. Updates futuros seguem contrato default-deny. Requer atenção em instalações existentes que carreguem customizações em arquivos agora framework-owned.

### Adicionado

**Manifesto de ownership (L1)**
- `.kairos-core/manifest.yaml` — fonte autoritativa do que é framework. Lista 37 `owned_files` com `layer` (L1/L2/L3) e `sha256`. Declara 4 `owned_sections` para arquivos mistos: blocos managed em `CLAUDE.md`, chaves `hooks` em `.claude/settings.json`, chaves `framework`/`runtime`/`versioning` em `.kairos-core/core-config.yaml`, categorias shipped em `.env.example`.
- `.claude/rules/ownership.md` — rule L1 com contrato operacional: default-deny, três fluxos de origem (oficial shipped / user-criado / brownfield pré-existente), regras para @kairos e executor ao modificar/criar/remover arquivos, contrato de arquivos mistos, casos de HALT.

**Constituição — Seção VI expandida**
- Princípio 24 (manifesto autoritativo) — nenhuma convenção de path ou frontmatter sobrepuja o manifesto
- Princípio 25 (contrato de update default-deny) — updates futuros não tocam em arquivos fora do manifesto
- Princípio 26 (três fluxos de origem) — (a) oficial shipped, (b) user-criado, (c) brownfield pré-existente

**Squad rules de cold-prospecting relocadas**
- `squads/cold-prospecting/rules/campaign-lifecycle.md` (ex-`.claude/rules/`)
- `squads/cold-prospecting/rules/memory-imports.md` (ex-`.claude/rules/agent-memory-imports.md`)
- `squads/cold-prospecting/rules/agent-authority.md` — matrizes dos agentes Clio/Lex/Nix/Eva (extraídas do `.claude/rules/agent-authority.md` original)
- `squads/cold-prospecting/data/workflow-chains.yaml` (ex-`.kairos-core/data/`)
- `squads/cold-prospecting/docs/data-flow.md` — fields do webhook, paths cold-prospecting, handoff example (extraídos de `docs/framework/data-flow.md`)
- `squads/cold-prospecting/docs/stories/1.1`, `1.2`, `2.1.story.md` (ex-`docs/stories/`)
- `squads/cold-prospecting/docs/epics/epic-1`, `epic-2`, `epic-4*.md` (ex-`docs/epics/`)

**Frontmatter `kairos-owned: true` + `kairos-version: 2.0.0`** em todos os 30+ markdown files do manifesto (marker de visibilidade — manifesto permanece autoritativo).

**Doctor checks de ownership**
- `.kairos-core/tasks/kairos-doctor.md` — novas checks 9 (integridade manifesto vs. filesystem + SHA drift + cross-check frontmatter) e 10 (validade de markers em arquivos mistos).

**Documentação de transição (instância, não framework)**
- `docs/public-repo-transition.md` — estratégia gitignore + branch para quando este repo virar o framework público `@kairos/core`. Não executa a transição, documenta o caminho. Classificado como **user/instance** (fora do manifesto): é metadado deste repo específico, não shipped em instalações futuras.

**CLAUDE.md**
- Novo bloco managed `<!-- KAIROS-MANAGED-START: framework-conventions -->` envolvendo o preamble (preamble + convenções). Seção "Restrições Operacionais" explicitamente user-owned.
- Nova seção "Squads ativos" user-owned com imports de `squads/cold-prospecting/rules/*` via sintaxe `@path`.

### Modificado

**Framework rules**
- `.claude/rules/agent-authority.md` — reduzido para conter apenas autoridade do @kairos + regras universais. Matrizes específicas de squad movidas para `squads/{squad}/rules/agent-authority.md`.
- `.claude/rules/framework-layers.md` — adicionado parágrafo autoritativo: classificação L1-L3 é declarada no manifesto, não por path. `ownership.md` incluído na tabela L1.

**Framework data despoluído**
- `.kairos-core/data/kairos-kb.md` — split: parte instância (webhook, tiers R$, verticais) removida; parte framework (decisões arquiteturais genéricas, YAML personas, naming, output paths, pipeline versioning) permanece.
- `.kairos-core/docs/data-flow.md` (ex-`docs/framework/data-flow.md`) — split: fields webhook + paths cold-prospecting removidos; shape de handoff + padrões de output permanecem.

**Docs framework relocados para `.kairos-core/docs/`**
- `docs/framework/agent-standards.md` → `.kairos-core/docs/agent-standards.md`
- `docs/framework/data-flow.md` → `.kairos-core/docs/data-flow.md`
- Diretório `docs/framework/` eliminado — regra operacional: **`docs/` é 100% user-owned, sem exceção**. Framework-owned markdown vive em `.kairos-core/`.
- Referências atualizadas em: `README.md`, `.kairos-core/core-config.yaml` (`devLoadAlwaysFiles`), `.claude/hooks/kairos-code-intel.cjs`, `.kairos-core/tasks/kairos-architecture.md`, `.kairos-core/tasks/kairos-help.md`, `.kairos-core/tasks/kairos-new-squad.md` (template de squad), `squads/cold-prospecting/{squad.yaml,README.md,docs/data-flow.md}`.

**Core config**
- `version: 1.3.1 → 2.0.0`, `updatedAt: 2026-04-15`
- `devLoadAlwaysFiles` aponta para `.kairos-core/docs/` (antes `docs/framework/`)

### Removido

- `.claude/rules/campaign-lifecycle.md` — movido para `squads/cold-prospecting/rules/`
- `.claude/rules/agent-memory-imports.md` — movido para `squads/cold-prospecting/rules/memory-imports.md`
- `.kairos-core/data/workflow-chains.yaml` — movido para `squads/cold-prospecting/data/`
- `docs/stories/{1.1,1.2,2.1}.story.md` — movidos para `squads/cold-prospecting/docs/stories/`
- `docs/epics/epic-{1,2,4}-*.md` — movidos para `squads/cold-prospecting/docs/epics/`

### Migração para instalações existentes

Este bump não tem migração automática — é breaking por design. Ao aplicar manualmente:

1. Rodar `@kairos *doctor` para identificar arquivos framework com drift (modificações locais)
2. Resolver drifts caso-a-caso: (a) é customização legítima do usuário → mover para arquivo user-owned; (b) é fix do framework → contribuir upstream via story
3. Arquivos user-criados **nunca** precisam ação — manifesto default-deny já os protege

---

## [1.3.1] — 2026-04-14

### Adicionado

- `.kairos-core/constitution.md` — **Seção VI: Fronteira Framework / Usuário** (princípios 18–23, L1): codifica a distinção entre infraestrutura do framework (`.kairos-core/`, rules, tasks, hooks) e artefatos do usuário (squads, agents, skills, integrações); proíbe que revisões futuras recategorizem conteúdo do usuário como conteúdo de framework

### Modificado

**Despersonalização dos docs de framework**
- `README.md` — referências pessoais removidas; "Squad ativo: cold-prospecting" → "Como funciona" (exemplo genérico); "Como rodar um agente" generalizado (`{nome-do-agente}.ts`); "Pipeline completo" → "Pipeline de squad (exemplo)" com cold-prospecting rotulado explicitamente; estrutura do repositório sem filenames específicos de squad, `{squad}/` genérico, skills descritas como "configuradas pelo usuário/equipe"
- `CLAUDE.md` — referências pessoais removidas; agentes de squad rotulados como "exemplo dos squads ativos neste projeto"; pipeline e diagrama de governança genéricos (`squads/*`); seção "Restrições Operacionais" agora espaço configurável pelo usuário com exemplos genéricos
- `.claude/rules/external-integrations.md` — tabela de skills dividida em nativas (sempre disponíveis) vs. de projeto (configuradas pelo usuário/equipe); exemplos rotulados como "stack Supabase/GitHub — não específicos do Kairos"
- `.kairos-core/constitution.md` — Seção I reescrita como princípio positivo sobre como usar ferramentas externas, sem menção a squads específicos
- `.env.example` — reescrito com 7 categorias abrangentes (AI Providers, Automation, Database, Communication, Search, Version Control, Squad-specific); todos opcionais exceto `ANTHROPIC_API_KEY` _(corrigido em v3.6.2: a chave é opcional — necessária apenas se scripts da instância fazem chamadas diretas via @anthropic-ai/sdk)_; exemplo de squad-specific comentado no final

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
