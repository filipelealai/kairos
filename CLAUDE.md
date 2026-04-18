<!-- KAIROS-MANAGED-START: framework-conventions -->
# Kairos — Orquestrador de Agentes

Kairos é um framework de orquestração de agentes de IA construído sobre o Claude Code. O nome vem do grego καιρός — o tempo certo, o momento oportuno. Cada agente age quando faz sentido, não em qualquer momento.

## Contexto

Kairos organiza trabalho em **squads**: grupos de agentes especializados que operam um domínio. O framework fornece governança, memória persistente, handoffs, workers agendados e ferramentas para criar e evoluir squads ao longo do tempo.

**Arquitetura:** múltiplos squads, múltiplas integrações, uso individual ou em equipe.

Este repo contém:
- **Agentes TypeScript** — computação pura para tarefas específicas de cada squad
- **Personas de agentes** — ativadas com `@nome` no Claude Code, cada uma especializada em um domínio
- **Infraestrutura de framework** — governança, memória, handoffs, workers, hooks

## Stack

- Runtime: Node.js (ESM)
- Linguagem: TypeScript
- AI: `@anthropic-ai/sdk` com modelo padrão `claude-sonnet-4-6`
- Runner: `tsx` (sem compilação — rodar direto com `npx tsx src/agents/nome.ts`)

## Estrutura

```
src/
  agents/     # Um arquivo por agente/caso de uso
  tools/      # Utilitários compartilhados (claude.ts, fs, etc.)
  types/      # Tipos TypeScript globais
data/         # Dados de entrada/saída dos agentes
.claude/
  commands/   # Slash commands customizados
```

## Convenções

- Cada agente em `src/agents/` é autossuficiente e pode ser rodado diretamente
- Usar `src/tools/claude.ts` como wrapper da Claude API — nunca instanciar Anthropic diretamente nos agentes
- Variáveis de ambiente em `.env` (nunca commitar — usar `.env.example` como template)
- Preferir ESM (`import`/`export`), sem CommonJS

## Como rodar um agente

```bash
npx tsx src/agents/nome-do-agente.ts
```

## Instruções para Claude Code

- Ao criar novos agentes, seguir o padrão de `src/tools/claude.ts` (funções `ask`, `chat`, `run`)
- Manter cada agente focado em uma responsabilidade
- Não criar abstrações desnecessárias — clareza é melhor que elegância prematura
- Responder em português (Brasil)
<!-- KAIROS-MANAGED-END: framework-conventions -->

<!-- KAIROS-MANAGED-START: agent-system -->
## Sistema de Agentes Kairos

### Dois Tipos de Agentes

**Governança (framework):**
- `@kairos` — orquestrador e governador do Kairos. Versiona, cria squads, gerencia stories, tem autoridade sobre tudo.

**Operacional (squads — definidos pelo usuário/equipe):**

Os agentes de squad são criados com `@kairos *new-squad` e variam por projeto.
Exemplo dos squads ativos neste projeto:

| Agente | Persona | Escopo |
|--------|---------|--------|
| `@campaign-analyst` | Clio | Métricas e análise da campanha |
| `@lead-scorer` | Lex | Pontuação e priorização de leads |
| `@niche-classifier` | Nix | Classificação de atividades por nicho |
| `@email-writer` | Eva | Geração de e-mails personalizados |

### Comandos de Agentes

Use prefixo `*` dentro de um agente ativo:
- `*help` — Mostrar comandos disponíveis
- `*guide` — Guia completo do agente
- `*exit` — Sair do modo agente

### Quando usar cada camada

| Situação | Use |
|----------|-----|
| Trabalho operacional de um squad | Agente do squad correspondente |
| Evoluir o Kairos, versionar, criar novo squad | `@kairos` |
| Construir/modificar o Kairos (código, arquivos) | Claude Code na conversa principal |

### Pipeline de Squad (exemplo)

Cada squad define seu pipeline. Exemplo com os squads ativos:

```
@campaign-analyst *analyze → @lead-scorer *score
→ @niche-classifier *classify → @email-writer *write 20
```

### Handoffs

Ao completar uma fase, cada agente gera um handoff em `.kairos-core/runtime/handoffs/`.
O próximo agente detecta e sugere o próximo comando automaticamente na ativação.

### Modelo de Governança

```
@kairos (governa o framework)
      ↓ autoridade sobre
squads/* (trabalho operacional — definido pelo usuário)
      ↓ implementado por
Claude Code na conversa principal (constrói e mantém o Kairos)
```

Stories em `docs/stories/` = desenvolvimento do Kairos. Outputs operacionais = `data/`.
<!-- KAIROS-MANAGED-END: agent-system -->

<!-- KAIROS-MANAGED-START: kairos-core -->
## Estrutura Kairos Core

```
.kairos-core/
  agents/       # Memória persistente por agente (MEMORY.md)
  tasks/        # Definições de tasks executáveis (referenciadas pelos agentes)
  data/         # kairos-kb.md, workflow-chains.yaml, dados de configuração
  templates/    # Templates para stories, agentes, squads
  constitution.md  # Princípios não-negociáveis do framework (L1)
  runtime/      # Handoffs e logs (conteúdo gitignored)

.claude/
  commands/kairos/agents/  # Personas completas dos agentes (YAML-in-Markdown)
  hooks/                   # PreCompact e PreToolUse hooks
  rules/                   # Regras cross-cutting (lifecycle, handoff, authority, IDS, layers)

src/agents/  # Scripts TypeScript de computação pura (sem AI)
data/        # Outputs dos agentes (reports, emails)
```

## Regras Cross-Cutting

| Rule | Descrição |
|------|-----------|
| `agent-handoff.md` | Protocolo de handoff compacto entre agentes |
| `agent-authority.md` | Matriz de autoridade — o que cada agente pode e não pode fazer |
| `story-lifecycle.md` | Protocolo do executor: transições de status e Execution Log obrigatório |
| `ids-principles.md` | REUTILIZAR > ADAPTAR > CRIAR — hierarquia de criação de artefatos |
| `framework-layers.md` | Camadas L1–L4 de imutabilidade do framework |
| `ownership.md` | Modelo de ownership framework/usuário e contrato de update |
| `external-integrations.md` | Skills → MCPs → scripts — hierarquia e diretrizes de integração com sistemas externos |

Rules específicas de squad vivem em `squads/{squad}/rules/` e são carregadas pelos imports abaixo (seção user-owned).

## Versionamento

Versão atual: ver `.kairos-core/core-config.yaml`
Histórico: `CHANGELOG.md`

Regras:
- **PATCH** — correção, ajuste de instrução, atualização de memória
- **MINOR** — novo agente, nova task, nova rule, nova capacidade
- **MAJOR** — novo squad/escopo, breaking change

Autoridade para versionar: `@kairos *version`
<!-- KAIROS-MANAGED-END: kairos-core -->
