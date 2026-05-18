---
kairos-owned: true
kairos-version: 5.0.0
task: Kairos New Story
responsavel: "@kairos"
responsavel_type: agent
atomic_layer: planning
elicit: true
Entrada: |
  - epic: Número do epic — perguntar sempre; listar epics disponíveis
  - type: kairos-core | instance — perguntar sempre; default é instance
  - description: Descrição do que precisa ser feito — elicitar interativamente
Saida: |
  - story_file: docs/stories/{epic}.{N}.story.md
Checklist:
  - "[ ] Listar epics disponíveis (lendo docs/epics/) e confirmar epic de destino"
  - "[ ] Elicitar: type (kairos-core | instance) — default instance"
  - "[ ] Se kairos-core: exibir aviso proeminente antes de criar"
  - "[ ] Determinar próximo número de story dentro do epic (lendo docs/stories/)"
  - "[ ] Elicitar: título da story"
  - "[ ] Elicitar: o que precisa ser feito (tarefas)"
  - "[ ] Elicitar: critérios de aceite (pelo menos 3)"
  - "[ ] Elicitar: fora de escopo (o que explicitamente NÃO inclui)"
  - "[ ] Elicitar: estimativa de complexidade (P/M/G)"
  - "[ ] Elicitar: dependências de outras stories"
  - "[ ] Criar arquivo docs/stories/{epic}.{N}.story.md"
  - "[ ] Atualizar docs/epics/epic-{N}-*.md com a nova story na tabela"
---

# *new-story — Criar Nova Story de Desenvolvimento do Kairos

## Contrato de Escrita

`*new-story` cria e atualiza conteúdo de instância/projeto:

- cria `docs/stories/{epic}.{N}.story.md`;
- atualiza o epic correspondente em `docs/epics/epic-{N}-*.md`.

Esses arquivos são user-owned/instance-owned por padrão, mesmo quando a story é
`type: kairos-core`. Nesse caso, a story descreve uma mudança futura no núcleo do
Kairos, mas a story em si continua sendo metadado de planejamento da instância.

Antes de escrever:

1. aplicar o manifesto e a boundary policy do runtime ativo;
2. confirmar que os arquivos-alvo não são `owned_files` nem `owned_sections` do
   framework;
3. se houver conflito com conteúdo existente, parar e pedir confirmação.

Esta task é runtime-neutral. O executor é o runtime Kairos ativo; não assumir
Claude Code ou Codex como executor universal.

## Modos de Entrada

Esta task aceita dois fluxos. Ambos estão disponíveis — o modo livre é o caminho principal:

- **Modo Livre**: o usuário descreve o objetivo em linguagem natural → o @kairos deriva os campos e exibe proposta consolidada para confirmação
- **Modo Guiado**: perguntas sequenciais campo a campo → ativado quando o usuário pede ("me faça as perguntas") ou quando a descrição não contém informação suficiente para derivar os campos

### Modo Livre

Quando o usuário fornece uma descrição do objetivo (ex: "quero rastrear quando o n8n falha"), derivar:

- **Epic**: selecionar o epic mais provável lendo `docs/epics/`; apresentar para confirmação se houver ambiguidade
- **Type**: `instance` por default (usar `kairos-core` apenas se a descrição indicar explicitamente modificação do framework)
- **Título**: derivado da descrição
- **Critérios de aceite**: mínimo 3, testáveis
- **Fora de escopo**: o que naturalmente não faz parte do objetivo descrito
- **Complexidade**: P/M/G com razão em uma frase (usar heurística: P = ajuste em um arquivo; M = múltiplos arquivos ou novo comportamento; G = novo agente, nova task ou mudança de pipeline)
- **Dependências**: se detectáveis da descrição

Exibir proposta consolidada para confirmação antes de criar qualquer arquivo:

```
Vou criar a story com estas informações:

Epic: {N} — {nome}
Tipo: {instance | kairos-core}
Título: {título derivado}

Critérios de aceite:
  - [ ] {AC 1}
  - [ ] {AC 2}
  - [ ] {AC 3}

Fora de escopo:
  - {item}

Complexidade: {P|M|G} — {razão}
Dependências: {deps ou "Nenhuma"}

Posso criar? (s/n — ou ajuste o que precisar)
```

Aguardar confirmação:
- `s` → criar
- Ajuste pontual → aplicar e criar
- "me faça as perguntas" ou pedido de edição campo a campo → ativar Modo Guiado abaixo

### Modo Guiado

Ativado quando o usuário pede explicitamente ("me faça as perguntas") ou quando a descrição livre não contém informação suficiente para derivar os campos. É um fallback, não o caminho principal.

Pergunte sequencialmente, aguardando resposta a cada passo:

1. **Epic**: Listar os epics disponíveis lendo `docs/epics/` e perguntar:
   "Qual epic? Epics disponíveis: {lista dos epics encontrados em docs/epics/}"
   → Ler os arquivos `docs/epics/epic-*.md` para extrair o número e nome de cada epic.

2. **ID automático**: Após o usuário escolher o epic, determinar o próximo número da story:
   → Listar `docs/stories/` e filtrar arquivos com prefixo `{epic}.`.
   → Contar quantas stories existem no epic escolhido e usar `N = count + 1`.
   → Informar ao usuário: "ID gerado: {epic}.{N}"

3. **Tipo**: "Esta story modifica o framework Kairos em si (kairos-core) ou cria/evolui um squad, worker ou agente (instance)? [instance]"
   → Default é `instance` se o usuário pressionar Enter sem resposta.
   → Se `kairos-core`: anotar para exibir aviso antes de criar o arquivo (ver Aviso abaixo).

4. **Título**: "Qual o título da story? (resumo em uma linha do que será feito)"

5. **O que precisa ser feito**:
   - Se `type: instance`: "Descreva o que precisa acontecer — pode ser em tópicos. Ex: criar agente, configurar pipeline, adicionar task, expandir persona, configurar worker"
   - Se `type: kairos-core`: "Descreva o que precisa acontecer — pode ser em tópicos"

6. **Critérios de aceite**: "Quais são os critérios de aceite? (pelo menos 3, testáveis)"

7. **Fora de escopo**: "O que explicitamente NÃO está incluído nesta story?"

8. **Complexidade**: "Estimativa: P (pequena) / M (média) / G (grande)?"

9. **Dependências**: "Depende de alguma story existente? (ex: 1.2 deve estar Done)"

## Aviso kairos-core (exibir antes de criar o arquivo)

Se `type: kairos-core`, exibir este aviso imediatamente antes de criar o arquivo:

```
⚠️  ATENÇÃO — MODIFICAÇÃO DO NÚCLEO DO KAIROS
────────────────────────────────────────────────────────────
Esta story modifica o núcleo do framework Kairos. Alterações são livres (Kairos é open-source), mas podem impedir futuras atualizações automáticas, e podem ser sobrescritas por eventuais atualizações. Ao prosseguir, você estará fazendo um fork local do Kairos. Continue com consciência — por conta e risco do usuário.
────────────────────────────────────────────────────────────
```

## Formato do Arquivo

### Para `type: instance` (padrão)

```markdown
# Story {epic}.{N} — {Título}

**Epic:** {N}
**Status:** Draft
**Complexidade:** {P|M|G}
**Tipo:** instance
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

### Para `type: kairos-core`

```markdown
# Story {epic}.{N} — {Título}

**Epic:** {N}
**Status:** Draft
**Complexidade:** {P|M|G}
**Tipo:** kairos-core
**Criada por:** @kairos
**Data:** {YYYY-MM-DD}

---

⚠️  ATENÇÃO — MODIFICAÇÃO DO NÚCLEO DO KAIROS
────────────────────────────────────────────────────────────
Esta story modifica o núcleo do framework Kairos. Alterações
são livres (Kairos é open-source), mas podem impedir futuras
atualizações automáticas, e podem ser sobrescritas por
eventuais atualizações. Ao prosseguir, você estará fazendo
um fork local do Kairos. Continue com consciência — por conta
e risco do usuário.
────────────────────────────────────────────────────────────

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

1. Atualizar `docs/epics/epic-{N}-*.md` — adicionar story na tabela de stories do epic
2. Informar ao usuário, com mensagem diferenciada por tipo:
   - **Se `type: kairos-core`:** "Story {epic}.{N} criada em Draft. Quando pronto para implementar no runtime ativo, execute `*implement {epic}.{N}` ou encaminhe ao executor apropriado; ao concluir, rode `*review {epic}.{N}`."
   - **Se `type: instance`:** "Story {epic}.{N} criada em Draft. Quando pronto para implementar, rode `*implement {epic}.{N}` (executor: runtime Kairos ativo)."
