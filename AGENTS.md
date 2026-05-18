<!-- KAIROS-MANAGED-START: kairos-codex-bootloader -->
# Kairos on Codex

Este projeto usa o Kairos como framework de orquestração de agentes.

Quando o usuário invocar sintaxe Kairos (`@kairos`, `@agent`, `*comando` em modo
ativo, ou `kairos ...`), carregue e siga `.agents/skills/kairos/SKILL.md`.

Não opere o Kairos apenas de memória. Use o protocolo do runtime Codex e carregue
o contexto canônico em `.kairos-core/` antes de agir.

Em uma ativação `@kairos`, a primeira mensagem visível do assistente deve ser o
greeting definido pela persona canônica. Não envie preâmbulos como "vou carregar"
ou "vou ler" antes do greeting.
<!-- KAIROS-MANAGED-END: kairos-codex-bootloader -->

## Instruções do Usuário para Codex

Adicione aqui regras específicas deste projeto para o Codex. Esta seção é
user-owned e não deve ser sobrescrita por install/update/materialize.
