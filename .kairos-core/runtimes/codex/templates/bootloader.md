---
kairos-owned: true
kairos-version: 5.0.0
---

# Kairos on Codex

Este projeto usa o Kairos como framework de orquestração de agentes.

Quando o usuário invocar sintaxe Kairos (`@kairos`, `@agent`, `*comando` em modo
ativo, ou `kairos ...`), carregue e siga `.agents/skills/kairos/SKILL.md`.

Não opere o Kairos apenas de memória. Use o protocolo do runtime Codex e carregue
o contexto canônico em `.kairos-core/` antes de agir.
