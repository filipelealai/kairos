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
git checkout main
```

---

#### Passo 2a — Arquivos inteiros (`owned_files`)

**Fonte autoritativa:** `.kairos-core/manifest.yaml → owned_files`. Para cada `path` listado:

```bash
git checkout filipe-instance -- <path>
```

Lista atual (atualizar conforme manifest evolui):

```bash
# L1 — Fundação
git checkout filipe-instance -- .kairos-core/constitution.md
git checkout filipe-instance -- .claude/rules/ownership.md
git checkout filipe-instance -- .claude/rules/agent-authority.md
git checkout filipe-instance -- .claude/rules/framework-layers.md
git checkout filipe-instance -- .claude/rules/ids-principles.md

# L2 — Controlado
git checkout filipe-instance -- .kairos-core/manifest.yaml
git checkout filipe-instance -- .claude/commands/kairos/agents/kairos.md
git checkout filipe-instance -- .claude/hooks/kairos-code-intel.cjs
git checkout filipe-instance -- .claude/hooks/kairos-precompact.cjs
git checkout filipe-instance -- .claude/settings.json
git checkout filipe-instance -- .kairos-core/data/workers.yaml

# L2 — Governance tasks
git checkout filipe-instance -- .kairos-core/tasks/kairos-architecture.md
git checkout filipe-instance -- .kairos-core/tasks/kairos-doctor.md
git checkout filipe-instance -- .kairos-core/tasks/kairos-help.md
git checkout filipe-instance -- .kairos-core/tasks/kairos-kb.md
git checkout filipe-instance -- .kairos-core/tasks/kairos-new-epic.md
git checkout filipe-instance -- .kairos-core/tasks/kairos-new-squad.md
git checkout filipe-instance -- .kairos-core/tasks/kairos-update-squad.md
git checkout filipe-instance -- .kairos-core/tasks/kairos-implement.md
git checkout filipe-instance -- .kairos-core/tasks/kairos-validate-squad.md
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

# L3 — Documentação pública
git checkout filipe-instance -- CHANGELOG.md
git checkout filipe-instance -- README.md
```

---

#### Passo 2b — Arquivos mistos (`owned_sections`)

**Fonte autoritativa:** `.kairos-core/manifest.yaml → owned_sections`. Cada arquivo é reconstruído para `main` contendo apenas as seções/chaves framework-owned. Conteúdo user-owned não chega ao `main`.

**Skip por arquivo:** antes de reprocessar cada arquivo misto, verificar se houve mudança desde o último commit de sync em `origin/main`:

```bash
git log origin/main..filipe-instance -- <path>
```

- Se retornar vazio → arquivo não foi tocado desde o último sync → `→ skip: sem mudança desde último sync` — não reprocessar
- Se retornar commits → reprocessar normalmente (extrair seções / reconstruir com placeholders)

O skip se aplica **independentemente** a cada arquivo misto.

##### CLAUDE.md (markdown_blocks)

**Verificar mudança:**
```bash
git log origin/main..filipe-instance -- CLAUDE.md
```
Se vazio → skip.

Caso contrário, extrair todos os blocos delimitados por `<!-- KAIROS-MANAGED-START: {nome} -->` ... `<!-- KAIROS-MANAGED-END: {nome} -->` do `CLAUDE.md` de `filipe-instance` e escrever em `main/CLAUDE.md` **apenas** esses blocos (na mesma ordem que aparecem no arquivo fonte), sem conteúdo user-owned entre eles.

Blocos atuais declarados no manifesto: `framework-conventions`, `agent-system`, `kairos-core`.

Formato esperado do `CLAUDE.md` em `main`:

```
<!-- KAIROS-MANAGED-START: framework-conventions -->
{conteúdo do bloco}
<!-- KAIROS-MANAGED-END: framework-conventions -->

<!-- KAIROS-MANAGED-START: agent-system -->
{conteúdo do bloco}
<!-- KAIROS-MANAGED-END: agent-system -->

<!-- KAIROS-MANAGED-START: kairos-core -->
{conteúdo do bloco}
<!-- KAIROS-MANAGED-END: kairos-core -->
```

##### .kairos-core/core-config.yaml (yaml_keys)

**Verificar mudança:**
```bash
git log origin/main..filipe-instance -- .kairos-core/core-config.yaml
```
Se vazio → skip.

Caso contrário, ler o `core-config.yaml` de `filipe-instance` e escrever em `main/.kairos-core/core-config.yaml` uma versão com:
- Campos top-level (`version`, `installedAt`, `updatedAt`) — copiados integralmente
- Seções `framework`, `runtime`, `versioning` (`owned_keys` no manifesto) — copiadas integralmente
- Seção `project` — substituída por placeholders: `owner: "{owner}"`, `name: "{project-name}"`, `scope: personal`
- Seção `agents` — substituída por placeholder: `squads: {}`
- Demais campos fora das seções acima — omitidos

Formato esperado do `core-config.yaml` em `main`:

```yaml
version: {atual}
installedAt: {atual}
updatedAt: {atual}

project:
  name: "{project-name}"
  type: claude-code-orchestrator
  owner: "{owner}"
  scope: personal

agents:
  master: kairos
  squads: {}

framework:
  ... (copiado integralmente)

runtime:
  ... (copiado integralmente)

versioning:
  ... (copiado integralmente)
```

##### Resumo ao final do Passo 2b

```
Passo 2b concluído:
  → {N} arquivo(s) reprocessado(s): {lista ou "nenhum"}
  → {M} arquivo(s) pulado(s) (sem mudança): {lista ou "nenhum"}
```

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
