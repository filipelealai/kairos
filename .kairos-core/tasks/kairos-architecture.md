---
kairos-owned: true
kairos-version: 3.10.0
task: Kairos Architecture
responsavel: "@kairos"
responsavel_type: agent
atomic_layer: documentation
elicit: false
Entrada: |
  - argument: squad slug (opcional)
    Se omitido: auditoria geral do framework
    Se fornecido: modo squad — data-flow do squad especificado
  - focus: área específica a checar (opcional — somente no modo framework)
    Valores: "stack" | "data-flow" | "agents" | "tasks" | "decisions" | "all" (padrão: "all")
Saida: |
  - Modo framework: relatório de estado arquitetural com checks ✅/⚠️/❌
  - Modo squad: squads/{squad}/workflows/data-flow.md criado ou atualizado
  - .kairos-core/docs/data-flow.md atualizado (se divergências encontradas, modo framework)
  - .kairos-core/docs/agent-standards.md atualizado (se divergências encontradas, modo framework)
  - sugestões de decisões a registrar (se ADRs ausentes)
Checklist:
  - "[ ] Detectar modo: com ou sem argumento {squad}"
  - "[ ] Modo framework: verificar stack (via docs/scope.md), agentes, tasks, data-flow, agent-standards, referências, decisões"
  - "[ ] Modo squad: verificar existência do squad, gerar/atualizar data-flow.md"
  - "[ ] Exibir relatório com checks marcados"
  - "[ ] Listar divergências e sugestões de atualização"
---

# *architecture — Auditoria Arquitetural do Kairos

Esta task opera em dois modos:

- **Sem argumento:** `*architecture` — auditoria geral do framework
- **Com argumento:** `*architecture {squad}` — data-flow do squad especificado

---

## Pré-passo — Detectar Modo

```
Se chamado como *architecture {squad}:
  → Ir para a seção "Modo Squad" abaixo

Se chamado como *architecture (sem argumento):
  → Executar a auditoria framework completa (Passos 1–7)
```

---

## Modo Framework — Auditoria Geral

> **Descoberta de stack sem hardcodes:** toda informação de runtime, linguagem e SDK é lida
> de `docs/scope.md` seção Stack. Se a seção não existir, os checks de stack são limitados
> sem assumir nenhum default de runtime ou linguagem. Scripts de agentes são descobertos via
> `dependencies.scripts` na persona ou `squads/{squad}/squad.yaml` — nunca por path fixo.
>
> **Agent-standards simétrico ao data-flow:** `.kairos-core/docs/agent-standards.md` recebe
> os mesmos checks aplicados a `data-flow.md` — comparação docs vs implementação, diff
> proposto e confirmação explícita antes de atualizar.

### Passo 1 — Verificar Stack

**Lógica de descoberta (sem hardcodes):**

1. Ler `docs/scope.md` seção Stack — fonte autoritativa de runtime, linguagem, SDK e modelo.
2. Se `docs/scope.md` não existir ou não tiver seção Stack:
   ```
   ⚠️ AVISO: docs/scope.md não tem seção Stack declarada.
      Checks de stack serão limitados — sem assumir runtime, linguagem ou dependências.
      Para checks completos, declare a stack em docs/scope.md via *prd.
   ```
   Prosseguir apenas com o check do núcleo do framework.
3. Se seção Stack presente: extrair `Runtime`, `AI` (SDK + modelo) e ferramentas declaradas.

Leia também:
- `.kairos-core/docs/scope.md` (stack declarada do framework)
- `.kairos-core/core-config.yaml` (agentes declarados)

Verifique cada item com base no que está declarado em `docs/scope.md`:

| Check | Como checar |
|-------|-------------|
| Núcleo do framework (markdown + YAML + CJS) | `.claude/hooks/` tem arquivos `.cjs`? `.kairos-core/` existe? |
| Runtime da instância | Declarado em `docs/scope.md` seção Stack → verificar se arquivo de dependências correspondente existe (ex: `package.json` para Node.js, `requirements.txt` para Python). Se runtime não declarado → ⚠️ "Runtime não declarado em docs/scope.md" |
| Modelo AI (se instância usa AI) | Declarado em `docs/scope.md` seção Stack → buscar o modelo declarado nos scripts e tools da instância |
| Consistência docs vs código | Se SDK AI declarado em scope.md → verificar se script client equivalente existe; se não declarado → ⚠️ "SDK não declarado em docs/scope.md" |

Marcar: ✅ consistente / ⚠️ desatualizado ou não declarado / ❌ divergente

---

### Passo 2 — Verificar Consistência de Agentes

Leia `.kairos-core/core-config.yaml`. Para cada agente em `agents.squads.{squad}.agents`:

| Check | Como checar |
|-------|-------------|
| Persona existe | `.claude/commands/kairos/agents/{id}.md` existe? |
| Definição no squad existe | `squads/{squad}/agents/{id}.md` existe? |
| MEMORY.md existe | `.kairos-core/agents/{id}/MEMORY.md` existe? |
| Script do agente existe | Ler campo `dependencies.scripts` na persona do agente; se declarado → verificar existência de cada path. Se não declarado → ⚠️ "Scripts não declarados no escopo" |
| `id` no YAML da persona bate | Campo `agent.id` no persona file bate com o nome do arquivo? |

Marcar cada agente: ✅ completo / ⚠️ artefato faltando / ❌ não encontrado

---

### Passo 3 — Verificar Consistência de Tasks

Para cada agente ativo, ler o arquivo de persona e verificar `dependencies.tasks`.
Para cada task listada:

| Check | Como checar |
|-------|-------------|
| Arquivo existe | `.kairos-core/tasks/{task}.md` existe? |
| Task tem frontmatter válido | Campos `task`, `responsavel`, `elicit` presentes? |
| Task referenciada em `commands` | Se um command tem `task:`, o arquivo existe? |

Para `@kairos` especificamente, verificar as tasks de governança:
```
kairos-status.md, kairos-review.md, kairos-validate-story.md,
kairos-pre-push.md, kairos-push.md, kairos-version-bump.md,
kairos-new-story.md, kairos-new-squad.md, kairos-new-epic.md,
kairos-prd.md, kairos-architecture.md
```

Marcar: ✅ presente e válida / ⚠️ frontmatter incompleto / ❌ ausente

---

### Passo 4 — Verificar Data Flow

Leia `.kairos-core/docs/data-flow.md` e compare com o código.

**Descoberta dinâmica dos agentes:**
Leia `core-config.yaml → agents.squads` para obter a lista de squads e agentes ativos.
Para cada squad ativo e seus agentes, encontrar o script correspondente via `dependencies.scripts` na persona do agente.

**Inputs/campos declarados no data-flow.md (para cada agente com script):**

> Esta verificação não assume mecanismo de transporte (webhook, API, arquivo, planilha). Os
> inputs/campos relevantes são os que o próprio `data-flow.md` da instância declara — seja qual
> for a seção em que estão documentados.

- Ler `.kairos-core/docs/data-flow.md` — identificar a seção de inputs/campos declarada no documento
- Ler o script correspondente — quais campos são lidos/usados?
- Se campo usado no código mas não documentado → ⚠️ "Campo não documentado: {campo}"
- Se campo documentado mas nunca usado no código → ⚠️ "Campo documentado mas sem uso encontrado: {campo}"

**Outputs dos agentes:**
- Verificar se os formatos de output documentados batem com o que o código gera
- `data/outputs/{squad}/reports/` — verificar padrão de nomenclatura
- Outputs adicionais: descobertos a partir do que está declarado no `data-flow.md` ou `squad.yaml` — nenhum subdiretório é assumido por default

**Handoff format:**
- Verificar se `.kairos-core/runtime/handoffs/` existe (runtime, pode não ter arquivos)
- Verificar se `squads/{squad}/data/workflow-chains.yaml` existe e está consistente (quando o squad define chains)

Marcar cada item: ✅ consistente / ⚠️ possível divergência / ❌ divergência confirmada

---

### Passo 4.5 — Verificar Agent Standards

Leia `.kairos-core/docs/agent-standards.md` e compare com as personas existentes em `.claude/commands/kairos/agents/`.

**Descoberta de agentes:** ler `core-config.yaml → agents.squads` para lista de agentes ativos.

Para cada agente ativo, verificar:

| Check | Como checar |
|-------|-------------|
| Formato da persona | Persona tem os campos obrigatórios: `activation-instructions`, `agent`, `persona_profile`, `persona`, `core_principles`, `commands`, `{id}-task`, `dependencies`, `autoClaude`? |
| Greeting em 6 steps | Persona inclui Step 5.5 (handoff check no greeting)? |
| `blocking` e `completion` declarados | `{id}-task.blocking` e `{id}-task.completion` presentes na persona? |
| Definição no squad | `squads/{squad}/agents/{id}.md` existe e tem campos obrigatórios (`agent`, `commands_key`, `outputs`, `handoff_to`)? |
| MEMORY.md | `.kairos-core/agents/{id}/MEMORY.md` existe e tem seções `Active Patterns`, `Gotchas Técnicos`, `Promotion Candidates`, `Archived`? |
| Nomenclatura | ID em kebab-case? Nome da persona em PascalCase? Arquivo de task em kebab-case? |

Para cada divergência entre as personas reais e o padrão documentado:
- ⚠️ "Campo ausente: {campo} em {persona}"
- ❌ "Formato incorreto: {item} em {persona}"

Marcar cada check: ✅ conforme / ⚠️ parcial / ❌ não conforme

---

### Passo 5 — Verificar Referências em .kairos-core/docs/

Para cada arquivo em `.kairos-core/docs/`:
- Links internos (`[texto](../...)`) apontam para arquivos que existem?
- Caminhos de arquivo mencionados no texto existem no repo?
- Agentes mencionados existem em `.claude/commands/kairos/agents/`?

Marcar: ✅ OK / ⚠️ referência não verificável / ❌ referência quebrada

---

### Passo 6 — Verificar Decisões Arquiteturais (ADRs lightweight)

Verificar se existe `.kairos-core/docs/decisions.md` (ADR log):
- Se não existe → ⚠️ "Nenhum log de decisões arquiteturais encontrado"
- Se existe → verificar se decisões-chave estão registradas

Decisões-chave esperadas para o estado atual do Kairos:
- Por que agentes como personas YAML-in-Markdown?
- Por que `.kairos-core/` em vez de `.kairos/`?
- Por que manifesto de ownership em vez de convenção por path?

Para cada decisão-chave ausente → listar como sugestão de registro.

---

### Passo 7 — Exibir Relatório

```
🏗️ AUDITORIA ARQUITETURAL — Kairos v{versão}
Data: {hoje}

━━━ STACK ━━━
  {✅/⚠️/❌} Núcleo framework (markdown + YAML + CJS): {nota}
  {✅/⚠️/❌} Runtime de scripts da instância: {nota}
  {✅/⚠️/❌} Modelo AI (se aplicável): {nota}
  {✅/⚠️/❌} Consistência docs vs código: {nota}

━━━ AGENTES ━━━
  {para cada squad ativo — lido dinamicamente de core-config.yaml}:
    {✅/⚠️/❌} {agente}: {nota}
    ...
  {✅/⚠️/❌} kairos: {nota}

━━━ TASKS DE GOVERNANÇA ━━━
  {✅/⚠️/❌} {task}: {nota}
  ...

━━━ DATA FLOW ━━━
  {✅/⚠️/❌} Inputs/campos documentados no data-flow: {nota}
  {✅/⚠️/❌} Outputs dos agentes: {nota}
  {✅/⚠️/❌} Handoff format: {nota}
  {✅/⚠️/❌} workflow-chains.yaml: {nota}

━━━ AGENT STANDARDS ━━━
  {✅/⚠️/❌} Formato das personas: {nota}
  {✅/⚠️/❌} Definições no squad: {nota}
  {✅/⚠️/❌} MEMORY.md dos agentes: {nota}
  {✅/⚠️/❌} Nomenclatura: {nota}

━━━ REFERÊNCIAS ━━━
  {✅/⚠️/❌} .kairos-core/docs/: {nota}
  {✅/⚠️/❌} Links internos: {nota}

━━━ DECISÕES ━━━
  {✅/⚠️} ADR log: {nota}
  Decisões sugeridas para registro: {lista ou "nenhuma"}
```

**Seção de ações recomendadas (somente se houver ⚠️ ou ❌):**

```
━━━ AÇÕES RECOMENDADAS ━━━
  ❌ {item crítico} — {ação}
  ⚠️ {item com ressalva} — {sugestão}
```

**Se tudo ✅:**
```
━━━ RESULTADO ━━━
✅ Arquitetura consistente — nenhuma divergência crítica encontrada.
```

---

### Atualização do data-flow.md

Se divergências de data-flow forem encontradas (⚠️ ou ❌), `@kairos` pode:

1. Exibir diff proposto ao usuário
2. Aguardar confirmação: "Posso atualizar .kairos-core/docs/data-flow.md com estas correções?"
3. Após confirmação → atualizar o arquivo
4. Registrar no Change Log do data-flow.md (se o arquivo tiver um)

**Nunca atualizar automaticamente sem confirmação explícita** — mudanças em .kairos-core/docs/ são estruturais.

---

### Atualização do agent-standards.md

Se divergências de agent-standards forem encontradas (⚠️ ou ❌), `@kairos` pode:

1. Exibir diff proposto ao usuário
2. Aguardar confirmação: "Posso atualizar .kairos-core/docs/agent-standards.md com estas correções?"
3. Após confirmação → atualizar o arquivo
4. Registrar no Change Log do agent-standards.md (se o arquivo tiver um)

**Nunca atualizar automaticamente sem confirmação explícita** — mudanças em .kairos-core/docs/ são estruturais.

---

## Modo Squad — *architecture {squad}

### Pré-verificação

1. Verificar se `squads/{squad}/` existe.
2. Se não existe → **HALT**:
   ```
   ❌ Squad "{squad}" não encontrado.

   Squads disponíveis (de core-config.yaml):
     - {squad-1}
     - {squad-2}
     ...

   Use *architecture {squad-existente} ou *new-squad para criar um novo squad.
   ```
3. Ler `squads/{squad}/squad.yaml` para obter: agentes, pipeline, dados, integrações externas.

---

### Passo M1 — Descobrir Agentes e Scripts

Ler `squads/{squad}/squad.yaml` (campo `agents`).
Para cada agente:

| Item | Onde encontrar |
|------|----------------|
| Persona | `.claude/commands/kairos/agents/{id}.md` |
| Script | `src/agents/{id}.*` (ou equivalente na linguagem da instância) |
| MEMORY.md | `.kairos-core/agents/{id}/MEMORY.md` |

Verificar existência de cada artefato. Marcar: ✅ existe / ⚠️ ausente.

---

### Passo M2 — Montar o Data Flow do Squad

Construir o diagrama de fluxo com base em:
1. **Inputs:** qual fonte de dados alimenta o squad? (webhook, planilha, arquivo, API)
2. **Pipeline:** para cada agente em ordem de execução:
   - Comando principal (`*{comando}`)
   - Dados consumidos (de onde lê)
   - Output gerado (o que cria, em qual formato, em qual path)
   - Handoff gerado (para quem)
3. **Outputs finais:** onde os dados saem do Kairos (ex: `{formato}` para `{sistema externo}`, CSV para planilha)
4. **Integrações externas:** sistemas externos que o squad aciona ou consome

---

### Passo M3 — Validar Consistência

Verificar:

| Check | O que checar |
|-------|--------------|
| Agentes em squad.yaml têm script | Campo `dependencies.scripts` na persona de cada agente — verificar existência dos paths declarados; se não declarado → ⚠️ "Scripts não declarados no escopo" |
| Agentes em squad.yaml têm persona | `.claude/commands/kairos/agents/{id}.md` existe? |
| Pipeline documentado | `squads/{squad}/workflows/` tem pelo menos um arquivo de pipeline? |
| Data-flow cobre todos os agentes | Cada agente do squad aparece no data-flow? |
| Outputs documentados batem com paths reais | Paths declarados no pipeline existem ou são coerentes com `core-config.yaml`? |

Resultado: **CONSISTENTE** / **DRIFT** / **INCOMPLETO**

- **CONSISTENTE:** todos os checks ✅
- **DRIFT:** agentes declarados mas sem script ou persona (⚠️)
- **INCOMPLETO:** pipeline não documentado, data-flow ausente, ou outputs sem path definido (⚠️/❌)

---

### Passo M4 — Criar ou Atualizar squads/{squad}/workflows/data-flow.md

Se o arquivo não existir → criar.
Se já existir → propor atualização ao usuário antes de sobrescrever.

**Formato canônico do data-flow.md de squad:**

```markdown
# Data Flow — {Squad Name}

**Squad:** {slug}
**Atualizado em:** {YYYY-MM-DD}
**Resultado da validação:** CONSISTENTE | DRIFT | INCOMPLETO

---

## Fonte de Dados

{descrição da fonte: webhook, planilha, arquivo, API — URL/path se conhecido}

---

## Pipeline

### Etapa 1 — {Agente} ({persona})

**Comando:** `*{comando}`
**Consome:** {o que lê — path, campos, formato}
**Produz:** `{path/output}` — {formato, schema resumido}
**Handoff:** → {próximo agente} via `handoff-{from}-to-{to}-{ts}.yaml`

### Etapa N — {Agente} ({persona})
...

---

## Outputs Finais

| Output | Path | Formato | Consumidor |
|--------|------|---------|------------|
| {nome} | `{path}` | {JSON/CSV/MD} | {quem consome} |

---

## Integrações Externas

| Sistema | Papel | Como aciona |
|---------|-------|-------------|
| {sistema} | {input/output} | {webhook/API/MCP} |

---

## Divergências Encontradas

{lista de ⚠️/❌ encontrados na validação, ou "Nenhuma"}
```

---

### Passo M5 — Exibir Resultado

```
🏗️ *architecture {squad} — Data Flow do Squad
Data: {hoje}

━━━ VALIDAÇÃO ━━━
  {✅/⚠️/❌} Agentes com script: {nota}
  {✅/⚠️/❌} Agentes com persona: {nota}
  {✅/⚠️/❌} Pipeline documentado: {nota}
  {✅/⚠️/❌} Outputs com path definido: {nota}

Resultado: {CONSISTENTE | DRIFT | INCOMPLETO}

━━━ AÇÃO ━━━
  squads/{squad}/workflows/data-flow.md {criado | atualizado | já consistente}
```

Se DRIFT ou INCOMPLETO → listar divergências e sugestões de correção.
