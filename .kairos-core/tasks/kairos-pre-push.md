---
kairos-owned: true
kairos-version: 3.1.8
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
  - "[ ] Passo 1: Gate de review para stories MINOR/MAJOR ativas"
  - "[ ] Passo 2: Detectar e executar bump de versão pendente"
  - "[ ] Passo 2.5: Transição da story para Done"
  - "[ ] Passo 2.6: SHA sync do manifest.yaml"
  - "[ ] Passo 2.7: Atualizar kairos-version nos arquivos modificados"
  - "[ ] Passo 3: Propor e executar commit dos changes relevantes"
  - "[ ] Passo 4: Spot check de referências quebradas"
  - "[ ] Passo 5: Consistência final de versão (core-config vs CHANGELOG)"
  - "[ ] Exibir sumário e verdict"
---

# *pre-push — Pré-Voo Completo

O `*pre-push` é o centro do pré-voo: trata o gate de review, o bump de versão interativo, o commit e as verificações finais. Deve ser executado antes de cada `*push`.

## Execução

### Pré-check — Ler estado do repositório

Execute e guarde em memória de sessão:

```bash
git status
git diff --stat HEAD
git log --oneline -5
```

Identifique:
- Branch atual, último commit (hash + mensagem)
- Arquivos com mudanças relevantes: staged + modificados não staged + untracked
- **Excluir de "relevantes":** `.kairos-core/runtime/`, `data/`, `node_modules/`

---

### Passo 1 — Gate de review

**Objetivo:** garantir que stories MINOR/MAJOR têm gate aprovado.

1. Liste todos os arquivos `docs/stories/*.story.md`
2. Identifique os que têm Status `In Progress` ou `In Review`
3. Para cada story identificada, determine se o conteúdo implica bump MINOR ou MAJOR:
   - **MINOR:** novo agente, nova task, nova rule, nova capacidade
   - **MAJOR:** novo squad/escopo, breaking change em agente existente
   - **PATCH:** correção, ajuste de instrução, atualização de memória → gate não obrigatório
4. Para stories MINOR ou MAJOR:
   - Procure gate em `docs/qa/gates/{story-id}-*.yaml` (qualquer data)
   - Leia o campo `verdict` do gate mais recente
   - Se `verdict: PASS` ou `verdict: RESSALVA` → registrar: `gate_ok[story-id] = true`
   - Se não existe gate, ou `verdict: BLOCK` → **BLOCK:**
     ```
     🚫 BLOCK — Story {id} ({título}) é MINOR/MAJOR e não tem gate PASS.
     Rode: *review {id}
     ```

**BLOCK se:** qualquer story MINOR/MAJOR ativa sem gate PASS ou RESSALVA.

---

### Passo 2 — Versionamento

**Objetivo:** detectar bump pendente e executar se necessário.

Pré-condição: Passo 1 passou (gate_ok confirmado para stories MINOR/MAJOR ativas).

1. Para cada story MINOR/MAJOR com `gate_ok = true`:
   a. Identifique a data do gate mais recente (nome do arquivo: `{story-id}-{YYYY-MM-DD}.yaml`)
   b. Leia `CHANGELOG.md` → data da entrada mais recente (formato `## [versão] — YYYY-MM-DD`)
   c. Se data do CHANGELOG >= data do gate → bump provavelmente feito → OK
   d. Se data do CHANGELOG < data do gate, ou CHANGELOG sem entradas → **bump pendente**

2. Se bump pendente detectado, pergunte:
   ```
   Story {id} é MINOR/MAJOR — sem bump. Qual tipo? (patch/minor/major):
   ```
   Aguarde resposta do usuário. Então execute bump inline:

   > Nota de manutenção: a lógica abaixo deve permanecer em sincronia com `kairos-version-bump.md`. Se essa task for atualizada, revisar este passo.

   **a.** Leia versão atual de `.kairos-core/core-config.yaml` → campo `version`

   **b.** Calcule nova versão:
   - `patch` → incrementa PATCH
   - `minor` → incrementa MINOR, zera PATCH
   - `major` → incrementa MAJOR, zera MINOR e PATCH

   **c.** Atualize `.kairos-core/core-config.yaml`:
   ```yaml
   version: {nova versão}
   updatedAt: '{ISO 8601 timestamp}'
   ```

   **d.** Derive a descrição automaticamente para o CHANGELOG (sem prompt ao usuário):

   ```
   1. Para cada story ativa (que disparou o bump):
      - Leia docs/stories/{story-id}.story.md
      - Localize "## Execution Log" → "### O que foi feito"
      - Se encontrado, pegue o primeiro item de lista (linha iniciada com "- ")
      - Sanitize: remover "(story X.Y)", "story X.Y", backticks de paths, texto entre aspas duplas
      → Se múltiplas stories: concatenar os bullets sanitizados separados por "; "
      → Se ao menos uma story tem o bullet: usar como descrição (prioridade 1)

   2. Se nenhuma story tem "## Execution Log" → "### O que foi feito":
      - Execute git diff HEAD --name-only e git diff --cached --name-only
        → union dos dois conjuntos de arquivos modificados/adicionados
      - Leia .kairos-core/manifest.yaml → owned_files (campo path de cada entrada)
        → mantenha apenas os arquivos que constam no manifesto
        → separe em: novos (status A no git) vs modificados (status M no git)
      - Se lista não vazia:
        → descrição = "{basename1}, {basename2}: adicionado|atualizado"
          (todos novos → "adicionado"; qualquer modificado → "atualizado")
          usar basename sem path completo quando autoexplicativo

   3. Fallback final: "ajuste de instrução no framework"
   ```

   Exiba para ciência (não para edição):
   ```
   → Descrição para CHANGELOG: "{descrição derivada}"
   ```

   Adicione entrada no topo do `CHANGELOG.md` (após cabeçalho, antes da entrada mais recente):
   ```markdown
   ## [{nova versão}] — {YYYY-MM-DD}

   ### Adicionado
   - {descrição derivada}
   ```

   **e.** Confirme: `✓ Versão bumped: {antiga} → {nova}`

3. Se nenhum bump pendente → confirme: `✓ Versão atual: {version} — sem bump pendente`

4. **Stories PATCH com gate (prompt opcional — não bloqueante):**

   > **Por que timestamp de commit e não data-dia:** comparar `YYYY-MM-DD` causa falso positivo quando o bump anterior e o gate ocorrem no mesmo dia de calendário — o sistema suprime o prompt mesmo sem bump novo. Timestamps epoch unix distinguem a ordem real dos eventos independente do dia. Não reverter para comparação por data.
   >
   > **Fallbacks de epoch:** `epoch_gate = 99999999999` (sentinel alto) quando o gate não foi commitado — garante que `epoch_changelog > epoch_gate` seja sempre falso, forçando a exibição do prompt. `epoch_changelog = 0` quando o CHANGELOG não foi commitado — garante que `0 <= epoch_gate`, também forçando o prompt. Não inverter os sentinels: usar `0` para `epoch_gate` causaria falso skip porque qualquer `epoch_changelog > 0` satisfaz a condição de skip.

   a. Liste todos os arquivos `docs/qa/gates/*.yaml`
   b. Para cada gate com `verdict: PASS` ou `verdict: RESSALVA`, identifique a story correspondente pelo prefixo do nome do arquivo (`{story-id}-{YYYY-MM-DD}.yaml`)
   c. Determine se a story implica bump **PATCH** (não é MINOR nem MAJOR — correção, ajuste de instrução, atualização de memória)
   d. Para cada story PATCH com gate PASS/RESSALVA, calcule os epochs:
      - Obtenha o timestamp epoch do gate:
        ```bash
        git log -1 --format="%ct" -- docs/qa/gates/{story-id}-{date}.yaml
        ```
        Se o comando retornar vazio (gate ainda não commitado) → usar `epoch_gate = 99999999999`
        *(sentinel alto garante que `epoch_changelog > epoch_gate` seja sempre falso — prompt sempre aparece quando gate não foi commitado)*
      - Obtenha o timestamp epoch do último commit do CHANGELOG:
        ```bash
        git log -1 --format="%ct" -- CHANGELOG.md
        ```
        Se o comando retornar vazio (CHANGELOG ainda não commitado) → usar `epoch_changelog = 0`
        *(`0 <= epoch_gate` → condição de skip não satisfeita → prompt aparece — comportamento correto)*
      - Se `epoch_changelog > epoch_gate` → bump realizado após o gate → **skip** (não adicionar à lista)
      - Caso contrário: adicionar à lista `patch_stories_pendentes`
   e. Após processar todas as stories PATCH:
      - Se `patch_stories_pendentes` estiver vazia → continuar sem prompt
      - Se `patch_stories_pendentes` tem **1 story** → exiba prompt **não-bloqueante**:
        ```
        ⚠️  Story {id} é PATCH — sem bump desde o último release.
        Deseja bumpar agora? (s/n):
        ```
      - Se `patch_stories_pendentes` tem **> 1 story** → exiba prompt consolidado **não-bloqueante**:
        ```
        ⚠️  Stories PATCH pendentes de bump: {id1}, {id2} — deseja bumpar agora? (s/n):
        ```
      - Se `s` (ou `sim`): execute **UM único bump PATCH** inline seguindo os passos 2.a–2.e (com tipo `patch`), usando todas as stories de `patch_stories_pendentes` como "stories ativas" ao derivar a descrição no step 2.d; confirme: `✓ Versão bumped: {antiga} → {nova} (PATCH)`; em seguida, para cada story em `patch_stories_pendentes`, execute a transição Done (igual ao Passo 2.5): atualize status `In Review → Done`, atualize o epic, adicione entrada no Change Log da story
      - Se `n` (ou `não`): registre aviso internamente e **continue normalmente — sem BLOCK**

   > Stories PATCH sem gate algum (não passaram por `*review`) não disparam o prompt.

---

### Passo 2.5 — Transição da story para Done

**Objetivo:** marcar a story como Done antes de commitar, para que o commit inclua o status final.

Pré-condição: Passo 2 concluído (versão confirmada).

Para cada story com `gate_ok = true` (gate PASS ou RESSALVA confirmado no Passo 1 — stories MINOR/MAJOR). Stories PATCH são tratadas no Passo 4.
1. Atualize `**Status:** In Review` → `**Status:** Done` no arquivo da story
2. Atualize a entrada da story no epic (`docs/epics/epic-{N}-*.md`): `In Review` → `Done`
3. Adicione entrada no Change Log da story:
   ```markdown
   | {data} | *pre-push: gate confirmado — status → Done |
   ```

> `*review` nunca move para Done — essa transição é exclusiva do `*pre-push`.

---

### Passo 2.6 — SHA Sync

**Objetivo:** manter o `manifest.yaml` sincronizado com o estado atual dos arquivos framework.

Pré-condição: Passo 2.5 concluído.

1. Leia `.kairos-core/manifest.yaml` → lista `owned_files`
2. Para cada entrada em `owned_files`:
   - Execute `sha256sum {path}` para calcular o SHA atual
   - Compare com o campo `sha256` registrado
   - Se divergir → atualize o campo `sha256` no manifesto
3. Se algum SHA foi atualizado → confirme: `✓ SHA sync: {N} arquivo(s) atualizado(s) em manifest.yaml`
4. Se nenhum SHA divergiu → confirme: `✓ SHA sync: manifest.yaml já está atualizado`

> Os arquivos modificados pelo SHA sync serão incluídos no commit do Passo 3.

---

### Passo 2.7 — Atualizar `kairos-version` nos arquivos modificados

**Objetivo:** manter o campo `kairos-version` no frontmatter sincronizado com a versão em que cada arquivo foi tocado pela última vez.

Pré-condição: Passo 2.6 concluído (versão confirmada, SHA sync realizado).

1. Execute `git status --porcelain` para listar arquivos modificados ou adicionados. Filtre linhas cujo código de duas letras (XY) contém `M` na posição X ou Y, ou `A` na posição X — padrões relevantes: `M `, ` M`, `MM`, `A `, `AM`. Ignorar `??` (untracked não staged) e `D`/` D` (deletados)
2. Para cada arquivo listado:
   - Leia o conteúdo e verifique se tem frontmatter YAML delimitado por `---`
   - Verifique se o frontmatter contém o campo `kairos-version:`
   - Se **sim**: atualize o valor para a versão atual (obtida de `.kairos-core/core-config.yaml`)
   - Se **não**: ignore — **não** criar o campo em arquivos que não o têm
3. Se algum arquivo foi atualizado → confirme: `✓ kairos-version: {N} arquivo(s) atualizado(s) para v{version}`
4. Se nenhum arquivo tinha o campo → confirme: `✓ kairos-version: sem frontmatter para atualizar`

> Os arquivos com `kairos-version` atualizado serão incluídos no commit do Passo 3.

---

### Passo 3 — Commit

**Objetivo:** garantir que as mudanças relevantes estão commitadas antes do push.

Pré-condição: Passo 2.7 concluído (kairos-version atualizado nos arquivos modificados).

1. Execute `git status` para listar arquivos com changes relevantes (excluindo `.kairos-core/runtime/`, `data/`, `node_modules/`)

2. Se existem arquivos relevantes não commitados:
   a. Identifique a story ativa (a que teve gate confirmado no Passo 1)
   b. Converta o título da story para kebab-case: minúsculas, espaços → hífens, remover acentos e caracteres especiais
   c. Leia a versão atual de `.kairos-core/core-config.yaml`
   d. Exiba:
      ```
      Mudanças não commitadas encontradas.
      Mensagem sugerida: "feat: {story-title-em-kebab-case} v{version}"
      Deseja fazer commit agora? (s/n):
      ```
   e. Se `s` (ou `sim`):
      - Execute `git add` nos arquivos relevantes (excluindo `.kairos-core/runtime/`, `data/`, `node_modules/`)
      - Execute `git commit -m "feat: {story-title-em-kebab-case} v{version}"`
      - Confirme: `✓ Commit realizado`
   f. Se `n` (ou `não`):
      **BLOCK:**
      ```
      🚫 BLOCK — Mudanças não commitadas. Faça o commit manualmente e rode *pre-push novamente.
      ```

3. Se não há mudanças relevantes não commitadas → confirme: `✓ Sem changes pendentes`

---

### Passo 4 — Referências quebradas (spot check)

Para arquivos `.md` modificados recentemente (identificados no pré-check):
- Verificar links internos `[texto](caminho)` — o path existe no repo?
- Verificar referências a tasks em YAML — o arquivo da task existe?

Limite: verificar até 10 arquivos. Não é revisão exaustiva.

**BLOCK se:** referência crítica quebrada (agente referencia task inexistente, story aponta para epic inexistente).

---

### Passo 5 — Consistência final

**Objetivo:** garantir que core-config e CHANGELOG estão sincronizados.

1. Leia `.kairos-core/core-config.yaml` → campo `version`
2. Leia `CHANGELOG.md` → versão da primeira entrada (formato `## [versão] — data`)
3. Se versões coincidem → `✓ Versão consistente: {version}`
4. Se não coincidem → **BLOCK:**
   ```
   🚫 BLOCK — Inconsistência de versão:
     core-config.yaml: {v1}
     CHANGELOG.md:     {v2}
   ```

---

### Resultado Final

**Se todos os passos PASS:**
```
✅ PRE-PUSH PASS

Resumo:
  Branch: {branch}
  Último commit: {hash} {mensagem}
  Versão: {version}

Checks:
  ✅ Passo 1 — Gate de review (stories MINOR/MAJOR com gate PASS/RESSALVA)
  ✅ Passo 2 — Versionamento ({bump feito: antiga → nova | sem bump pendente | PATCH: bump aplicado/ignorado pelo usuário})
  ✅ Passo 2.6 — SHA sync ({N} atualizado(s) | já atualizado)
  ✅ Passo 2.7 — kairos-version ({N} atualizado(s) | sem frontmatter)
  ✅ Passo 3 — Commit ({mensagem do commit | sem changes pendentes})
  ✅ Passo 4 — Referências verificadas
  ✅ Passo 5 — Versão consistente ({version})

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

---

## Estado de Sessão

Após execução, registre internamente:
- `pre_push_passed = true` se PASS
- `pre_push_passed = false` se BLOCK

O comando `*push` verifica este estado antes de executar.
