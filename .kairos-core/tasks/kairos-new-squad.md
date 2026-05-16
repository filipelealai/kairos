---
kairos-owned: true
kairos-version: 3.13.0
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
  - "[ ] Criar squads/{squad_name}/agents/{id}.yaml por agente"
  - "[ ] Gerar persona .claude/commands/kairos/agents/{id}.md a partir do .yaml por agente"
  - "[ ] Criar squads/{squad_name}/tasks/ com stubs de tasks"
  - "[ ] Criar squads/{squad_name}/workflows/full-pipeline.md"
  - "[ ] Criar .kairos-core/agents/{id}/MEMORY.md por agente"
  - "[ ] Criar squads/{squad_name}/rules/ com memory-imports.md, agent-authority.md e {squad_name}-lifecycle.md"
  - "[ ] Adicionar @imports dos três arquivos rules/ na seção Squads ativos do CLAUDE.md"
  - "[ ] Atualizar .kairos-core/core-config.yaml"
  - "[ ] Auto-executar *new-story com type: instance ao final do scaffolding"
---

# *new-squad — Criação de Squad

Um squad é um grupo de agentes especializados que colaboram para um fluxo de trabalho específico do usuário/equipe.
Esta task elicita tudo o que é necessário para scaffoldar uma estrutura completa e útil — não stubs genéricos.

---

## Pré-passo — Detectar candidatos em epic de planejamento (opcional)

Se o usuário mantém um epic listando squads candidatos (ex: "Novos Escopos"), ler esse epic e apresentar os candidatos antes de elicitar do zero.

Se não houver epic de candidatos: pular este passo e ir direto para a elicitação completa.

Se não houver candidatos (ou o nome já foi passado como argumento) → prosseguir para elicitação.

---

## Entrada — Pergunta Inicial

Após o pré-passo, fazer uma única pergunta:

```
Descreva o que este squad vai fazer ou qual problema resolve.
Pode ser livre — o Kairos cuida do resto.
```

Com base na resposta, seguir para o modo adequado:

- **Modo Propósito**: o usuário descreveu o objetivo em linguagem natural com informação suficiente para derivar uma arquitetura razoável → ir para "Modo Propósito" abaixo
- **Modo Guiado**: o usuário respondeu com perguntas, disse que não sabe por onde começar, ou a descrição foi insuficiente para derivar arquitetura razoável → ir para "Modo Guiado" (Blocos 1–4 abaixo)

---

## Modo Propósito

Quando o usuário descreve o objetivo em linguagem livre:

1. **Derivar todos os campos dos Blocos 1–4** a partir da descrição:
   - Nome do squad (slug em kebab-case)
   - Contexto de negócio
   - Agentes: IDs, personas, papéis, comandos principais, se precisam de script de computação
   - Fonte de dados e outputs esperados por agente
   - Pipeline: ordem, execução parcial
   - Integração externa e frequência de uso

2. **Exibir proposta consolidada para confirmação** usando o formato da seção "Confirmação antes de criar" abaixo, com todos os campos preenchidos pelo @kairos.

3. **Aguardar resposta do usuário:**
   - `s` → criar com a arquitetura proposta
   - Ajuste pontual (ex: "mudar nome do agente para X") → aplicar o ajuste e criar
   - "me faça as perguntas" ou pedido de reelicitação campo a campo → ativar Modo Guiado (Blocos 1–4 abaixo)

---

## Modo Guiado — Elicitação Sequencial

Ativado quando o usuário pede ajuda para estruturar, responde com perguntas à pergunta inicial, ou a descrição livre não é suficiente para derivar uma arquitetura razoável. As perguntas são um fallback, não o caminho principal.

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

**Pergunta 2.3 — Tem scripts de computação?**
```
Algum agente precisa de computação pura (sem AI) — processamento de dados,
cálculos, transformações — que deveria virar um script em src/agents/?

Liste quais agentes terão script e uma frase do que o script faz.
(Pressione Enter sem texto se todos usam Claude diretamente)
```

---

### Bloco 3 — Dados

**Pergunta 3.1 — Fonte de dados**
```
De onde vêm os dados que este squad processa?
  1. Webhook externo (ex: n8n, Make, Zapier) — informar URL e plataforma
  2. API externa direta — informar endpoint e autenticação
  3. Arquivo local (CSV, JSON) — informar path e formato
  4. Input manual do usuário (sem fonte automatizada)
  5. Misto — descrever
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
Este squad depende de algum sistema externo de automação ou integração?
(ex: n8n, Make, Zapier, scripts próprios, API de terceiro)

Se sim: descreva o papel desse sistema — o que ele faz que o Kairos não faz.
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
    Script de computação: {sim/não}
  ...

Pipeline: {agente1} → {agente2} → {agente3}
Execução parcial: {sim/não}

Fonte de dados: {fonte}
Integração externa: {sim/não — sistema e papel}
Frequência: {frequência}

Arquivos a criar:
  squads/{squad_name}/squad.yaml
  squads/{squad_name}/README.md
  squads/{squad_name}/agents/{id}.yaml  (× N — definição canônica)
  .claude/commands/kairos/agents/{id}.md  (× N — persona gerada do YAML)
  squads/{squad_name}/tasks/{task}.md  (× N — stubs)
  squads/{squad_name}/workflows/full-pipeline.md
  squads/{squad_name}/rules/memory-imports.md
  squads/{squad_name}/rules/agent-authority.md
  squads/{squad_name}/rules/{squad_name}-lifecycle.md
  .kairos-core/agents/{id}/MEMORY.md  (× N)
  CLAUDE.md — seção "Squads ativos" com @imports dos três arquivos acima

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
    # Padrão canônico — ver .kairos-core/rules/output-naming.md
    # Cada path deve seguir: data/outputs/{squad}/{tipo}/{agent}_{filename}-{INSTANCE}-YYYY-MM-DD.{ext}
    {lista de paths com formato}
  handoffs: .kairos-core/runtime/handoffs/

dependencies:
  # adapte para sua stack
  # node: [tsx, "@anthropic-ai/sdk", dotenv]
  # python: [requests, anthropic]
  squads: []
  external:
    {lista de integrações externas — ex: "n8n webhook"}

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

### agents/{id}.yaml (definição canônica — fonte de verdade)

Para cada agente, criar `squads/{squad_name}/agents/{id}.yaml` com o schema rico:

```yaml
id: {id}
name: "{Nome da Persona}"
title: "{Título do Papel}"
icon: "{emoji relevante ao papel}"
squad: "{squad_name}"
whenToUse: "{quando usar este agente em uma frase}"

persona_profile:
  archetype: "{Arquétipo — ex: Observadora, Classificador, Escritora}"
  communication:
    tone: "{tom, estilo, orientação}"
    emoji_frequency: "{baixa|baixíssima|média}"
    vocabulary:
      - {termo1}
      - {termo2}
      - {termo3}
    greeting_levels:
      minimal: "{icon} {id} pronto"
      named: "{icon} {Nome} ({Título curto}) pronto. {Frase curta}."
      archetypal: "{icon} {Nome}, {Papel Arquetípico}. {Frase arquetípica}."
    signature_closing: "— {Nome}, {frase de assinatura} {icon}"

persona:
  role: "{Papel Completo do Agente}"
  style: "{estilo de comunicação}"
  identity: "{identidade — quem é este agente e para quem trabalha}"
  focus: "{foco de execução}"

core_principles:
  - "{princípio crítico 1}"
  - "{princípio 2}"
  - "{princípio 3}"

commands:
  - name: help
    visibility: [full, quick, key]
    description: "Mostrar todos os comandos disponíveis"
  - name: "{cmd-principal}"
    visibility: [full, quick, key]
    description: "{descrição do comando principal}"
  - name: guide
    visibility: [full]
    description: "Mostrar guia completo de uso deste agente"
  - name: exit
    visibility: [full, quick, key]
    description: "Sair do modo {id}"

outputs:
  # Padrão canônico — ver .kairos-core/rules/output-naming.md
  # {INSTANCE} resolvido em runtime a partir de KAIROS_INSTANCE_NAME (fallback: "default")
  - "data/outputs/{squad_name}/{tipo}/{id}_{filename}-{INSTANCE}-YYYY-MM-DD.{ext}"

handoff_from: "{agente-anterior-id}"  # null se primeiro no pipeline
handoff_to: "{próximo-agente-id}"     # null se último no pipeline
```

---

### Gerar personas em .claude/commands/kairos/agents/

Após criar todos os `.yaml`, gerar a persona `.claude/commands/kairos/agents/{id}.md` para cada agente usando o template abaixo. Substituir todos os `{campos}` com os valores do `.yaml` correspondente.

**Template de persona (Markdown embutido):**

Antes de gerar o template, calcular o SHA256 do arquivo `squads/{squad}/agents/{id}.yaml`:
```bash
sha256sum squads/{squad}/agents/{id}.yaml | cut -d' ' -f1
```
Usar o resultado como `{sha256}` no marcador abaixo.

```markdown
<!-- kairos-generated-from: squads/{squad}/agents/{id}.yaml sha:{sha256} -->
# {id}

ACTIVATION-NOTICE: Este arquivo contém sua definição completa de operação. NÃO carregue arquivos externos — toda a configuração está no bloco YAML abaixo.

CRÍTICO: Leia o BLOCO YAML completo que segue para entender seus parâmetros de operação. Siga as activation-instructions exatamente para entrar neste modo e permaneça nele até receber *exit.

## COMPLETE AGENT DEFINITION FOLLOWS — NO EXTERNAL FILES NEEDED

```yaml
IDE-FILE-RESOLUTION:
  - APENAS PARA USO POSTERIOR — NÃO na ativação
  - Tasks mapeiam para .kairos-core/tasks/{name}
  - Carregue arquivos de tasks SOMENTE quando o usuário executar um comando

REQUEST-RESOLUTION: Mapeie pedidos do usuário para comandos com flexibilidade. Peça clarificação só se não houver match razoável.

activation-instructions:
  - STEP 1: Leia ESTE ARQUIVO COMPLETO
  - STEP 2: Adote a persona definida nas seções 'agent' e 'persona' abaixo
  - STEP 3: |
      Exiba o greeting usando contexto nativo (zero execução de comandos):
      1. Mostre: "{icon} {persona_profile.communication.greeting_levels.archetypal}" + badge de permissão do modo atual ([⚠️ Ask], [🟢 Auto], [🔍 Explore])
      2. Mostre: "**Papel:** {persona.role}"
      3. Mostre: "**Status dos Dados:**" como narrativa baseada no gitStatus do system prompt
      4. Mostre: "**Comandos Disponíveis:**" — liste apenas comandos com 'key' em visibility
      5. Mostre: "Digite *guide para instruções completas."
      5.5. Verifique .kairos-core/runtime/handoffs/ pelo handoff não consumido mais recente (YAML com consumed != true).
           Se encontrado: leia from_agent e last_command e exiba: "💡 **Sugerido:** *{next_command}"
           Se não encontrado: ignore silenciosamente.
           Após exibir o greeting, marque o handoff como consumed: true.
      6. Mostre: "{persona_profile.communication.signature_closing}"
  - STEP 4: Exiba o greeting montado no STEP 3
  - STEP 5: HALT e aguarde input do usuário
  - FIQUE NO PERSONAGEM!

agent:
  name: {name}
  id: {id}
  title: {title}
  icon: {icon}
  whenToUse: "{whenToUse}"

persona_profile:
  archetype: {archetype}
  communication:
    tone: {tone}
    emoji_frequency: {emoji_frequency}
    vocabulary: {vocabulary — lista YAML}
    greeting_levels:
      minimal: "{greeting_levels.minimal}"
      named: "{greeting_levels.named}"
      archetypal: "{greeting_levels.archetypal}"
    signature_closing: "{signature_closing}"

persona:
  role: {role}
  style: {style}
  identity: {identity}
  focus: {focus}

core_principles: {core_principles — lista YAML}

commands: {commands — lista YAML completa}
```

---

## Comandos Rápidos

{lista dos comandos com visibility: key, formato: `*{name}` — {description}}

---

## Guia (*guide)

### Quando usar @{id}

{whenToUse expandido — 2-3 frases sobre casos de uso típicos}

### Saída gerada

{outputs — um item por linha, formato: `{path}` — {descrição do arquivo}}

<!-- kairos-custom-start -->
<!-- Adicione customizações específicas de instância aqui — preservadas em regenerações -->
<!-- kairos-custom-end -->

---

*Kairos Agent — {id} ({name})*
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
<!-- Padrões vistos em 3+ execuções — candidatos para .kairos-core/rules/ -->

## Archived
<!-- Padrões obsoletos — manter para histórico -->
```

---

### rules/memory-imports.md

```markdown
# Agent Memory Imports

Cada agente Kairos tem um MEMORY.md com padrões persistentes aprendidos entre sessões.
Estes são os locais canônicos — os agentes devem ler sua memória na ativação.

@import .kairos-core/agents/{id1}/MEMORY.md
{@import .kairos-core/agents/{id2}/MEMORY.md — uma linha por agente}
```

---

### rules/agent-authority.md (stub)

```markdown
# {squad_name} — Matriz de Autoridade

Matriz de autoridade dos agentes do squad {squad_name}. Autoridade do @kairos e regras universais vivem em `.kairos-core/rules/agent-authority.md`.

---

## @{id1} ({Nome1}) — {Papel}

| Operação | Autoridade |
|----------|-----------|
| {operação exclusiva — preencher na story de implementação} | EXCLUSIVA |
| {operação bloqueada — preencher na story de implementação} | BLOQUEADA |

---

{repetir bloco por agente}

---

## Operações Universalmente Proibidas no Squad

- {preencher na story de implementação}

---

## Escalação Específica do Squad

| Situação | Ação |
|----------|------|
| Fonte de dados externa indisponível | HALT — informar usuário |
| {condição específica — preencher na story de implementação} | HALT |
```

---

### rules/{squad_name}-lifecycle.md (stub)

```markdown
# {Squad NomeHumanReadable} Lifecycle — Fluxo do Pipeline

## Fluxo Principal

```
{agente1} *{cmd1}
        ↓
{agente2} *{cmd2}
        ↓
{agente3} *{cmd3}
```

## Fases e Responsáveis

| Fase | Agente | Comando | Output |
|------|--------|---------|--------|
{linha por agente — preencher na story de implementação}

## Handoff Chain

{lista de handoffs: agente-a → agente-b — preencher na story de implementação}

## Execução Parcial

{preencher na story de implementação}

## Frequência Recomendada

{preencher na story de implementação}
```

---

## Atualizar CLAUDE.md — seção "Squads ativos"

Após criar os arquivos em `rules/`:

1. Verificar se a seção `## Squads ativos` existe no CLAUDE.md.
   - Se **não existir**: adicionar ao final do arquivo com a estrutura abaixo.
   - Se **existir**: ir para o passo 2.

2. Para cada arquivo criado em `rules/`, adicionar uma linha `@squads/{squad_name}/rules/{arquivo}.md` sob a seção "Squads ativos".
   - Verificar duplicatas: não adicionar se a linha já existir.
   - Não modificar nenhum bloco `KAIROS-MANAGED` nem outras seções user-owned.

Formato quando a seção não existe (adicionar ao final do arquivo):

```markdown
## Squads ativos

Esta seção é user-owned. Cada squad importa suas rules específicas aqui.

@squads/{squad_name}/rules/{squad_name}-lifecycle.md
@squads/{squad_name}/rules/memory-imports.md
@squads/{squad_name}/rules/agent-authority.md
```

Se a seção já existir, inserir apenas as três linhas de `@squads/` (sem o cabeçalho nem a descrição), verificando duplicatas.

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
  ✅ agents/ ({N} agentes — .yaml)
  ✅ .claude/commands/kairos/agents/ ({N} personas geradas)
  ✅ tasks/ ({N} stubs)
  ✅ workflows/full-pipeline.md
  ✅ rules/memory-imports.md
  ✅ rules/agent-authority.md (stub)
  ✅ rules/{squad_name}-lifecycle.md (stub)
  ✅ .kairos-core/agents/{id}/MEMORY.md  (× N)
  ✅ core-config.yaml atualizado
  ✅ CLAUDE.md atualizado (seção Squads ativos — 3 @imports adicionados)
  ✅ Epic {N} atualizado

Criando story de implementação para o squad {squad_name}…
```

Em seguida, **auto-executar `*new-story`** sem perguntar ao usuário (a story é parte obrigatória do scaffolding):

- `type`: `instance` (fixo — nunca kairos-core para squads de usuário)
- `epic`: selecionar o epic existente que mais se encaixa (ler `docs/epics/` e escolher o que tiver maior afinidade temática com o squad); se nenhum bater ou não existir nenhum, criar um novo epic antes com `*new-epic`
- `title`: `"Implementar squad {squad_name}"` (pré-preenchido)
- ACs pré-preenchidos derivados do elicitado:
  1. Tasks em `squads/{squad_name}/tasks/` implementadas com conteúdo real (não stubs)
  2. Scripts `src/agents/{id}.{ext}` por agente com script de computação (apenas se elicitado na pergunta 2.3)
  3. Comportamentos específicos de domínio adicionados às personas em `.claude/commands/kairos/agents/{id}.md` (ex: task-sections, core_principles refinados, campos de integração)
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
