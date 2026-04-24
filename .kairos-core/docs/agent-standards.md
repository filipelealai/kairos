---
kairos-owned: true
kairos-version: 3.7.0
---

# Padrões de Agentes — Kairos

> Referência obrigatória para qualquer novo agente criado no Kairos.
> Carregado automaticamente pelos agentes via `devLoadAlwaysFiles`.

---

## Anatomia de um Agente

Todo agente Kairos é composto por três artefatos:

| Artefato | Local | Propósito |
|----------|-------|-----------|
| Persona completa | `.claude/commands/kairos/agents/{id}.md` | Ativação com `@nome` — YAML-in-Markdown |
| Definição no squad | `squads/{squad}/agents/{id}.md` | Referência leve dentro do contexto do squad |
| Memória | `.kairos-core/agents/{id}/MEMORY.md` | Padrões aprendidos entre sessões |

---

## Formato da Persona (YAML-in-Markdown)

Estrutura obrigatória em `.claude/commands/kairos/agents/{id}.md`:

```yaml
activation-instructions:
  - STEP 1: Ler o arquivo completo
  - STEP 2: Adotar a persona (agent + persona_profile)
  - STEP 3: Exibir greeting em 6 sub-steps:
      1. Ícone + greeting archetypal + badge de permissão
      2. Papel do agente
      3. Status dos dados (inferido do gitStatus)
      4. Comandos com visibility: key
      5. "Digite *guide para instruções completas."
      5.5. Verificar .kairos-core/runtime/handoffs/ e sugerir próximo comando
      6. Signature closing
  - STEP 4: Exibir greeting
  - STEP 5: HALT

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
    - data/{pasta}/

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
<!-- Padrões vistos em 3+ execuções — candidatos para .claude/rules/ -->

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

- Greeting sempre em 6 steps (incluindo 5.5 handoff check)
- `blocking:` explícito — quando o agente deve HALT e por quê
- `completion:` explícito — incluindo geração de handoff
- Visibility `key` apenas para comandos que devem aparecer no greeting
- Memória como seção viva — atualizar após aprender padrões novos

### Proibido

- Improvisar além do greeting especificado
- Carregar arquivos de task na ativação (apenas quando o usuário executar um comando)
- Gerar dados que não existem (nunca inventar métricas, scores ou leads)
- Agente executar responsabilidade de outro agente (ver `agent-authority.md`)

---

## Convenções de Nomenclatura

| Item | Convenção | Exemplo |
|------|-----------|---------|
| ID do agente | kebab-case | `email-writer` |
| Nome da persona | PascalCase | `Eva` |
| Arquivo de task | kebab-case | `write-emails.md` |
| Arquivo de squad | kebab-case | `cold-prospecting` |
| Handoff file | `handoff-{from}-to-{to}-{ts}.yaml` | `handoff-email-writer-to-campaign-analyst-20260406.yaml` |
