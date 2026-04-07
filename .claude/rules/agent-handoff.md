# Agent Handoff Protocol

## Propósito

Evitar acúmulo de contexto ao trocar de agente. Cada troca compacta o estado relevante em um artefato < 500 tokens em vez de carregar a persona anterior completa.

## Quando Aplica

Este protocolo ativa sempre que:
1. Um usuário ativa um novo agente (`@nome`) em uma sessão que já tem outro ativo
2. Um agente completa sua fase e gera handoff para o próximo

## Formato do Handoff

```yaml
handoff:
  from_agent: "{id do agente atual}"
  to_agent: "{id do próximo agente}"
  last_command: "{último comando executado}"
  timestamp: "{ISO 8601}"
  consumed: false
  context:
    # Campos específicos de cada transição — ver campaign-lifecycle.md
    output_file: "data/..."
    total_processados: N
    insight_principal: "..."
  next_action: "{o que o agente entrante deve fazer}"
```

## Armazenamento

- Local: `.kairos/handoffs/`
- Formato do nome: `handoff-{from}-to-{to}-{timestamp}.yaml`
- Lifecycle: marcado como `consumed: true` após o agente entrante lê-lo na ativação

## Limites

| Limite | Valor |
|--------|-------|
| Tamanho máximo do artefato | 500 tokens |
| Handoffs retidos simultaneamente | 3 (o mais antigo é descartado no 4º) |
| Campos em `context` | máximo 6 |
| Campos em decisões | máximo 5 |

## O que Preservar

- Output file gerado na fase anterior
- Totais relevantes (leads processados, e-mails gerados)
- Insight principal que informa a próxima fase
- Próxima ação recomendada

## O que Descartar

- Persona completa do agente anterior
- Lista de comandos do agente anterior
- Dados brutos (leads individuais, linhas do CSV)
- Contexto de conversa anterior

## Lookup no Activation Step 5.5

Ao ativar, o agente verifica `.kairos/handoffs/` pelo handoff não consumido mais recente:

```
1. Listar arquivos em .kairos/handoffs/ ordenados por timestamp (mais recente primeiro)
2. Pegar o primeiro com consumed: false
3. Se from_agent + last_command tem match em .kairos-core/data/workflow-chains.yaml:
   → Exibir "💡 Sugerido: *{next_command}"
4. Marcar handoff como consumed: true
```
