---
id: kairos-workers
title: Workers — Agentes Agendados
agent: kairos
command: "*workers [{id}] [{ação}]"
version: 1
---

# Task: kairos-workers

## Propósito

Gerenciar agentes agendados: definir quais agentes rodam quando, ativar/desativar schedules, e disparar execuções imediatas.

O registry de workers vive em `.kairos-core/data/workers.yaml`.
O scheduling real usa o mecanismo nativo do Claude Code (`/schedule`).

---

## Modos de Execução

### `*workers` — Listar workers configurados

1. Ler `.kairos-core/data/workers.yaml`
2. Se nenhum worker definido: informar e sugerir `*workers new`
3. Exibir tabela:

```
ID                        Agente             Comando         Cron             Status
weekly-campaign-analysis  @campaign-analyst  *analyze        0 9 * * 1        ⏸ desativado
daily-email-batch         @email-writer      *write 20       0 8 * * 1-5      ▶ ativo
```

---

### `*workers new` — Criar novo worker (elicitação guiada)

**Bloco 1 — Identidade**
1. "Qual agente deve executar? (@campaign-analyst / @lead-scorer / @niche-classifier / @email-writer)"
2. "Qual comando? (ex: analyze, score, write 20)"
3. "Descrição em uma frase — o que este worker faz?"

**Bloco 2 — Agendamento**
4. "Com que frequência? Sugestões:
   - Diário (dias úteis às 8h) → `0 8 * * 1-5`
   - Semanal (segunda às 9h) → `0 9 * * 1`
   - Manual (sem agendamento automático) → deixar desativado
   - Outro → fornecer expressão cron"

**Confirmação**
5. Mostrar preview do worker e pedir confirmação
6. Adicionar em `.kairos-core/data/workers.yaml` com `enabled: false`
7. Informar: "Worker criado como desativado. Use `*workers {id} schedule` para ativar o agendamento no Claude Code."

---

### `*workers {id} enable` / `*workers {id} disable`

1. Localizar worker por ID no YAML
2. Atualizar campo `enabled: true | false`
3. Confirmar mudança

> Nota: `enable` aqui só muda o flag no YAML — não cria automaticamente o trigger no Claude Code.
> Para agendar de verdade: `*workers {id} schedule`.

---

### `*workers {id} schedule` — Registrar no Claude Code

1. Ler definição do worker (agent, command, cron)
2. Montar o prompt de ativação: `@{agent} *{command}`
3. Usar `/schedule` do Claude Code para criar o trigger com a expressão cron
4. Atualizar `enabled: true` no YAML
5. Confirmar: "Worker agendado. Próxima execução: {próximo horário baseado no cron}."

---

### `*workers {id} run` — Executar imediatamente (one-shot)

1. Localizar worker por ID
2. Exibir: "Executando `@{agent} *{command}` agora..."
3. Acionar o agente com o comando definido
4. Atualizar `last_run` no YAML com timestamp atual

---

### `*workers {id} delete` — Remover worker

1. Confirmar: "Remover worker `{id}`? Isso não cancela automaticamente schedules ativos no Claude Code."
2. Se confirmado: remover entrada do YAML
3. Lembrar o usuário de cancelar o schedule no Claude Code se houver um ativo (`/schedule list`)

---

## Blocking

- HALT se ID fornecido não existe no registry — listar IDs disponíveis

---

## Completion

Sem handoff. Workers é gerenciamento de configuração, não parte do pipeline operacional.
