# Stories — Desenvolvimento do Kairos

## O que são as stories aqui

Stories neste diretório rastreiam o **desenvolvimento do próprio Kairos** — mudanças no framework, novos agentes, novos squads, integrações, refatorações estruturais.

**NÃO são stories os outputs operacionais dos squads:**
- ✗ "Gerei 20 e-mails hoje" → vai para `data/emails/`
- ✗ "Analisei campanha de abril" → vai para `data/reports/`
- ✗ "Classifiquei 142 atividades" → vai para `data/reports/`
- ✓ "Criar workflow n8n de disparo" → story `2.1.story.md`
- ✓ "Adicionar agente de agendamento" → story em epic 4

## Quem cria stories

`@kairos *new-story "título"` — o único agente com autoridade para criar stories de desenvolvimento do Kairos.

Claude Code na conversa principal executa o que a story descreve.

## Estrutura de Epics

Cada epic tem arquivo dedicado em `docs/epics/`:

| Epic | Tema | Status |
|------|------|--------|
| [1](../epics/epic-1-infraestrutura-de-dados.md) | Infraestrutura de Dados | Done |
| [2](../epics/epic-2-automacao-de-disparo.md) | Automação de Disparo | In Progress |
| [3](../epics/epic-3-governanca-e-versionamento.md) | Governança e Versionamento | Done |
| [4](../epics/epic-4-novos-escopos.md) | Novos Escopos | Backlog |

## Nomenclatura

`{epic}.{número}.story.md` — ex: `2.1.story.md`

## Stories Ativas

| Story | Título | Status |
|-------|--------|--------|
| [1.1](1.1.story.md) | Webhook de Leads | Done |
| [1.2](1.2.story.md) | Pipeline de Agentes | Done |
| [2.1](2.1.story.md) | Loop de Disparo — n8n Lê JSON e Dispara E-mails | Draft |
| [3.1](3.1.story.md) | Tasks de Governança do @kairos | Done |
