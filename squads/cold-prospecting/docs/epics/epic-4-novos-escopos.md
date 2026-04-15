# Epic 4 — Novos Escopos

**Status:** Backlog
**Objetivo:** Expandir o Kairos além da prospecção fria, adicionando squads para outros fluxos de trabalho de Filipe.

---

## Descrição

O squad `cold-prospecting` é o primeiro escopo do Kairos, mas não o único. Este epic é o contêiner para futuros escopos — cada um materializado como um novo squad com seus próprios agentes, tasks e pipeline.

Novos escopos só entram aqui quando: (a) há um fluxo real de trabalho de Filipe que se beneficia de automação/IA, e (b) `@kairos` cria a story de planejamento do squad.

---

## Critério de Conclusão

Este epic não tem critério fixo — é um backlog vivo. Considera-se "fechado" quando um novo squad é entregue (cada entrega abre um epic próprio ou uma sub-entrada aqui).

---

## Escopos Candidatos (não priorizados)

Estes são candidatos potenciais — **não comprometidos**. Precisam de validação de Filipe antes de virar story.

| Candidato | Descrição | Pré-requisito |
|-----------|-----------|--------------|
| `lead-followup` | Agentes para acompanhamento de leads que responderam aos e-mails | Epic 2 concluído |
| `content-scheduler` | Planejamento e agendamento de conteúdo para redes sociais da Vendoteca | — |
| `client-onboarding` | Automatizar onboarding de novos clientes da Vendoteca | — |
| `financial-tracker` | Análise de receita e projeções financeiras pessoais | — |

---

## Como adicionar um novo escopo

1. `@kairos *new-squad "nome-do-squad"` — scaffolda a estrutura
2. `@kairos *new-story "Planejamento do squad X"` — registra a decisão
3. `@kairos *version minor "Novo squad X"` — bump de versão
4. Claude Code executa a implementação
5. Story passa para Done após squad estar operacional

---

## Change Log

| Data | Mudança |
|------|---------|
| 2026-04-06 | Epic criado como backlog — nenhum escopo comprometido ainda |
