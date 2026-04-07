# Kairos — Agente Pessoal

Kairos é o agente pessoal de Filipe Leal. O nome vem do grego καιρός — o tempo certo, o momento oportuno, em contraste com χρόνος (chronos), o tempo cronológico. Em Kairos, cada ação acontece no momento certo.

## Contexto

Este repo contém:
- **Agentes TypeScript** que usam a Claude API para automações, análises e gestão de tarefas
- **Configuração do Claude Code** com comandos e hooks customizados

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

<!-- KAIROS-MANAGED-START: agent-system -->
## Sistema de Agentes Kairos

### Dois Tipos de Agentes

**Governança (framework):**
- `@kairos` — orquestrador e governador do Kairos. Versiona, cria squads, gerencia stories, tem autoridade sobre tudo.

**Operacional (squads — fazem o trabalho de negócio de Filipe):**

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
| Gerar e-mails, analisar campanha, pontuar leads | Agente do squad correspondente |
| Evoluir o Kairos, versionar, criar novo squad | `@kairos` |
| Construir/modificar o Kairos (código, arquivos) | Claude Code na conversa principal |

### Pipeline Operacional (squad cold-prospecting)

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
squads/cold-prospecting/ (trabalho operacional)
      ↓ executado por
Claude Code na conversa principal (constrói e mantém o Kairos)
```

Stories em `docs/stories/` = desenvolvimento do Kairos. Outputs operacionais = `data/`.
<!-- KAIROS-MANAGED-END: agent-system -->

<!-- KAIROS-MANAGED-START: kairos-core -->
## Estrutura Kairos Core

```
.kairos-core/
  agents/     # Memória persistente por agente (MEMORY.md)
  tasks/      # Definições de tasks executáveis (referenciadas pelos agentes)
  data/       # workflow-chains.yaml, dados de configuração

.claude/
  commands/kairos/agents/  # Personas completas dos agentes (YAML-in-Markdown)
  rules/                   # Regras cross-cutting (lifecycle, handoff, authority)

src/agents/  # Scripts TypeScript de computação pura (sem AI)
data/        # Outputs dos agentes (reports, emails)
.kairos/     # Runtime: handoffs/, logs/ (conteúdo gitignored)
```

## Regras Cross-Cutting

| Rule | Descrição |
|------|-----------|
| `campaign-lifecycle.md` | Pipeline completo e gates de qualidade |
| `agent-handoff.md` | Protocolo de handoff compacto entre agentes |
| `agent-authority.md` | Matriz de autoridade — o que cada agente pode e não pode fazer |
| `agent-memory-imports.md` | Imports de MEMORY.md por agente |
| `story-lifecycle.md` | Protocolo do executor: transições de status e Execution Log obrigatório |

## Versionamento

Versão atual: ver `.kairos-core/core-config.yaml`
Histórico: `CHANGELOG.md`

Regras:
- **PATCH** — correção, ajuste de instrução, atualização de memória
- **MINOR** — novo agente, nova task, nova rule, nova capacidade
- **MAJOR** — novo squad/escopo, breaking change

Autoridade para versionar: `@kairos *version`
<!-- KAIROS-MANAGED-END: kairos-core -->
