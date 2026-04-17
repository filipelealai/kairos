# Task: push-dual

**Squad:** ops
**Executada por:** @kairos (via `*push`)
**Propósito:** Manter `origin/main` (framework público) e `private/filipe-instance` (instância privada) sincronizados com um único comando.

---

## Guard Obrigatório

**ANTES de qualquer coisa**, verificar o estado de sessão (herdado de `kairos-push.md`):

```
SE pre_push_passed != true na sessão atual:
  RECUSAR com:
  "🚫 Push recusado. *pre-push não foi executado ou retornou BLOCK nesta sessão.
   Execute *pre-push primeiro e certifique-se de que retorna PASS."
  HALT — não continuar
```

Se `*pre-push` foi rodado em outra sessão (não a atual), tratar como não executado.

---

## Pré-condições

Após o guard passar, verificar:

1. Branch atual é `filipe-instance` — se não, HALT e informar o usuário
2. `git status` está limpo (sem uncommitted changes) — se não, HALT
3. Remotes `origin` e `private` estão configurados — verificar com `git remote -v`

---

## Passos

### Passo 1 — Push da instância completa para o remote privado

```bash
git push private filipe-instance
```

Resultado esperado: todos os arquivos da instância (framework + conteúdo do usuário) enviados para `filipelealweb/kairos-pessoal`.

---

### Passo 2 — Sincronizar arquivos framework para main

```bash
# Ir para a branch limpa de framework
git checkout main

# Para cada arquivo em manifest.yaml → owned_files:
# git checkout filipe-instance -- {path}
```

**Implementação:** ler `.kairos-core/manifest.yaml` e extrair todos os `path` dentro de `owned_files`. Para cada path:

```bash
git checkout filipe-instance -- <path>
```

Lista atual de owned_files (atualizar conforme manifest evolui):

```bash
# L1 — Fundação
git checkout filipe-instance -- .kairos-core/constitution.md
git checkout filipe-instance -- .claude/rules/ownership.md
git checkout filipe-instance -- .claude/rules/agent-authority.md
git checkout filipe-instance -- .claude/rules/framework-layers.md
git checkout filipe-instance -- .claude/rules/ids-principles.md

# L2 — Controlado
git checkout filipe-instance -- .claude/commands/kairos/agents/kairos.md
git checkout filipe-instance -- .claude/hooks/kairos-code-intel.cjs
git checkout filipe-instance -- .claude/hooks/kairos-precompact.cjs
git checkout filipe-instance -- src/tools/claude.ts
git checkout filipe-instance -- .kairos-core/data/workers.yaml

# L2 — Governance tasks
git checkout filipe-instance -- .kairos-core/tasks/kairos-architecture.md
git checkout filipe-instance -- .kairos-core/tasks/kairos-doctor.md
git checkout filipe-instance -- .kairos-core/tasks/kairos-help.md
git checkout filipe-instance -- .kairos-core/tasks/kairos-kb.md
git checkout filipe-instance -- .kairos-core/tasks/kairos-new-epic.md
git checkout filipe-instance -- .kairos-core/tasks/kairos-new-squad.md
git checkout filipe-instance -- .kairos-core/tasks/kairos-new-story.md
git checkout filipe-instance -- .kairos-core/tasks/kairos-prd.md
git checkout filipe-instance -- .kairos-core/tasks/kairos-pre-push.md
git checkout filipe-instance -- .kairos-core/tasks/kairos-push.md
git checkout filipe-instance -- .kairos-core/tasks/kairos-review.md
git checkout filipe-instance -- .kairos-core/tasks/kairos-status.md
git checkout filipe-instance -- .kairos-core/tasks/kairos-validate-story.md
git checkout filipe-instance -- .kairos-core/tasks/kairos-version-bump.md
git checkout filipe-instance -- .kairos-core/tasks/kairos-workers.md

# L2 — Templates
git checkout filipe-instance -- .kairos-core/templates/agent-template.md
git checkout filipe-instance -- .kairos-core/templates/story-template.md
git checkout filipe-instance -- ".kairos-core/templates/squad-template/README.md"
git checkout filipe-instance -- ".kairos-core/templates/squad-template/squad.yaml"
git checkout filipe-instance -- ".kairos-core/templates/squad-template/agents/agent-id.md"
git checkout filipe-instance -- ".kairos-core/templates/squad-template/workflows/full-pipeline.md"

# L3 — Gerenciado
git checkout filipe-instance -- .claude/rules/agent-handoff.md
git checkout filipe-instance -- .claude/rules/story-lifecycle.md
git checkout filipe-instance -- .claude/rules/external-integrations.md
git checkout filipe-instance -- .kairos-core/data/kairos-kb.md
git checkout filipe-instance -- .kairos-core/docs/agent-standards.md
git checkout filipe-instance -- .kairos-core/docs/data-flow.md
git checkout filipe-instance -- .kairos-core/docs/scope.md
```

**Também sincronizar arquivos mistos — seções framework:**
Os arquivos em `owned_sections` (CLAUDE.md, `.claude/settings.json`, `.kairos-core/core-config.yaml`) são mistos.
O push-dual NÃO sobrescreve esses arquivos — eles são gerenciados manualmente pelo @kairos quando há mudanças de framework.

---

### Passo 3 — Commit e push para origin/main

```bash
# Verificar o que mudou em main
git status

# Se houver mudanças (framework evoluiu desde o último push-dual):
git add <arquivos modificados>
git commit -m "sync: framework files from filipe-instance → main (push-dual)"

# Push para o repo público
git push origin main
```

Se `git status` estiver limpo (nenhum arquivo framework mudou), pular o commit — apenas push:

```bash
git push origin main
```

---

### Passo 4 — Retornar para filipe-instance

```bash
git checkout filipe-instance
```

---

### Passo 5 — Pós-push (herdado de `kairos-push.md`)

Se havia story com status `In Review` cujo gate está PASS/RESSALVA:
- Informar: "Story {id} tem gate PASS. Deseja atualizar o status para Done? (s/n)"
- Se confirmado: atualizar `**Status:**` para `Done` e adicionar entrada no Change Log

Resetar `pre_push_passed = false` em sessão (força novo `*pre-push` no próximo ciclo).

---

## Resumo do fluxo

```
filipe-instance (trabalho)
    │
    ├─ git push private filipe-instance      → kairos-pessoal (privado, completo)
    │
    └─ git checkout main
       git checkout filipe-instance -- {owned_files}
       git commit + git push origin main     → kairos (público, framework puro)
       git checkout filipe-instance
```

---

## Erros comuns

| Situação | Ação |
|----------|------|
| Branch não é `filipe-instance` | HALT — `git checkout filipe-instance` primeiro |
| `git status` com uncommitted changes | HALT — commitar ou stash antes |
| Remote `private` não existe | Configurar: `git remote add private https://github.com/filipelealweb/kairos-pessoal.git` |
| Remote `origin` não tem permissão de push | HALT — verificar autenticação do `gh` CLI |
| Arquivo de manifest não encontrado | HALT — executar `*doctor` para diagnóstico |

---

## Manutenção

Quando o manifesto evolui (story 5.3 refresh de SHAs, novos owned_files adicionados):
- Atualizar a lista de `git checkout` no Passo 2
- A lista nesta task deve sempre espelhar `manifest.yaml → owned_files`
