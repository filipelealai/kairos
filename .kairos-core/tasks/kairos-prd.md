---
kairos-owned: true
kairos-version: 2.0.0
task: Kairos PRD
responsavel: "@kairos"
responsavel_type: agent
atomic_layer: documentation
elicit: true
Entrada: |
  - action: "create" | "update" — inferido pela existência de docs/scope.md
  - section: seção específica a atualizar (opcional — para updates cirúrgicos)
Saida: |
  - docs/scope.md criado ou atualizado
  - versão do scope.md incrementada
  - Change Log do scope.md atualizado
Checklist:
  - "[ ] Verificar se docs/scope.md já existe"
  - "[ ] Modo create: elicitar todas as seções via perguntas guiadas"
  - "[ ] Modo update: mostrar estado atual, elicitar mudanças específicas"
  - "[ ] Confirmar conteúdo com usuário antes de escrever"
  - "[ ] Escrever/atualizar docs/scope.md"
  - "[ ] Incrementar versão do scope e registrar no Change Log interno"
---

# *prd — Criação e Atualização do Product Requirements Document

`docs/scope.md` é o escopo desta instância do Kairos — descreve os squads, objetivos e restrições específicos deste projeto. Esta task é a única responsável por criar e atualizar esse documento.

---

## Pré-passo — Detectar modo

```
Se docs/scope.md não existe → modo: CREATE
Se docs/scope.md existe     → modo: UPDATE
```

---

## Modo CREATE — Novo PRD

### Sequência de elicitação

Faça as perguntas em ordem. Aguarde resposta de cada uma antes de prosseguir.

---

**Pergunta 1 — Foco desta instância**
```
Para quem esta instância do Kairos serve e qual é o foco dela?
```

---

**Pergunta 2 — Arquitetura geral**
```
Quais são os sistemas que o Kairos conecta?
Liste os componentes principais e como eles se comunicam.
(ex: n8n ↔ Kairos ↔ Google Sheets, via webhook)
```

---

**Pergunta 3 — Escopos ativos**
```
Quais escopos (squads) estão ativos hoje?
Para cada um: nome, descrição em uma frase, fluxo de trabalho resumido.
```

---

**Pergunta 4 — Objetivos e métricas**
```
Para cada escopo ativo, quais são os objetivos mensuráveis?
(ex: "Taxa de resposta > baseline de templates genéricos")
```

---

**Pergunta 5 — Restrições**
```
O que o Kairos NUNCA faz (por design)?
(ex: não envia e-mails, não modifica planilha diretamente)
```

---

**Pergunta 6 — Stack**
```
Qual é a stack técnica atual?
(Runtime, linguagem, AI SDK, banco de dados, integrações externas)
```

---

**Confirmação final:**
```
Vou criar docs/scope.md com estas informações:

[resumo das respostas]

Posso prosseguir? (s/n — ou diga o que ajustar)
```

Após confirmação → escrever o arquivo.

---

## Modo UPDATE — Atualizar PRD existente

### Passo 1 — Mostrar estado atual

Leia `docs/scope.md` completo. Exiba um resumo:

```
📄 PRD atual — docs/scope.md (v{versão}, {data})

Seções presentes:
  ✅ O que é o Kairos
  ✅ Arquitetura Geral
  ✅ Escopos ({N} escopo(s): {nomes})
  ✅/⚠️ Objetivos por Escopo
  ✅/⚠️ Restrições
  ✅ Stack
  ✅ Change Log

O que deseja atualizar?
  1. Adicionar/atualizar escopo
  2. Atualizar objetivos/métricas
  3. Atualizar restrições
  4. Atualizar stack
  5. Atualizar arquitetura
  6. Atualizar "O que é o Kairos"
  7. Revisão completa
  8. Outra coisa (descreva)
```

### Passo 2 — Elicitação cirúrgica

Com base na seleção do usuário, faça apenas as perguntas relevantes para a seção escolhida.

**Se novo escopo (opção 1):**
```
- Nome do escopo (slug em kebab-case):
- Descrição em uma frase:
- Fluxo de trabalho (passos principais):
- Squad responsável (agentes):
- Dados gerenciados (inputs/outputs):
- Objetivos e métricas para este escopo:
```

**Se revisão completa (opção 7):** percorrer todas as seções e confirmar cada uma.

### Passo 3 — Confirmação antes de escrever

```
Vou fazer as seguintes mudanças em docs/scope.md:

[lista de mudanças]

Posso prosseguir? (s/n — ou diga o que ajustar)
```

---

## Pós-escrita — Atualizar versão e Change Log

Após escrever o arquivo:

1. Ler a versão atual no cabeçalho (`**Versão:** X.Y`)
2. Incrementar MINOR se seção nova ou escopo novo, PATCH se correção/atualização
3. Atualizar `**Atualizado em:**` para hoje
4. Adicionar entrada no `## Change Log` interno do scope.md:
   ```
   | {versão nova} | {data} | {descrição curta da mudança} |
   ```

---

## Formato do docs/scope.md

O arquivo deve sempre seguir esta estrutura:

```markdown
# Instância Kairos — Escopo e Objetivos da Instância

**Versão:** {X.Y}
**Atualizado em:** {YYYY-MM-DD}

---

## O que é o Kairos

{parágrafo de identidade}

---

## Arquitetura Geral

{diagrama ou descrição}

---

## Escopos

### Escopo N — {Nome} ({status: ativo | planejado | descontinuado})

{descrição}

**Fluxo:**
{passos}

**Squad responsável:** `{squad}` ({agentes})

**Dados gerenciados:**
- {inputs e outputs}

---

## Objetivos por Escopo

### {Nome do Escopo}

| Objetivo | Métrica |
|----------|---------|
| {objetivo} | {métrica mensurável} |

---

## Restrições

- **{restrição}** — {justificativa}

---

## Stack

- **Runtime:** {valor}
- **Linguagem:** {valor}
- **AI:** {valor}
- **Runner:** {valor}
- **Dados externos:** {valor}

---

## Change Log

| Versão | Data | Mudança |
|--------|------|---------|
| {X.Y} | {data} | {mudança} |
```
