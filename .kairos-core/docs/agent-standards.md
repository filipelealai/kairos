---
kairos-owned: true
kairos-version: 5.0.0
---

# Padrões de Agentes — Kairos

> Referência obrigatória para qualquer novo agente criado no Kairos.
> Carregado via `core-config.yaml` (campo `devLoadAlwaysFiles`) em toda sessão.

---

## Anatomia de um Agente

Todo agente Kairos é composto por três artefatos:

| Artefato | Local | Propósito |
|----------|-------|-----------|
| Persona completa | `.claude/commands/kairos/agents/{id}.md` | Ativação com `@nome` — Markdown com YAML interno |
| Definição no squad | `squads/{squad}/agents/{id}.md` | Referência leve dentro do contexto do squad |
| Memória | `.kairos-core/agents/{id}/MEMORY.md` | Padrões aprendidos entre sessões |

---

## Estrutura do Arquivo de Persona

O arquivo `.claude/commands/kairos/agents/{id}.md` tem **dois níveis obrigatórios**: o wrapper Markdown externo e o bloco YAML interno.

### Wrapper Markdown (estrutura externa)

O arquivo deve seguir exatamente este wrapper:

```markdown
---
kairos-owned: true
kairos-version: 3.10.0
---

# {id}

ACTIVATION-NOTICE: Este arquivo contém sua definição completa de operação. NÃO carregue arquivos externos — toda a configuração está no bloco YAML abaixo.

CRÍTICO: Leia o BLOCO YAML completo que segue para entender seus parâmetros de operação. Siga as activation-instructions exatamente para entrar neste modo e permaneça nele até receber *exit.

## COMPLETE AGENT DEFINITION FOLLOWS — NO EXTERNAL FILES NEEDED

```yaml
{bloco YAML interno — ver seção abaixo}
```

---

## Comandos Rápidos

- `*{comando-principal}` — {descrição}
- `*help` — Listar todos os comandos
- `*exit` — Sair

---

## Guia (*guide)

{Conteúdo do guia completo — explica o propósito do agente, quando usar, fluxos típicos.}

---

*{Nome} Agent — @{id} (squad {squad})*
```

**Componentes obrigatórios do wrapper:**

| Componente | Obrigatório | Propósito |
|------------|-------------|-----------|
| Frontmatter `kairos-owned` + `kairos-version` | Sim | Marker de ownership e rastreamento de versão |
| `ACTIVATION-NOTICE` | Sim | Instrui o modelo a não carregar arquivos externos |
| `CRÍTICO` | Sim | Força leitura completa do YAML antes de agir |
| `## COMPLETE AGENT DEFINITION FOLLOWS` | Sim | Delimitador visual obrigatório antes do bloco YAML |
| Bloco YAML (code fence ` ```yaml `) | Sim | Definição completa da persona |
| `## Comandos Rápidos` | Sim | Referência rápida para o usuário |
| `## Guia (*guide)` | Sim | Conteúdo expandido exibido ao executar `*guide` |
| Footer `*{Nome} Agent — @{id} (squad {squad})*` | Sim | Identificação visual do agente |

---

### Bloco YAML Interno (estrutura obrigatória)

```yaml
IDE-FILE-RESOLUTION:
  - APENAS PARA USO POSTERIOR — NÃO na ativação
  - Tasks mapeiam para .kairos-core/tasks/{name}
  - Carregue arquivos de tasks SOMENTE quando o usuário executar um comando

activation-instructions:
  - STEP 1: Leia ESTE ARQUIVO COMPLETO — contém sua definição completa de persona
  - STEP 2: Adote a persona definida nas seções 'agent' e 'persona' abaixo
  - STEP 3: |
      Exiba o greeting usando contexto nativo (zero execução de comandos):
      1. Mostre: "{icon} {persona_profile.communication.greeting_levels.archetypal}" + badge de permissão
      2. Mostre: "**Papel:** {persona.role}"
         Mencione o squad ao qual pertence
      3. Mostre: "**Status dos dados:**" — inferido do gitStatus (último output gerado)
      4. Mostre: "**Comandos Disponíveis:**" — apenas visibility: key
      5. Mostre: "Digite *guide para instruções completas."
      5.5. Verificar .kairos-core/runtime/handoffs/ pelo handoff não consumido mais recente:
           - Se from_agent + last_command tem match em squads/{squad}/data/workflow-chains.yaml:
             exibir "💡 Sugerido: *{next_command}"
           - Marcar handoff como consumed: true
      6. Mostre: "{persona_profile.communication.signature_closing}"
  - STEP 4: Exiba o greeting
  - STEP 5: HALT e aguarde input
  - IMPORTANTE: Não improvise além do greeting especificado
  - NÃO carregue outros arquivos de agente durante a ativação
  - FIQUE NO PERSONAGEM!

agent:
  name: {NomeDaPersona}
  id: {id-kebab-case}
  title: {Título Human-Readable}
  icon: {emoji}
  whenToUse: "Uma frase descrevendo quando usar este agente"

persona_profile:
  archetype: {Arquétipo}
  communication:
    tone: {adjetivos}
    emoji_frequency: baixa | baixíssima | média
    vocabulary: [lista de verbos/substantivos característicos]
    greeting_levels:
      minimal: "{icon} {id} pronto"
      named: "{icon} {Nome} ({Arquétipo}) pronto. {Frase curta.}"
      archetypal: "{icon} {Nome}, {artigo} {Arquétipo}. {Frase de identidade.}"
    signature_closing: "— {Nome}, {frase de assinatura} {icon}"

persona:
  role: {Papel completo}
  style: {3-5 adjetivos}
  identity: {Uma frase de identidade}
  focus: {O que concretamente faz}

core_principles:
  - CRÍTICO: {princípio mais importante}
  - {outros princípios}

commands:
  - name: help
    visibility: [full, quick, key]
    description: "Mostrar todos os comandos disponíveis"
  - name: {comando}
    visibility: [full, quick, key]  # key = aparece no greeting
    description: "{descrição}"
  - name: exit
    visibility: [full, quick, key]
    description: "Sair do modo {id}"

{id}-task:
  order-of-execution: "{sequência de passos}"
  blocking: "HALT se: {condições de bloqueio}"
  ready: "{o que define pronto}"
  completion: "{o que define completo + handoff}"

dependencies:
  tasks:
    - {nome-da-task}.md
  scripts:
    - src/agents/{id}.{ext}  # extensão definida pela linguagem da instância
  data:
    - data/outputs/{squad}/{tipo}/

autoClaude:
  execution:
    canExecute: true
    canVerify: true
  recovery:
    maxAttempts: 2 | 3
    stuckDetection: true
  memory:
    canCaptureInsights: true
```

**Campos obrigatórios do YAML:**

| Campo | Obrigatório | Observação |
|-------|-------------|------------|
| `IDE-FILE-RESOLUTION` | Sim | Deve ser o **primeiro campo** do YAML — instrui o IDE/modelo sobre resolução de arquivos |
| `activation-instructions` | Sim | Define os 5 steps de ativação (incluindo 5.5 handoff check) |
| `agent` | Sim | Identidade: `name`, `id`, `title`, `icon`, `whenToUse` |
| `persona_profile` | Sim | Arquétipo, comunicação, greeting levels, signature |
| `persona` | Sim | `role`, `style`, `identity`, `focus` |
| `core_principles` | Sim | Primeiro item deve ser `CRÍTICO:` |
| `commands` | Sim | Incluir sempre `help` e `exit`; `visibility: key` apenas para o greeting |
| `{id}-task` | Sim | `blocking` e `completion` explícitos |
| `dependencies` | Sim | Scripts, tasks e dados de que o agente depende |
| `autoClaude` | Sim | Controle de execução autônoma |

---

## Formato da Definição no Squad

Arquivo leve em `squads/{squad}/agents/{id}.md`:

```yaml
---
agent:
  id: {id}
  name: {Nome}
  icon: {emoji}
  persona_file: .claude/commands/kairos/agents/{id}.md
  whenToUse: "{quando usar}"

commands_key:
  - "*{cmd1}" — {descrição}
  - "*{cmd2}" — {descrição}

outputs:
  - "{arquivo ou dado gerado}"

handoff_to: "{próximo agente no pipeline}"
---
```

---

## Formato da Memória (MEMORY.md)

```markdown
# {Nome} Memory ({NomeDaPersona})

## Active Patterns
### Dados e Saída
- {padrões verificados e em uso}

### Gotchas Técnicos
- {armadilhas conhecidas — inclua causa, sintoma e solução}

## Promotion Candidates
<!-- Padrões vistos em 3+ execuções — candidatos para .kairos-core/rules/ -->

## Archived
<!-- Padrões obsoletos — manter para histórico -->
```

**Regras para Gotchas Técnicos:**
- Cada gotcha deve ter contexto suficiente para ser acionável sem a conversa original
- Preferir "Campo X pode ser null — usar `String(x || '')`" a "Campo X pode ser null"
- Gotchas que afetam múltiplos agentes → promover para `.kairos-core/data/kairos-kb.md` via `@kairos *kb add`

**Promoção de Decisões ao KB:**
- Se um padrão descoberto durante execução for uma **decisão arquitetural** ou **gotcha sistêmico** (não específico a um agente):
  → Promover para `kairos-kb.md` em vez de apenas manter no MEMORY.md do agente
  → Usar `@kairos *kb add` para adicionar com contexto completo

---

## Regras de Escrita

### Obrigatório

- Wrapper Markdown completo (ACTIVATION-NOTICE, CRÍTICO, COMPLETE AGENT DEFINITION FOLLOWS, Comandos Rápidos, Guia, footer)
- `IDE-FILE-RESOLUTION` como primeiro campo do YAML interno
- Greeting sempre em 6 steps (incluindo 5.5 handoff check com `workflow-chains.yaml`)
- `blocking:` explícito — quando o agente deve HALT e por quê
- `completion:` explícito — incluindo geração de handoff
- Visibility `key` apenas para comandos que devem aparecer no greeting
- Memória como seção viva — atualizar após aprender padrões novos

### Proibido

- Omitir qualquer componente do wrapper Markdown
- Improvisar além do greeting especificado
- Carregar arquivos de task na ativação (apenas quando o usuário executar um comando)
- Gerar dados que não existem (nunca inventar métricas, scores ou leads)
- Agente executar responsabilidade de outro agente (ver `agent-authority.md`)
- Referenciar squads ou integrações específicas de instância como convenção do framework (constituição VI.21)

---

## Convenções de Nomenclatura

| Item | Convenção | Exemplo |
|------|-----------|---------|
| ID do agente | kebab-case | `email-writer` |
| Nome da persona | PascalCase | `Eva` |
| Arquivo de task | kebab-case | `write-emails.md` |
| Arquivo de squad | kebab-case | `cold-prospecting` |
| Handoff file | `handoff-{from}-to-{to}-{ts}.yaml` | `handoff-email-writer-to-campaign-analyst-20260406.yaml` |
