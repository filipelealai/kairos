# Stories — Desenvolvimento do Kairos

## O que são as stories aqui

Stories neste diretório rastreiam o **desenvolvimento do próprio Kairos** — mudanças no framework, novos agentes, novos squads, integrações, refatorações estruturais.

**NÃO são stories os outputs operacionais dos squads:**
- ✗ "Gerei 20 e-mails hoje" → vai para `data/outputs/cold-prospecting/emails/`
- ✗ "Analisei campanha de abril" → vai para `data/outputs/cold-prospecting/reports/`
- ✗ "Classifiquei 142 atividades" → vai para `data/outputs/cold-prospecting/reports/`
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
| [3](../epics/epic-3-governanca-e-versionamento.md) | Governança e Versionamento | In Progress |
| [4](../epics/epic-4-novos-escopos.md) | Novos Escopos | Backlog |
| [5](../epics/epic-5-arquitetura-do-framework.md) | Arquitetura do Framework | In Progress |

## Nomenclatura

`{epic}.{número}.story.md` — ex: `2.1.story.md`

## Stories Ativas

| Story | Título | Status |
|-------|--------|--------|
| [1.1](1.1.story.md) | Webhook de Leads | Done |
| [1.2](1.2.story.md) | Pipeline de Agentes | Done |
| [2.1](2.1.story.md) | Loop de Disparo — n8n Lê JSON e Dispara E-mails | Draft |
| [3.1](3.1.story.md) | Tasks de Governança do @kairos | Done |
| [3.2](3.2.story.md) | Commit Integrado ao Fluxo de Review e Pre-Push | Done |
| [3.3](3.3.story.md) | Refinamentos de UX: *new-story, *version no Pre-Push e *help | Done |
| [3.4](3.4.story.md) | *review-squad: Validação de Coerência de Squad | Done |
| [3.5](3.5.story.md) | Modelo de Stories para Instâncias: type, *update-squad, Framing e Avisos | Done |
| [3.6](3.6.story.md) | Executor @kairos para Instâncias: *implement, src/ e Modelo de Autoridade | In Review |
| [3.7](3.7.story.md) | scope.md do Framework em .kairos-core/docs/ e *architecture {squad} | Draft |
| [3.8](3.8.story.md) | Workers: Listagem Dinâmica de Agentes na Elicitação | Draft |
| [3.9](3.9.story.md) | Pre-Push: Prompt Opcional de Bump para Stories PATCH | Draft |
| [3.10](3.10.story.md) | Pre-Push: Atualizar `kairos-version` nos Arquivos Modificados | Draft |
| [3.11](3.11.story.md) | Renomear `*review-squad` → `*validate-squad` | Draft |
| [3.12](3.12.story.md) | self_reviewed Automático em *review para Stories Implementadas via *implement | Draft |
| [3.13](3.13.story.md) | *prd: Elicitação Conversacional para o Escopo da Instância | Draft |
| [3.16](3.16.story.md) | *validate-story: Verificar Ordem do Cabeçalho e Estrutura dos ACs | Draft |
| [3.17](3.17.story.md) | Pre-Push Step 4: Corrigir Fallback de Epoch para Gate Não Commitado | Draft |
| [5.1](5.1.story.md) | Segregação Framework × Usuário via Manifesto de Ownership | Done |
| [5.8](5.8.story.md) | SHA Auto-referencial do manifest.yaml: usar sentinel em vez de hash real | Draft |
| [5.9](5.9.story.md) | push-dual Passo 2b: skip real por conteúdo managed, não por commits | Draft |
