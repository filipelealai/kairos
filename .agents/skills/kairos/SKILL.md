---
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
- Para qualquer operação Kairos, carregue antes:
  - `.kairos-core/constitution.md`
  - `.kairos-core/manifest.yaml`
  - `.kairos-core/core-config.yaml`
  - `.kairos-core/rules/*.md`
  - arquivos em `devLoadAlwaysFiles`

## Fase Atual

Este runtime está em beta estrutural. A Fase 1 materializa o contrato
multi-runtime; a execução fluida de `@kairos` via context loader será completada
na Fase 2.

## Sintaxe Kairos

Reconheça como intenção Kairos:

- `@kairos *comando`
- `@{agent} *comando`
- `*comando` quando houver agente Kairos ativo
- `kairos ...`

Enquanto o context loader Codex não estiver completo, opere de forma explícita:
leia os arquivos canônicos necessários antes de responder ou modificar qualquer
arquivo do framework.

