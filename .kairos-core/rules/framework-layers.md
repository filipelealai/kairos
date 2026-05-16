---
kairos-owned: true
kairos-version: 2.0.0
---

# Framework Layers — Camadas de Imutabilidade

## Visão Geral

O Kairos organiza seus artefatos em 4 camadas de imutabilidade crescente:

```
L1 (Fundação)   — Não se toca sem decisão arquitetural explícita
L2 (Controlado) — Apenas @kairos pode modificar
L3 (Gerenciado) — Modificável via governança normal do @kairos
L4 (Volátil)    — Efêmero, gitignored, recriado a cada execução
```

**Fonte autoritativa:** a classificação de cada arquivo framework em L1-L3 é declarada em `.kairos-core/manifest.yaml` (campo `layer`). Path não determina camada — o manifesto sim. Arquivos não listados no manifesto são conteúdo do usuário e não têm camada atribuída. Ver `.kairos-core/rules/ownership.md` para o contrato completo.

---

## L1 — Fundação (Imutável)

Artefatos que definem as regras do jogo. Mudanças exigem decisão consciente e bump MAJOR.

| Artefato | Local | Por que é L1 |
|----------|-------|--------------|
| Constituição | `.kairos-core/constitution.md` | Princípios não-negociáveis do framework |
| Ownership | `.kairos-core/rules/ownership.md` | Contrato de fronteira framework/usuário |
| Matriz de autoridade | `.kairos-core/rules/agent-authority.md` | Define quem pode fazer o quê |
| Este arquivo | `.kairos-core/rules/framework-layers.md` | Define as próprias regras de mudança |
| IDS principles | `.kairos-core/rules/ids-principles.md` | Princípio de criação de novos artefatos |

**Protocolo para mudança L1:**
1. Justificativa explícita documentada (não apenas "parece bom")
2. `@kairos *review` aprovando a mudança
3. Bump MAJOR obrigatório
4. Entrada no CHANGELOG com seção `### Fundação`

---

## L2 — Controlado (Somente @kairos)

Artefatos de framework que definem como o Kairos funciona. Mudanças via @kairos, exigem story MINOR ou MAJOR.

| Artefato | Local | Por que é L2 |
|----------|-------|--------------|
| Configuração central | `.kairos-core/core-config.yaml` | Versão, paths, squads registrados |
| Personas dos agentes | `.claude/commands/kairos/agents/*.md` | Identidade e comportamento dos agentes |
| Tasks de governança | `.kairos-core/tasks/kairos-*.md` | Comandos do @kairos |
| Tasks operacionais | `.kairos-core/tasks/{squad}-*.md` | Comandos dos agentes de squad |
| Definições de squads | `squads/*/squad.yaml` | Manifesto do squad |

**Protocolo para mudança L2:**
1. Story criada por `@kairos *new-story` (se MINOR/MAJOR)
2. Executor implementa e move para In Review
3. `@kairos *review` aprova
4. Bump MINOR ou MAJOR + CHANGELOG

---

## L3 — Gerenciado (Governança normal)

Artefatos que evoluem regularmente como parte do trabalho de desenvolvimento. Mudanças via fluxo normal, podem ser PATCH.

| Artefato | Local | Por que é L3 |
|----------|-------|--------------|
| Rules cross-cutting | `.kairos-core/rules/*.md` (exceto L1) | Guiam comportamento mas evoluem com aprendizado |
| Stories de dev | `docs/stories/` | Rastreiam o desenvolvimento do Kairos |
| Epics | `docs/epics/` | Planejamento de alto nível |
| PRD | `docs/scope.md` | Escopo evolui com o produto |
| CHANGELOG | `CHANGELOG.md` | Histórico de versões |
| Definições leves de squad | `squads/*/agents/*.md`, `squads/*/workflows/` | Documentação viva do squad |

**Protocolo para mudança L3:**
- PATCH: sem story obrigatória — executor pode aplicar, @kairos versiona
- MINOR: story recomendada se mudança for significativa

---

## L4 — Volátil (Efêmero)

Artefatos de runtime. Não fazem parte do framework — são gerados e consumidos na execução.

| Artefato | Local | Lifecycle |
|----------|-------|-----------|
| Handoffs | `.kairos-core/runtime/handoffs/` | Criado ao final de fase, consumido na ativação seguinte |
| Logs de execução | `.kairos-core/runtime/logs/` | Gerados opcionalmente, nunca versionados |
| Outputs dos agentes | `data/outputs/` | Gerados por cada execução, idempotentes por data |
| Gates de review | `docs/qa/gates/` | Gerados por `*review` — são L3 (versionados) |

> Nota: `docs/qa/gates/` é versionado (L3) porque serve como histórico de auditoria do framework.

---

## Regras de Cruzamento de Camadas

1. **Executor nunca modifica L1** — apenas @kairos pode propor, com justificativa
2. **@kairos não delega mudanças L2 para o executor sem story** — se é MINOR, tem story
3. **L4 nunca vira L3 sem decisão explícita** — um handoff não vira regra por acidente
4. **Leitura é livre** — qualquer agente pode ler qualquer camada; restrição é de escrita

---

## Diagrama de Autoridade por Camada

```
L1 Fundação    ←  apenas @kairos + bump MAJOR + justificativa
L2 Controlado  ←  apenas @kairos + story MINOR/MAJOR
L3 Gerenciado  ←  @kairos + executor (bump PATCH ou MINOR)
L4 Volátil     ←  qualquer agente (sem versioning)
```
