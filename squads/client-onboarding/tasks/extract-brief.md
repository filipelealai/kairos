---
task: Extract Brief
responsavel: "@brief-extractor"
responsavel_type: agent
atomic_layer: analysis
elicit: true
Entrada: |
  - material: texto livre do cliente (brief, notas de call, docs) — obrigatório
  - empresa: nome da empresa cliente — obrigatório
Saida: |
  - brief estruturado: data/outputs/client-onboarding/briefs/brief-extractor_brief-{empresa}-{INSTANCE}-YYYY-MM-DD.md
Checklist:
  - "[ ] Receber material do cliente (texto livre, notas, docs)"
  - "[ ] Identificar e extrair: empresa, setor, dores, objetivos, escopo esperado"
  - "[ ] Identificar: stakeholders, restrições, contexto técnico, prazo esperado"
  - "[ ] Marcar campos ausentes com [AUSENTE — perguntar ao usuário]"
  - "[ ] Elicitar campos críticos faltantes antes de salvar"
  - "[ ] Salvar brief estruturado em data/outputs/client-onboarding/briefs/"
  - "[ ] Gerar handoff para proposal-writer se aplicável"
---

# *extract — Extração e Estruturação de Brief do Cliente

## Passo 1 — Receber material do cliente

O material pode chegar em qualquer formato:
- **Texto colado diretamente** na conversa (brief informal, e-mail do cliente, notas de call)
- **Arquivo** referenciado por path (ler o arquivo antes de prosseguir)
- **Descrição oral** do usuário sobre o cliente e o projeto

Se o material for insuficiente para identificar empresa e escopo mínimo:
```
⚠️ Material insuficiente — preciso de:
- Nome da empresa/cliente
- Descrição mínima do que precisa (serviço, projeto, objetivo)

Cole o material ou descreva o contexto.
```

---

## Passo 2 — Extrair e estruturar campos

Percorrer o material e preencher o mapa de campos abaixo. Para cada campo não encontrado, marcar `[AUSENTE — perguntar ao usuário]`.

### Mapa de Campos Canônicos do Brief

**Identificação**
- `empresa`: Nome da empresa ou cliente
- `setor`: Segmento de atuação (ex: e-commerce, SaaS, serviços B2B)
- `porte`: Tamanho aproximado (micro, pequena, média, grande) — se identificável
- `contato_principal`: Nome e cargo do interlocutor

**Contexto do Problema**
- `dores`: Problemas concretos que o cliente quer resolver (listar por ordem de prioridade)
- `situacao_atual`: Como o cliente opera hoje (o que está quebrado ou faltando)
- `tentativas_anteriores`: O que já foi tentado e por que não funcionou — se mencionado

**Objetivo do Projeto**
- `objetivos`: O que o cliente quer alcançar ao final do projeto (resultados esperados)
- `criterios_sucesso`: Como o cliente vai saber que funcionou — se declarado
- `prioridade_negocio`: Urgência percebida (alta / média / baixa) — se identificável

**Escopo**
- `escopo_esperado`: O que o cliente quer que seja feito (funcionalidades, entregas, serviços)
- `fora_do_escopo`: O que explicitamente não faz parte — se mencionado
- `integrações`: Sistemas, ferramentas ou plataformas que precisam se conectar

**Restrições**
- `orcamento`: Valor ou faixa disponível — se mencionado
- `prazo_esperado`: Data de entrega ou duração esperada do projeto
- `restricoes_tecnicas`: Limitações de stack, infra, equipe interna
- `restricoes_legais`: Regulamentações ou compliance relevantes — se aplicável

**Stakeholders**
- `stakeholders`: Quem mais é afetado ou tem voz na decisão
- `decisor`: Quem aprova o projeto — se diferente do contato principal
- `equipe_cliente`: Pessoas do lado do cliente que participarão do projeto

**Contexto Técnico**
- `stack_atual`: Tecnologias, ferramentas e plataformas em uso
- `nivel_tecnico_interno`: Capacidade técnica da equipe do cliente
- `dados_disponiveis`: Dados, acessos ou integrações que o cliente pode fornecer

---

## Passo 3 — Elicitar lacunas

Após mapear os campos, identificar quais são **campos críticos** — sem eles o @proposal-writer não consegue gerar uma proposta coerente:

| Campo crítico | Por que é bloqueante |
|---------------|---------------------|
| `empresa` | Necessário para nomear todos os documentos |
| `dores` | Define o problema que o projeto resolve |
| `objetivos` | Define o que a proposta precisa prometer |
| `escopo_esperado` | Define o que será entregue |
| `prazo_esperado` | Entra na proposta e no contrato |

Se algum campo crítico estiver ausente, perguntar ao usuário antes de salvar:

```
Para completar o brief da {empresa}, preciso de mais informações:

1. {campo_ausente_1}: {pergunta específica}
2. {campo_ausente_2}: {pergunta específica}
...

Responda diretamente ou diga "pular" para marcar como [AUSENTE].
```

Campos não-críticos ausentes: marcar `[AUSENTE — opcional]` e salvar sem bloquear.

---

## Passo 4 — Salvar e gerar handoff

### Formato do brief estruturado

```markdown
# Brief — {Empresa}

**Data:** YYYY-MM-DD
**Extraído por:** @brief-extractor (Brix)
**Versão:** 1.0

---

## Identificação

- **Empresa:** {empresa}
- **Setor:** {setor}
- **Porte:** {porte}
- **Contato principal:** {contato_principal}

## Contexto do Problema

**Dores:**
{dores — lista por prioridade}

**Situação atual:**
{situacao_atual}

**Tentativas anteriores:**
{tentativas_anteriores | [AUSENTE — não mencionado]}

## Objetivo do Projeto

**Objetivos:**
{objetivos — lista}

**Critérios de sucesso:**
{criterios_sucesso | [AUSENTE — perguntar ao usuário]}

## Escopo

**Escopo esperado:**
{escopo_esperado — lista de entregas/funcionalidades}

**Fora do escopo:**
{fora_do_escopo | Não declarado pelo cliente}

**Integrações:**
{integracoes | Nenhuma mencionada}

## Restrições

- **Orçamento:** {orcamento | [AUSENTE — perguntar ao usuário]}
- **Prazo esperado:** {prazo_esperado}
- **Restrições técnicas:** {restricoes_tecnicas | Nenhuma declarada}

## Stakeholders

- **Decisor:** {decisor}
- **Stakeholders:** {stakeholders | Não identificados}
- **Equipe cliente:** {equipe_cliente | Não declarada}

## Contexto Técnico

- **Stack atual:** {stack_atual | Não declarada}
- **Nível técnico interno:** {nivel_tecnico_interno | Não declarado}
- **Dados disponíveis:** {dados_disponiveis | Não declarados}

---

## Campos para Elicitação

Os campos abaixo precisam ser confirmados com o usuário antes de gerar a proposta:
{lista_de_ausentes_criticos — ou "Nenhum — brief completo"}

---

*Gerado por @brief-extractor — base para proposta, contrato e onboarding*
```

### Salvar o arquivo

```
data/outputs/client-onboarding/briefs/brief-extractor_brief-{empresa}-{INSTANCE}-YYYY-MM-DD.md
```

### Gerar handoff (se pipeline continua)

Se o usuário indicar que quer continuar para a proposta, gerar handoff:

```yaml
handoff:
  from_agent: brief-extractor
  to_agent: proposal-writer
  last_command: "*extract"
  timestamp: "{ISO 8601}"
  consumed: false
  context:
    output_file: "data/outputs/client-onboarding/briefs/brief-extractor_brief-{empresa}-{INSTANCE}-YYYY-MM-DD.md"
    empresa: "{empresa}"
    campos_ausentes: {N}
    escopo_resumido: "{1-2 linhas do escopo}"
  next_action: "*write {empresa}"
```

Salvar em `.kairos-core/runtime/handoffs/handoff-brief-extractor-to-proposal-writer-{timestamp}.yaml`.

### Confirmar ao usuário

```
✅ Brief estruturado salvo:
   data/outputs/client-onboarding/briefs/brief-extractor_brief-{empresa}-{INSTANCE}-YYYY-MM-DD.md

Campos extraídos: {N_preenchidos}/{N_total}
Campos ausentes críticos: {lista_ou_nenhum}

Próximo passo: @proposal-writer *write {empresa}
```
