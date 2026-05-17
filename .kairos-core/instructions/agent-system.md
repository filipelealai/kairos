---
kairos-owned: true
kairos-version: 5.0.0
---

# Sistema de Agentes Kairos

## Dois Tipos de Agentes

**Governança (framework):**
- `@kairos` — orquestrador e governador do Kairos. Versiona, cria squads,
  gerencia stories, tem autoridade sobre tudo.

**Operacional (squads — definidos pelo usuário/equipe):**

Os agentes de squad são criados com `@kairos *new-squad` e variam por instância.

## Comandos de Agentes

Use prefixo `*` dentro de um agente ativo:
- `*help` — Mostrar comandos disponíveis
- `*guide` — Guia completo do agente
- `*exit` — Sair do modo agente

## Quando usar cada camada

| Situação | Use |
|----------|-----|
| Trabalho operacional de um squad | Agente do squad correspondente |
| Evoluir o Kairos, versionar, criar novo squad | `@kairos` |
| Construir/modificar o Kairos (código, arquivos) | Executor principal do runtime |

## Pipeline de Squad (exemplo)

Cada squad define seu pipeline. Exemplo ilustrativo:

```text
@campaign-analyst *analyze → @lead-scorer *score
→ @niche-classifier *classify → @email-writer *write 20
```

## Handoffs

Ao completar uma fase, cada agente gera um handoff em
`.kairos-core/runtime/handoffs/`. O próximo agente detecta e sugere o próximo
comando automaticamente na ativação.

## Modelo de Governança

```text
@kairos (governa o framework)
      ↓ autoridade sobre
squads/* (trabalho operacional — definido pelo usuário)
      ↓ implementado por
executor principal do runtime (constrói e mantém o Kairos)
```

Kairos consegue se auto-aperfeiçoar com planejamento de arquitetura, PRD,
stories, epics e revisões do que foi implementado, mas NÃO pode
implementar/desenvolver modificações em si próprio (`type: kairos-core` nas
stories).

Stories em `docs/stories/` = log, histórico e desenvolvimento criados e
gerenciados pelo Kairos. Outputs operacionais dos agentes = `data/`.
