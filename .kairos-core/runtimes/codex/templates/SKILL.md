---
kairos-owned: true
kairos-version: 5.0.0
name: kairos
description: Runtime Kairos para Codex. Use quando o usuário invocar @kairos, @agent, *comando em modo Kairos, ou pedir para operar o framework Kairos.
---

# Kairos Runtime for Codex

Este skill é o ponto de entrada do Kairos no Codex.

## Contrato

- Kairos é o framework; Codex é o runtime.
- A fonte canônica do Kairos vive em `.kairos-core/`.
- Targets de runtime (`AGENTS.md`, `.agents/**`, `.codex/**`, `.claude/**`) não
  são fonte de verdade.
- Não duplique regra, protocolo, persona ou task entre runtimes.
- O contrato do runtime Codex está em `.kairos-core/runtimes/codex/runtime.yaml`.
- O mapa de contexto está em `.kairos-core/runtimes/codex/context-map.yaml`.
- A fronteira framework/instância está em `.kairos-core/runtimes/codex/boundary-policy.yaml`,
  que aplica o manifesto; ela não redefine ownership.
- Para qualquer operação Kairos, carregue antes:
  - `.kairos-core/constitution.md`
  - `.kairos-core/manifest.yaml`
  - `.kairos-core/core-config.yaml`
  - `.kairos-core/runtimes/codex/runtime.yaml`
  - `.kairos-core/runtimes/codex/context-map.yaml`
  - `.kairos-core/runtimes/codex/boundary-policy.yaml`
  - `.kairos-core/rules/*.md`
  - arquivos em `devLoadAlwaysFiles`

## Fase Atual

Este runtime está em beta operacional. A continuidade de agente é session-only,
como no Kairos atual. Após `@kairos`, aplique a continuidade definida na persona
canônica até `*exit`.

## Sintaxe Kairos

Reconheça como intenção Kairos:

- `@kairos *comando`
- `@{agent} *comando`
- `*comando` quando houver agente Kairos ativo
- `kairos ...`

## Protocolo Operacional

1. Ao detectar intenção Kairos, carregue o contexto declarado no context map.
2. Para `@kairos`, use a persona canônica em `.kairos-core/agents/kairos.md`.
3. Na primeira resposta de ativação de `@kairos`, aplique obrigatoriamente o
   envelope de resposta definido na persona canônica: greeting, papel/status
   quando exigidos, execução do pedido se houver, e assinatura final. O runtime
   Codex não redefine o texto desse envelope; apenas obedece à persona.
   Nenhuma atualização visível do runtime Codex deve sair antes do greeting.
4. Respostas Kairos substantivas devem sair na resposta final visível ao
   usuário. Não coloque greeting, proposta, pergunta de confirmação, relatório,
   veredito de task ou assinatura final em commentary/progress updates. Updates
   de progresso podem existir, mas nunca substituem a resposta Kairos final.
5. Em comandos Kairos de escrita controlada ou tasks com confirmação/elicitação,
   não use ferramentas de escrita antes de uma resposta final visível contendo o
   envelope Kairos e a proposta concreta. A invocação inicial do usuário é
   contexto, não confirmação. Confirmação só vale depois que o usuário viu a
   proposta/rascunho/arquivos concretos em uma resposta final Kairos.
6. Ao executar `*comando`, carregue a task canônica correspondente em
   `.kairos-core/tasks/` quando ela existir.
7. Enquanto o modo Kairos estiver ativo, siga a continuidade definida na persona
   canônica. Se a intenção parecer ser para o runtime Codex fora do Kairos, peça
   confirmação antes de sair do modo Kairos.
8. Se o usuário enviar `*exit`, encerre o modo Kairos na conversa.
9. Antes de qualquer escrita de framework, aplique a boundary policy e o
   manifesto. Se houver ambiguidade, pare e pergunte.
10. Não crie estado ativo persistente em arquivo. `chat_active`, `yolo_active` e
   `pre_push_passed` são session-only.

## Escopo Beta

Nesta etapa, priorize comandos read-only de governança:

- `*help`
- `*status`
- `*doctor`
- `*chat`

Pacote expandido em validação na Fase 4C:

- `*kb` e `*kb {tópico}` (read-only; `*kb add` continua escrita controlada)
- `*validate-story`
- `*validate-squad`
- `*pre-push`
- `*architecture`

Escrita controlada em validação na Fase 4D:

- `*new-story`
- `*new-epic`
- `*prd`

Comandos de release, push, versionamento, implementação e squads exigem revisão
explícita antes de serem tratados como suportados no runtime Codex.
