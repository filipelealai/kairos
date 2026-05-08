<!-- KAIROS-MANAGED-START: framework-conventions -->
# Kairos — Orquestrador de Agentes

Kairos é um framework de orquestração de agentes de IA construído sobre o Claude Code. O nome vem do grego καιρός — o tempo certo, o momento oportuno. Cada agente age quando faz sentido, não em qualquer momento.

## Contexto

Kairos organiza trabalho em **squads**: grupos de agentes especializados que operam um domínio. O framework fornece governança, memória persistente, handoffs, workers agendados e ferramentas para criar e evoluir squads ao longo do tempo.

**Arquitetura:** múltiplos squads, múltiplas integrações, uso individual ou em equipe.

Este repo contém:
- **Scripts de agentes** — computação pura para tarefas específicas de cada squad (linguagem definida pela stack da instância)
- **Personas de agentes** — ativadas com `@nome` no Claude Code, cada uma especializada em um domínio
- **Infraestrutura de framework** — governança, memória, handoffs, workers, hooks

## Stack

**Framework** — o que o Kairos é:
- Personas, documentação e memória: Markdown
- Configuração: YAML
- Hooks: CJS (`.claude/hooks/`)

**Instância** — stack definida pelo usuário (scripts, integrações, ferramentas).

## Convenções

- Cada agente é autossuficiente e pode ser rodado diretamente
- Variáveis de ambiente em `.env` (nunca commitar — usar `.env.example` como template)

## Instruções para Claude Code

- Manter cada agente focado em uma responsabilidade
- Não criar abstrações desnecessárias — clareza é melhor que elegância prematura
- Responder em português (Brasil)
- As diretrizes de como usar skills, MCPs e APIs estão em `.claude/rules/external-integrations.md`.
<!-- KAIROS-MANAGED-END: framework-conventions -->

<!-- KAIROS-MANAGED-START: agent-system -->
## Sistema de Agentes Kairos

### Dois Tipos de Agentes

**Governança (framework):**
- `@kairos` — orquestrador e governador do Kairos. Versiona, cria squads, gerencia stories, tem autoridade sobre tudo.

**Operacional (squads — definidos pelo usuário/equipe):**

Os agentes de squad são criados com `@kairos *new-squad` e variam por instância.

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

Cada squad define seu pipeline. Exemplo ilustrativo:

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

NOTA: Kairos consegue se auto-aperfeiçoar com planejamento de arquitetura, PRD, stories, epics, revisões do que foi implementado, mas NÃO pode implementar/desenvolver modificações em si próprio (`**Tipo:** kairos-core` nas stories)

Stories em `docs/stories/` = log, histórico e desenvolvimento criados e gerenciados pelo Kairos. Outputs operacionais dos agentes = `data/`.
<!-- KAIROS-MANAGED-END: agent-system -->

<!-- KAIROS-MANAGED-START: kairos-core -->
## Estrutura Kairos Core

```
.github/                     # Templates de PR/Issue, CODEOWNERS e CI workflows

.claude/
  commands/kairos/agents/  # Personas completas dos agentes (YAML-in-Markdown)
  rules/                   # Regras cross-cutting (lifecycle, handoff, authority...)
  hooks/                   # Hooks do Claude Code que o Kairos usa (PreCompact, PreToolUse, SessionStart)

.kairos-core/
  constitution.md          # Princípios não-negociáveis do framework (L1)
  core-config.yaml         # Configuração central e versão semântica
  manifest.yaml            # Ownership: o que é framework vs. usuário
  agents/                  # MEMORY.md persistente por agente
  tasks/                   # Definições de tasks executáveis
  data/                    # KB, workers registry e dados de configuração
  docs/                    # Documentação de arquitetura e escopo do Kairos
    install.md             # Guia de instalação, cloud sync, troubleshooting
  runtime/                 # Handoffs e logs de execução (conteúdo gitignored)
  templates/               # Templates do Kairos para criação de agentes, squads, stories etc.

src/agents/    # Scripts e ferramentas (user-owned, linguagem definida pela instância)
data/outputs/  # Outputs dos agentes (pode ser symlink para nuvem via *configure-cloud)

install.sh   install.ps1     # Instaladores interativos (Linux/Mac/WSL e Windows)
uninstall.sh uninstall.ps1   # Desinstaladores (preservam conteúdo user-owned)
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
| `output-naming.md` | Padrão canônico de nomenclatura de outputs por instância (`KAIROS_INSTANCE_NAME`) |

Rules específicas de squad vivem em `squads/{squad}/rules/` e são carregadas pelos imports abaixo (seção user-owned).

## Versionamento

Versão atual: ver `.kairos-core/core-config.yaml`
Histórico: `CHANGELOG.md`

Regras:
- **PATCH** — correção, bug fixes, ajuste de instrução, documentação
- **MINOR** — novo agente, nova task, nova rule, nova capacidade
- **MAJOR** — novo escopo, breaking change, mudança de arquitetura, modificações em arquivos L1

Autoridade para versionar: `@kairos *version` e `@kairos *pre-push`
<!-- KAIROS-MANAGED-END: kairos-core -->
