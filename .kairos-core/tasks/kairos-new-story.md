---
task: Kairos New Story
responsavel: "@kairos"
responsavel_type: agent
atomic_layer: planning
elicit: true
Entrada: |
  - title: Título da story (string)
  - epic: Número do epic (1-4) — perguntar se não informado
  - description: Descrição do que precisa ser feito — elicitar interativamente
Saida: |
  - story_file: docs/stories/{epic}.{N}.story.md
Checklist:
  - "[ ] Confirmar epic de destino (perguntar se ambíguo)"
  - "[ ] Determinar próximo número de story dentro do epic"
  - "[ ] Elicitar: o que precisa ser feito (tarefas)"
  - "[ ] Elicitar: critérios de aceite (pelo menos 3)"
  - "[ ] Elicitar: fora de escopo (o que explicitamente NÃO inclui)"
  - "[ ] Elicitar: estimativa de complexidade (P/M/G)"
  - "[ ] Elicitar: dependências de outras stories"
  - "[ ] Criar arquivo docs/stories/{epic}.{N}.story.md"
  - "[ ] Atualizar docs/stories/README.md com a nova story"
  - "[ ] Atualizar docs/epics/epic-{N}-*.md com a nova story na tabela"
---

# *new-story — Criar Nova Story de Desenvolvimento do Kairos

## Elicitação (obrigatória)

Esta task tem `elicit: true` — colete as informações abaixo antes de criar o arquivo.

Pergunte sequencialmente, aguardando resposta a cada passo:

1. **Epic**: "Qual epic? (1=Infra Dados, 2=Disparo, 3=Governança, 4=Novos Escopos)"
2. **O que precisa ser feito**: "Descreva o que precisa acontecer — pode ser em tópicos"
3. **Critérios de aceite**: "Quais são os critérios de aceite? (pelo menos 3, testáveis)"
4. **Fora de escopo**: "O que explicitamente NÃO está incluído nesta story?"
5. **Complexidade**: "Estimativa: P (pequena) / M (média) / G (grande)?"
6. **Dependências**: "Depende de alguma story existente? (ex: 1.2 deve estar Done)"

## Formato do Arquivo

```markdown
# Story {epic}.{N}: {Título}

**Status:** Draft
**Escopo:** {squad ou "framework"}
**Epic:** {N} — {nome do epic}

---

## Contexto

{Descrição do porquê esta story existe — problema ou necessidade que resolve}

---

## O que precisa ser feito

{Tarefas numeradas com subtarefas}

---

## Critérios de Aceite

- [ ] AC1: ...
- [ ] AC2: ...
- [ ] AC3: ...

---

## Fora de Escopo

{O que explicitamente não está incluído}

---

## Estimativa de Complexidade

**{P/M/G}** — {justificativa}

---

## Dependências

{Stories que precisam estar Done antes desta}

---

## Dev Agent Record

### Arquivos Esperados
{Lista de arquivos que serão criados/modificados — preencher antes de implementar}

### Completion Notes
{Preencher após implementação}

### Change Log
- {data}: Story criada por @kairos
```

## Após Criar

1. Atualizar `docs/stories/README.md` — adicionar linha na tabela de stories
2. Atualizar `docs/epics/epic-{N}-*.md` — adicionar story na tabela de stories do epic
3. Informar ao usuário: "Story {epic}.{N} criada em Draft. Quando pronto para implementar, Claude Code executa — ao concluir, rode `*review {epic}.{N}`."
