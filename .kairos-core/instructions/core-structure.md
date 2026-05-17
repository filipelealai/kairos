---
kairos-owned: true
kairos-version: 5.0.0
---

# Estrutura Kairos Core

```text
.github/                     # Templates de PR/Issue, CODEOWNERS e CI workflows

.kairos-core/
  constitution.md            # Princípios não-negociáveis do framework (L1)
  core-config.yaml           # Configuração central e versão semântica
  manifest.yaml              # Ownership: o que é framework vs. usuário
  agents/                    # Personas canônicas do framework e MEMORY.md de agentes
  tasks/                     # Definições de tasks executáveis
  rules/                     # Regras cross-cutting canônicas
  instructions/              # Blocos canônicos de instrução do framework
  runtimes/                  # Suporte de materialização por runtime
    claude/                  # Runtime Claude Code
    codex/                   # Runtime Codex
  data/                      # KB, workers registry e dados de configuração
  docs/                      # Documentação de arquitetura e escopo do Kairos
    install.md               # Guia de instalação, cloud sync, troubleshooting
  runtime/                   # Handoffs e logs de execução (conteúdo gitignored)
  templates/                 # Templates do Kairos para agentes, squads, stories etc.

.claude/                     # Target materializado do runtime Claude
  commands/kairos/agents/    # Targets de personas no formato esperado pelo Claude Code
  rules/                     # Projeção das rules canônicas para Claude Code
  hooks/                     # Hooks do Claude Code

AGENTS.md                    # Target materializado do runtime Codex
.agents/skills/kairos/       # Skill Kairos para Codex
.codex/hooks.json            # Hooks do runtime Codex

src/agents/                  # Scripts e ferramentas (user-owned)
data/outputs/                # Outputs dos agentes

install.sh   install.ps1     # Instaladores interativos
uninstall.sh uninstall.ps1   # Desinstaladores
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
| `external-integrations.md` | Skills → MCPs → scripts — hierarquia e diretrizes de integração |
| `output-naming.md` | Padrão canônico de nomenclatura de outputs por instância |

Rules específicas de squad vivem em `squads/{squad}/rules/`.

## Versionamento

Versão atual: ver `.kairos-core/core-config.yaml`
Histórico: `CHANGELOG.md`

Regras:
- **PATCH** — Correção de bugs, ajuste de instrução, documentação
- **MINOR** — Novo comando, nova task, nova rule, nova capacidade ou expansão significativa de capacidade
- **MAJOR** — Novo escopo, breaking change, mudança de arquitetura, modificações em arquivos L1

Autoridade para versionar: `@kairos *version` (standalone ou via modo
contribuidor no `*push`).
