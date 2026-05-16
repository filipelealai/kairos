# Kairos — Orquestrador de Agentes

Kairos é um framework de orquestração de agentes de IA. O nome vem do grego
καιρός — o tempo certo, o momento oportuno. Cada agente age quando faz sentido,
não em qualquer momento.

## Contexto

Kairos organiza trabalho em **squads**: grupos de agentes especializados que
operam um domínio. O framework fornece governança, memória persistente,
handoffs, workers agendados e ferramentas para criar e evoluir squads ao longo
do tempo.

**Arquitetura:** múltiplos squads, múltiplas integrações, uso individual ou em
equipe.

Este repo contém:
- **Scripts de agentes** — computação pura para tarefas específicas de cada
  squad (linguagem definida pela stack da instância)
- **Personas de agentes** — ativadas pelo runtime, cada uma especializada em um
  domínio
- **Infraestrutura de framework** — governança, memória, handoffs, workers,
  hooks e runtimes

## Stack

**Framework** — o que o Kairos é:
- Personas, documentação e memória: Markdown
- Configuração: YAML
- Runtime support: arquivos em `.kairos-core/runtimes/{runtime}/`

**Instância** — stack definida pelo usuário (scripts, integrações, ferramentas).

## Convenções

- Cada agente é autossuficiente e pode ser rodado diretamente
- Variáveis de ambiente em `.env` (nunca commitar — usar `.env.example` como
  template)
- Diretrizes de integrações vivem em `.kairos-core/rules/external-integrations.md`
- Targets de runtime (`.claude/**`, `AGENTS.md`, `.agents/**`, `.codex/**`) não
  são a fonte canônica do comportamento do Kairos

