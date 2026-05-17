---
kairos-owned: true
kairos-version: 5.0.0
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

`*doctor` é runtime-aware. Reporte os resultados agrupados em:

```text
Core canônico
Runtime Claude
Runtime Codex
Materialização e ownership
Instância / squads
Operação local
```

Checks de runtime validam se cada runtime consegue carregar o Kairos pelo seu
contrato próprio; eles não redefinem ownership. O manifesto continua sendo a
fonte de verdade para framework/instância.

**1. Core Canônico (L1/L2)**

Fundação:

- [ ] `.kairos-core/constitution.md` existe
- [ ] `.kairos-core/manifest.yaml` existe
- [ ] `.kairos-core/core-config.yaml` existe e tem campo `version`
- [ ] `.kairos-core/rules/agent-authority.md` existe
- [ ] `.kairos-core/rules/framework-layers.md` existe
- [ ] `.kairos-core/rules/ids-principles.md` existe
- [ ] `.kairos-core/rules/ownership.md` existe
- [ ] `.kairos-core/data/kairos-kb.md` existe
- [ ] `.kairos-core/agents/kairos.md` existe
- [ ] `.kairos-core/rules/` contém as rules canônicas listadas no manifesto
- [ ] `.kairos-core/instructions/` contém apenas contexto operacional
  runtime-neutral, não regra normativa, task, persona ou template de runtime
- [ ] `version` em `core-config.yaml` bate com a entrada mais recente do
  `CHANGELOG.md`

Persona canônica do `@kairos`:

- [ ] `.kairos-core/agents/kairos.md` está em `owned_files` com `role: source`
  → ❌ FAIL se ausente do manifesto
- [ ] `.kairos-core/agents/kairos.md` tem frontmatter `kairos-owned: true`
  → ⚠️ WARN se ausente
- [ ] O bloco YAML da persona contém `REQUEST-RESOLUTION`
  → ❌ FAIL se ausente
- [ ] A persona declara continuidade até `*exit`
  → ⚠️ WARN se não houver instrução equivalente a "toda mensagem subsequente
     pertence ao modo @kairos até *exit"
- [ ] A persona declara envelope obrigatório de ativação com greeting e
  assinatura, inclusive quando `@kairos` vier com comando/pedido na mesma
  mensagem
  → ⚠️ WARN se não houver instrução equivalente a "nenhuma mensagem visível
     antes do greeting", "exiba o greeting antes do resultado" e "feche a
     resposta com signature_closing"

**2. Runtime Claude**

Contrato:

- [ ] `.kairos-core/runtimes/claude/runtime.yaml` existe e é YAML válido
- [ ] `runtime.yaml → id` é `claude`
- [ ] `capabilities.command_persona.mode` é `native_command`
- [ ] `capabilities.command_persona.source` é `.kairos-core/agents/kairos.md`
- [ ] `capabilities.command_persona.entrypoint` é
  `.claude/commands/kairos/agents/kairos.md`
- [ ] `capabilities.active_agent_continuity.persistence` é `session_only`
- [ ] `capabilities.active_agent_continuity.clear_on` é `*exit`
- [ ] `capabilities.active_agent_continuity.scope` é
  `all_messages_until_exit`
- [ ] `protocol.canonical_sources` aponta para `.kairos-core/` para
  `manifest`, `config`, `agents`, `rules`, `instructions` e `tasks`

Targets Claude:

- [ ] `CLAUDE.md` existe
- [ ] `.claude/commands/kairos/agents/kairos.md` existe
- [ ] `.claude/commands/kairos/agents/kairos.md` está no manifesto com
  `role: materialized_target`, `runtime: claude` e
  `generated_from: .kairos-core/agents/kairos.md`
  → ❌ FAIL se ainda aparecer como fonte de verdade
- [ ] Conteúdo de `.claude/commands/kairos/agents/kairos.md` é idêntico ao de
  `.kairos-core/agents/kairos.md`
  → ⚠️ WARN "drift da persona @kairos no target Claude" se divergir
- [ ] `.claude/rules/*.md` listados no manifesto têm
  `generated_from: .kairos-core/rules/*.md`
- [ ] `.claude/hooks/*.cjs` listados no manifesto têm
  `generated_from: .kairos-core/runtimes/claude/hooks/*.cjs`

Hooks Claude:

- [ ] `.claude/settings.json` existe e é JSON válido
- [ ] Para cada hook registrado em `.claude/settings.json`: arquivo do hook
  existe no path referenciado
  → ❌ FAIL se hook obrigatório estiver ausente

**3. Runtime Codex**

Contrato:

- [ ] `.kairos-core/runtimes/codex/runtime.yaml` existe e é YAML válido
- [ ] `.kairos-core/runtimes/codex/context-map.yaml` existe e é YAML válido
- [ ] `.kairos-core/runtimes/codex/boundary-policy.yaml` existe e é YAML válido
- [ ] `runtime.yaml → id` é `codex`
- [ ] `capabilities.command_persona.mode` é `skill`
- [ ] `capabilities.command_persona.source` é `.kairos-core/agents/kairos.md`
- [ ] `capabilities.command_persona.entrypoint` é
  `.agents/skills/kairos/SKILL.md`
- [ ] `capabilities.active_agent_continuity.persistence` é `session_only`
- [ ] `capabilities.active_agent_continuity.clear_on` é `*exit`
- [ ] `capabilities.active_agent_continuity.scope` é
  `all_messages_until_exit`
- [ ] `protocol.canonical_sources` aponta para `.kairos-core/` para
  `manifest`, `config`, `agents`, `rules`, `instructions` e `tasks`

Context map:

- [ ] `context-map.yaml → load_order.agent.kairos.persona` é
  `.kairos-core/agents/kairos.md`
  → ❌ FAIL se apontar para `.claude/commands/kairos/agents/kairos.md`
- [ ] `context-map.yaml → session_continuity.source` é
  `.kairos-core/agents/kairos.md`
- [ ] `context-map.yaml → command_task.pattern` é
  `.kairos-core/tasks/kairos-{command}.md`

Targets Codex:

- [ ] `AGENTS.md` existe
- [ ] `.agents/skills/kairos/SKILL.md` existe
- [ ] `.codex/hooks.json` existe
- [ ] `.agents/skills/kairos/SKILL.md` está no manifesto com
  `role: materialized_target`, `runtime: codex` e
  `generated_from: .kairos-core/runtimes/codex/templates/SKILL.md`
- [ ] `.agents/skills/kairos/SKILL.md` é idêntico a
  `.kairos-core/runtimes/codex/templates/SKILL.md`
  → ⚠️ WARN "drift do skill Kairos materializado para Codex" se divergir
- [ ] Skill Codex não instrui usar
  `.claude/commands/kairos/agents/kairos.md` como fonte da persona
  → ❌ FAIL se houver instrução operacional nesse sentido
- [ ] `AGENTS.md` contém exatamente um bloco
  `KAIROS-MANAGED-START: kairos-codex-bootloader`

Limitações declaradas:

- [ ] `pre_compaction_digest.mode` no runtime Codex é `unsupported` ou
  equivalente explicitamente documentado
- [ ] Squads operacionais no Codex aparecem como não suportados ou pendentes no
  `context-map.yaml`

**4. Materialização e Ownership (manifesto)**

Ler `.kairos-core/manifest.yaml` e validar cada entrada:

- [ ] Para cada `owned_files[*].path`: arquivo existe no filesystem
  → ❌ FAIL com "manifesto lista {path} mas arquivo não existe" se ausente
- [ ] Para cada `owned_files[*]`: se `sha256 == "self-referential"` → ignorar
  (valor válido, sem comparação); caso contrário calcular sha256 do arquivo e
  comparar com `sha256` declarado
  → ⚠️ WARN "drift de conteúdo em {path}" se divergir
- [ ] Para cada entrada `role: materialized_target` com `generated_from`:
  verificar que o source existe
  → ❌ FAIL se o source não existir
- [ ] Para cada entrada `role: materialized_target` com `generated_from` e
  `type` implícito/owned file: se o target deve ser cópia byte-a-byte, comparar
  target e source
  → ⚠️ WARN "drift materializado: {target} difere de {source}" se divergir
- [ ] Para cada `owned_sections[*].path`: arquivo existe
  → ❌ FAIL se ausente
- [ ] Para cada `sync_files[*].path`: arquivo existe no filesystem
  → ❌ FAIL com "manifesto lista {path} em sync_files mas arquivo não existe"
  se ausente
  (nota: sem verificação de SHA — sync_files não tem sha256)
- [ ] Para arquivos `.md` com frontmatter `kairos-owned: true`: validar que path
  está em `owned_files`
  → ⚠️ WARN "arquivo marca-se como kairos-owned mas não está no manifesto: {path}"
- [ ] Para arquivos em `owned_files` com extensão `.md`: validar que têm
  frontmatter `kairos-owned: true`
  → ⚠️ WARN "arquivo no manifesto sem frontmatter kairos-owned: {path}"

**5. Arquivos Mistos e Blocos Gerenciados**

Para cada entrada em `owned_sections[*]` do tipo `markdown_blocks`:

- [ ] Para cada `blocks[*]`: o arquivo contém exatamente um `start` e um `end`
  com o mesmo `name`, e o `start` aparece antes do `end`
  → ❌ FAIL "marker {name} ausente/desemparelhado em {path}" se inválido
- [ ] Nenhum marker órfão (`KAIROS-MANAGED-START/END` sem par) existe no arquivo
  → ❌ FAIL se houver
- [ ] Para cada bloco com `sha256` declarado: calcular SHA do conteúdo interno
  (excluindo linhas de marker, removendo apenas quebras de linha externas com
  `strip("\n")`) e comparar com o registrado
  → ⚠️ WARN "drift de SHA no bloco {name} de {path}" se divergir

  Algoritmo canônico:

  ```python
  start_idx = text.index(start_marker) + len(start_marker)
  end_idx = text.index(end_marker, start_idx)
  content = text[start_idx:end_idx].strip("\n")
  sha256 = hashlib.sha256(content.encode("utf-8")).hexdigest()
  ```

Para cada entrada em `owned_sections[*]` do tipo `yaml_keys`:

- [ ] Para cada chave em `owned_keys` com `sha256_by_key[chave]` declarado: ler
  o campo `sha_method` da entrada no manifesto, serializar o valor da chave
  usando esse algoritmo e comparar o SHA com o registrado
  → ⚠️ WARN "drift de SHA na chave {chave} de {path}" se divergir

  Para `.kairos-core/core-config.yaml`, o algoritmo atual é:

  ```python
  serialized = yaml.dump({key: value}, sort_keys=False)
  sha256 = hashlib.sha256(serialized.encode("utf-8")).hexdigest()
  ```

Para cada entrada em `owned_sections[*]` do tipo `comment_blocks`:

- [ ] Para cada seção em `owned_sections[*]` com `sha256` declarado: verificar
  que os markers `# KAIROS-MANAGED-START: {nome}` e
  `# KAIROS-MANAGED-END: {nome}` existem no arquivo
  → ❌ FAIL "marker {nome} ausente/desemparelhado em {path}" se inválido
- [ ] Calcular SHA do conteúdo interno (excluindo linhas de marker, removendo
  apenas quebras de linha externas com `strip("\n")`) e comparar com o registrado
  → ⚠️ WARN "drift de SHA na seção {nome} de {path}" se divergir

Para cada entrada em `owned_sections[*]` do tipo `json_keys`:

- [ ] Verificar que o arquivo é JSON válido (parse sem erros)
  → ❌ FAIL "JSON inválido em {path}" se o parse falhar
- [ ] Para cada chave em `owned_keys`: verificar que a chave existe no JSON raiz
  → ⚠️ WARN "chave gerenciada '{chave}' ausente em {path}" se não existir
- [ ] Se `sha256_by_key` declarado no manifesto: para cada chave com SHA
  registrado, serializar o valor atual com
  `json.dumps(value, sort_keys=True, separators=(',', ':'))`, calcular sha256 e
  comparar com o registrado
  → ⚠️ WARN "drift de SHA na chave '{chave}' de {path}" se divergir

> SHAs de `owned_sections` são verificados com WARN (não FAIL) — drift indica
> conteúdo framework-owned que foi modificado localmente; operável mas requer
> atenção do *pre-push.

**6. Instância e Squads**

Agentes registrados:

Para cada agente em `core-config.yaml → agents.squads.*.agents`:
- [ ] Persona existe em `.claude/commands/kairos/agents/{id}.md`
  → ⚠️ WARN "persona de squad é target Claude; suporte Codex para squads ainda
     não está completo nesta fase" se rodando no runtime Codex
- [ ] MEMORY.md existe em `.kairos-core/agents/{id}/MEMORY.md`

Drift YAML → Persona:

Para cada arquivo `squads/*/agents/*.yaml` encontrado no filesystem:
- [ ] Extrair `id` do campo `id:` no arquivo `.yaml`
- [ ] Verificar se `.claude/commands/kairos/agents/{id}.md` existe
  → ⚠️ WARN "YAML sem persona: squads/{squad}/agents/{id}.yaml definido mas .claude/commands/kairos/agents/{id}.md não existe — rodar *new-squad ou gerar persona manualmente" se ausente

Tasks referenciadas:

Para cada `task:` declarado nos arquivos de persona dos agentes:
- [ ] Arquivo correspondente existe em `.kairos-core/tasks/{task-name}`

Squads registrados:

Para cada squad em `core-config.yaml → agents.squads`:
- [ ] `squads/{squad}/squad.yaml` existe
- [ ] `squads/{squad}/README.md` existe

**7. Stories e Gates**

Para cada `*.story.md` em `docs/stories/`:
- [ ] Campo `**Status:**` presente
- [ ] Se Status = "In Review": gate correspondente existe em `docs/qa/gates/`?
  → ⚠️ WARN se não existe (não é FAIL — o review pode não ter sido rodado ainda)

Para stories com Status ≠ Done: verificar se arquivos citados em backticks existem.
- [ ] Arquivos `.md`, `.ts`, `.yaml` mencionados explicitamente nos ACs existem
  → ⚠️ WARN (não FAIL — pode ser um arquivo a criar)

**8. Operação Local**

Identificação da instância:

- [ ] `.env` existe e contém `KAIROS_INSTANCE_NAME` definido com valor não-vazio
  → ⚠️ WARN "KAIROS_INSTANCE_NAME ausente ou vazio em .env — outputs vão usar fallback `default`. Configure para evitar colisão em equipe (ver `.kairos-core/rules/output-naming.md`)" se ausente/vazio
  → ⚠️ WARN "KAIROS_INSTANCE_NAME contém caracteres fora de kebab-case: {valor}" se o valor tem espaço, maiúscula ou caractere especial
  → PASS silencioso se válido

> Este check é WARN — o framework opera normalmente em modo solo com fallback `default`.
> O objetivo é alertar usuários em time que ainda não configuraram a variável.

Dependências externas de squads (`external_dependencies`):

Para cada squad listado em `core-config.yaml → agents.squads` (ou inferido dos diretórios em `squads/`):

1. Ler `squads/{squad}/squad.yaml`
2. Se o campo `external_dependencies` não existir → pular (squad legado, sem declaração)
3. Para cada entrada em `external_dependencies` com `type: cli`:
   - Executar o comando de detecção:
     - Unix/WSL: `which {name}` ou `detection.unix` declarado
     - Windows: `Get-Command {name}` ou `detection.windows` declarado
   - Se encontrado → PASS silencioso (exceto se `optional: true` → ainda PASS silencioso)
   - Se **não encontrado** e `optional: false`:
     → ⚠️ WARN "{squad}: dependência obrigatória '{name}' não encontrada — {purpose}. Instalar: {install.npm | install.linux | install.mac | install.windows — conforme SO detectado}"
   - Se **não encontrado** e `optional: true`:
     → ⚠️ WARN "(opcional) {squad}: '{name}' não encontrado — {purpose}. {install.note se existir}"
4. Para cada entrada com `type: service` → PASS silencioso (serviço remoto, sem check local possível)

> Este check é WARN — dependências ausentes não bloqueiam o framework, mas impedem que o squad funcione corretamente.

Cloud Sync (opcional):

Se `.kairos-core/runtime/cloud-sync.json` existe E `configured: true`:

- [ ] `data/outputs` é um symlink (`test -L data/outputs`)
  → ❌ FAIL "cloud-sync.json indica sync ativo mas data/outputs não é um symlink — rodar `@kairos *configure-cloud` para reconfigurar"

- [ ] O symlink resolve para um caminho acessível e gravável

  Ler o campo `provider` do JSON. Determinar estratégia de validação:

  **Provedores cloud / rclone** — usar polling com backoff quando `provider` for `rclone:*` ou um dos provedores reconhecidos (`Google Drive`, `OneDrive`, `Dropbox`, `iCloud`):

  Resolver destino físico com `readlink -f data/outputs` (ou `Resolve-Path` no PS).
  Tentar escrever e ler arquivo de teste. Sequência de espera entre tentativas: `1s → 2s → 5s → 10s → 15s` (total ≤ 30s):

  ```bash
  _delays=(0 1 2 5 10 15)
  _ok=false
  for _d in "${_delays[@]}"; do
    [ "$_d" -gt 0 ] && sleep "$_d"
    if echo "kairos-doctor-test" > data/outputs/.doctor-test 2>/dev/null \
       && grep -q "kairos-doctor-test" data/outputs/.doctor-test 2>/dev/null; then
      rm -f data/outputs/.doctor-test
      _ok=true
      break
    fi
  done
  ```

  Tick de sucesso em qualquer tentativa → PASS silencioso imediato.

  Se todas as tentativas falharem (janela de 30s esgotada):
  → ⚠️ WARN "symlink data/outputs/ → {target} não acessível após 30s (provável cold start do mount) — verifique o mount ou reconfigure com `@kairos *configure-cloud`"

  **custom / paths locais** — validação rápida (sem polling):

  ```bash
  echo "kairos-doctor-test" > data/outputs/.doctor-test \
    && rm -f data/outputs/.doctor-test
  ```

  → ⚠️ WARN "symlink data/outputs/ → {target} quebrado ou sem permissão de escrita — rodar `@kairos *configure-cloud` para reconfigurar" se falhar
  → ✅ PASS silencioso se tudo OK

  **Resolução para reporte ao usuário:** usar `realpath -L data/outputs` (preserva o caminho do symlink, não substitui pelo target) ou `(Get-Item data\outputs).Target` no PS. Nunca exibir o path físico resolvido em lugar do target declarado.

> Este check é silencioso quando `cloud-sync.json` não existe ou tem `configured: false` — ausência de sync é estado normal.

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
