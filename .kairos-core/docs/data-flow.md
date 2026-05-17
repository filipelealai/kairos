---
kairos-owned: true
kairos-version: 5.0.0
---

# Fluxo de Dados — Kairos

> Referência para entender como dados entram, transitam e saem de um squad Kairos.
> Documentação genérica de framework. Para fluxo específico de um squad, ver `squads/{squad}/workflows/data-flow.md`.

---

## Visão Geral — Arquitetura de Duas Camadas

O processamento em um squad Kairos é dividido em duas camadas com responsabilidades distintas:

```
┌─────────────────────────────────────────────────────────────────┐
│                      FONTES EXTERNAS                            │
│   (API, webhook, banco, planilha — definidas pelo squad)        │
└───────────────────────────┬─────────────────────────────────────┘
                            │ entrada
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│              CAMADA 1 — COMPUTAÇÃO (scripts)                    │
│                                                                  │
│  src/agents/{id}.{ext}                                          │
│  • Computação pura: parsear, calcular, classificar              │
│  • Acesso a fontes externas (APIs, banco, arquivos)             │
│  • Gera outputs estruturados em data/outputs/{squad}/{tipo}/    │
│                                                                  │
│  Executados pelos agentes IA via comando do usuário             │
└───────────────────────────┬─────────────────────────────────────┘
                            │ outputs
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│              CAMADA 2 — ORQUESTRAÇÃO (agentes IA)               │
│                                                                  │
│  @agente — persona ativa no Claude Code                         │
│  • Interpreta outputs dos scripts                               │
│  • Orquestra o pipeline (sequência definida em                  │
│    squads/{squad}/data/workflow-chains.yaml)                    │
│  • Gera handoffs para o próximo agente                          │
│  • Não recalcula — lê e interpreta                              │
└───────────────────────────┬─────────────────────────────────────┘
                            │ outputs consumidos por
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                     DESTINOS EXTERNOS                           │
│   (sistemas de ação — definidos pelo squad)                     │
└─────────────────────────────────────────────────────────────────┘
```

**Separação de responsabilidades (constituição IV.14):** scripts são a única fonte de computação pura — agentes IA interpretam e orquestram, nunca recalculam.

---

## Padrões de Fluxo

### Entrada

Squads definem suas fontes de entrada em `squads/{squad}/squad.yaml` (campo `integrations`). Fontes típicas: webhook HTTP, arquivos locais, APIs externas, banco de dados.

Leitura é **read-only** do ponto de vista do Kairos — escrita em sistemas externos é delegada a ferramentas especializadas fora do Kairos.

### Outputs de Agente

Outputs seguem o padrão canônico (definido em `.kairos-core/rules/output-naming.md`):

```
data/outputs/{squad}/{tipo}/{agent-id}_{tipo-curto}-{INSTANCE}-YYYY-MM-DD.{ext}
```

Onde:
- `{INSTANCE}` vem de `KAIROS_INSTANCE_NAME` no `.env` (fallback: `default`)
- `{tipo}` é definido pelo squad — não é uma convenção do framework

O segmento `{INSTANCE}` garante que dois membros do time rodando o mesmo agente no mesmo dia gerem arquivos com nomes distintos, sem colisão. Ver `.kairos-core/rules/output-naming.md` para regras completas de normalização e fallback.

Idempotência por data: regerar no mesmo dia (mesma instância) sobrescreve o arquivo anterior (constituição IV.13).

Cada squad declara seus tipos de output em `squads/{squad}/workflows/data-flow.md`.

### Pipeline e workflow-chains

A sequência do pipeline — qual agente aciona qual após cada fase — é declarada em `squads/{squad}/data/workflow-chains.yaml`.

Este arquivo é lido pelo agente entrante no **Step 5.5 do greeting**: ao verificar handoffs não consumidos, o agente cruza `from_agent + last_command` com as entradas do `workflow-chains.yaml` para sugerir o próximo comando (`💡 Sugerido: *{next_command}`).

### Handoffs (Runtime)

**Local:** `.kairos-core/runtime/handoffs/` (conteúdo gitignored)

**Formato do nome:** `handoff-{from}-to-{to}-{timestamp}.yaml`

```yaml
handoff:
  from_agent: {id-do-agente-que-terminou}
  to_agent: {id-do-proximo-agente}
  last_command: {comando-executado}
  timestamp: "{ISO 8601}"
  consumed: false
  context:
    {campos-relevantes-para-o-proximo-agente}
  next_action: "{o-que-o-proximo-agente-deve-fazer}"
```

**Lifecycle:** criado pelo agente que termina uma fase → lido e marcado `consumed: true` pelo próximo agente na ativação. Ver `.kairos-core/rules/agent-handoff.md` para o protocolo completo.

---

## Responsabilidade de Documentação por Nível

| Nível | O que documenta | Onde vive |
|-------|-----------------|-----------|
| **Framework** | Arquitetura genérica do fluxo de dados, padrões de handoff, separação de camadas | `.kairos-core/docs/data-flow.md` (este arquivo) |
| **Squad** | Tipos de output do squad, fontes de entrada, destinos externos, sequência do pipeline | `squads/{squad}/workflows/data-flow.md` |
| **Pipeline** | Encadeamento específico de agentes e condições de transição | `squads/{squad}/data/workflow-chains.yaml` |

Regra: este arquivo descreve o framework genericamente — squads, integrações e tipos de output específicos de uma instância não são documentados aqui (constituição VI.21).

---

## Limites e Restrições Genéricas

| Restrição | Fundamento |
|-----------|------------|
| Agentes IA não recalculam — scripts são a única fonte de computação pura | Constituição IV.14 |
| Outputs são idempotentes por data — regerar no mesmo dia sobrescreve | Constituição IV.13 |
| Ações com side effects em sistemas externos são explícitas e confirméveis | Constituição I.2 |
| Integrações externas seguem hierarquia: Skills → MCPs → scripts → HTTP | Constituição I.1 / I.4 |
| Autoridade de agente é escopada ao squad | `.kairos-core/rules/agent-authority.md` |

Restrições específicas de squad (quem pode acionar qual sistema externo, quais campos são read-only) vivem em `squads/{squad}/` — não aqui.

---

## Referências

- `.kairos-core/rules/agent-handoff.md` — protocolo de handoff em detalhe
- `.kairos-core/rules/agent-authority.md` — matriz de autoridade por agente
- `.kairos-core/rules/external-integrations.md` — hierarquia de integrações externas
- `squads/{squad}/workflows/data-flow.md` — fluxo específico do squad ativo
- `squads/{squad}/data/workflow-chains.yaml` — sequência do pipeline e condições de transição
