---
task: Kairos New Squad
responsavel: "@kairos"
responsavel_type: agent
atomic_layer: scaffolding
elicit: true
Entrada: |
  - squad_name: nome em kebab-case (string)
  - description: descrição do escopo do squad
  - agents: lista de agentes (nome e responsabilidade)
Saida: |
  - squads/{squad_name}/ com estrutura completa
  - docs/epics/epic-4-novos-escopos.md atualizado
  - .kairos-core/core-config.yaml atualizado (novo squad em agents.squads)
  - Story MINOR gerada automaticamente
Checklist:
  - "[ ] Confirmar nome do squad (kebab-case)"
  - "[ ] Elicitar agentes necessários e responsabilidades"
  - "[ ] Elicitar fonte de dados (webhook, arquivo, API)"
  - "[ ] Criar squads/{squad_name}/squad.yaml"
  - "[ ] Criar squads/{squad_name}/README.md"
  - "[ ] Criar squads/{squad_name}/agents/ com stub por agente"
  - "[ ] Criar squads/{squad_name}/workflows/"
  - "[ ] Criar squads/{squad_name}/tasks/"
  - "[ ] Adicionar squad em .kairos-core/core-config.yaml"
  - "[ ] Atualizar docs/epics/epic-4-novos-escopos.md"
  - "[ ] Criar story MINOR para o novo squad"
  - "[ ] Instruir: *version minor 'Novo squad {squad_name}'"
---

# *new-squad — Scaffoldar Novo Squad

## Elicitação

1. **Nome**: "Nome do squad em kebab-case (ex: lead-followup, content-scheduler)"
2. **Descrição**: "O que este squad faz em uma frase?"
3. **Agentes**: "Quantos e quais agentes? Descreva brevemente o papel de cada um."
4. **Dados**: "Qual a fonte de dados? (webhook n8n existente / novo webhook / arquivo / API)"
5. **Pipeline**: "Qual a ordem de execução dos agentes?"

## Estrutura Criada

```
squads/{squad_name}/
├── squad.yaml
├── README.md
├── agents/
│   └── {agent-id}.md  (um por agente — stub leve)
├── tasks/
│   └── (tasks serão criadas quando os agentes forem definidos)
└── workflows/
    └── full-pipeline.md
```

## squad.yaml Template

```yaml
name: {squad_name}
version: 0.1.0
description: "{description}"
author: Filipe Leal

kairos:
  minVersion: "1.1.0"
  type: squad
  scope: {squad_name}

components:
  agents: {lista}
  tasks: []
  workflows:
    - workflows/full-pipeline.md

config:
  scope: ../../docs/scope.md
  agent-standards: ../../docs/framework/agent-standards.md
  data-flow: ../../docs/framework/data-flow.md

pipeline:
  order: {lista de agentes}
  partial_execution: true

data:
  outputs: []

tags:
  - {squad_name}
  - kairos
```

## Após Scaffoldar

Informe:
```
✓ Squad '{squad_name}' scaffoldado em squads/{squad_name}/
✓ core-config.yaml atualizado
✓ Epic 4 atualizado

Próximos passos:
1. *new-story 'Implementar agentes do squad {squad_name}' (epic 4)
2. *version minor 'Novo squad {squad_name}'
3. Implementar personas em .claude/commands/kairos/agents/
```
