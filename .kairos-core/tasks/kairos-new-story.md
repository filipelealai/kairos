---
kairos-owned: true
kairos-version: 2.1.0
task: Kairos New Story
responsavel: "@kairos"
responsavel_type: agent
atomic_layer: planning
elicit: true
Entrada: |
  - epic: Número do epic — perguntar sempre; listar epics disponíveis
  - description: Descrição do que precisa ser feito — elicitar interativamente
Saida: |
  - story_file: docs/stories/{epic}.{N}.story.md
Checklist:
  - "[ ] Listar epics disponíveis (lendo docs/epics/) e confirmar epic de destino"
  - "[ ] Determinar próximo número de story dentro do epic (lendo docs/stories/)"
  - "[ ] Elicitar: título da story"
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

1. **Epic**: Listar os epics disponíveis lendo `docs/epics/` e perguntar:
   "Qual epic? Epics disponíveis: {lista dos epics encontrados em docs/epics/}"
   → Ler os arquivos `docs/epics/epic-*.md` para extrair o número e nome de cada epic.

2. **ID automático**: Após o usuário escolher o epic, determinar o próximo número da story:
   → Listar `docs/stories/` e filtrar arquivos com prefixo `{epic}.`.
   → Contar quantas stories existem no epic escolhido e usar `N = count + 1`.
   → Informar ao usuário: "ID gerado: {epic}.{N}"

3. **Título**: "Qual o título da story? (resumo em uma linha do que será feito)"

4. **O que precisa ser feito**: "Descreva o que precisa acontecer — pode ser em tópicos"

5. **Critérios de aceite**: "Quais são os critérios de aceite? (pelo menos 3, testáveis)"

6. **Fora de escopo**: "O que explicitamente NÃO está incluído nesta story?"

7. **Complexidade**: "Estimativa: P (pequena) / M (média) / G (grande)?"

8. **Dependências**: "Depende de alguma story existente? (ex: 1.2 deve estar Done)"

## Formato do Arquivo

```markdown
# Story {epic}.{N} — {Título}

**Epic:** {N}
**Status:** Draft
**Complexidade:** {P|M|G}
**Criada por:** @kairos
**Data:** {YYYY-MM-DD}

---

## Objetivo

{Uma frase clara do que esta story entrega e por quê.}

## Critérios de Aceite

- [ ] {AC 1 — específico e testável}
- [ ] {AC 2 — específico e testável}
- [ ] {AC 3 — específico e testável}

## Fora de Escopo

- {O que esta story explicitamente NÃO cobre}

## Dependências

- {Story ou sistema necessário, ou "Nenhuma"}

## Change Log

| Data | Evento |
|------|--------|
| {data} | Story criada por @kairos |
```

## Após Criar

1. Atualizar `docs/stories/README.md` — adicionar linha na tabela de stories
2. Atualizar `docs/epics/epic-{N}-*.md` — adicionar story na tabela de stories do epic
3. Informar ao usuário: "Story {epic}.{N} criada em Draft. Quando pronto para implementar, Claude Code executa — ao concluir, rode `*review {epic}.{N}`."
