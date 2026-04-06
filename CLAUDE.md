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
