---
kairos-owned: true
kairos-version: 2.0.0
---

# Ownership — Fronteira Framework / Usuário

**Camada:** L1 (Fundação — muda apenas com bump MAJOR + justificativa explícita)

Esta rule define operacionalmente como o Kairos distingue framework de usuário, qual é o contrato de update, e como agentes e o executor devem agir perante essa fronteira.

Fundamentos declarativos: constituição, Seção VI (princípios 18-26).

---

## O Manifesto é Autoritativo

A fonte da verdade sobre o que é framework é **`.kairos-core/manifest.yaml`**. Nenhuma outra convenção (path, frontmatter, diretório) sobrepuja o manifesto.

**Regra default-deny:**

> Se um arquivo NÃO está listado no manifesto → é do usuário → não pode ser tocado por update ou por operação de @kairos.

Para arquivos mistos (ex: `CLAUDE.md`, `.claude/settings.json`, `.kairos-core/core-config.yaml`), o manifesto declara **quais seções/chaves** são framework-owned. O resto do arquivo é user-owned.

---

## Três Fluxos de Origem

Qualquer artefato pertence a um destes fluxos:

### (a) Oficial shipped

Adicionado pelo instalador ou updater do Kairos (ou manualmente por `@kairos` ao evoluir o framework). Listado no manifesto.

**Quem pode modificar:** `@kairos` (via stories), updater futuro. Executor (Claude Code normal) só modifica via story aprovada.

### (b) User-criado

Criado pelo usuário após a instalação (novo squad, novo agente, skill, MCP, config custom). Nunca listado no manifesto.

**Quem pode modificar:** o usuário, a qualquer momento. Updater **nunca** toca.

### (c) Pré-existente (brownfield)

Presente antes da instalação do Kairos. Não listado no manifesto.

**Quem pode modificar:** o usuário. Updater **nunca** toca. Install brownfield pode oferecer merge com versão oficial — nunca substitui silenciosamente.

---

## Regras para @kairos e o Executor

### Ao modificar arquivos

1. **Antes de modificar um arquivo**, verificar se ele está no manifesto.
2. Se estiver no manifesto **como arquivo inteiro** (`owned_files`): modificação autorizada (para @kairos ou executor com story).
3. Se estiver no manifesto **como seções declaradas** (`owned_sections`): modificar **apenas** dentro dos blocos/chaves declarados.
4. Se **não estiver no manifesto**: é conteúdo do usuário — **não modificar**, a menos que o próprio usuário peça explicitamente e a modificação não seja parte de um update/evolução de framework.

### Ao criar arquivos novos

1. Se o novo arquivo é framework: adicioná-lo ao manifesto (`owned_files` com layer e sha256). Sem entry no manifesto, o arquivo é considerado user-criado.
2. Se o arquivo é user-criado: **não** adicionar ao manifesto — ele deve permanecer fora.

### Ao remover arquivos

1. Arquivo no manifesto: pode ser removido via story (com entry correspondente no CHANGELOG e remoção do manifesto).
2. Arquivo fora do manifesto: **não remover** — é do usuário.

---

## Arquivos Mistos — Contrato

Arquivos como `CLAUDE.md`, `.claude/settings.json`, `.kairos-core/core-config.yaml` contêm conteúdo framework E conteúdo usuário.

**Mecanismos de marcação:**

- **Markdown:** blocos `<!-- KAIROS-MANAGED-START: {nome} -->` ... `<!-- KAIROS-MANAGED-END: {nome} -->`. Tudo dentro é framework; tudo fora é usuário.
- **YAML/JSON:** o manifesto declara `owned_keys` — listas de chaves top-level ou paths dot-notation que são framework. Chaves fora dessa lista são user-owned.

**Regra:** um update **nunca** modifica conteúdo fora dos blocos/keys declarados, mesmo que a ferramenta seja tecnicamente capaz.

---

## Frontmatter `kairos-owned`

Arquivos markdown de framework **devem** ter frontmatter:

```yaml
---
kairos-owned: true
kairos-version: {versão em que foi shipped}
---
```

Esse marker existe para:
- **Visibilidade** — um humano lendo o arquivo sabe imediatamente que é framework
- **Auditoria** — `@kairos *doctor` valida consistência entre frontmatter e manifesto

Frontmatter **não** sobrepuja o manifesto. Se um arquivo tem `kairos-owned: true` mas **não** está no manifesto, o `*doctor` reporta drift e o manifesto vence (arquivo é considerado user-owned).

---

## Casos que exigem HALT

Um agente ou o executor deve HALT e consultar o usuário se:

- A operação envolver modificar um arquivo cujo ownership é ambíguo (não claro se está no manifesto).
- Uma operação "automática" (update, migração, doctor-fix) ameaçar tocar em conteúdo fora do manifesto.
- O manifesto e o filesystem divergem significativamente (muitos arquivos com drift de SHA, arquivos listados mas inexistentes, etc.).

Nesses casos: reportar a situação, não aplicar mudanças, aguardar decisão do usuário.

---

## Referências

- Constituição, Seção VI (princípios 18-26)
- `.claude/rules/framework-layers.md` — camadas L1-L4 são definidas pelo manifesto
- `.kairos-core/manifest.yaml` — fonte autoritativa
- `.kairos-core/tasks/kairos-doctor.md` — validação de integridade
