# Transição para Repo Público — Estratégia

> **Escopo:** este documento é metadado **deste repo específico** — não faz parte do framework shipped. Descreve a decisão arquitetural e o processo one-time para transformar este monorepo no repo público `@kairos/core`. Instalações novas do Kairos (via `npx install kairos` no futuro) não precisam deste documento porque já chegam separadas.

## Contexto

Este repo Kairos é hoje um monorepo híbrido: contém o **framework** (hooks, commands, rules, tasks, templates, constituição) e **conteúdo de instância** (squad `cold-prospecting`, agentes TypeScript específicos, memórias, outputs). A visão de longo prazo é tornar este repo o **framework público** — `@kairos/core` no npm, instalável via `npx install kairos` — enquanto a instância privada deste projeto continua operando sem interrupção.

Este documento registra a estratégia acordada para viabilizar essa transição sem perda de histórico nem contaminação cruzada.

---

## O que já está resolvido (Story 5.1)

- **Manifesto de ownership** (`.kairos-core/manifest.yaml`) é a fonte autoritativa do que é framework
- **Default-deny**: qualquer arquivo fora do manifesto é user-content
- **Princípios 24–26** na constituição impedem regressão
- **Relocações** já consolidaram poluição cruzada em `squads/cold-prospecting/`

Com isso, o repo já está **logicamente particionado**. A transição física para repo público é a próxima camada.

---

## Estratégia escolhida: Gitignore + Overlay privado

**Padrão:** o repo `main` é framework puro (público). O conteúdo de instância fica listado em `.gitignore.public` e vive em uma branch privada ou em arquivos untracked localmente.

**Por que essa abordagem:**
- Preserva o histórico git completo do desenvolvimento do framework
- Evita fork/split que obrigaria manter dois repos paralelos
- Updates ao framework seguem o fluxo natural de commits em `main`
- Instância consome updates via merge/rebase da `main` na branch privada

---

## Inventário: o que vira público vs. privado

### Público (framework)

Tudo listado em `.kairos-core/manifest.yaml`:
- `.kairos-core/constitution.md`, `manifest.yaml`, tasks `kairos-*.md`, templates, `data/workers.yaml`
- `.claude/commands/kairos/agents/kairos.md` (persona única framework)
- `.claude/hooks/kairos-*.cjs`
- `.claude/rules/*` (todas — L1 e L3 framework)
- `src/tools/claude.ts`
- `.kairos-core/docs/agent-standards.md`, `.kairos-core/docs/data-flow.md`
- Seções managed de `CLAUDE.md`, `core-config.yaml`, `settings.json`, `.env.example`

### Privado (instância)

Tudo que **não** está no manifesto, incluindo:
- `squads/cold-prospecting/` (squad completo com rules, data, docs, agents)
- `src/agents/*.ts` (agentes específicos da campanha)
- `.kairos-core/agents/*/MEMORY.md` (memórias persistentes)
- `data/outputs/` (artefatos gerados)
- `.env`, `.claude/settings.local.json`
- `.claude/commands/kairos/agents/{campaign-analyst,lead-scorer,niche-classifier,email-writer}.md`
- `docs/stories/`, `docs/epics/` (metadados do desenvolvimento do Kairos neste repo — não são shipped)
- `docs/qa/gates/`, `docs/scope.md`
- `.kairos-core/runtime/` (handoffs e logs — já gitignored)
- `package.json`, `package-lock.json`, `tsconfig.json`, `.mcp.json`, `.gitignore`, `README.md`, `CHANGELOG.md` (metadados da instância)

---

## Mecânica: `.gitignore.public`

Ao virar repo público, aplicar:

```gitignore
# Instance-specific content — not shipped as framework
squads/
!squads/.gitkeep

src/agents/*.ts
!src/agents/.gitkeep

.kairos-core/agents/
!.kairos-core/agents/.gitkeep

.kairos-core/runtime/

data/outputs/
!data/outputs/.gitkeep

.env
.claude/settings.local.json

# Squad personas (geradas pelo squad owner, não shipped)
.claude/commands/kairos/agents/*.md
!.claude/commands/kairos/agents/kairos.md

# Project metadata (instance-owned)
docs/stories/
docs/epics/
docs/qa/
docs/scope.md
```

**Nota:** `package.json`, `CHANGELOG.md` e `README.md` ficam versionados no repo público — mas são **templates/metadados da release do framework**, não metadados desta instância. A instância privada sobrescreve ou estende via branch.

---

## Estratégia de branches

```
main                  — framework puro, público
  ↓ merge
filipe-instance       — branch privada com todo o conteúdo de instância
```

**Fluxo operacional:**

1. Mudanças no framework são commitadas em `main`
2. `filipe-instance` rebate ou rebasa regularmente de `main` para consumir updates
3. Mudanças em squad/agents/memória ficam apenas em `filipe-instance`
4. `main` **nunca** recebe merge de `filipe-instance` — flow unidirecional

**Política de push:**
- `main` vira público quando limpo → aplicar `.gitignore.public` e `git push` para o remote público
- `filipe-instance` fica em remote privado separado (ou sem remote, só local)

---

## Alternativa considerada (e descartada)

**Fork com repos separados**: manter `kairos-core` (público) e `kairos-filipe` (privado) como repos distintos, sincronizando via git subtree ou submódulo.

**Por que descartada:**
- Dobra o custo de manutenção (dois repos, dois CIs, dois sets de dependências)
- Histórico git fica fragmentado
- Divergência inevitável ao longo do tempo

**Quando reconsiderar:** se o framework crescer ao ponto de ter CI/CD, releases versionadas no npm, e ciclo de release independente da instância — aí vale separar.

---

## Checklist para quando a transição for executada

Esta story (5.1) **não** executa a transição — apenas documenta. Quando executar:

- [ ] Criar branch `filipe-instance` a partir de `main` atual
- [ ] Commitar `.gitignore.public` → `.gitignore` em `main`
- [ ] Remover do tracked tree (`git rm --cached`) todos os paths listados acima
- [ ] Verificar com `git status --ignored` que o conteúdo listado está ignorado
- [ ] Criar remote público (ex: `github.com/kairos-framework/core`)
- [ ] `git push public main`
- [ ] Configurar branch protection em `main` do remote público
- [ ] Documentar em `README.md` o fluxo greenfield/brownfield para consumidores

---

## Dependências futuras

- **Story 5.2** — CLI `npx install kairos` / `npx kairos update` (consome manifesto)
- **Story 5.3** — Publicação de `@kairos/core` no npm (release pipeline)
- **Story 5.4** — Squad-scaffolding dinâmico (gerar personas a partir de `squads/{squad}/agents/*.yaml`)

A transição para repo público é pré-requisito das stories 5.2+ ou pode acontecer em paralelo — o manifesto já é suficiente para que o CLI identifique o que atualizar.
