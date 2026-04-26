---
kairos-owned: true
kairos-version: 3.10.0
task: Kairos Implement
responsavel: "@kairos"
responsavel_type: agent
atomic_layer: implementation
elicit: false
Entrada: |
  - story_id: ID da story a implementar (ex: "3.7", "4.1") — opcional
    Se omitido: listar stories type: instance com status Draft ou In Progress
  - "all": implementar em massa todas as stories type: instance em Draft ou In Progress
Saida: |
  - story(s) movida(s) para In Review
  - Execution Log adicionado em cada story (assinado "@kairos via *implement")
  - arquivos declarados nos ACs criados/modificados
  - [modo all] relatório consolidado + gate de cada story salvo em docs/qa/gates/
Checklist:
  - "[ ] Resolver argumento: 'all', story_id explícito ou seleção interativa"
  - "[ ] [modo all] Listar elegíveis, confirmar com usuário, iterar sequencialmente"
  - "[ ] Verificar que story é type: instance — recusar se kairos-core"
  - "[ ] Mover story Draft → In Progress (se ainda em Draft)"
  - "[ ] Ler Objetivo, ACs e contexto da story"
  - "[ ] Implementar arquivo por arquivo conforme os ACs"
  - "[ ] Adicionar seção ## Execution Log na story"
  - "[ ] Mover story In Progress → In Review"
  - "[ ] [modo all] Executar *review automaticamente após cada story"
  - "[ ] [modo all] Exibir relatório consolidado e aguardar confirmação antes de *pre-push"
---

# *implement — Executor de Stories type: instance

Esta task formaliza @kairos como executor de stories que criam ou evoluem squads,
workers, agentes e scripts associados (`type: instance`). Para stories `type: kairos-core`,
a implementação é responsabilidade do Claude Code plain — @kairos recusa explicitamente.

---

## Despacho de argumento

Se o argumento recebido for `all` → ir para **[Modo All]** abaixo.
Caso contrário → seguir o **Pré-passo** normal.

---

## [Modo All] — Implementação em Massa

> Ativado por `*implement all`. Implementa sequencialmente todas as stories `type: instance`
> em Draft ou In Progress, executa `*review` em cada uma e exibe relatório consolidado.

### All-Passo 1 — Varrer o backlog

1. Listar todos os arquivos em `docs/stories/` com extensão `.story.md`
2. Para cada um, ler os campos `**Status:**` e `**Tipo:**`
3. Separar em três grupos:
   - **Elegíveis:** `type: instance` E status `Draft` ou `In Progress`
   - **Ignoradas:** `type: kairos-core` (qualquer status)
   - **Puladas:** qualquer outro tipo ou status diferente de Draft/In Progress
4. Se **nenhuma elegível** encontrada → exibir e HALT:
   ```
   Nenhuma story type: instance em Draft ou In Progress encontrada.
   
   Para criar uma nova story: *new-story
   Para implementar uma story específica: *implement {id}
   ```

### All-Passo 2 — Confirmação única do usuário

Exibir lista e aguardar confirmação antes de iniciar:

```
*implement all — Stories que serão implementadas:

  Elegíveis ({N} stories):
    {id}: {título} [{status}]
    ...

  Ignoradas — type: kairos-core ({M} stories):
    {id}: {título} → usar *yolo para implementação autônoma de framework
    ...

Implementar sequencialmente? (s = continuar, n = cancelar)
```

Aguardar resposta. Se `n` → HALT.

### All-Passo 3 — Iterar sequencialmente

Para cada story elegível, **na ordem em que aparecem** (numeric sort por id):

```
━━━ Implementando story {id}/{total}: {título} ━━━
```

Executar os Passos 1–6 do fluxo normal (seções abaixo) para a story atual:
- Verificar tipo (Passo 1)
- Iniciar implementação, mover Draft→In Progress (Passo 2)
- Ler a story (Passo 3)
- Implementar ACs (Passo 4)
- Adicionar Execution Log (Passo 5)
- Mover para In Review (Passo 6)

Após concluir cada story → executar `*review {id}` automaticamente (carregar `kairos-review.md`):
- Gate salvo em `docs/qa/gates/{id}-{YYYY-MM-DD}.yaml`
- Resultado registrado internamente para o relatório

**Se gate = BLOCK:** NÃO interromper — registrar story como `BLOCK` no relatório e continuar com a próxima.
**Se gate = PASS ou RESSALVA:** registrar story como `OK` no relatório e continuar.
**Se implementação falhar com erro inesperado:** registrar story como `ERRO` e continuar.

### All-Passo 4 — Relatório consolidado

Após processar todas as stories, exibir:

```
━━━ RELATÓRIO *implement all ━━━
Processadas: {N} stories   OK: {X}   BLOCK: {Y}   ERRO: {Z}

Stories implementadas:
  ✅ {id}: {título}
     Gate: PASS (quality_score: {N}) | Arquivos: {lista resumida}

  ⚠️ {id}: {título}
     Gate: RESSALVA (quality_score: {N}) | Arquivos: {lista resumida}

  🚫 {id}: {título}
     Gate: BLOCK (quality_score: {N})
     Issues: {lista de issues bloqueantes}
     → Corrigir manualmente e rodar *review {id} após correção

  ❌ {id}: {título}
     ERRO durante implementação: {motivo}
     → Verificar manualmente

Stories ignoradas (type: kairos-core):
  ⬜ {id}: {título} — usar *yolo para implementação autônoma

━━━ PRÉ-PUSH ━━━
{N_ok} stories prontas para commit. {N_block} com gate BLOCK (serão incluídas no commit mas precisam de correção posterior).

Prosseguir com *pre-push? (s = continuar, n = cancelar)
```

Aguardar confirmação. Se `s` → executar `*pre-push`. Se `n` → HALT.

---

## Pré-passo — Resolver story_id

**Se story_id foi fornecido:** usar diretamente.

**Se não foi fornecido:**
1. Listar todos os arquivos em `docs/stories/` com extensão `.story.md`
2. Para cada um, ler os campos `**Status:**` e `**Tipo:**`
3. Coletar os que têm `type: instance` E status `Draft` ou `In Progress`
4. Se nenhuma encontrada → exibir:
   ```
   Nenhuma story type: instance com status Draft ou In Progress encontrada.
   Para criar uma nova story: *new-story
   Para especificar diretamente: *implement {story-id}
   ```
5. Se exatamente 1 → usar automaticamente, exibindo:
   `→ Implementando story instance: {id} — {título}`
6. Se múltiplas → exibir lista e pedir que o usuário escolha:
   ```
   Stories type: instance disponíveis para implementação:
     {id}: {título} [{status}]
     ...
   Qual implementar? (*implement {id})
   ```

---

## Passo 1 — Verificar tipo da story

Ler o campo `**Tipo:**` (ou `type:` no frontmatter) da story.

**Se `type: kairos-core`:**
```
⛔ Esta story modifica o framework (type: kairos-core) — implementação é por Claude Code plain.
   Saia do modo @kairos para implementar: *exit → implementar na conversa principal.

   Stories kairos-core são implementadas pelo Claude Code sem persona ativa.
   @kairos governa (cria story, exibe aviso, revisa via *review) mas não executa.
```
→ **HALT**. Não prosseguir.

**Se `type: instance`:** continuar.

---

## Passo 2 — Iniciar implementação

1. Abrir `docs/stories/{story_id}.story.md`
2. Se Status = `Draft`:
   - Atualizar: `**Status:** In Progress`
   - Adicionar ao Change Log da story: `| {data} | *implement iniciado — status → In Progress |`
3. Se Status = `In Progress`: continuar sem alterar o status.
4. Exibir: `→ Implementando story {id}: {título}`

---

## Passo 3 — Ler a story

Extrair da story:
- **Objetivo** — o que deve ser alcançado
- **Critérios de Aceite** — lista completa de ACs com checkboxes
- **Fora de Escopo** — o que explicitamente não fazer
- **Arquivos esperados** (se declarados)
- **Dependências** (verificar se estão Done antes de prosseguir)

Se houver dependências com Status ≠ Done:
```
⚠️ Esta story tem dependências não concluídas:
  - Story {dep_id}: {título} — Status: {status}

Prosseguir mesmo assim? (s = continuar, n = aguardar dependências)
```

---

## Passo 4 — Implementar ACs

Implementar os Critérios de Aceite **um por um**, na ordem declarada.

Para cada AC:
1. Exibir: `→ Implementando: {texto do AC}`
2. Executar a implementação (criar arquivo, modificar task, atualizar persona, etc.)
3. Verificar que o artefato foi criado corretamente
4. Marcar o checkbox na story: `- [x] {texto do AC}`

**Regras durante a implementação:**
- Seguir o princípio IDS: REUTILIZAR > ADAPTAR > CRIAR
- Para scripts em `src/`: criar em `src/agents/{id}.{ext}` ou `src/tools/{id}.{ext}`
- Para personas: criar em `.claude/commands/kairos/agents/{id}.md`
- Para tasks de squad: criar em `squads/{squad}/tasks/{task}.md`
- Para tasks de governança: criar em `.kairos-core/tasks/kairos-{task}.md`
- Se um AC for ambíguo → HALT e consultar o usuário antes de prosseguir

**Se implementação falhar em algum AC:**
```
⚠️ Não foi possível implementar: {texto do AC}
Motivo: {descrição do problema}

Opções:
  1. Tentar abordagem alternativa (descreva)
  2. Marcar como pendente e continuar com os demais ACs
  3. HALT — aguardar input do usuário
```

---

## Passo 5 — Adicionar Execution Log

Após implementar todos os ACs, adicionar a seção `## Execution Log` na story,
**antes** do `## Change Log`:

```markdown
## Execution Log

**Executor:** @kairos via *implement
**Data:** {YYYY-MM-DD}
**Status anterior → novo:** In Progress → In Review

### O que foi feito

- {item 1 — o que foi criado/modificado e por quê}
- {item 2}
- {item 3}

### Decisões tomadas

- {decisão não óbvia — qual alternativa foi descartada e por quê}
- {se não houve decisões relevantes: "Sem desvios do plano da story"}

### Arquivos criados/modificados

- `{caminho/arquivo}` — {criado / modificado / removido}

### Pendências / questões abertas

- {algo que ficou incompleto e por quê}
- {se nada ficou pendente: "Nenhuma"}

### Notas para *review

- {algo que o revisor deve checar com atenção}
- {se não há notas: "Nenhuma"}
```

---

## Passo 6 — Mover para In Review

1. Atualizar: `**Status:** In Review`
2. Adicionar ao Change Log da story:
   ```
   | {data} | *implement concluído — status → In Review |
   ```

---

## Passo 7 — Confirmação final

```
✅ Implementação concluída — Story {id}: {título}

ACs implementados: {N}/{total}
Arquivos criados/modificados: {lista resumida}

Story movida para In Review.
Rode `*review {id}` para validar e gerar o gate.
```

---

## Bloqueios (HALT obrigatório)

| Situação | Ação |
|----------|------|
| Story é `type: kairos-core` | HALT — recusar explicitamente, instruir Claude Code plain |
| Dependência não concluída | HALT — consultar usuário antes de prosseguir |
| AC ambíguo sem critério claro | HALT — pedir clarificação antes de implementar |
| Arquivo a criar já existe com conteúdo divergente | HALT — apresentar diferença ao usuário |
| Operação irreversível (delete, reset) | HALT — confirmar antes de executar |
