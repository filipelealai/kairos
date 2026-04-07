---
task: Kairos Pre-Push
responsavel: "@kairos"
responsavel_type: agent
atomic_layer: validation
elicit: false
Entrada: |
  Nenhuma — inspeciona o estado atual do repositório
Saida: |
  - verdict: PASS | BLOCK exibido em tela
  - pre_push_passed: true|false (guardado em sessão para *push verificar)
Checklist:
  - "[ ] Rodar git status"
  - "[ ] Rodar git diff --stat HEAD"
  - "[ ] Verificar consistência de versão (core-config vs CHANGELOG)"
  - "[ ] Verificar stories In Progress — existe gate PASS para elas?"
  - "[ ] Verificar referências quebradas nos arquivos modificados"
  - "[ ] Exibir sumário de mudanças e verdict"
---

# *pre-push — Verificações Pré-Push

## Execução

### Passo 1 — Estado do repositório

```bash
git status
git diff --stat HEAD
git log --oneline -5
```

Identifique:
- Arquivos staged (prontos para commit)
- Arquivos modificados não staged
- Arquivos untracked relevantes (excluir `.kairos-core/runtime/`, `data/`, `node_modules/`)

**BLOCK se:** há arquivos modificados não staged que parecem parte da mudança intencional (não são `.kairos-core/runtime/handoffs/` ou `data/`).

### Passo 2 — Consistência de versão

Leia `.kairos-core/core-config.yaml` → campo `version`.
Leia `CHANGELOG.md` → versão da primeira entrada (mais recente).

**BLOCK se:** as versões não coincidem.

### Passo 3 — Gate de story ativa

Liste `docs/stories/*.story.md` com status `In Progress` ou `Draft` com arquivos modificados.

Para cada story In Progress:
- Verificar se existe gate em `docs/qa/gates/{story-id}-*.yaml` com `verdict: PASS`
- Se não existe gate PASS → **aviso** (não BLOCK — pode ser PATCH sem story obrigatória)
- Se a mudança é MAJOR ou MINOR e não há gate PASS → **BLOCK**

### Passo 4 — Referências quebradas (spot check)

Para arquivos `.md` modificados recentemente:
- Verificar links internos `[texto](caminho)` — o path existe?
- Verificar referências a tasks em YAML — o arquivo da task existe?

Limite: verificar até 10 arquivos, não é revisão exaustiva.

**BLOCK se:** referência crítica quebrada (agente referencia task inexistente, story aponta para epic inexistente).

### Passo 5 — Exibir resultado

**Se PASS:**
```
✅ PRE-PUSH PASS

Resumo das mudanças:
  Arquivos modificados: N
  Branch: {branch}
  Último commit: {hash} {mensagem}
  Versão: {version}

Checks:
  ✅ git status — sem conflitos
  ✅ Versão consistente (core-config = CHANGELOG = {version})
  ✅ Stories com gate PASS (ou PATCH sem story obrigatória)
  ✅ Referências verificadas

Pronto para push. Execute: *push
```

**Se BLOCK:**
```
🚫 PRE-PUSH BLOCK

Issues que precisam ser resolvidos:
  ❌ {issue 1}
  ❌ {issue 2}

Avisos (não bloqueantes):
  ⚠️ {aviso}

Resolva os issues e rode *pre-push novamente.
```

## Estado de Sessão

Após execução, registre internamente:
- `pre_push_passed = true` se PASS
- `pre_push_passed = false` se BLOCK

O comando `*push` verifica este estado antes de executar.
