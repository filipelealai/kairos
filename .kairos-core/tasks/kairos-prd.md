---
kairos-owned: true
kairos-version: 3.1.3
task: Kairos PRD
responsavel: "@kairos"
responsavel_type: agent
atomic_layer: documentation
elicit: true
Entrada: |
  - action: "create" | "update" — inferido pela existência de docs/scope.md
  - section: seção específica a atualizar (opcional — para updates cirúrgicos)
  - context: o que o usuário descreveu ao chamar *prd (opcional)
Saida: |
  - docs/scope.md criado ou atualizado
  - versão do scope.md incrementada
  - Change Log do scope.md atualizado
Checklist:
  - "[ ] Verificar se docs/scope.md já existe"
  - "[ ] Modo create: fluxo conversacional para elicitar escopo"
  - "[ ] Modo update: mostrar estado atual ou ir direto à elicitação se contexto fornecido"
  - "[ ] Confirmar rascunho com usuário antes de escrever"
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

### Passo 0 — Coletar contexto antes de perguntar

Antes de fazer qualquer pergunta ao usuário, ler:

1. `package.json` → extrair `name`, runtime, principais dependências
2. `.kairos-core/core-config.yaml` → extrair `agents.squads` (squads ativos e seus agentes)

Com esse contexto em mãos, formular a abertura.

---

### Passo 1 — Abertura conversacional

Faça **uma única pergunta aberta**:

```
Me conta: o que você está construindo com o Kairos aqui, e para quê?
(pode ser informal — objetivo, problema que resolve, contexto de uso)
```

Aguarde a resposta antes de continuar.

---

### Passo 2 — Processar resposta e inferir

A partir da resposta do usuário:

**Inferência de domínio:** se o usuário menciona termos como "prospecção", "leads", "e-mails", "clientes", "vendas" → inferir domínio de cold outreach. Se menciona "dados", "relatórios", "análise" → inferir analytics. Confirmar a inferência em vez de perguntar do zero.

**Squads ativos:** os squads lidos de `core-config.yaml` → `agents.squads` são apresentados como confirmação:
```
Vi que você tem o squad X ativo (agentes: A, B, C). Quer incluir no escopo?
```
Não perguntar quais squads existem — confirmá-los.

**Stack:** inferida de `package.json` e `core-config.yaml`. Não perguntar ao usuário, a menos que o `package.json` não exista ou indique stack divergente do padrão Kairos (Node.js/tsx/Anthropic SDK).

---

### Passo 3 — Perguntas de follow-up (máximo 2-3)

Faça perguntas de follow-up **apenas para o que ainda está faltando** após a resposta inicial. Se o usuário já respondeu voluntariamente algo, não pergunte de novo.

Informações que precisam ser cobertas antes do rascunho:
- Arquitetura geral (sistemas que o Kairos conecta) — se não mencionada
- Objetivos mensuráveis por escopo — se não mencionados
- Restrições principais (o que o Kairos nunca faz) — se não mencionadas

Se o usuário for vago, faça no máximo 2-3 perguntas adicionais e depois prossiga com um rascunho para ajuste.

---

### Passo 4 — Apresentar rascunho para confirmação

Antes de escrever o arquivo, apresentar o rascunho completo do `docs/scope.md` e perguntar:

```
Ficou bom ou quer ajustar alguma coisa?
```

Aguarde confirmação ou ajustes. Só após aprovação → escrever o arquivo.

---

## Modo UPDATE — Atualizar PRD existente

### Pré-passo — Verificar se contexto foi fornecido

Se o usuário descreveu o que quer mudar ao chamar `*prd` (ex: `*prd adicionar novo squad`, `*prd atualizar objetivos`):
→ **pular o menu** e ir direto à elicitação da mudança descrita.

Se nenhum contexto foi fornecido → mostrar menu abaixo.

---

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
  2. Objetivos e métricas
  3. Restrições
  4. Stack
  5. Arquitetura
  6. Identidade da instância
  7. Revisão completa
  8. Outra coisa (descreva)
```

### Passo 2 — Elicitação cirúrgica

Com base na seleção do usuário (ou no contexto fornecido), faça apenas as perguntas relevantes para a seção escolhida.

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

Ficou bom ou quer ajustar alguma coisa?
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
