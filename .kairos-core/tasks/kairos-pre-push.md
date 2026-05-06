---
kairos-owned: true
kairos-version: 3.14.0
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
  - "[ ] Passo 0: *doctor — health check completo do framework (Checks 1–10)"
  - "[ ] Passo 1: Gate de review para stories MINOR/MAJOR ativas"
  - "[ ] Passo 2: Detectar e executar bump de versão pendente"
  - "[ ] Passo 2.5: Transição da story para Done"
  - "[ ] Passo 2.6: Atualizar kairos-version nos arquivos modificados"
  - "[ ] Passo 2.7: SHA sync do manifest.yaml"
  - "[ ] Passo 3: Spot check de referências quebradas"
  - "[ ] Passo 4: Propor e executar commit dos changes relevantes"
  - "[ ] Passo 5: Consistência final de versão (core-config vs CHANGELOG)"
  - "[ ] Exibir sumário e verdict"
---

# *pre-push — Pré-Voo Completo

O `*pre-push` é o centro do pré-voo: trata o gate de review, o bump de versão interativo, o commit e as verificações finais. Deve ser executado antes de cada `*push`.

## Execução

### Guard de Git

**ANTES de qualquer coisa**, verificar se o Git está disponível:

```bash
git --version
```

Se o comando falhar (Git não instalado ou não encontrado no PATH):

```
🚫 HALT — Git não encontrado.

O *pre-push requer Git para operar. Instale com:
  • Linux (apt):   sudo apt install git
  • macOS (brew):  brew install git
  • Windows:       winget install --id Git.Git -e

Deseja que eu execute a instalação agora? (s/n):
```

Se `s` (ou `sim`): executar o comando de instalação correspondente ao SO detectado com confirmação explícita antes de rodar.
Se `n` (ou `não`): HALT — encerrar sem executar nada.

---

### Passo 0 — *doctor (Health Check Completo)

**Objetivo:** executar o health check completo do framework antes de qualquer outro passo — fail fast em problemas estruturais.

Execute `*doctor` (Checks 1–10 conforme definido em `kairos-doctor.md`) e avalie o veredicto:

**Mapeamento de veredicto → decisão do `*pre-push`:**

| Veredicto `*doctor` | Ação |
|---------------------|------|
| `HEALTHY` | Confirme `✓ *doctor: HEALTHY — prosseguindo` e continue |
| `WARNING` | Verifique a natureza dos WARNs (ver abaixo) |
| `CRITICAL` | **BLOCK imediato** — listar todos os FAILs |

**Regra para `WARNING`:**

- WARNs de **integridade de manifesto** — arquivo com `kairos-owned: true` não está em `owned_files` (Check 9) → **BLOCK:**
  ```
  🚫 BLOCK — *doctor WARNING de manifest integrity:
    ⚠️ {arquivo} marca-se como kairos-owned mas não está no manifesto
  Adicione ao manifest.yaml e ao push-dual antes de continuar.
  ```
- WARNs de **drift de persona** (Check 3b) — YAML editado desde a última geração → **executar regeneração automática** antes de continuar:
  1. Identificar todos os squads afetados (extrair `{squad}` do path `squads/{squad}/agents/{id}.yaml` dos WARNs)
  2. Para cada squad com drift: executar `*regenerate-squad {squad}` (carregar `kairos-regenerate-squad.md` e executar inline)
  3. Após regeneração bem-sucedida: confirmar `✓ Regeneração automática: personas de {squad1}[, {squad2}] atualizadas`
  4. Continuar com o próximo passo do `*pre-push`
  5. Se regeneração falhar → **BLOCK:**
     ```
     🚫 BLOCK — Falha na regeneração automática de personas:
       ⚠️ {detalhe do erro}
     Rode *regenerate-squad {squad} manualmente e rode *pre-push novamente.
     ```
- Todos os demais WARNs (drift de SHA de owned_files, story sem gate, referência quebrada, YAML sem persona — check 3a, etc.) → **não bloqueam**; os warnings são listados no sumário final do `*pre-push` na seção "Avisos".

**BLOCK se:** veredicto `*doctor` = CRITICAL, **ou** se qualquer WARN for de categoria manifest integrity (arquivo `kairos-owned: true` fora de `owned_files`), **ou** se regeneração automática falhar.

---

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

   **e.** Atualize o `README.md`:

   Localize a linha que começa com `**Versão atual:**` e substitua a versão:
   ```
   **Versão atual:** `{nova versão}` — ver [CHANGELOG.md](CHANGELOG.md)
   ```

   **f.** Confirme: `✓ Versão bumped: {antiga} → {nova}`

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
      - Se `s` (ou `sim`): execute **UM único bump PATCH** inline seguindo os passos 2.a–2.f (com tipo `patch`), usando todas as stories de `patch_stories_pendentes` como "stories ativas" ao derivar a descrição no step 2.d; confirme: `✓ Versão bumped: {antiga} → {nova} (PATCH)`; em seguida, para cada story em `patch_stories_pendentes`, execute a transição Done (igual ao Passo 2.5): atualize status `In Review → Done`, atualize o epic, adicione entrada no Change Log da story
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

### Passo 2.6 — Atualizar `kairos-version` nos arquivos modificados

**Objetivo:** manter o campo `kairos-version` no frontmatter sincronizado com a versão em que cada arquivo foi tocado pela última vez.

Pré-condição: Passo 2.5 concluído (versão confirmada).

1. Execute `git status --porcelain` para listar arquivos modificados ou adicionados. Filtre linhas cujo código de duas letras (XY) contém `M` na posição X ou Y, ou `A` na posição X — padrões relevantes: `M `, ` M`, `MM`, `A `, `AM`. Ignorar `??` (untracked não staged) e `D`/` D` (deletados)
2. Para cada arquivo listado:
   - Leia o conteúdo e verifique se tem frontmatter YAML delimitado por `---`
   - Verifique se o frontmatter contém o campo `kairos-version:`
   - Se **sim**: atualize o valor para a versão atual (obtida de `.kairos-core/core-config.yaml`)
   - Se **não**: ignore — **não** criar o campo em arquivos que não o têm
3. Se algum arquivo foi atualizado → confirme: `✓ kairos-version: {N} arquivo(s) atualizado(s) para v{version}`
4. Se nenhum arquivo tinha o campo → confirme: `✓ kairos-version: sem frontmatter para atualizar`

> Os arquivos com `kairos-version` atualizado serão incluídos no commit do Passo 4.

---

### Passo 2.7 — SHA Sync

**Objetivo:** manter o `manifest.yaml` sincronizado com o estado atual dos arquivos framework. Executado **depois** do Passo 2.6 para capturar numa única passagem todas as modificações do ciclo (bump de versão, kairos-version, edições de conteúdo).

Pré-condição: Passo 2.6 concluído (kairos-version atualizado nos arquivos modificados).

#### 2.7a — owned_files

1. Leia `.kairos-core/manifest.yaml` → lista `owned_files`
2. Para cada entrada em `owned_files`:
   - Se `sha256 == "self-referential"` → pular esta entrada (sem calcular ou comparar)
   - Caso contrário: execute `sha256sum {path}` para calcular o SHA atual
   - Compare com o campo `sha256` registrado
   - Se divergir → atualize o campo `sha256` no manifesto

#### 2.7b — owned_sections

Para cada entrada em `owned_sections`, atualizar os SHAs por bloco/chave/seção:

**markdown_blocks (ex: CLAUDE.md):**
- Para cada bloco em `blocks[*]`:
  - Extraia o conteúdo interno entre o marker START e o marker END (excluindo as próprias linhas de marker)
  - Calcule `sha256` do conteúdo interno (string pura, sem processar)
  - Se divergir do `sha256` registrado → atualize o campo `sha256` do bloco no manifesto

**yaml_keys (ex: core-config.yaml):**
- Para cada chave em `owned_keys`:
  - Leia o valor da chave no arquivo YAML
  - Leia o campo `sha_method` da entrada no manifesto — esse campo é a especificação canônica do algoritmo de serialização (ex: `"yaml.dump({key: value}, sort_keys=False)"`)
  - Serialize o valor usando o algoritmo descrito em `sha_method`
  - Calcule `sha256` da string serializada
  - Se divergir do `sha256_by_key[chave]` registrado → atualize o campo no manifesto

**env_sections (ex: .env.example):**
- Para cada seção em `owned_sections[*]`:
  - Extraia o conteúdo interno entre `# KAIROS-MANAGED-START: {nome}` e `# KAIROS-MANAGED-END: {nome}` (excluindo as linhas de marker)
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

#### Confirmação

3. Se algum SHA (owned_files ou owned_sections) foi atualizado → confirme: `✓ SHA sync: {N} arquivo(s)/bloco(s) atualizado(s) em manifest.yaml`
4. Se nenhum SHA divergiu → confirme: `✓ SHA sync: manifest.yaml já está atualizado`

> Os arquivos modificados pelo SHA sync serão incluídos no commit do Passo 4.

---

### Passo 3 — Referências quebradas (spot check)

**Objetivo:** verificar links internos nos arquivos `.md` modificados antes de commitar — para que o executor possa corrigir eventuais problemas antes de o commit acontecer.

Pré-condição: Passo 2.7 concluído (SHA sync realizado).

Para arquivos `.md` modificados recentemente (identificados no pré-check):
- Verificar links internos `[texto](caminho)` — o path existe no repo?
- Verificar referências a tasks em YAML — o arquivo da task existe?

**Resolução de paths relativos:** ao verificar um link relativo, resolver o path **a partir do diretório do arquivo que contém o link** — não a partir de `docs/` nem da raiz do repositório.

Exemplo correto: link `../stories/3.1.story.md` encontrado em `docs/epics/epic-3-*.md`
→ resolver a partir de `docs/epics/` → `docs/epics/../stories/3.1.story.md` → `docs/stories/3.1.story.md` ✓

Limite: verificar até 10 arquivos. Não é revisão exaustiva.

**BLOCK se:** referência crítica quebrada (agente referencia task inexistente, story aponta para epic inexistente).

---

### Passo 4 — Commit

**Objetivo:** garantir que as mudanças relevantes estão commitadas antes do push.

Pré-condição: Passo 3 concluído (spot check realizado).

1. Execute `git status` para listar arquivos com changes relevantes (excluindo `.kairos-core/runtime/`, `data/`, `node_modules/`)

2. Se existem arquivos relevantes não commitados:
   a. Derive a descrição e o tipo do commit automaticamente a partir dos arquivos modificados (mesmo padrão do Passo 2.d para o CHANGELOG):

      **Descrição:**

      1. Para cada story ativa (gate_ok = true ou patch_stories_pendentes):
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
           → separe em: novos (status `A`) vs modificados (status `M`)
         - Se lista não vazia:
           → descrição = `"{basename1}, {basename2}: adicionado|atualizado"`
             (todos novos → `adicionado`; qualquer modificado → `atualizado`; usar basename sem path completo quando autoexplicativo)

      3. Fallback final: `"ajuste de instrução no framework"`

      **Tipo (type) — inferir do conteúdo:**
      - `fix` → se a descrição contém palavras de correção (`corrigir`, `fix`, `corrige`, `ajuste`, `remove`, `bug`) ou se todos os arquivos modificados são `M` (sem adições)
      - `feat` → se há arquivos novos (`A`) ou a descrição indica criação de capacidade nova
      - `docs` → se todos os arquivos modificados são `.md` e nenhum é task ou persona de agente
      - `chore` → se os únicos arquivos modificados são manifest, core-config, CHANGELOG, README ou arquivos de kairos-version sync
      - Padrão quando ambíguo: `feat`

   b. Leia a versão atual de `.kairos-core/core-config.yaml`
   c. Exiba para ciência (não para edição):
      ```
      Mudanças não commitadas encontradas.
      Mensagem sugerida: "{type}: {descrição derivada} v{version}"
      Deseja fazer commit agora? (s/n):
      ```
   d. Se `s` (ou `sim`):
      - Execute `git add` nos arquivos relevantes (excluindo `.kairos-core/runtime/`, `data/`, `node_modules/`)
      - Construa a mensagem de commit:
        - Subject: `{type}: {descrição derivada} v{version}` — sem referência a story ID ou título
        - Se há story(ies) ativa(s): adicionar corpo estendido com referência interna:
          ```
          Stories: {story-id1}[, {story-id2}, ...]
          ```
      - Execute `git commit` passando subject + corpo via heredoc (se houver stories ativas) ou apenas subject (se não houver)
      - Confirme: `✓ Commit realizado`
   e. Se `n` (ou `não`):
      **BLOCK:**
      ```
      🚫 BLOCK — Mudanças não commitadas. Faça o commit manualmente e rode *pre-push novamente.
      ```

3. Se não há mudanças relevantes não commitadas → confirme: `✓ Sem changes pendentes`

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
  ✅ Passo 0 — *doctor (HEALTHY | regeneração automática executada se drift | warnings listados abaixo se houver)
  ✅ Passo 1 — Gate de review (stories MINOR/MAJOR com gate PASS/RESSALVA)
  ✅ Passo 2 — Versionamento ({bump feito: antiga → nova | sem bump pendente | PATCH: bump aplicado/ignorado pelo usuário})
  ✅ Passo 2.6 — kairos-version ({N} atualizado(s) | sem frontmatter)
  ✅ Passo 2.7 — SHA sync ({N} atualizado(s) | já atualizado)
  ✅ Passo 3 — Referências verificadas
  ✅ Passo 4 — Commit ({mensagem do commit | sem changes pendentes})
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
