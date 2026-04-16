---
kairos-owned: true
kairos-version: 2.0.0
task: Kairos New Squad
responsavel: "@kairos"
responsavel_type: agent
atomic_layer: scaffolding
elicit: true
Entrada: |
  - squad_name: nome sugerido (opcional — pode ser elicitado)
Saida: |
  - squads/{squad_name}/ com estrutura completa e conteúdo real (não stubs vazios)
  - .kairos-core/core-config.yaml atualizado (novo squad em agents.squads)
  - epic de candidatos do usuário atualizado (se existir e houver correspondência)
  - story de implementação auto-criada via *new-story (type: instance)
Checklist:
  - "[ ] Elicitar escopo, propósito e contexto do squad"
  - "[ ] Elicitar agentes: nome, persona, responsabilidade, comando principal"
  - "[ ] Elicitar fonte de dados e integrações externas"
  - "[ ] Elicitar outputs esperados por agente"
  - "[ ] Elicitar pipeline: ordem, execução parcial permitida"
  - "[ ] Elicitar integrações com sistemas externos"
  - "[ ] Confirmar arquitetura completa antes de criar qualquer arquivo"
  - "[ ] Criar squads/{squad_name}/squad.yaml (com conteúdo real)"
  - "[ ] Criar squads/{squad_name}/README.md"
  - "[ ] Criar squads/{squad_name}/agents/{id}.md por agente"
  - "[ ] Criar squads/{squad_name}/tasks/ com stubs de tasks"
  - "[ ] Criar squads/{squad_name}/workflows/full-pipeline.md"
  - "[ ] Criar .kairos-core/agents/{id}/MEMORY.md por agente"
  - "[ ] Atualizar .kairos-core/core-config.yaml"
  - "[ ] Auto-executar *new-story com type: instance ao final do scaffolding"
---

# *new-squad — Criação de Squad com Elicitação Guiada

Um squad é um grupo de agentes especializados que colaboram para um fluxo de trabalho específico do usuário/equipe.
Esta task elicita tudo o que é necessário para scaffoldar uma estrutura completa e útil — não stubs genéricos.

---

## Pré-passo — Detectar candidatos em epic de planejamento (opcional)

Se o usuário mantém um epic listando squads candidatos (ex: "Novos Escopos"), ler esse epic e apresentar os candidatos antes de elicitar do zero.

Se não houver epic de candidatos: pular este passo e ir direto para a elicitação completa.

Se não houver candidatos (ou o nome já foi passado como argumento) → prosseguir para elicitação.

---

## Sequência de Elicitação

Faça as perguntas em ordem. Aguarde resposta completa antes de prosseguir.

---

### Bloco 1 — Propósito

**Pergunta 1.1 — Nome**
```
Como se chama este squad? (slug em kebab-case)
ex: lead-followup, content-scheduler, financial-tracker
```

**Pergunta 1.2 — O que faz**
```
Descreva em 2-3 frases: o que este squad faz, para qual fluxo de trabalho,
e qual problema resolve ou qual resultado entrega.
```

**Pergunta 1.3 — Contexto de negócio**
```
Este squad está ligado a qual contexto (domínio de trabalho, área de atuação)?
```

---

### Bloco 2 — Agentes

**Pergunta 2.1 — Quantidade e papéis**
```
Quais agentes compõem este squad?
Para cada um, informe:
  - ID (kebab-case): ex: followup-analyst
  - Nome da persona (para o agente ter "personalidade"): ex: Felix
  - Papel em uma frase: o que ele faz exclusivamente

(Liste um agente por linha no formato: id | nome | papel)
```

**Pergunta 2.2 — Comandos principais**
```
Para cada agente, qual é o comando mais importante que ele executa?
(ex: campaign-analyst → *analyze | lead-scorer → *score)

Pode listar mais de um por agente se necessário.
```

**Pergunta 2.3 — Tem script TypeScript?**
```
Algum agente precisa de computação pura (sem AI) — processamento de dados,
cálculos, transformações — que deveria virar um script em src/agents/?

(ex: o lead-scorer.ts calcula scores numericamente sem chamar Claude)

Liste quais agentes terão script TS e uma frase do que o script faz.
(Pressione Enter sem texto se todos usam Claude diretamente)
```

---

### Bloco 3 — Dados

**Pergunta 3.1 — Fonte de dados**
```
De onde vêm os dados que este squad processa?
  1. Webhook n8n existente (kairos-leads ou similar) — informar URL
  2. Novo webhook n8n — descrever o que retorna
  3. Arquivo local (CSV, JSON) — informar path e formato
  4. API externa direta — informar endpoint e autenticação
  5. Input manual do usuário (sem fonte automatizada)
  6. Misto — descrever
```

**Pergunta 3.2 — Outputs**
```
O que cada agente gera?
Para cada agente, informe:
  - Arquivo gerado (path e formato): ex: data/outputs/{squad}/reports/followup-YYYY-MM-DD.md
  - Destino final: apenas lido pelo próximo agente / enviado para integração externa / exibido ao usuário / outro

(Liste um por linha: agente → path → destino)
```

---

### Bloco 4 — Pipeline e Integrações

**Pergunta 4.1 — Ordem de execução**
```
Qual é a ordem dos agentes no pipeline?
(ex: followup-analyst → response-scorer → reply-writer)

Execução parcial é permitida? (pode rodar agentes individualmente, sem o pipeline completo?)
```

**Pergunta 4.2 — Integração externa**
```
Este squad depende de n8n para alguma ação automatizada?
(ex: disparo de e-mails, leitura de planilha, webhook de entrada)

Se sim: descreva o papel do n8n — o que ele faz que o Kairos não faz.
Se não: o squad opera de forma autônoma com os dados disponíveis.
```

**Pergunta 4.3 — Frequência de uso**
```
Com que frequência este squad deve ser rodado?
  1. Diariamente (parte de uma rotina fixa)
  2. Semanalmente
  3. Sob demanda
  4. Triggered por evento (qual?)
```

---

## Confirmação antes de criar

Após coletar tudo, exibir para confirmação:

```
Vou criar o squad com esta arquitetura:

Squad: {squad_name}
Contexto: {contexto}
Descrição: {descrição}

Agentes ({N}):
  {id} ({Nome}) — {papel}
    Comando principal: *{cmd}
    Output: {path}
    Script TS: {sim/não}
  ...

Pipeline: {agente1} → {agente2} → {agente3}
Execução parcial: {sim/não}

Fonte de dados: {fonte}
Integração n8n: {sim/não — papel}
Frequência: {frequência}

Arquivos a criar:
  squads/{squad_name}/squad.yaml
  squads/{squad_name}/README.md
  squads/{squad_name}/agents/{id}.md  (× N)
  squads/{squad_name}/tasks/{task}.md  (× N — stubs)
  squads/{squad_name}/workflows/full-pipeline.md
  .kairos-core/agents/{id}/MEMORY.md  (× N)

Posso criar? (s/n — ou diga o que ajustar)
```

Aguardar confirmação. Se "n" → voltar ao ponto específico indicado.

---

## Scaffolding

### squad.yaml

```yaml
name: {squad_name}
version: 0.1.0
description: >
  {descrição completa — 2-3 linhas}
author: {autor do squad}

kairos:
  minVersion: "{versão atual do core-config.yaml}"
  type: squad
  scope: {squad_name}
  context: {contexto do usuário ou equipe}

components:
  agents:
    {lista: - agents/{id}.md}
  tasks:
    {lista: - tasks/{task-slug}.md}
  workflows:
    - workflows/full-pipeline.md

config:
  scope: ../../docs/scope.md
  agent-standards: ../../.kairos-core/docs/agent-standards.md
  data-flow: ../../.kairos-core/docs/data-flow.md

pipeline:
  order:
    {lista com comentário: - {id}  # *{cmd}}
  partial_execution: {true|false}

data:
  {se webhook:   input_webhook: {url}}
  {se arquivo:   input_file: {path}}
  {se api:       input_api: {endpoint}}
  outputs:
    {lista de paths com formato}
  handoffs: .kairos-core/runtime/handoffs/

dependencies:
  node:
    - tsx
    - "@anthropic-ai/sdk"
    - dotenv
  squads: []
  external:
    {lista de integrações externas — ex: "n8n webhook (kairos-leads)"}

tags:
  - {squad_name}
  - kairos
  {tags relevantes de negócio}
```

---

### README.md

```markdown
# Squad {NomeHumanReadable} — {descrição curta}

## O que faz

{descrição em 2-3 parágrafos}

## Agentes

| Agente | Persona | Responsabilidade | Comando |
|--------|---------|-----------------|---------|
{linha por agente}

## Pipeline

```
{agente1} → {agente2} → {agente3}
```

Execução parcial: {permitida/não permitida}

## Fonte de Dados

{descrição da fonte, URL se webhook, path se arquivo}

## Outputs

| Agente | Output | Destino |
|--------|--------|---------|
{linha por agente}

## Como Usar

```
@{primeiro-agente} *{cmd-principal}
```

{exemplo de pipeline completo}
```

---

### agents/{id}.md (definição leve)

Para cada agente:

```markdown
---
agent:
  id: {id}
  name: {Nome da Persona}
  icon: {emoji relevante ao papel}
  persona_file: .claude/commands/kairos/agents/{id}.md
  whenToUse: "{quando usar este agente em uma frase}"

commands_key:
  - "*{cmd1}" — {descrição}
  {se houver mais:}
  - "*{cmd2}" — {descrição}

outputs:
  - "{path do output}"

{se tiver próximo agente:}
handoff_to: {próximo-agente-id}
{se não tiver:}
handoff_to: null  # último agente do pipeline
---

{Nome} é {papel em uma frase}. {Descrição do que faz e do que não pode fazer — analogia com Clio/Lex/Nix/Eva}.

**Responsabilidade exclusiva:** {o que só ele pode fazer}
**Não pode:** {restrições explícitas}
```

---

### tasks/{task-slug}.md (stubs)

Para cada agente com task principal, criar um stub mínimo:

```markdown
---
task: {Nome da Task}
responsavel: "@{id}"
responsavel_type: agent
atomic_layer: {analysis|scoring|classification|generation|automation}
elicit: false
Entrada: |
  - {campo}: {descrição} — {obrigatório/opcional}
Saida: |
  - {output}: {path e formato}
Checklist:
  - "[ ] {passo 1}"
  - "[ ] {passo 2}"
  - "[ ] {passo 3}"
---

# *{cmd} — {Título da Task}

> ⚠️ Task stub — implementação pendente.
> Ver story de implementação do squad {squad_name}.

## Execução

### Passo 1 — {descrição}

{placeholder — preencher quando implementar}

### Passo 2 — {descrição}

{placeholder — preencher quando implementar}
```

---

### workflows/full-pipeline.md

```markdown
# Pipeline Completo — {Squad NomeHumanReadable}

## Fluxo

```
{diagrama ASCII do pipeline com fases}
```

## Fases

| Fase | Agente | Comando | Output |
|------|--------|---------|--------|
{linha por fase}

## Handoff Chain

{lista de handoffs: agente-a → agente-b : nome-do-arquivo-de-handoff}

## Execução Parcial

{Exemplos de execuções válidas que não percorrem o pipeline inteiro}

## Frequência Recomendada

{com base na frequência de uso elicitada}
```

---

### .kairos-core/agents/{id}/MEMORY.md (por agente)

```markdown
# {Nome} Memory ({NomeDaPersona})

## Active Patterns

### Dados e Saída
- (sem padrões registrados ainda — atualizar após primeiras execuções)

### Gotchas Técnicos
- (sem gotchas registrados ainda)

## Promotion Candidates
<!-- Padrões vistos em 3+ execuções — candidatos para .claude/rules/ -->

## Archived
<!-- Padrões obsoletos — manter para histórico -->
```

---

## Atualizar core-config.yaml

Adicionar em `agents.squads`:

```yaml
{squad_name}:
  agents: [{lista de ids}]
  status: active
  version: 0.1.0
```

---

## Atualizar epic de candidatos (se existir)

Se o usuário mantém um epic listando squads candidatos e o novo squad estava lá:

1. Remover da tabela de candidatos
2. Adicionar no Change Log do epic:
   ```
   | {data} | Squad `{squad_name}` scaffoldado — story de implementação criada |
   ```

Se não há epic de candidatos: pular este passo.

---

## Notas pós-scaffolding e auto-criação de story

Após criar tudo, exibir o resumo e em seguida auto-executar `*new-story`:

```
✅ Squad '{squad_name}' scaffoldado em squads/{squad_name}/

Criado:
  ✅ squad.yaml
  ✅ README.md
  ✅ agents/ ({N} agentes)
  ✅ tasks/ ({N} stubs)
  ✅ workflows/full-pipeline.md
  ✅ .kairos-core/agents/{id}/MEMORY.md  (× N)
  ✅ core-config.yaml atualizado
  ✅ Epic {N} atualizado

Criando story de implementação para o squad {squad_name}…
```

Em seguida, **auto-executar `*new-story`** sem perguntar ao usuário (a story é parte obrigatória do scaffolding):

- `type`: `instance` (fixo — nunca kairos-core para squads de usuário)
- `epic`: selecionar o epic existente que mais se encaixa (ler `docs/epics/` e escolher o que tiver maior afinidade temática com o squad); se nenhum bater ou não existir nenhum, criar um novo epic antes com `*new-epic`
- `title`: `"Implementar squad {squad_name}"` (pré-preenchido)
- ACs pré-preenchidos derivados do elicitado:
  1. Persona `.claude/commands/kairos/agents/{id}.md` criada para cada agente
  2. Tasks em `squads/{squad_name}/tasks/` implementadas com conteúdo real (não stubs)
  3. Scripts `src/agents/{id}.ts` por agente com script TS (apenas se elicitado na pergunta 2.3)
- Demais campos (fora de escopo, complexidade, dependências): elicitar normalmente

Após a story ser criada, exibir a oferta de implementação imediata:

```
✅ Story {epic}.{N} criada em Draft.

Implementar o squad agora?
  s → *implement {epic}.{N}  (executa inline nesta sessão)
  n → fazer depois           (retomar com *implement {epic}.{N} ou *roadmap)
```

Aguardar resposta do usuário:
- Se **s**: executar `*implement {epic}.{N}` inline na mesma sessão (carregar a task kairos-implement.md)
- Se **n** (ou qualquer resposta negativa):
  ```
  Ok. Quando quiser implementar: *implement {epic}.{N}
  ```
