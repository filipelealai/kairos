---
kairos-owned: true
kairos-version: 3.11.0
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

**1. Fundação (L1)**
- [ ] `.kairos-core/constitution.md` existe
- [ ] `.kairos-core/manifest.yaml` existe
- [ ] `.claude/rules/agent-authority.md` existe
- [ ] `.claude/rules/framework-layers.md` existe
- [ ] `.claude/rules/ids-principles.md` existe
- [ ] `.claude/rules/ownership.md` existe

**2. Configuração Central (L2)**
- [ ] `.kairos-core/core-config.yaml` existe e tem campo `version`
- [ ] `version` em `core-config.yaml` bate com a entrada mais recente do `CHANGELOG.md`
- [ ] `.kairos-core/data/kairos-kb.md` existe

**3. Agentes Registrados**

Para cada agente em `core-config.yaml → agents.squads.*.agents`:
- [ ] Persona existe em `.claude/commands/kairos/agents/{id}.md`
- [ ] MEMORY.md existe em `.kairos-core/agents/{id}/MEMORY.md`

**3a. Drift YAML → Persona**

Para cada arquivo `squads/*/agents/*.yaml` encontrado no filesystem:
- [ ] Extrair `id` do campo `id:` no arquivo `.yaml`
- [ ] Verificar se `.claude/commands/kairos/agents/{id}.md` existe
  → ⚠️ WARN "YAML sem persona: squads/{squad}/agents/{id}.yaml definido mas .claude/commands/kairos/agents/{id}.md não existe — rodar *new-squad ou gerar persona manualmente" se ausente

**3b. SHA Drift — Persona desatualizada em relação ao YAML**

Para cada arquivo `squads/*/agents/*.yaml` que tem persona correspondente (`.claude/commands/kairos/agents/{id}.md`):
- [ ] Ler a primeira linha da persona e verificar se contém o marcador `<!-- kairos-generated-from: ... sha:{sha256} -->`
  - Se a primeira linha **não contém** o marcador → ignorar silenciosamente (persona pré-5.33, sem SHA rastreável)
  - Se contém o marcador:
    - Extrair o path do YAML e o SHA do marcador
    - Calcular SHA atual do arquivo YAML: `sha256sum squads/{squad}/agents/{id}.yaml | cut -d' ' -f1`
    - Comparar com o SHA no marcador
    - Se divergir → ⚠️ WARN "drift de persona: squads/{squad}/agents/{id}.yaml foi editado desde a última geração — rodar *regenerate-squad {squad} para atualizar"
    - Se igual → PASS silencioso (sem output)

**4. Tasks Referenciadas**

Para cada `task:` declarado nos arquivos de persona dos agentes:
- [ ] Arquivo correspondente existe em `.kairos-core/tasks/{task-name}`

**5. Squads Registrados**

Para cada squad em `core-config.yaml → agents.squads`:
- [ ] `squads/{squad}/squad.yaml` existe
- [ ] `squads/{squad}/README.md` existe

**6. Hooks**

Para cada hook registrado em `.claude/settings.json`:
- [ ] Arquivo do hook existe no path referenciado

**7. Stories Abertas**

Para cada `*.story.md` em `docs/stories/`:
- [ ] Campo `**Status:**` presente
- [ ] Se Status = "In Review": gate correspondente existe em `docs/qa/gates/`?
  → ⚠️ WARN se não existe (não é FAIL — o review pode não ter sido rodado ainda)

**8. Referências Quebradas em Stories**

Para stories com Status ≠ Done: verificar se arquivos citados em backticks existem.
- [ ] Arquivos `.md`, `.ts`, `.yaml` mencionados explicitamente nos ACs existem
  → ⚠️ WARN (não FAIL — pode ser um arquivo a criar)

**9. Integridade de Ownership (manifesto)**

Ler `.kairos-core/manifest.yaml` e validar cada entrada:

- [ ] Para cada `owned_files[*].path`: arquivo existe no filesystem
  → ❌ FAIL com "manifesto lista {path} mas arquivo não existe" se ausente
- [ ] Para cada `owned_files[*]`: se `sha256 == "self-referential"` → ignorar (valor válido, sem comparação); caso contrário calcular sha256 do arquivo e comparar com `sha256` declarado
  → ⚠️ WARN "drift de conteúdo em {path}" se divergir (pode ser edit legítimo do usuário
     em arquivo framework — requer atenção mas não é fatal)
- [ ] Para cada `owned_sections[*].path`: arquivo existe
  → ❌ FAIL se ausente
- [ ] Para cada `sync_files[*].path`: arquivo existe no filesystem
  → ❌ FAIL com "manifesto lista {path} em sync_files mas arquivo não existe" se ausente
  (nota: sem verificação de SHA — sync_files não tem sha256)
- [ ] Para arquivos `.md` com frontmatter `kairos-owned: true`: validar que path está em
  `owned_files`
  → ⚠️ WARN "arquivo marca-se como kairos-owned mas não está no manifesto: {path}"
- [ ] Para arquivos em `owned_files` com extensão `.md`: validar que têm frontmatter
  `kairos-owned: true`
  → ⚠️ WARN "arquivo no manifesto sem frontmatter kairos-owned: {path}"

**10. Validade de Marcadores e SHA de Blocos em Arquivos Mistos**

Para cada entrada em `owned_sections[*]` do tipo `markdown_blocks`:

- [ ] Para cada `blocks[*]`: o arquivo contém exatamente um `start` e um `end` com o
  mesmo `name`, e o `start` aparece antes do `end`
  → ❌ FAIL "marker {name} ausente/desemparelhado em {path}" se inválido
- [ ] Nenhum marker órfão (`KAIROS-MANAGED-START/END` sem par) existe no arquivo
  → ❌ FAIL se houver
- [ ] Para cada bloco com `sha256` declarado: calcular SHA do conteúdo interno (excluindo
  linhas de marker) e comparar com o registrado
  → ⚠️ WARN "drift de SHA no bloco {name} de {path}" se divergir

Para cada entrada em `owned_sections[*]` do tipo `yaml_keys`:

- [ ] Para cada chave em `owned_keys` com `sha256_by_key[chave]` declarado: ler o campo
  `sha_method` da entrada no manifesto (especificação canônica do algoritmo de serialização),
  serializar o valor da chave usando esse algoritmo e comparar o SHA com o registrado
  → ⚠️ WARN "drift de SHA na chave {chave} de {path}" se divergir

Para cada entrada em `owned_sections[*]` do tipo `env_sections`:

- [ ] Para cada seção em `owned_sections[*]` com `sha256` declarado: verificar que os markers
  `# KAIROS-MANAGED-START: {nome}` e `# KAIROS-MANAGED-END: {nome}` existem no arquivo
  → ❌ FAIL "marker {nome} ausente/desemparelhado em {path}" se inválido
- [ ] Calcular SHA do conteúdo interno (excluindo linhas de marker) e comparar com o registrado
  → ⚠️ WARN "drift de SHA na seção {nome} de {path}" se divergir

> SHAs de `owned_sections` são verificados com WARN (não FAIL) — drift indica conteúdo
> framework-owned que foi modificado localmente; operável mas requer atenção do *pre-push.

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
