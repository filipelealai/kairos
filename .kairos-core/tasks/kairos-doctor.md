---
id: kairos-doctor
title: Health Check do Framework Kairos
agent: kairos
command: "*doctor"
version: 1
---

# Task: kairos-doctor

## Propósito

Verificar a integridade estrutural do framework Kairos: arquivos existem, referências não estão quebradas, versões são consistentes.

Não verifica comportamento — verifica que o framework está fisicamente íntegro e pode ser operado.

---

## Execução

### Formato de output por check

```
✅ PASS   — {descrição}
⚠️  WARN   — {descrição}: {detalhe}
❌ FAIL   — {descrição}: {detalhe}
```

### Checks (em ordem)

**1. Fundação (L1)**
- [ ] `.kairos-core/constitution.md` existe
- [ ] `.claude/rules/agent-authority.md` existe
- [ ] `.claude/rules/framework-layers.md` existe
- [ ] `.claude/rules/ids-principles.md` existe

**2. Configuração Central (L2)**
- [ ] `.kairos-core/core-config.yaml` existe e tem campo `version`
- [ ] `version` em `core-config.yaml` bate com a entrada mais recente do `CHANGELOG.md`
- [ ] `.kairos-core/data/kairos-kb.md` existe

**3. Agentes Registrados**

Para cada agente em `core-config.yaml → agents.squads.*.agents`:
- [ ] Persona existe em `.claude/commands/kairos/agents/{id}.md`
- [ ] MEMORY.md existe em `.kairos-core/agents/{id}/MEMORY.md`

**4. Tasks Referenciadas**

Para cada `task:` declarado nos arquivos de persona dos agentes:
- [ ] Arquivo correspondente existe em `.kairos-core/tasks/{task-name}`

**5. Squads Registrados**

Para cada squad em `core-config.yaml → agents.squads`:
- [ ] `squads/{squad}/squad.yaml` existe
- [ ] `squads/{squad}/README.md` existe

**6. Hooks**

Para cada hook registrado em `.claude/settings.json`:
- [ ] Arquivo do hook existe no path referenciado

**7. Stories Abertas**

Para cada `*.story.md` em `docs/stories/`:
- [ ] Campo `**Status:**` presente
- [ ] Se Status = "In Review": gate correspondente existe em `docs/qa/gates/`?
  → ⚠️ WARN se não existe (não é FAIL — o review pode não ter sido rodado ainda)

**8. Referências Quebradas em Stories**

Para stories com Status ≠ Done: verificar se arquivos citados em backticks existem.
- [ ] Arquivos `.md`, `.ts`, `.yaml` mencionados explicitamente nos ACs existem
  → ⚠️ WARN (não FAIL — pode ser um arquivo a criar)

---

## Verdict Final

Após todos os checks:

```
┌─────────────────────────────────────┐
│  KAIROS DOCTOR — {data}             │
│                                     │
│  ✅ HEALTHY    — todos checks PASS  │
│  ⚠️  WARNING   — há WARNs, sem FAIL │
│  ❌ CRITICAL   — há ao menos 1 FAIL │
└─────────────────────────────────────┘
```

- **HEALTHY**: sistema operável, nenhuma ação necessária
- **WARNING**: sistema operável, mas há inconsistências não bloqueantes — listar
- **CRITICAL**: sistema pode ter comportamento inesperado — listar FAILs e recomendar ação

---

## Completion

Sem handoff. `*doctor` é diagnóstico puro — não modifica nada.

Se CRITICAL: sugerir `@kairos *architecture` para auditoria mais profunda ou `@kairos *pre-push` se o contexto for pré-push.
