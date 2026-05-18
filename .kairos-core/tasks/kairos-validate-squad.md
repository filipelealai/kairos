---
kairos-owned: true
kairos-version: 5.0.0
id: kairos-validate-squad
title: Validação de Coerência de Squad
agent: kairos
command: "*validate-squad {squad}"
version: 1
---

# Task: kairos-validate-squad

## Propósito

Validar se a configuração de um squad instanciado é coerente e completa: personas declaradas existem, tasks referenciadas existem, squad.yaml tem campos obrigatórios e o pipeline está documentado.

Distinto do `*doctor` (que diagnostica a integridade do framework) — `*validate-squad` é diagnóstico de conteúdo instanciado pelo usuário.

---

## Entrada

- `{squad}` — nome do squad a validar (obrigatório)
  - Se omitido: ler `.kairos-core/core-config.yaml` → campo `agents.squads`, listar os squads registrados e pedir ao usuário que escolha.

---

## Execução

### Formato de output por check

```
✅ PASS   — {descrição}
⚠️  WARN   — {descrição}: {detalhe}
❌ FAIL   — {descrição}: {detalhe}
```

### Pré-passo — Resolver squad

Se `{squad}` foi omitido:
1. Ler `.kairos-core/core-config.yaml`
2. Listar squads em `agents.squads`
3. Exibir lista numerada e pedir ao usuário que escolha
4. Aguardar input antes de continuar

Se `{squad}` foi fornecido:
1. Verificar se está registrado em `core-config.yaml → agents.squads`
   - Se não encontrado: exibir aviso e continuar mesmo assim (squad pode existir sem registro)

---

### Check 1 — squad.yaml válido

Verificar `squads/{squad}/squad.yaml`:

- [ ] Arquivo existe
  → ❌ FAIL se ausente (squad não inicializado)
- [ ] Campo `name` presente
  → ❌ FAIL se ausente
- [ ] Lista de agentes presente — verificar em ordem:
  1. Campo top-level `agents` (lista)
  2. Ou campo `components.agents` (lista de paths)
  3. Ou `core-config.yaml → agents.squads.{squad}.agents`
  → ❌ FAIL se nenhuma das formas encontrar agentes
- [ ] Status definido — verificar em ordem:
  1. Campo `status` no próprio `squad.yaml`
  2. Ou `core-config.yaml → agents.squads.{squad}.status`
  → ⚠️ WARN se nenhuma das formas encontrar status (não é bloqueante)

---

### Check 2 — Personas existem

Para cada agente do squad (derivado do Check 1 — IDs extraídos dos paths quando necessário, ex: `agents/campaign-analyst.yaml` → `campaign-analyst`):

- [ ] Definição canônica do agente existe em `squads/{squad}/agents/{agent-id}.yaml` ou caminho equivalente declarado em `squad.yaml`
  → ❌ FAIL se ausente
- [ ] Persona materializada existe no target esperado pelo runtime disponível (Claude atual: `.claude/commands/kairos/agents/{agent-id}.md`; outros runtimes podem declarar targets próprios)
  → ⚠️ WARN se ausente em runtime ainda não suportado para squads; ❌ FAIL se o runtime corrente declara suporte operacional para squads

---

### Check 3 — Tasks existem

Fontes de tasks a verificar:
1. Tasks declaradas em `squad.yaml → components.tasks` (paths relativos ao squad: `squads/{squad}/{path}`)
2. Tasks declaradas nas personas dos agentes (campo `task:` ou `dependencies.tasks` no YAML interno)

Para cada task encontrada:
- [ ] Se path relativo ao squad (`tasks/nome.md`): verificar `squads/{squad}/tasks/{nome}.md`
- [ ] Se referência a task de framework (`kairos-*.md`): verificar `.kairos-core/tasks/{nome}`
  → ❌ FAIL se task de framework não encontrada
  → ⚠️ WARN se task de squad não encontrada (pode ser stub a implementar)

---

### Check 4 — Pipeline documentado

- [ ] Existe pelo menos um arquivo em `squads/{squad}/rules/`
  → ⚠️ WARN se ausente (squad sem regras documentadas)
- [ ] Existe pelo menos um `.md` em `squads/{squad}/` OU `squad.yaml` contém campo `pipeline`
  → ⚠️ WARN se ausente

---

### Check 5 — MEMORY.md dos agentes

Para cada agente do squad:

- [ ] Existe `.kairos-core/agents/{agent-id}/MEMORY.md`
  → ⚠️ WARN se ausente (agente sem memória — não crítico, mas subótimo)

---

## Verdict Final

Após todos os checks:

```
┌─────────────────────────────────────────────────┐
│  VALIDATE-SQUAD: {squad} — {data}               │
│                                                 │
│  ✅ VÁLIDO      — todos os checks PASS/WARN     │
│  ⚠️  INCOMPLETO  — há WARNs, sem FAILs          │
│  ❌ QUEBRADO    — há ao menos 1 FAIL            │
└─────────────────────────────────────────────────┘
```

- **VÁLIDO**: squad configurado e coerente, pronto para operar
- **INCOMPLETO**: squad operável, mas com lacunas — listar WARNs com sugestão de correção
- **QUEBRADO**: squad não pode operar corretamente — listar FAILs e indicar o que precisa ser criado/corrigido

### Após o verdict

- Se INCOMPLETO ou QUEBRADO: exibir resumo de ações recomendadas, agrupadas por severidade
- Se VÁLIDO: exibir resumo do que foi validado (N agentes, N tasks, pipeline documentado)
- Sem handoff automático — diagnóstico puro, não modifica nada

---

## Exemplo de Output

```
🌀 @kairos *validate-squad {squad-name}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Check 1 — squad.yaml válido
  ✅ PASS   — squads/{squad-name}/squad.yaml existe
  ✅ PASS   — campo name presente: "{squad-name}"
  ✅ PASS   — agentes encontrados em components.agents: {N} agentes
  ✅ PASS   — status encontrado em core-config.yaml: active

Check 2 — Personas existem
  ✅ PASS   — definição canônica squads/{squad-name}/agents/{agent-id-1}.yaml
  ✅ PASS   — target Claude .claude/commands/kairos/agents/{agent-id-1}.md
  ⚠️  WARN   — target materializado ausente para {agent-id-3} no runtime atual

Check 3 — Tasks existem
  ✅ PASS   — squads/{squad-name}/tasks/{task-id-1}.md
  ⚠️  WARN   — squads/{squad-name}/tasks/{task-id-2}.md: arquivo ausente
  ⚠️  WARN   — squads/{squad-name}/tasks/{task-id-3}.md: arquivo ausente

Check 4 — Pipeline documentado
  ✅ PASS   — squads/{squad-name}/rules/ tem 3 arquivo(s)
  ✅ PASS   — squad.yaml contém campo pipeline

Check 5 — MEMORY.md dos agentes
  ✅ PASS   — .kairos-core/agents/{agent-id-1}/MEMORY.md
  ✅ PASS   — .kairos-core/agents/{agent-id-2}/MEMORY.md
  ⚠️  WARN   — .kairos-core/agents/{agent-id-3}/MEMORY.md: arquivo ausente

┌─────────────────────────────────────────────────┐
│  VALIDATE-SQUAD: {squad-name} — {YYYY-MM-DD}    │
│  ⚠️  INCOMPLETO — 3 WARNs, 0 FAILs              │
└─────────────────────────────────────────────────┘

Ações recomendadas:
  ⚠️  Criar tasks ausentes em squads/{squad-name}/tasks/:
     • {task-id-2}.md
     • {task-id-3}.md
  ⚠️  Materializar persona ausente para {agent-id-3} no runtime alvo
  ⚠️  Criar MEMORY.md ausente: .kairos-core/agents/{agent-id-3}/MEMORY.md
```
