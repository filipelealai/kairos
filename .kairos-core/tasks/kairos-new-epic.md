---
kairos-owned: true
kairos-version: 5.0.0
task: Kairos New Epic
responsavel: "@kairos"
responsavel_type: agent
atomic_layer: governance
elicit: true
Entrada: |
  - titulo: título sugerido (opcional — pode ser elicitado)
Saida: |
  - docs/epics/epic-{N}-{slug}.md criado
  - docs/stories/README.md atualizado (tabela de epics)
  - handoff condicional para *new-story (com confirmação do usuário)
Checklist:
  - "[ ] Detectar próximo número de epic disponível"
  - "[ ] Elicitar campos via perguntas guiadas"
  - "[ ] Confirmar conteúdo completo com usuário"
  - "[ ] Criar docs/epics/epic-{N}-{slug}.md"
  - "[ ] Atualizar docs/stories/README.md"
  - "[ ] Oferecer handoff condicional para *new-story"
---

# *new-epic — Criação de Epic

---

## Pré-passo — Detectar próximo número

1. Listar arquivos em `docs/epics/` com padrão `epic-{N}-*.md`
2. Pegar o maior N encontrado
3. Próximo epic = N + 1
4. Exibir: `→ Criando Epic {N+1}`

---

## Modos de Entrada

Esta task aceita dois fluxos. Ambos estão disponíveis — o modo livre é o caminho principal:

- **Modo Livre**: o usuário descreve o objetivo do epic em linguagem natural → o @kairos deriva os campos e exibe proposta consolidada para confirmação
- **Modo Guiado**: perguntas sequenciais campo a campo → ativado quando o usuário pede ou quando a descrição não contém informação suficiente

### Modo Livre

Quando o usuário fornece uma descrição do objetivo do epic (ex: "quero um epic para organizar tudo relacionado a integrações externas"), derivar:

- **Tema**: em uma frase curta
- **Objetivo**: o que estará diferente/melhor quando o epic for concluído
- **Critérios de conclusão**: mínimo 3, verificáveis
- **Status inicial**: `Backlog` por default (salvo se a descrição indicar trabalho já em andamento)
- **Stories candidatas**: se mencionadas na descrição
- **Dependências**: se mencionadas na descrição

Exibir proposta consolidada para confirmação antes de criar qualquer arquivo:

```
Vou criar o epic com estas informações:

Epic {N} — {Tema}
Status: {status}
Objetivo: {objetivo}

Critérios de Conclusão:
  - [ ] {critério 1}
  - [ ] {critério 2}
  - [ ] {critério 3}

Stories Candidatas:
  - {candidata 1}
  (ou "nenhuma")

Dependências: {deps ou "nenhuma"}

Arquivo: docs/epics/epic-{N}-{slug}.md

Posso criar? (s/n — ou diga o que ajustar)
```

Aguardar confirmação:
- `s` → criar
- Ajuste pontual → aplicar e criar
- "me faça as perguntas" → ativar Modo Guiado abaixo

---

## Modo Guiado — Elicitação Sequencial

Ativado quando o usuário pede explicitamente ou quando a descrição livre não contém informação suficiente. É um fallback, não o caminho principal.

Faça as perguntas em ordem. Aguarde resposta completa antes de prosseguir.
Não pule nem junte perguntas.

---

**Pergunta 1 — Tema**
```
Qual é o tema do epic em uma frase curta?
(ex: "Automação de Disparo de E-mails", "Integração com CRM")

Nota: O uso padrão do Kairos é criar e gerenciar squads, workers e agentes.
Se este epic não for sobre o núcleo do framework, considere começar com *new-squad.
```

---

**Pergunta 2 — Objetivo**
```
Qual é o objetivo principal deste epic?
O que estará diferente/melhor quando ele for concluído?
```

---

**Pergunta 3 — Critérios de Conclusão**
```
Quais são os critérios objetivos de conclusão?
Liste pelo menos 3 itens verificáveis (eles virarão checkboxes).

Exemplos de bons critérios:
  — Para squads / workers / agentes (uso mais comum):
    - "Squad {nome} scaffoldado com persona, tasks e pipeline documentados"
    - "Agente {id} com persona .claude/commands/kairos/agents/{id}.md funcional"
    - "Worker agendado rodando pipeline completo semanalmente"
    - "Integração com {sistema} configurada e testada end-to-end"
  — Para núcleo do framework (kairos-core):
    - "Task kairos-xyz.md implementada e funcional"
    - "Rule {nome}.md em .kairos-core/rules/ documentada e referenciada"

(Liste um por linha)
```

---

**Pergunta 4 — Status inicial**
```
Qual o status inicial do epic?
  1. Backlog — planejado, sem work ativo
  2. In Progress — já tem implementação em andamento
  3. Draft — rascunho, ainda sendo refinado
```

---

**Pergunta 5 — Stories candidatas (opcional)**
```
Já tem alguma ideia de stories (sub-tarefas) para este epic?
São candidatas — não comprometidas ainda.

Formato: uma por linha — "título da story candidata"
(Pressione Enter sem texto para pular)
```

---

**Pergunta 6 — Dependências (opcional)**
```
Este epic depende de algum outro epic estar concluído ou em progresso?
(ex: "Epic 2 concluído", "Epic 3 In Progress")
(Pressione Enter sem texto para pular)
```

---

## Confirmação antes de criar

Após coletar todas as respostas, exibir para confirmação:

```
Vou criar o epic com estas informações:

Epic {N} — {Tema}
Status: {status}
Objetivo: {objetivo}

Critérios de Conclusão:
  - [ ] {critério 1}
  - [ ] {critério 2}
  - [ ] {critério 3}
  ...

Stories Candidatas:
  - {candidata 1}
  - {candidata 2}
  (ou "nenhuma")

Dependências: {deps ou "nenhuma"}

Arquivo: docs/epics/epic-{N}-{slug}.md

Posso criar? (s/n — ou diga o que ajustar)
```

Aguardar confirmação. Se "n" ou ajuste → retornar às perguntas afetadas.

---

## Criar o arquivo do epic

Após confirmação, criar `docs/epics/epic-{N}-{slug}.md`:

**Gerar slug:** título em kebab-case, sem acentos, sem caracteres especiais.
Ex: "Automação de Disparo" → `automacao-de-disparo`

```markdown
# Epic {N} — {Tema}

**Status:** {Backlog | In Progress | Draft}
**Objetivo:** {objetivo}

---

## Descrição

{objetivo expandido — 2-3 parágrafos com contexto}

---

## Critério de Conclusão

{Para cada critério}
- [ ] {critério}

---

## Stories

| Story | Título | Status |
|-------|--------|--------|
| — | (nenhuma criada ainda) | — |

---

## Stories Candidatas (não criadas ainda)

{Se houver candidatas:}
- **{N}.1** — {candidata 1}
- **{N}.2** — {candidata 2}

{Se não houver:}
Nenhuma story candidata definida ainda.

{Se houver dependências:}
---

## Dependências

{lista de dependências de outros epics}

---

## Change Log

| Data | Mudança |
|------|---------|
| {hoje} | Epic criado |
```

---

## Atualizar docs/stories/README.md

Adicionar linha na tabela de epics:

```markdown
| [{N}](../epics/epic-{N}-{slug}.md) | {Tema} | {Status} |
```

---

## Handoff condicional para *new-story

Após criar o epic, perguntar:

```
Epic {N} criado em docs/epics/epic-{N}-{slug}.md ✅

Deseja criar a primeira story para este epic agora?
  s — iniciar *new-story "{título sugerido da primeira story candidata}"
  n — encerrar aqui

(As stories candidatas podem ser criadas depois com *new-story)
```

Se "s":
- Executar `*new-story` com o epic {N} já pré-selecionado
- Pular a pergunta "qual epic?" na elicitação do *new-story

Se "n":
- Exibir: `Epic registrado. Para criar stories depois: *new-story "título" (epic {N})`
- Encerrar
