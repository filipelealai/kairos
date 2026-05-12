---
kairos-owned: true
kairos-version: 3.10.0
task: Kairos Status
responsavel: "@kairos"
responsavel_type: agent
atomic_layer: report
elicit: false
Entrada: |
  Nenhuma — lê estado atual do repositório e arquivos de configuração
Saida: |
  Relatório de estado exibido em tela (não persiste em arquivo)
Checklist:
  - "[ ] Ler .kairos-core/core-config.yaml → versão e squads ativos"
  - "[ ] Ler CHANGELOG.md → última entrada"
  - "[ ] Listar docs/stories/ → stories por status (Done/In Progress/Draft)"
  - "[ ] Listar docs/epics/ → epics por status"
  - "[ ] Verificar docs/qa/gates/ → último gate e seu verdict"
  - "[ ] Verificar .kairos-core/runtime/handoffs/ → handoff não consumido mais recente"
  - "[ ] Exibir resumo formatado"
---

# *status — Estado Completo do Kairos

## Execução

### Passo 1 — Versão e configuração

Leia `.kairos-core/core-config.yaml`:
- `version` — versão atual
- `agents.squads` — squads ativos e seus agentes

### Passo 2 — Histórico recente

Leia as últimas 2 entradas do `CHANGELOG.md`.

### Passo 3 — Stories

Liste todos os arquivos em `docs/stories/*.story.md` e agrupe por status:
- **Done** — concluídas
- **In Progress** — em andamento
- **Draft** — pendentes

Para cada story, leia o campo `**Tipo:**` no cabeçalho e prefixe:
- `[core]` para stories com `type: kairos-core`
- `[instance]` para stories com `type: instance`
- sem prefixo para stories sem campo type (compatibilidade retroativa)

### Passo 4 — Epics

Liste `docs/epics/*.md` e o status de cada um.

### Passo 5 — Último gate

Verifique `docs/qa/gates/` pelo arquivo mais recente. Mostre story, verdict e data.

### Passo 6 — Handoff pendente

Verifique `.kairos-core/runtime/handoffs/` por handoff com `consumed: false`. Se existir, mencione qual agente está aguardando ação.

### Passo 7 — Exibir

```
🌀 Kairos v{version}

📦 Squads Ativos
  {squad-id}: {agente-1}, {agente-2}, ...

📋 Stories
  Done (N): [core] 1.1, [core] 1.2
  In Progress (N): —
  Draft (N): [core] 2.1, [instance] 3.1

🗂️ Epics
  1 — Infraestrutura de Dados: Done
  2 — Automação de Disparo: In Progress
  3 — Governança e Versionamento: In Progress
  4 — Novos Escopos: Backlog

🔍 Último Gate
  PASS — 2026-04-06

💬 Handoff Pendente
  {from-agent} → {to-agent} (aguardando *{command})
  [ou: nenhum]

📝 Último Changelog
  [última entrada do CHANGELOG.md]
```
