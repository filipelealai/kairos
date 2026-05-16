---
kairos-owned: true
kairos-version: 4.3.0
task: Kairos Version Bump
responsavel: "@kairos"
responsavel_type: agent
atomic_layer: governance
elicit: false
Entrada: |
  - bump_type: patch | minor | major
  - description: descrição curta da mudança (string) — opcional quando derivável do Execution Log
Saida: |
  - .kairos-core/core-config.yaml atualizado (version + updatedAt)
  - CHANGELOG.md com nova entrada
  - README.md atualizado (linha "Versão atual")
  - manifest.yaml com SHAs sincronizados
  - kairos-version nos frontmatters atualizados
Checklist:
  - "[ ] Passo 1: *doctor (health check — bloqueia se CRITICAL ou WARN de integridade)"
  - "[ ] Passo 2: Verificar que há arquivos framework modificados (recusa se instance-only)"
  - "[ ] Passo 3: Validar bump_type"
  - "[ ] Passo 4: Ler versão atual e calcular nova versão"
  - "[ ] Passo 5: Atualizar core-config.yaml"
  - "[ ] Passo 6: Derivar descrição do CHANGELOG"
  - "[ ] Passo 7: Adicionar entrada no CHANGELOG.md"
  - "[ ] Passo 8: Atualizar README.md"
  - "[ ] Passo 9: Atualizar kairos-version nos frontmatters"
  - "[ ] Passo 10: SHA sync do manifest.yaml"
  - "[ ] Confirmar mudanças ao usuário"
---

# *version — Bump de Versão Semântica

Autoridade única de bump de versão do Kairos. Pode ser executado standalone (`@kairos *version`) ou embutido no `*push` via prompt "modo contribuidor".

## Guard de Git

**ANTES de qualquer coisa**, verificar se o Git está disponível:

```bash
git --version
```

Se o comando falhar (Git não instalado ou não encontrado no PATH):

```
🚫 HALT — Git não encontrado.

O *version requer Git para operar. Instale com:
  • Linux (apt):   sudo apt install git
  • macOS (brew):  brew install git
  • Windows:       winget install --id Git.Git -e

Deseja que eu execute a instalação agora? (s/n):
```

Se `s` (ou `sim`): executar o comando de instalação correspondente ao SO detectado com confirmação explícita antes de rodar.
Se `n` (ou `não`): HALT — encerrar sem executar nada.

---

## Passo 1 — *doctor (Health Check)

**Objetivo:** garantir que o framework está íntegro antes de versionar.

Execute `*doctor` (Checks 1–10+ conforme definido em `kairos-doctor.md`) e avalie o veredicto:

| Veredicto `*doctor` | Ação |
|---------------------|------|
| `HEALTHY` | Confirme `✓ *doctor: HEALTHY — prosseguindo` e continue |
| `WARNING` | Verificar natureza dos WARNs (ver abaixo) |
| `CRITICAL` | **BLOCK imediato** — listar todos os FAILs |

**Regra para `WARNING`:**

- WARNs de **integridade de manifesto** — arquivo com `kairos-owned: true` não está em `owned_files` (Check 9) → **BLOCK:**
  ```
  🚫 BLOCK — *doctor WARNING de manifest integrity:
    ⚠️ {arquivo} marca-se como kairos-owned mas não está no manifesto
  Adicione ao manifest.yaml antes de continuar.
  ```
- Todos os demais WARNs → **não bloqueam**; listados no sumário final na seção "Avisos".

**BLOCK se:** veredicto `*doctor` = CRITICAL, **ou** WARN de categoria manifest integrity.

---

## Passo 2 — Verificar Escopo

**Objetivo:** recusar bump quando não há arquivos framework modificados.

Execute:

```bash
git diff HEAD --name-only
git diff --cached --name-only
```

Cruzar com `.kairos-core/manifest.yaml` → `owned_files[].path` e `owned_sections[].path`.

- Se **nenhum** arquivo modificado consta no manifest → **BLOCK:**
  ```
  🚫 BLOCK — nada a versionar: todas as mudanças são de instância.
  Arquivos de framework (listados no manifest) não foram modificados.
  Use *push diretamente para commitar e enviar mudanças de instância.
  ```
- Se ao menos um arquivo framework foi modificado → prosseguir.

---

## Passo 3 — Validação

Antes de executar, verifique:

- `bump_type` é um de: `patch`, `minor`, `major`
- Se `minor` ou `major`: existe story Done ou In Progress que justifica o bump?
  - Se não existe story → **BLOCK**: instrua a criar story primeiro com `@kairos *new-story`

---

## Passo 4 — Calcular Nova Versão

Leia `version` de `.kairos-core/core-config.yaml`.

Separe em `[MAJOR, MINOR, PATCH]` e aplique:
- `patch` → incrementa PATCH, zera nada
- `minor` → incrementa MINOR, zera PATCH
- `major` → incrementa MAJOR, zera MINOR e PATCH

---

## Passo 5 — Atualizar core-config.yaml

Atualize dois campos:
```yaml
version: {nova versão}
updatedAt: '{ISO 8601 timestamp}'
```

---

## Passo 6 — Derivar Descrição do CHANGELOG

Derive a descrição automaticamente (sem prompt ao usuário):

1. Para cada story ativa (status In Review ou Done com gate_ok, se chamado a partir do *push):
   - Leia `docs/stories/{story-id}.story.md`
   - Localize `## Execution Log` → `### O que foi feito`
   - Se encontrado, pegue o primeiro item de lista (linha iniciada com `- `)
   - Sanitize: remover `(story X.Y)`, `story X.Y`, backticks de paths, texto entre aspas duplas
   → Se múltiplas stories: concatenar os bullets sanitizados separados por `; `
   → Se ao menos uma story tem o bullet: usar como descrição (prioridade 1)

2. Se nenhuma story tem `## Execution Log` → `### O que foi feito`:
   - Execute `git diff HEAD --name-only` e `git diff --cached --name-only`
     → union dos dois conjuntos de arquivos modificados/adicionados
   - Leia `.kairos-core/manifest.yaml` → `owned_files`
     → mantenha apenas os arquivos que constam no manifesto
     → separe em: novos (status `A` no git) vs modificados (status `M` no git)
   - Se lista não vazia:
     → descrição = `"{basename1}, {basename2}: adicionado|atualizado"`
       (todos novos → `adicionado`; qualquer modificado → `atualizado`; usar basename sem path completo quando autoexplicativo)

3. Fallback final: `"ajuste de instrução no framework"`

Exiba para ciência (não para edição):
```
→ Descrição para CHANGELOG: "{descrição derivada}"
```

---

## Passo 7 — Entrada no CHANGELOG.md

Adicione no topo (após o cabeçalho), antes da entrada mais recente:

```markdown
## [{nova versão}] — {YYYY-MM-DD}

### {Categoria}
- {descrição derivada}
```

Categorias: `Adicionado`, `Mudado`, `Corrigido`, `Removido`, `Segurança`

---

## Passo 8 — Atualizar README.md

Localize a linha que começa com `**Versão atual:**` e substitua a versão:

```
**Versão atual:** `{nova versão}` — ver [CHANGELOG.md](CHANGELOG.md)
```

---

## Passo 9 — Atualizar `kairos-version` nos Frontmatters

**Objetivo:** manter o campo `kairos-version` no frontmatter sincronizado com a versão em que cada arquivo foi tocado pela última vez.

1. Execute `git status --porcelain` para listar arquivos modificados ou adicionados. Filtre linhas cujo código de duas letras (XY) contém `M` na posição X ou Y, ou `A` na posição X — padrões relevantes: `M `, ` M`, `MM`, `A `, `AM`. Ignorar `??` (untracked não staged) e `D`/` D` (deletados).
2. Para cada arquivo listado:
   - Leia o conteúdo e verifique se tem frontmatter YAML delimitado por `---`
   - Verifique se o frontmatter contém o campo `kairos-version:`
   - Se **sim**: atualize o valor para a versão atual (obtida de `.kairos-core/core-config.yaml`)
   - Se **não**: ignore — **não** criar o campo em arquivos que não o têm
3. Se algum arquivo foi atualizado → confirme: `✓ kairos-version: {N} arquivo(s) atualizado(s) para v{version}`
4. Se nenhum arquivo tinha o campo → confirme: `✓ kairos-version: sem frontmatter para atualizar`

---

## Passo 10 — SHA Sync

**Objetivo:** manter o `manifest.yaml` sincronizado com o estado atual dos arquivos framework. Executado **depois** do Passo 9 para capturar numa única passagem todas as modificações do ciclo.

### 10a — owned_files

1. Leia `.kairos-core/manifest.yaml` → lista `owned_files`
2. Para cada entrada em `owned_files`:
   - Se `sha256 == "self-referential"` → pular esta entrada (sem calcular ou comparar)
   - Caso contrário: execute `sha256sum {path}` para calcular o SHA atual
   - Compare com o campo `sha256` registrado
   - Se divergir → atualize o campo `sha256` no manifesto

### 10b — owned_sections

Para cada entrada em `owned_sections`, atualizar os SHAs por bloco/chave/seção:

**markdown_blocks (ex: CLAUDE.md):**
- Para cada bloco em `blocks[*]`:
  - Extraia o conteúdo interno entre o marker START e o marker END (excluindo as próprias linhas de marker)
  - Calcule `sha256` do conteúdo interno (string pura, sem processar)
  - Se divergir do `sha256` registrado → atualize o campo `sha256` do bloco no manifesto

**yaml_keys (ex: core-config.yaml):**
- Para cada chave em `owned_keys`:
  - Leia o valor da chave no arquivo YAML
  - Leia o campo `sha_method` da entrada no manifesto
  - Serialize o valor usando o algoritmo descrito em `sha_method`
  - Calcule `sha256` da string serializada
  - Se divergir do `sha256_by_key[chave]` registrado → atualize o campo no manifesto

**comment_blocks (ex: .env.example, .gitignore):**
- Para cada seção em `owned_sections[*]`:
  - Extraia o conteúdo interno entre os markers START/END (excluindo as linhas de marker)
  - Calcule `sha256` do conteúdo interno
  - Se divergir do `sha256` registrado → atualize o campo no manifesto

**json_keys (ex: .claude/settings.json):**
- Para cada entrada com `sha256_by_key` declarado no manifesto:
  - Parse do JSON do arquivo local
  - Para cada `owned_key` em `owned_keys`:
    - Serializar o valor atual: `json.dumps(value, sort_keys=True, separators=(',', ':'))`
    - Calcular `sha256` da string serializada
    - Se divergir do `sha256_by_key[chave]` → atualizar o campo no manifesto
- Se a entrada não tiver `sha256_by_key` → skip

### Confirmação

3. Se algum SHA foi atualizado → confirme: `✓ SHA sync: {N} arquivo(s)/bloco(s) atualizado(s) em manifest.yaml`
4. Se nenhum SHA divergiu → confirme: `✓ SHA sync: manifest.yaml já está atualizado`

---

## Confirmação Final

Exiba:
```
✓ Versão bumped: {antiga} → {nova}
✓ core-config.yaml atualizado
✓ CHANGELOG.md atualizado
✓ README.md atualizado
✓ kairos-version: {N} arquivo(s) atualizado(s)
✓ SHA sync: {N} arquivo(s)/bloco(s) atualizado(s) em manifest.yaml

{Se chamado standalone:}
Próximo passo: @kairos *pre-push → @kairos *push

{Se chamado embutido em *push (modo contribuidor):}
→ Bump concluído — retomando *push
```
