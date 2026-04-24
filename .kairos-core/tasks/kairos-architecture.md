---
kairos-owned: true
kairos-version: 3.7.0
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
  - sugestões de decisões a registrar (se ADRs ausentes)
Checklist:
  - "[ ] Detectar modo: com ou sem argumento {squad}"
  - "[ ] Modo framework: verificar stack, agentes, tasks, data-flow, referências, decisões"
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

### Passo 1 — Verificar Stack

Leia:
- `package.json` (dependências reais)
- `.kairos-core/docs/scope.md` (stack declarada do framework)
- `docs/scope.md` (escopo da instância — para contexto de squads e integrações ativas)
- `CLAUDE.md` (stack na seção principal)
- `.kairos-core/core-config.yaml` (agentes declarados)

Verifique cada item:

| Check | Como checar |
|-------|-------------|
| Núcleo do framework (markdown + YAML + CJS) | `.claude/hooks/` tem arquivos `.cjs`? `.kairos-core/` existe? |
| Runtime de scripts da instância | `package.json` existe? Se sim, verificar `"type"` e dependências declaradas. Se não, verificar se há outro runtime (ex: `requirements.txt`, `pyproject.toml`) |
| Modelo declarado (se instância usa AI) | Buscar `claude-sonnet-4-6` ou equivalente nos arquivos de agente e tools/scripts |
| Versão do SDK (se instância usa SDK Anthropic) | `@anthropic-ai/sdk` em `package.json` — está recente? |
| Modelo nos docs vs código (se aplicável) | `src/tools/claude.ts` (ou equivalente) declara o mesmo modelo mencionado em `.kairos-core/docs/scope.md`? |

Marcar: ✅ consistente / ⚠️ desatualizado / ❌ divergente

---

### Passo 2 — Verificar Consistência de Agentes

Leia `.kairos-core/core-config.yaml`. Para cada agente em `agents.squads.{squad}.agents`:

| Check | Como checar |
|-------|-------------|
| Persona existe | `.claude/commands/kairos/agents/{id}.md` existe? |
| Definição no squad existe | `squads/{squad}/agents/{id}.md` existe? |
| MEMORY.md existe | `.kairos-core/agents/{id}/MEMORY.md` existe? |
| Script do agente existe | `src/agents/{id}.*` existe (ou equivalente na linguagem da instância)? |
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
Para cada squad ativo e seus agentes, encontrar o script correspondente em `src/agents/{id}.{ext}`.

**Campos do webhook (para cada agente com script):**
- Ler `.kairos-core/docs/data-flow.md` seção "Campos do Lead" (ou equivalente)
- Ler o script correspondente — quais campos são lidos/usados?
- Se campo usado no código mas não documentado → ⚠️ "Campo não documentado: {campo}"
- Se campo documentado mas nunca usado no código → ⚠️ "Campo documentado mas sem uso encontrado: {campo}"

**Outputs dos agentes:**
- Verificar se os formatos de output documentados batem com o que o código gera
- `data/outputs/{squad}/reports/` — verificar padrão de nomenclatura
- `data/outputs/{squad}/emails/` (quando aplicável) — verificar schema do JSON

**Handoff format:**
- Verificar se `.kairos-core/runtime/handoffs/` existe (runtime, pode não ter arquivos)
- Verificar se `squads/{squad}/data/workflow-chains.yaml` existe e está consistente (quando o squad define chains)

Marcar cada item: ✅ consistente / ⚠️ possível divergência / ❌ divergência confirmada

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
- (Se instância usa TypeScript) Por que tsx sem compilação? Por que ESM?
- (Se instância usa n8n) Por que n8n para disparo e não direto pela API?

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
  {✅/⚠️/❌} Campos do webhook documentados: {nota}
  {✅/⚠️/❌} Outputs dos agentes: {nota}
  {✅/⚠️/❌} Handoff format: {nota}
  {✅/⚠️/❌} workflow-chains.yaml: {nota}

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
3. **Outputs finais:** onde os dados saem do Kairos (ex: JSON para n8n, CSV para planilha)
4. **Integrações externas:** sistemas externos que o squad aciona ou consome

---

### Passo M3 — Validar Consistência

Verificar:

| Check | O que checar |
|-------|--------------|
| Agentes em squad.yaml têm script | `src/agents/{id}.*` existe para cada agente declarado? |
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
