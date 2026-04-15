---
kairos-owned: true
kairos-version: 2.0.0
task: Kairos Architecture
responsavel: "@kairos"
responsavel_type: agent
atomic_layer: documentation
elicit: false
Entrada: |
  - focus: área específica a checar (opcional)
    Valores: "stack" | "data-flow" | "agents" | "tasks" | "decisions" | "all" (padrão: "all")
Saida: |
  - relatório de estado arquitetural com checks ✅/⚠️/❌
  - .kairos-core/docs/data-flow.md atualizado (se divergências encontradas)
  - sugestões de decisões a registrar (se ADRs ausentes)
Checklist:
  - "[ ] Verificar consistência da stack (package.json vs docs)"
  - "[ ] Verificar consistência de agentes (core-config vs arquivos)"
  - "[ ] Verificar consistência de tasks (agentes vs arquivos de task)"
  - "[ ] Verificar data-flow: campos do webhook vs código TypeScript"
  - "[ ] Verificar referências cruzadas em .kairos-core/docs/"
  - "[ ] Exibir relatório com checks marcados"
  - "[ ] Listar divergências e sugestões de atualização"
---

# *architecture — Auditoria Arquitetural do Kairos

Esta task inspeciona a consistência entre o que está documentado e o que está implementado.
É a responsável por manter `.kairos-core/docs/data-flow.md` e `.kairos-core/docs/agent-standards.md` em dia.

---

## Execução

### Passo 1 — Verificar Stack

Leia:
- `package.json` (dependências reais)
- `docs/scope.md` (stack declarada)
- `CLAUDE.md` (stack na seção principal)
- `.kairos-core/core-config.yaml` (agentes declarados)

Verifique cada item:

| Check | Como checar |
|-------|-------------|
| Runtime Node.js + ESM | `package.json` tem `"type": "module"`? |
| TypeScript + tsx | `@anthropic-ai/sdk` e `tsx` estão em dependencies/devDependencies? |
| Modelo declarado | Buscar `claude-sonnet-4-6` ou equivalente nos arquivos de agente e tools |
| Versão do SDK | `@anthropic-ai/sdk` em package.json — está recente? |
| Modelo nos docs vs código | `src/tools/claude.ts` declara o mesmo modelo mencionado nos docs? |

Marcar: ✅ consistente / ⚠️ desatualizado / ❌ divergente

---

### Passo 2 — Verificar Consistência de Agentes

Leia `.kairos-core/core-config.yaml`. Para cada agente em `agents.squads.{squad}.agents`:

| Check | Como checar |
|-------|-------------|
| Persona existe | `.claude/commands/kairos/agents/{id}.md` existe? |
| Definição no squad existe | `squads/{squad}/agents/{id}.md` existe? |
| MEMORY.md existe | `.kairos-core/agents/{id}/MEMORY.md` existe? |
| Script TypeScript existe | `src/agents/{id}.ts` existe? |
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

Leia `.kairos-core/docs/data-flow.md` e compare com o código:

**Campos do webhook:**
- Ler `.kairos-core/docs/data-flow.md` seção "Campos do Lead"
- Ler `src/agents/campaign-analyst.ts` (ou equivalente) — quais campos são lidos?
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
- Por que n8n para disparo (não direto pela API)?
- Por que tsx sem compilação?
- Por que ESM ao invés de CommonJS?
- Por que agentes como personas YAML-in-Markdown?

Para cada decisão-chave ausente → listar como sugestão de registro.

---

### Passo 7 — Exibir Relatório

```
🏗️ AUDITORIA ARQUITETURAL — Kairos v{versão}
Data: {hoje}

━━━ STACK ━━━
  {✅/⚠️/❌} Runtime ESM: {nota}
  {✅/⚠️/❌} TypeScript + tsx: {nota}
  {✅/⚠️/❌} Modelo AI: {nota}
  {✅/⚠️/❌} Consistência docs vs código: {nota}

━━━ AGENTES ━━━
  {para cada squad ativo}:
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

## Atualização do data-flow.md

Se divergências de data-flow forem encontradas (⚠️ ou ❌), `@kairos` pode:

1. Exibir diff proposto ao usuário
2. Aguardar confirmação: "Posso atualizar .kairos-core/docs/data-flow.md com estas correções?"
3. Após confirmação → atualizar o arquivo
4. Registrar no Change Log do data-flow.md (se o arquivo tiver um)

**Nunca atualizar automaticamente sem confirmação explícita** — mudanças em .kairos-core/docs/ são estruturais.
