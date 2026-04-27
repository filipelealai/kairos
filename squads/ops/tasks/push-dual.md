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

**Leitura do manifest (uma vez, usada em todos os sub-passos abaixo):**

Executar `git show filipe-instance:.kairos-core/manifest.yaml` e extrair:

- **manifest_owned_files** — lista de `owned_files[].path`
- **manifest_sync_files** — lista de `sync_files[].path`
- **manifest_owned_sections** — lista de entradas de `owned_sections` (cada entrada com `path`, `type`, e os campos específicos do tipo: `blocks[]` para markdown_blocks, `owned_keys[]` para yaml_keys, `owned_sections[]` para env_sections)
- **manifest_all_paths** — união de manifest_owned_files + manifest_sync_files + `[e.path for e in manifest_owned_sections]`

---

#### Passo 2.0 — Detecção de remoções

Antes de sincronizar, identificar arquivos que estão em `main` mas não fazem mais parte do manifest.

1. Executar `git ls-files` para obter todos os arquivos tracked em `main`
2. Para cada arquivo tracked que **não** esteja em `manifest_all_paths`:

```bash
git rm <arquivo>
```

3. Ao final, exibir:

```
Passo 2.0 — Detecção de remoções:
  → {N} arquivo(s) removido(s): {lista, ou "nenhum"}
```

Se não houver remoções: `→ Passo 2.0: sem remoções.`

---

#### Passo 2a — Arquivos inteiros (`owned_files` e `sync_files`)

**Fonte autoritativa:** `manifest_owned_files` e `manifest_sync_files` (lidos no início do Passo 2).

Para cada path em `manifest_owned_files`, executar:

```bash
git checkout filipe-instance -- <path>
```

Em seguida, para cada path em `manifest_sync_files`, executar:

```bash
git checkout filipe-instance -- <path>
```

> **`sync_files`:** diferente dos `owned_files`, arquivos em `sync_files` são copiados integralmente para `main` mas nunca serão sobrescritos por um `kairos update` futuro — o conteúdo é instância-específico e pertence ao usuário.

Ao final, exibir:

```
Passo 2a concluído:
  → {N} owned_files sincronizados
  → {M} sync_files sincronizados
```

---

#### Passo 2b — Arquivos mistos (`owned_sections`)

**Fonte autoritativa:** `manifest_owned_sections` (lido no início do Passo 2). Iterar sobre cada entrada — o `type` determina a lógica de reconstrução aplicada.

**Skip por conteúdo:** antes de reprocessar cada arquivo misto, construir mentalmente a versão que seria escrita em `main` e compará-la com o que já está em `main`. Se o conteúdo managed que seria escrito for idêntico ao que já existe → `→ skip: conteúdo managed sem mudança` — não reprocessar. O skip se aplica **independentemente** a cada arquivo misto.

##### Tipo `markdown_blocks`

**Verificar skip:**
1. Extrair todos os blocos `<!-- KAIROS-MANAGED-START: {nome} -->` ... `<!-- KAIROS-MANAGED-END: {nome} -->` do arquivo de `filipe-instance` (na ordem em que aparecem, conforme declarado em `owned_sections[i].blocks[].name`).
2. Montar a string resultante (apenas os blocos, sem conteúdo user-owned entre eles).
3. Comparar com o conteúdo atual do arquivo em `main`.
4. Se idêntico → `→ skip: conteúdo managed sem mudança` — não reprocessar.

Caso contrário, escrever no arquivo em `main` **apenas** esses blocos (na mesma ordem em que aparecem no arquivo fonte de `filipe-instance`), sem conteúdo user-owned entre eles.

Formato esperado em `main`:

```
<!-- KAIROS-MANAGED-START: {bloco 1} -->
{conteúdo do bloco}
<!-- KAIROS-MANAGED-END: {bloco 1} -->

<!-- KAIROS-MANAGED-START: {bloco 2} -->
{conteúdo do bloco}
<!-- KAIROS-MANAGED-END: {bloco 2} -->

...
```

##### Tipo `yaml_keys`

**Verificar skip:**
1. Construir a versão que seria escrita em `main` a partir do arquivo de `filipe-instance` (campos top-level + seções declaradas em `owned_sections[i].owned_keys[]` + placeholders para `project` e `agents`).
2. Comparar com o conteúdo atual do arquivo em `main`.
3. Se idêntico → `→ skip: conteúdo managed sem mudança` — não reprocessar.

Caso contrário, ler o arquivo de `filipe-instance` e escrever em `main` uma versão com:
- Campos top-level (`version`, `installedAt`, `updatedAt`) — copiados integralmente
- Seções declaradas em `owned_keys` (lidas do manifest) — copiadas integralmente
- Seção `project` — substituída por placeholders: `owner: "{owner}"`, `name: "{project-name}"`, `scope: personal`
- Seção `agents` — substituída por placeholder: `squads: {}`
- Demais campos fora das seções acima — omitidos

##### Tipo `env_sections`

**Verificar skip:**
1. Para cada seção declarada em `owned_sections[i].owned_sections[].name` (na ordem do manifest), extrair o conteúdo entre `# KAIROS-MANAGED-START: {nome}` e `# KAIROS-MANAGED-END: {nome}` do arquivo em `filipe-instance`.
2. Montar a string resultante: os blocos concatenados na mesma ordem, mantendo os markers START/END.
3. Comparar com o conteúdo atual do arquivo em `main` (apenas as seções gerenciadas).
4. Se idêntico → `→ skip: conteúdo managed sem mudança` — não reprocessar.

Caso contrário, escrever no arquivo em `main` **apenas** os blocos gerenciados (na mesma ordem declarada no manifest), sem conteúdo user-owned. Seções não declaradas no manifest **não** vão para `main`.

##### Resumo ao final do Passo 2b

```
Passo 2b concluído:
  → {N} arquivo(s) reprocessado(s): {lista ou "nenhum"}
  → {M} arquivo(s) pulado(s) (sem mudança): {lista ou "nenhum"}
```

---

### Passo 3 — Commit e push para origin/main

```bash
# Capturar mensagem do commit mais recente em filipe-instance
COMMIT_MSG=$(git log filipe-instance -1 --pretty=%B)

# Verificar o que mudou em main
git status
```

Se houver mudanças (remoções do Passo 2.0, arquivos atualizados do Passo 2a/2b, ou ambos):

```bash
git add -A
git commit -m "$COMMIT_MSG"
git push origin main
```

Se `git status` estiver limpo (nenhum arquivo framework mudou e nenhuma remoção ocorreu), pular o commit — apenas push:

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
       git show filipe-instance:.kairos-core/manifest.yaml  ← leitura única do manifest
       git rm {arquivos não mais no manifest}               ← Passo 2.0 (detecção de remoções)
       git checkout filipe-instance -- {owned_files}        ← Passo 2a (derivado do manifest)
       git checkout filipe-instance -- {sync_files}         ← Passo 2a (derivado do manifest)
       {reconstruir owned_sections}                         ← Passo 2b (derivado do manifest)
       git add -A + git commit + git push origin main       → kairos (público, framework puro)
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
| `git show filipe-instance:.kairos-core/manifest.yaml` falha | HALT — verificar se branch `filipe-instance` existe e manifest está commitado |
