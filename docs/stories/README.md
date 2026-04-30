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
| [4](../epics/epic-4-novos-escopos.md) | Novos Escopos | In Progress |
| [5](../epics/epic-5-arquitetura-do-framework.md) | Arquitetura do Framework | In Progress |
| [6](../epics/epic-6-kairos-como-servico.md) | Kairos como Serviço — Acesso Multi-usuário via MCP | In Progress |

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
| [5.8](5.8.story.md) | SHA Auto-referencial do manifest.yaml: usar sentinel em vez de hash real | Done |
| [5.9](5.9.story.md) | push-dual Passo 2b: skip real por conteúdo managed, não por commits | Done |
| [5.10](5.10.story.md) | Manifest owned_sections: SHA por bloco para suporte a updates | In Review |
| [5.11](5.11.story.md) | Manifest yaml_keys: campo sha_method como especificação canônica de serialização | Draft |
| [5.12](5.12.story.md) | Manifest sync_files: categoria para arquivos sincronizados sem ownership de update | Draft |
| [5.13](5.13.story.md) | ownership.md: documentar sync_files como terceira categoria do manifesto | Done |
| [5.14](5.14.story.md) | push-dual Passo 3: commit para main usa mensagem do commit em filipe-instance | Done |
| [5.15](5.15.story.md) | CONTRIBUTING.md (Governança de Contribuição ao Repo Público) | Done |
| [5.16](5.16.story.md) | CODE_OF_CONDUCT.md (Código de Conduta) | Done |
| [5.17](5.17.story.md) | `.github/` Scaffold (Templates de PR/Issue e CODEOWNERS) | Done |
| [5.18](5.18.story.md) | Configurar Branch Protection no Repo Público | Draft |
| [5.19](5.19.story.md) | CI: Validação de Manifest em PRs (GitHub Actions) | Draft |
| [5.20](5.20.story.md) | README.md: Limpeza de Hardcodes, Versão e Falsos Positivos | Draft |
| [5.21](5.21.story.md) | CLAUDE.md: Limpar Hardcodes TypeScript dos Blocos Managed | Draft |
| [5.22](5.22.story.md) | Expurgar package.json/package-lock.json/tsconfig.json do Repo Público | Draft |
| [5.23](5.23.story.md) | Expurgar ANTHROPIC_API_KEY como Pré-requisito Universal do Framework | Draft |
| [5.24](5.24.story.md) | Documentar Posição Stack-Agnóstica do Kairos | Draft |
| [5.25](5.25.story.md) | Fix Arquitetural (L1): src/ É User-Owned — Corrigir Documentação de Fundação | Draft |
| [5.26](5.26.story.md) | *architecture Stack-Agnóstico e Gestão Simétrica de agent-standards.md | Draft |
| [3.28](3.28.story.md) | Refatoração de data-flow.md e agent-standards.md | Draft |
| [5.28](5.28.story.md) | `*ci`: Gate de Validação para Contribuidores (PRs) | Draft |
| [5.29](5.29.story.md) | Expurgar Exemplos de Instância e Hardcodes de Stack das Tasks e Templates do Framework | In Review |
| [5.30](5.30.story.md) | Expurgar Hardcodes de Ferramentas Específicas das Tasks e Templates do Framework | Draft |
| [3.29](3.29.story.md) | Elicitação Propósito-First em *new-squad, *update-squad, *new-story e *new-epic | Draft |
| [5.31](5.31.story.md) | Atualizar scope.md para Refletir o Estado Atual do Framework | In Review |
| [5.32](5.32.story.md) | Squad-scaffolding Dinâmico — Gerar Personas a partir de `squads/{squad}/agents/*.yaml` | Draft |
| [5.33](5.33.story.md) | Regeneração Incremental de Personas — `*regenerate-squad` e Integração ao `*pre-push` | Draft |
| [5.35](5.35.story.md) | update: cold-prospecting — conformar squad ao framework v3.11.x | Draft |
| [4.3](4.3.story.md) | Implementar squad client-onboarding | Draft |
| [4.4](4.4.story.md) | Especializar templates de contrato por tipo de serviço | Draft |
| [6.1](6.1.story.md) | Kairos MCP Server v1 — Implementação (Código + Docker + Docs) | In Review |
| [6.2](6.2.story.md) | Kairos MCP Server v1 — Deploy, Integração e Validação | Draft |
