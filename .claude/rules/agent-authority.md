---
kairos-owned: true
kairos-version: 2.0.0
---

# Agent Authority — Matriz de Autoridade

Define quem pode fazer o quê no Kairos. A matriz dos agentes de squad vive em `squads/{squad}/rules/agent-authority.md` — esta rule cobre apenas o @kairos e as regras universais.

---

## @kairos — Autoridade Total (Framework)

| Operação | Autoridade |
|----------|-----------|
| Versionar o Kairos (`*version`) | EXCLUSIVA |
| Criar novos squads (`*new-squad`) | EXCLUSIVA |
| Criar stories de desenvolvimento do Kairos (`*new-story`) | EXCLUSIVA |
| Modificar arquivos listados no manifesto `.kairos-core/manifest.yaml` | EXCLUSIVA |
| Modificar seções `<!-- KAIROS-MANAGED-... -->` em arquivos mistos | EXCLUSIVA |
| Deprecar agentes | EXCLUSIVA |
| Executar qualquer operação de qualquer squad | AUTORIZADO |

---

## Quem Constrói o Kairos

- **@kairos** — planeja, versiona, cria stories, decide o roadmap
- **Claude Code (conversa principal)** — executa: escreve código, cria arquivos, modifica tasks/agents
- **Não existe `@dev` no Kairos** — o executor é o próprio Claude Code em modo normal

---

## Operações Universalmente Proibidas

Nenhum agente (inclusive @kairos) pode:

- Commitar ou fazer `git push` sem passar pelo protocolo `@kairos *push`
- Modificar arquivos do usuário listados como user-owned (default-deny: tudo fora do manifesto)
- Forçar operações destrutivas (delete, drop, reset) sem confirmação explícita

---

## Autoridade de Agentes de Squad

Cada squad define a matriz de autoridade dos seus agentes em `squads/{squad}/rules/agent-authority.md`. Regras típicas que um squad declara:

- Quais scripts TypeScript cada agente pode executar (exclusividade)
- Quais sistemas externos o agente pode acionar e quais são delegados a integrações
- Quais dados são read-only do ponto de vista do Kairos
- Condições de HALT específicas do pipeline do squad

---

## Escalação Genérica

| Situação | Ação |
|----------|------|
| Fonte de dados externa indisponível | HALT — informar usuário |
| Script TS falha | HALT — exibir stderr e sugerir debug |
| Ação irreversível sem confirmação prévia do usuário | HALT — consultar antes |
| Ambiguidade entre ownership framework/usuário | HALT — consultar manifesto e rule `ownership.md` |

Escalações específicas de squad vivem em `squads/{squad}/rules/`.
