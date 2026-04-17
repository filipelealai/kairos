---
kairos-owned: true
kairos-version: 3.1.3
task: Kairos Implement
responsavel: "@kairos"
responsavel_type: agent
atomic_layer: implementation
elicit: false
Entrada: |
  - story_id: ID da story a implementar (ex: "3.7", "4.1") — opcional
    Se omitido: listar stories type: instance com status Draft ou In Progress
Saida: |
  - story movida para In Review
  - Execution Log adicionado na story (assinado "@kairos via *implement")
  - arquivos declarados nos ACs criados/modificados
Checklist:
  - "[ ] Resolver story_id: argumento explícito ou seleção interativa"
  - "[ ] Verificar que story é type: instance — recusar se kairos-core"
  - "[ ] Mover story Draft → In Progress (se ainda em Draft)"
  - "[ ] Ler Objetivo, ACs e contexto da story"
  - "[ ] Implementar arquivo por arquivo conforme os ACs"
  - "[ ] Adicionar seção ## Execution Log na story"
  - "[ ] Mover story In Progress → In Review"
  - "[ ] Exibir confirmação com próximo passo (*review)"
---

# *implement — Executor de Stories type: instance

Esta task formaliza @kairos como executor de stories que criam ou evoluem squads,
workers, agentes e scripts associados (`type: instance`). Para stories `type: kairos-core`,
a implementação é responsabilidade do Claude Code plain — @kairos recusa explicitamente.

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
- Para scripts em `src/`: criar em `src/agents/{id}.ts` ou `src/tools/{id}.ts`
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
