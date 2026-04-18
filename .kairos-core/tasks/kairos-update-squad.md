---
kairos-owned: true
kairos-version: 3.3.0
task: Kairos Update Squad
responsavel: "@kairos"
responsavel_type: agent
atomic_layer: governance
elicit: true
Entrada: |
  - squad: nome do squad a ser atualizado (opcional — pode ser elicitado)
Saida: |
  - story_file: docs/stories/{epic}.{N}.story.md com type: instance e prefixo update:
Checklist:
  - "[ ] Identificar ou elicitar o squad alvo"
  - "[ ] Elicitar: qual aspecto está sendo modificado"
  - "[ ] Elicitar: descrição da mudança"
  - "[ ] Elicitar: critérios de aceite (pelo menos 3)"
  - "[ ] Selecionar epic de destino (preferencialmente o epic original do squad)"
  - "[ ] Criar story com type: instance e prefixo update: no título"
  - "[ ] Atualizar docs/stories/README.md"
  - "[ ] Atualizar docs/epics/epic-{N}-*.md"
---

# *update-squad — Rastrear Edição de Squad via Story

Quando um squad existente precisa evoluir — nova regra, nova persona, task atualizada, pipeline revisado, integração adicionada — este comando cria uma story do tipo `instance` para rastrear a mudança.

---

## Pré-passo — Identificar squad

Se `*update-squad {squad}` foi chamado com argumento → usar esse squad.
Se chamado sem argumento → listar squads disponíveis (lendo `squads/` ou `.kairos-core/core-config.yaml`) e perguntar:

```
Qual squad você quer atualizar?
Squads disponíveis: {lista}
```

---

## Sequência de Elicitação

Faça as perguntas em ordem. Aguarde resposta completa antes de prosseguir.

---

**Pergunta 1 — Aspecto a modificar**

```
Qual aspecto do squad '{squad_name}' está sendo modificado?
  1. Persona de agente (comportamento, estilo, comandos disponíveis)
  2. Task existente (instruções, checklist, lógica)
  3. Nova task / novo comando
  4. Pipeline ou ordem de execução
  5. Regra específica do squad (arquivo em squads/{squad}/rules/)
     ⚠️  Se a atualização adicionar um novo arquivo em `rules/`, o AC da story gerada deve incluir explicitamente:
         "Adicionar `@squads/{squad}/rules/{novo-arquivo}.md` na seção Squads ativos do CLAUDE.md"
  6. Integração externa (n8n, API, webhook)
  7. Script TypeScript (src/agents/)
  8. Outro — descreva

(Pode selecionar múltiplos — separe por vírgula)
```

---

**Pergunta 2 — Descrição da mudança**

```
Descreva a mudança em 2-3 frases:
  - O que vai mudar?
  - Por que está mudando? (qual problema resolve ou melhoria entrega)
```

---

**Pergunta 3 — Critérios de aceite**

```
Quais são os critérios de aceite? (pelo menos 3, testáveis)
Ex:
  - "Persona {id}.md atualizada com novo comportamento X"
  - "Task squads/{squad}/tasks/{task}.md com instrução Y implementada"
  - "Script src/agents/{id}.ts com nova lógica Z"
```

---

**Pergunta 4 — Fora de escopo**

```
O que explicitamente NÃO está incluído nesta atualização?
(Pressione Enter para pular — usaremos "Nenhum escopo descartado")
```

---

**Pergunta 5 — Complexidade**

```
Estimativa: P (pequena) / M (média) / G (grande)?
```

---

## Seleção de Epic

Após coletar as respostas, selecionar o epic de destino:

1. Ler `docs/epics/` e identificar o epic que mais se relaciona com o squad ou com evoluções de squads ativos.
2. Informar ao usuário: "Destino: Epic {N} — {nome}" e prosseguir.
3. Se nenhum epic existente fizer sentido: criar novo epic via `*new-epic` antes de criar a story.

---

## Criar a Story

Criar `docs/stories/{epic}.{N}.story.md` com:

- `type: instance`
- Título com prefixo `update:` — ex: `update: cold-prospecting — nova regra de scoring`
- ACs derivados da elicitação
- Demais campos preenchidos normalmente

### Formato do arquivo gerado

```markdown
# Story {epic}.{N} — update: {squad_name} — {descrição curta}

**Epic:** {N}
**Status:** Draft
**Complexidade:** {P|M|G}
**Tipo:** instance
**Criada por:** @kairos
**Data:** {YYYY-MM-DD}

---

## Objetivo

Atualizar o squad `{squad_name}`: {descrição da mudança em uma frase}.

## Critérios de Aceite

- [ ] {AC 1 — específico e testável}
- [ ] {AC 2 — específico e testável}
- [ ] {AC 3 — específico e testável}

## Fora de Escopo

- {O que explicitamente NÃO cobre, ou "Nenhum escopo descartado"}

## Dependências

- Nenhuma (ou indicar se depende de outra story)

## Change Log

| Data | Evento |
|------|--------|
| {data} | Story criada por @kairos via *update-squad |
```

---

## Após Criar

1. Atualizar `docs/stories/README.md` — adicionar linha na tabela de stories
2. Atualizar `docs/epics/epic-{N}-*.md` — adicionar story na tabela do epic
3. Informar ao usuário:

```
✅ Story {epic}.{N} criada em Draft.

Squad: {squad_name}
Aspecto: {aspecto(s) elicitado(s)}

Quando pronto para implementar: Claude Code executa.
Ao concluir: *review {epic}.{N}
```
