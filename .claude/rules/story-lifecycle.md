---
kairos-owned: true
kairos-version: 3.3.1
---

# Story Lifecycle — Protocolo do Executor

## Executor por Tipo de Story

Stories do Kairos têm dois tipos com executores distintos:

| Tipo | Executor | Modo de execução |
|------|----------|-----------------|
| `type: kairos-core` | Claude Code plain (sem persona ativa) | Implementação direta na conversa principal; @kairos governa, exibe aviso e revisa via `*review` |
| `type: instance` | @kairos via `*implement` | @kairos permanece ativo durante toda a implementação; Execution Log assinado "@kairos via *implement" |

**Regras de executor:**
- Stories `type: kairos-core`: Claude Code plain é o executor. @kairos cria a story, exibe o aviso de modificação de núcleo a cada resposta, e move para Done após gate PASS/RESSALVA.
- Stories `type: instance`: @kairos não delega ao Claude Code plain. Usa `*implement` para executar inline. O executor externo (Claude Code) não deve iniciar implementações de stories `type: instance`.

---

## Quem é o Executor (kairos-core)

O executor de stories `type: kairos-core` é o **Claude Code na conversa principal** (sem persona de agente ativa).
Quando o usuário pede para implementar o que uma story `type: kairos-core` descreve, Claude Code está atuando como executor.

Este protocolo define o que o executor **deve fazer** ao longo do ciclo de vida de uma story.

---

## Estados de uma Story

```
Draft → In Progress → In Review → Done
```

| Estado | Significado | Quem transita |
|--------|-------------|---------------|
| `Draft` | Criada, aguardando execução | @kairos cria |
| `In Progress` | Executor iniciou o trabalho | Executor seta ao começar |
| `In Review` | Implementação concluída, aguarda @kairos *review | Executor seta ao terminar |
| `Done` | *pre-push confirmou gate PASS/RESSALVA e executou commit | *pre-push transita antes do commit |

---

## Regras do Executor

### Ao INICIAR implementação de uma story

1. Abrir `docs/stories/{epic}.{N}.story.md`
2. Atualizar campo de status: `**Status:** In Progress`
3. Adicionar entrada no Change Log interno da story:
   ```markdown
   | {data} | Implementação iniciada |
   ```
4. Abrir `docs/epics/epic-{N}-*.md` — localizar a linha da story na tabela de Stories e atualizar a célula de status de `Draft → In Progress`
5. Adicionar entrada no Change Log do epic:
   ```markdown
   | {data} | Story {id} iniciada — In Progress |
   ```

### Ao CONCLUIR implementação de uma story

1. Atualizar campo de status: `**Status:** In Review`
2. Marcar checkboxes dos ACs implementados: `- [x]`
3. **Adicionar seção `## Execution Log`** (ver formato abaixo)
4. Adicionar entrada no Change Log interno da story:
   ```markdown
   | {data} | Implementação concluída — status → In Review |
   ```
5. Abrir `docs/epics/epic-{N}-*.md` — localizar a linha da story na tabela de Stories e atualizar a célula de status de `In Progress → In Review`
6. Adicionar entrada no Change Log do epic:
   ```markdown
   | {data} | Story {id} concluída — In Review |
   ```

---

## Formato do Execution Log

A seção `## Execution Log` deve ser adicionada **antes** do `## Change Log` da story.

```markdown
## Execution Log

**Executor:** Claude Code
**Data:** YYYY-MM-DD
**Status anterior → novo:** In Progress → In Review

### O que foi feito

- {item 1 — o que foi criado/modificado e por quê}
- {item 2}
- {item 3}

### Decisões tomadas

- {decisão não óbvia — qual alternativa foi descartada e por quê}
- {se não houve decisões relevantes: "Sem desvios do plano da story"}

### Arquivos criados/modificados

- `{caminho/arquivo}` — {o que mudou}
- `{caminho/arquivo}` — {criado / modificado / removido}

### Pendências / questões abertas

- {algo que ficou incompleto e por quê}
- {se nada ficou pendente: "Nenhuma"}

### Notas para @kairos

- {algo que o revisor deve checar com atenção}
- {trade-off que pode precisar de revisão}
- {se não há notas: "Nenhuma"}
```

---

## O que NÃO fazer

- **Não** apenas marcar checkboxes e mover o status sem adicionar o Execution Log
- **Não** mover diretamente para `Done` — apenas `@kairos *review` pode fazer isso
- **Não** deixar a story em `Draft` após começar o trabalho
- **Não** omitir decisões ou desvios do plano original da story
- **Não** escrever "implementado conforme story" sem detalhar o que foi feito

---

## Exemplo de story corretamente atualizada pelo executor

```markdown
# Story 3.1 — Tasks de Governança do @kairos

**Epic:** 3
**Status:** In Review          ← atualizado pelo executor
**Complexidade:** G
...

## Critérios de Aceite

- [x] `kairos-new-story.md` cria story com template completo  ← marcado
- [x] `kairos-status.md` agrega versão, squads, stories       ← marcado
- [x] `kairos-review.md` emite gate PASS/BLOCK                ← marcado
...

## Execution Log                ← adicionado pelo executor

**Executor:** Claude Code
**Data:** 2026-04-06
**Status anterior → novo:** In Progress → In Review

### O que foi feito

- Criadas 7 tasks em `.kairos-core/tasks/`: new-story, new-squad, version-bump,
  status, review, pre-push, push
- Persona @kairos migrada de kairos-master.md para kairos.md
- Referências a @kairos-master atualizadas em 6 arquivos via sed

### Decisões tomadas

- `pre_push_passed` implementado como estado de sessão (não arquivo) para
  evitar falsos positivos entre sessões diferentes
- kairos-review.md usa quality_score determinístico (começa em 100, deduções fixas)
  para evitar veredictos vagos

### Arquivos criados/modificados

- `.kairos-core/tasks/kairos-*.md` — 7 arquivos criados
- `.claude/commands/kairos/agents/kairos.md` — criado (substituiu kairos-master.md)
- `docs/epics/epic-3-*.md` — checkboxes atualizados, status → Done

### Pendências / questões abertas

- `docs/qa/gates/` diretório referenciado mas não criado — criar antes do primeiro *review

### Notas para @kairos

- Verificar se o guard de sessão de *push é suficiente ou precisa de persistência em arquivo
```

---

## Decision Log — Decisões Arquiteturais Persistentes

Algumas decisões tomadas durante a implementação de uma story não pertencem só àquela story — elas definem como o Kairos funciona e devem ser preservadas para contexto futuro.

### Quando promover ao KB

Se uma decisão no Execution Log atender a pelo menos um destes critérios:
- Explica um **trade-off arquitetural** (por que X e não Y)
- Define um **padrão que outros agentes/stories seguirão**
- Resolve um **gotcha técnico** não documentado em nenhum outro lugar
- **Contradiz uma suposição óbvia** — alguém razoável poderia fazer diferente

→ Promover para `.kairos-core/data/kairos-kb.md` via `@kairos *kb add`.

### O que NÃO promover

- Decisões óbvias que qualquer dev faria igual ("usei kebab-case por convenção")
- Detalhes de implementação já visíveis no código
- Decisões temporárias que serão revisitadas em breve

### Formato para decisões no Execution Log

Ao escrever a seção `### Decisões tomadas`, seja específico sobre alternativas consideradas:

```markdown
### Decisões tomadas

- **State de sessão vs arquivo para pre_push_passed:** escolhemos estado de sessão 
  para forçar re-verificação a cada nova sessão — arquivo permitiria burlar o guard.
  Trade-off aceito: não persiste entre sessões (intencional).
```

---

## Responsabilidade do *pre-push na transição In Review → Done

`*review` emite o gate (PASS/RESSALVA/BLOCK) mas **não** move a story para Done.

Quando `*pre-push` confirma gate PASS ou RESSALVA (Passo 1) e executa o commit (Passo 3):
- Atualiza a story para `Done` e adiciona entrada no Change Log antes do commit
- Marca a story no epic como Done

**BLOCK**: `*review` move a story de volta para `In Progress`, atualiza o epic e aguarda nova rodada de implementação pelo executor. O executor deve corrigir os issues e mover para `In Review` novamente antes de rodar `*review` de novo.

Entrada adicionada pelo *pre-push ao mover para Done:
```markdown
| {data} | *pre-push: gate confirmado — status → Done |
```
