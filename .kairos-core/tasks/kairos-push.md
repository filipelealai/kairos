---
kairos-owned: true
kairos-version: 4.2.0
task: Kairos Push
responsavel: "@kairos"
responsavel_type: agent
atomic_layer: deployment
elicit: false
Entrada: |
  - pre_push_passed: deve ser true na sessão atual apenas se scope=framework e há story type:kairos-core In Review
Saida: |
  - git push executado ao remoto
  - Confirmação com hash do commit e URL (se disponível)
Checklist:
  - "[ ] Pré-check: detectar escopo (instance-only vs framework)"
  - "[ ] Verificar pre_push_passed (somente se scope=framework e há story type:kairos-core In Review)"
  - "[ ] Passo 0a: *doctor (apenas via *version — somente em scope=framework)"
  - "[ ] Passo 0b: Detectar drift de persona (sempre, independente de escopo)"
  - "[ ] Passo 0c: Prompt modo contribuidor + *version inline (somente em scope=framework)"
  - "[ ] Passo 0c-bis: Prompt de intenção (scope=framework sem story type:kairos-core In Review)"
  - "[ ] Passo 0d: Gate pre_push_passed (somente se há story type:kairos-core In Review)"
  - "[ ] Passo 1: Transição Done (stories com gate_ok)"
  - "[ ] Passo 2: Commit"
  - "[ ] Passo 3: Confirmar branch de destino"
  - "[ ] Passo 4: git push"
---

# *push — Orquestrador de Release

O `*push` é o orquestrador do ciclo de release: detecta escopo, invoca `*version` quando há mudanças de framework, faz a transição Done das stories, commita e faz push. `*pre-push` é obrigatório apenas quando há story `type:kairos-core` In Review — para pushes de instância não é necessário.

## Guard de Git

**ANTES de qualquer coisa**, verificar se o Git está disponível:

```bash
git --version
```

Se o comando falhar (Git não instalado ou não encontrado no PATH):

```
🚫 HALT — Git não encontrado.

O *push requer Git para operar. Instale com:
  • Linux (apt):   sudo apt install git
  • macOS (brew):  brew install git
  • Windows:       winget install --id Git.Git -e

Deseja que eu execute a instalação agora? (s/n):
```

Se `s` (ou `sim`): executar o comando de instalação correspondente ao SO detectado com confirmação explícita antes de rodar.
Se `n` (ou `não`): HALT — encerrar sem executar nada.

---

## Pré-check — Detectar Escopo

Execute:

```bash
git diff HEAD --name-only
git diff --cached --name-only
git status --porcelain
```

Leia `.kairos-core/manifest.yaml` → `owned_files[].path` e `owned_sections[].path`.

Cruzar arquivos modificados (excluindo `.kairos-core/runtime/`, `data/`, `node_modules/`) com o manifest:

- **scope = framework** — ao menos um arquivo modificado consta em `owned_files` ou `owned_sections`
- **scope = instance-only** — nenhum arquivo modificado consta no manifest

**Se scope = instance-only:**
- Pular Passos 0a, 0c, 0d — e o guard de `pre_push_passed` não se aplica
- Executar sempre: Passo 0b (drift de persona)
- Ir direto para: Passo 1 (transição Done, se aplicável) → Passo 2 (commit) → Passo 3 → Passo 4

**Se scope = framework:**

Verificar o estado de sessão **antes** de prosseguir para os Passos 0a-0d:

```
SE há story type:kairos-core com Status "In Review"
  E pre_push_passed != true na sessão atual:
    RECUSAR com:
    "🚫 Push recusado. *pre-push não foi executado ou retornou BLOCK nesta sessão.
     Execute *pre-push primeiro e certifique-se de que retorna PASS."
    HALT — não continuar
```

Se `*pre-push` foi rodado em outra sessão (não a atual), tratar como não executado.
Se não há story `type:kairos-core` In Review: prosseguir sem verificar `pre_push_passed`.

---

## Execução

### Passo 0a — *doctor (somente scope=framework)

**Objetivo:** garantir que o framework está íntegro antes de versionar. O doctor é executado automaticamente pelo `*version` quando invocado no Passo 0c — não executa `*doctor` diretamente aqui; o resultado vem do `*version`.

Se scope=instance-only: pular este passo (confirmação: `⏭  Passo 0a — pulado (scope=instance-only)`).

---

### Passo 0b — Detectar Drift de Persona (sempre)

**Objetivo:** garantir que personas geradas de YAMLs de squad estejam atualizadas antes de commitar.

Este passo roda **sempre**, independente de escopo.

Para cada arquivo `squads/*/agents/*.yaml` encontrado no filesystem:

1. Construir o path esperado da persona: `.claude/commands/kairos/agents/{id}.md`
2. Verificar se a persona existe
3. Se existe, ler a primeira linha e verificar se contém o marcador `<!-- kairos-generated-from: ... sha:{sha256} -->`
4. Se o marcador existe:
   - Extrair o SHA declarado no marcador
   - Calcular SHA atual do YAML: `sha256sum squads/{squad}/agents/{id}.yaml | cut -d' ' -f1`
   - Se divergir → drift detectado para este squad

5. Após verificar todos os YAMLs, agregar os squads com drift:

   **Se há squads com drift:**
   - Para cada squad com drift: invocar `*regenerate-squad {squad}` (carregar `kairos-regenerate-squad.md` e executar inline)
   - Após regeneração bem-sucedida: confirmar `✓ Regeneração: personas de {squad1}[, {squad2}] atualizadas`
   - Se `kairos-regenerate-squad.md` não estiver disponível: emitir WARN (não bloquear):
     ```
     ⚠️  WARN — drift de persona detectado em {squad(s)} mas *regenerate-squad não disponível.
     As personas podem estar desatualizadas. Rode *regenerate-squad {squad} manualmente.
     ```
   - Se regeneração falhar: emitir WARN (não bloquear):
     ```
     ⚠️  WARN — Falha na regeneração automática de personas: {detalhe do erro}
     Rode *regenerate-squad {squad} manualmente.
     ```

   **Se não há drift:** confirmar `✓ Passo 0b — personas atualizadas (sem drift)`

> Passo 0b não bloqueia o push — emite WARNs para garantir visibilidade mas não interrompe o fluxo.

---

### Passo 0c — Prompt "Modo Contribuidor" (somente scope=framework)

**Objetivo:** detectar se há bump de versão pendente e oferecer ao usuário a oportunidade de versionar antes de commitar. "Modo contribuidor" comunica que essa governança serve para quem contribui upstream com o Kairos público — para uso local/fork pessoal o bump é opcional (ver Passo 0c-bis).

Se scope=instance-only: pular este passo.

Para cada story em `In Review` com `type: kairos-core`:
- Verificar se há bump pendente usando a mesma lógica de epoch do ciclo anterior:
  - Obter epoch do gate mais recente: `git log -1 --format="%ct" -- docs/qa/gates/{story-id}-{date}.yaml`
    → Se vazio: `epoch_gate = 99999999999`
  - Obter epoch do último commit do CHANGELOG: `git log -1 --format="%ct" -- CHANGELOG.md`
    → Se vazio: `epoch_changelog = 0`
  - Se `epoch_changelog > epoch_gate` → bump já feito → skip
  - Caso contrário → bump pendente para esta story

Se há bump pendente detectado:

```
⚠️  Modo contribuidor detectado: há stories type:kairos-core sem bump desde o último release
(obrigatório para contribuir com o Kairos público; opcional para uso local/fork pessoal).

Stories pendentes: {id1}[, {id2}, ...]

Deseja versionar agora antes de commitar? (s/n):
```

Se `s` (ou `sim`):
- Perguntar: `Qual tipo de bump? (patch/minor/major):`
- Aguardar resposta
- Invocar `*version` inline com o tipo informado (carregar `kairos-version-bump.md` e executar)
- Após conclusão: confirmar `✓ *version concluído — retomando *push`

Se `n` (ou `não`): registrar aviso internamente e continuar normalmente — sem BLOCK.

Se não há bump pendente: confirmar `✓ Passo 0c — sem bump pendente`.

---

### Passo 0c-bis — Prompt de Intenção (scope=framework sem story type:kairos-core In Review)

**Objetivo:** fechar o loophole em que mudanças em arquivos de framework (declarados no manifesto) seriam empurradas sem story `type:kairos-core`, sem gate de `*review` e sem `pre_push_passed`. Quando esse cenário é detectado, perguntar explicitamente a intenção do usuário.

**Condições para executar este passo:**
- scope = framework, **e**
- **não** há nenhuma story `type:kairos-core` com Status `In Review`

Caso contrário (scope=instance-only, ou há story `type:kairos-core` In Review): pular este passo. Confirmação: `⏭  Passo 0c-bis — não aplicável`.

**Detecção dos arquivos de framework modificados:** reaproveitar a lista construída no Pré-check (cruzamento de `git diff/git status` com `owned_files[].path` e `owned_sections[].path` do manifesto).

**Exibir prompt:**

```
Detectei modificação em arquivos do framework Kairos (listados no manifesto):
  - {arquivo 1}
  - {arquivo 2}
  - ...

Estas mudanças são para contribuir com o Kairos público (upstream) ou
são apenas para seu uso local/fork?

(c) Contribuidor — exige story type:kairos-core + gate PASS/RESSALVA + pre_push_passed
(l) Local apenas — segue sem story/gate (sua responsabilidade; será barrado pelo CI se PR for aberto)
(a) Abortar push
```

Aguardar resposta. Tratamento (case-insensitive):

- **`c` / `contribuidor`** → **BLOCK** com instruções de story retroativa:
  ```
  🚫 Push recusado — modo contribuidor exige story type:kairos-core + gate + pre_push_passed.

  Como as mudanças já foram feitas, crie uma story retroativa:

  1. @kairos *new-story type=kairos-core
     → descrever o que foi modificado e a motivação
  2. Marcar a story como In Review e preencher Execution Log
     com o que foi feito (arquivos, decisões, pendências)
  3. @kairos *review
     → obter gate PASS/RESSALVA
  4. @kairos *pre-push
     → validar e marcar pre_push_passed
  5. *push novamente
  ```
  HALT — não continuar.

- **`l` / `local`** → registrar `local_intent = true` na sessão e prosseguir. O Passo 2 (Commit) deve injetar o seguinte warning persistente na mensagem de commit (no corpo, após o subject):
  ```
  ⚠️  framework files modified outside contributor flow
  ```
  Confirmação imediata após resposta: `⚠️  Modo local — prosseguindo com warning no commit. Sua responsabilidade.`

- **`a` / `abortar`** → abortar `*push` sem modificar Git/arquivos. Mensagem: `⏹  *push abortado pelo usuário (Passo 0c-bis).` HALT.

- **Qualquer outra resposta** (vazia, inválida, fora de `c`/`l`/`a`) → repergunta exibindo o mesmo prompt até receber resposta válida. Não assumir default.

---

### Passo 0d — Gate Pre-Push (somente se há story type:kairos-core In Review)

**Objetivo:** verificar gate antes de transitar para Done.

Se não há nenhuma story `type: kairos-core` com Status `In Review`: pular este passo.

Para cada story `type: kairos-core` In Review:
- Procure gate em `docs/qa/gates/{story-id}-*.yaml`
- Se `verdict: PASS` ou `verdict: RESSALVA` → registrar: `gate_ok[story-id] = true`
- Se não existe gate, ou `verdict: BLOCK` → **BLOCK:**
  ```
  🚫 BLOCK — Story {id} ({título}) não tem gate PASS/RESSALVA.
  Rode: @kairos *review {id}
  ```

---

### Passo 1 — Transição Done

**Objetivo:** marcar stories como Done antes de commitar, para que o commit inclua o status final.

Para cada story com `gate_ok = true` (gate PASS ou RESSALVA confirmado no Passo 0d — stories `type: kairos-core`):

1. Verificar o status atual da story no arquivo `docs/stories/{story-id}.story.md`:
   - Se `**Status:** Done` → **pular** esta story (já foi marcada como Done via `*implement` ou `*review`) — confirmar: `⏭  Story {id} já está Done — pulando transição`
   - Se `**Status:** In Review` → executar a transição:
     1. Atualize `**Status:** In Review` → `**Status:** Done` no arquivo da story
     2. Atualize a entrada da story no epic (`docs/epics/epic-{N}-*.md`): `In Review` → `Done`
     3. Adicione entrada no Change Log da story:
        ```markdown
        | {data} | *push: gate confirmado — status → Done |
        ```

> Stories `type: instance` podem ter sido marcadas como Done diretamente via `*implement` ou `*review` — o `*push` detecta e pula a transição, mas ainda as inclui normalmente no commit.

---

### Passo 2 — Commit

**Objetivo:** garantir que as mudanças relevantes estão commitadas antes do push.

1. Execute `git status` para listar arquivos com changes relevantes (excluindo `.kairos-core/runtime/`, `data/`, `node_modules/`)

2. Se existem arquivos relevantes não commitados:
   a. Derive a descrição e o tipo do commit automaticamente:

      **Descrição:**
      1. Para cada story com `gate_ok = true`:
         - Leia `docs/stories/{story-id}.story.md`
         - Localize `## Execution Log` → `### O que foi feito`
         - Se encontrado, pegue o primeiro item de lista e sanitize (remover `(story X.Y)`, `story X.Y`, backticks, aspas duplas)
         → Se múltiplas stories: concatenar com `; `
         → Se ao menos uma story tem o bullet: usar como descrição (prioridade 1)
      2. Se nenhuma story tem o bullet: usar basenames dos arquivos modificados do manifest (`adicionado|atualizado`)
      3. Fallback: `"ajuste de instrução no framework"`

      **Tipo (type):**
      - `fix` → se a descrição contém palavras de correção ou todos os arquivos são `M`
      - `feat` → se há arquivos novos (`A`) ou a descrição indica nova capacidade
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
        - Subject: `{type}: {descrição derivada} v{version}`
        - Corpo estendido (concatenar linhas abaixo conforme aplicável, separadas por linha em branco):
          - Se há stories com gate_ok: `Stories: {story-id1}[, {story-id2}, ...]`
          - Se `local_intent = true` na sessão (Passo 0c-bis): `⚠️  framework files modified outside contributor flow`
      - Execute `git commit` passando subject + corpo via heredoc (se houver corpo) ou apenas subject
      - Confirme: `✓ Commit realizado`
   e. Se `n` (ou `não`):
      **BLOCK:**
      ```
      🚫 BLOCK — Mudanças não commitadas. Faça o commit manualmente e rode *push novamente.
      ```

3. Se não há mudanças relevantes não commitadas → confirme: `✓ Sem changes pendentes`

---

### Passo 3 — Confirmar Branch

```bash
git branch --show-current
```

Se branch é `main`:
- Avisar: "Você está prestes a fazer push direto para `main`. Confirma? (s/n)"
- Aguardar confirmação antes de prosseguir

Se branch é outra: prosseguir sem confirmação adicional.

---

### Passo 4 — Executar Push

```bash
git push origin {branch}
```

**Se push bem-sucedido:**
```
✅ Push realizado com sucesso

Branch: {branch}
Remote: origin
Último commit: {hash} — {mensagem}

{URL do remote se disponível via git remote get-url origin}
```

**Se push falhou:**
```
❌ Push falhou

Erro: {stderr do git}

Possíveis causas:
- Remote divergiu — rode: git pull --rebase origin {branch}
- Sem permissão — verifique credenciais git
- Branch protegida — contate administrador do repo
```

---

### Pós-push

Resetar `pre_push_passed = false` em sessão (força novo `*pre-push` no próximo ciclo).

---

## Restrições

- **Nunca** usar `--force` ou `--force-with-lease` sem confirmação explícita do usuário
- **Nunca** fazer push de `main` sem confirmação explícita
- **Nunca** executar sem pre_push_passed = true quando scope=framework e há story `type:kairos-core` In Review
