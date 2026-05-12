# `.github/` — Governança CI do Kairos

Este diretório contém workflows, scripts e templates de GitHub que servem como **backstop de governança** para PRs ao `origin/main`. O objetivo é validar o processo Kairos (story `type:kairos-core` Done + gate `*review` + bump + CHANGELOG) **independente** do que aconteceu localmente no `*push` do contribuidor.

> A documentação local do fluxo de contribuição vive em [`CONTRIBUTING.md`](../CONTRIBUTING.md). Este README cobre apenas a camada de CI.

---

## Workflows ativos

| Workflow | Dispara em | Função | Bloqueia merge? |
|----------|-----------|--------|------------------|
| `validate-manifest.yml` | `pull_request` para `main` | Roda `validate-manifest.sh` — integridade do manifesto (existência, sha256, marcadores, JSON) | Sim (em caso de FAIL) |
| `version-guard.yml` | `pull_request` para `main` | Roda `version-guard.sh` — bump, frontmatter, CHANGELOG, status Done + gate | Sim (em caso de FAIL) |

Ambos rodam em `ubuntu-latest` e instalam `mikefarah/yq` via action oficial (`mikefarah/yq@latest`) — Go binary cross-platform, sem dependência de Python, Ruby ou gerenciador de pacote do sistema.

---

## Scripts em `.github/scripts/`

### `validate-manifest.sh`

Validador estático do manifesto. Checks:

1. `owned_files` — paths existem
2. `owned_files` — sha256 bate (exceto `self-referential`)
3. `.md` em `owned_files` tem frontmatter `kairos-owned: true` (WARN se ausente)
4. `.md` com `kairos-owned: true` está em `owned_files` (WARN se órfão)
5. `owned_sections` markdown_blocks — marcadores `<!-- KAIROS-MANAGED-* -->` emparelhados e sem órfãos
6. `sync_files` — paths existem
7. `owned_sections` json_keys — arquivo existe, JSON válido, owned_keys presentes

Dependências (todas instaladas no runner via action oficial ou presentes por padrão):

| Dependência | Onde | Por que essencial |
|-------------|------|-------------------|
| `bash` | runner | Linguagem base do script |
| `mikefarah/yq` v4 | action `mikefarah/yq@latest` | Parsing YAML e JSON (`-p json`) — sem ela não há como ler o manifesto |
| `sha256sum` | runner padrão (coreutils) | Verificação de integridade — substituir por `shasum -a 256` quebraria portabilidade |
| `grep` | runner padrão | Busca textual de frontmatter e marcadores |

### `version-guard.sh`

Gate de versionamento para PRs ao `main`. Checks:

- **A. Bump** — `version` em `.kairos-core/core-config.yaml` foi bumped vs `origin/main`
- **B. Frontmatter** — arquivos framework `.md` modificados têm `kairos-version` igual à versão atual (ignora arquivos sem frontmatter; backfill não obrigatório)
- **C. CHANGELOG** — versão mais recente em `CHANGELOG.md` bate com `core-config.yaml`
- **D. Status Done + Gate** — toda story `type:kairos-core` modificada no PR tem **status `Done`** (não basta `In Review`) **e** gate `PASS`/`RESSALVA` em `docs/qa/gates/`. Adicionalmente: se o PR modifica arquivos do manifesto **sem incluir nenhuma story `type:kairos-core`**, o check D falha — sinaliza que o usuário pulou o fluxo contribuidor (Story 3.34, opção "Local") e está empurrando direto para `main` sem governança.

Pula todos os checks se nenhum arquivo do PR está no manifesto (`owned_files[].path` ou `owned_sections[].path`).

Dependências (todas instaladas no runner via action oficial ou presentes por padrão):

| Dependência | Onde | Por que essencial |
|-------------|------|-------------------|
| `bash` | runner | Linguagem base do script |
| `git` | runner padrão | Diff entre branches e leitura de `core-config.yaml` em `BASE` |
| `mikefarah/yq` v4 | action `mikefarah/yq@latest` | Parsing do manifesto |
| `grep` / `awk` / `sed` / `basename` | runner padrão (coreutils) | Manipulação textual |

---

## Auditoria de dependências

Critério (ver AC4–AC6 da Story 3.35):

- **Essencial** — sem alternativa razoável sem reescrever o script.
- **Substituível** — existe equivalente que evita introduzir novo runtime/linguagem.
- **Enviesada** — não declarada em `CONTRIBUTING.md` **e** introduz runtime/linguagem não usado pelo framework (Python, Ruby, etc.).

### Hits substituídos

| Dependência removida | Onde | Substituição | Razão |
|----------------------|------|--------------|-------|
| `pip install yq` (python yq de Andrey Kislyuk) | `version-guard.yml` | action `mikefarah/yq@latest` | Removia inconsistência com `validate-manifest.yml` e introduzia Python como runtime sem que nada no framework dependesse |
| `python3` para parsing JSON | `validate-manifest.sh` | `yq -p json` (mikefarah suporta JSON nativamente) | Eliminava Python como runtime — agora `yq` cobre YAML **e** JSON |

### Hits essenciais mantidos

| Dependência | Onde | Justificativa |
|-------------|------|---------------|
| `bash` | ambos os scripts | Linguagem base; framework já depende para hooks `.claude/hooks/*` |
| `git` | `version-guard.sh` | Diff de PR é parte do contrato do framework |
| `mikefarah/yq` v4 | ambos os scripts | Parsing YAML/JSON; única ferramenta agnóstica de runtime instalada via action oficial |
| `sha256sum` | `validate-manifest.sh` | Integridade do manifesto; já presente em todo runner Linux padrão |
| `grep`/`awk`/`sed`/`basename`/`sort` | ambos | Coreutils — universalmente presentes |

### Hits opcionais

Nenhum no momento. Convenção para futuros casos: usar `command -v {tool}` e logar o que foi pulado caso a ferramenta esteja ausente; nunca tentar instalar implicitamente.

---

## Rodando os checks localmente

Pré-requisitos: ver [`CONTRIBUTING.md`](../CONTRIBUTING.md#dependências-para-checks-locais).

```bash
# Validação completa do manifesto
bash .github/scripts/validate-manifest.sh

# Version guard (compara HEAD vs origin/main)
BASE=origin/main bash .github/scripts/version-guard.sh
```

Ambos podem ser rodados a partir da raiz do repo. `version-guard.sh` exige acesso a `origin/main` para diff — em fork novo, rode `git fetch origin main` antes.

---

## O que **bloqueia merge** no PR para `main`

Resumo consolidado dos dois workflows:

| Falha | Workflow | Como destravar |
|-------|----------|----------------|
| Arquivo em `owned_files` com sha256 divergente | `validate-manifest` | `@kairos *pre-push` (recomputa sha256) |
| Arquivo em `owned_files` não encontrado | `validate-manifest` | Restaurar arquivo ou remover do manifesto via story |
| Marcador `KAIROS-MANAGED-*` órfão ou desemparelhado | `validate-manifest` | Corrigir o markdown |
| JSON inválido em `owned_sections` json_keys | `validate-manifest` | Validar localmente: `yq -p json '.' arquivo.json` |
| `version` em `core-config.yaml` igual a `origin/main` | `version-guard` (A) | `@kairos *version` (bump) |
| `CHANGELOG.md` divergente da versão atual | `version-guard` (C) | `@kairos *version` (sincroniza CHANGELOG) |
| Story `type:kairos-core` no PR com status ≠ `Done` | `version-guard` (D) | `@kairos *push` (move para Done após commit) |
| Story `type:kairos-core` Done sem gate `PASS`/`RESSALVA` | `version-guard` (D) | `@kairos *review {id}` |
| Arquivo de framework modificado sem story `type:kairos-core` no PR | `version-guard` (D) | Criar story retroativa (`@kairos *new-story type=kairos-core`) e seguir o fluxo contribuidor (Story 3.34) |

---

## Templates

- [`PULL_REQUEST_TEMPLATE.md`](PULL_REQUEST_TEMPLATE.md) — carregado automaticamente ao abrir PR
- [`ISSUE_TEMPLATE/`](ISSUE_TEMPLATE/) — bug report e feature request
- [`CODEOWNERS`](CODEOWNERS) — donos por path

---

## Referências

- [`.kairos-core/manifest.yaml`](../.kairos-core/manifest.yaml) — fronteira framework/usuário (fonte autoritativa)
- [`.claude/rules/ownership.md`](../.claude/rules/ownership.md) — contrato de ownership
- [`.kairos-core/tasks/kairos-push.md`](../.kairos-core/tasks/kairos-push.md) — fluxo `*push` (modo contribuidor, transição Done)
