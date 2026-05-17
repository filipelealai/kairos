---
kairos-owned: true
kairos-version: 5.0.0
---

# Codex Beta Runtime Plan

Este documento registra o plano consolidado da conversa sobre tornar o Kairos
multi-runtime, preservando a experiência atual no Claude Code e abrindo caminho
para um runtime Codex sem criar duas versões paralelas do framework.

## Objetivo

Kairos deve ser Kairos. Claude Code e Codex devem ser runtimes que executam o
framework, não fontes paralelas de verdade.

O alvo é:

```text
.kairos-core/      fonte canônica do Kairos
.claude/           materialização para Claude Code
AGENTS.md/.codex   materialização para Codex
```

## Decisões Fechadas

1. `.claude/` não deve ser apagado, mas deve deixar de ser fonte canônica do
   Kairos no longo prazo.
2. Usar `.kairos-core/runtimes/`, não `.kairos-core/adapters/`.
   O termo "adapter" faz Codex parecer uma gambiarra sobre um Kairos
   Claude-native; "runtime" deixa claro que Claude e Codex são portas de
   execução equivalentes.
3. `CLAUDE.md` e `AGENTS.md` devem ser arquivos mixed, com blocos
   framework-owned e espaço user-owned fora dos blocos.
4. O usuário final não deve precisar rodar comando manual de sync. A
   materialização deve acontecer em install/update e nos fluxos normais de
   desenvolvimento do framework.
5. `codex-beta` é um branch paralelo de `main`, usado para experimentar o port
   somente com conteúdo sanitizado de framework, como o `push-dual` enviaria ao
   `main`.

## Estrutura Alvo

```text
.kairos-core/
  constitution.md
  core-config.yaml
  manifest.yaml

  tasks/
  rules/
  agents/
  instructions/

  runtimes/
    claude/
      runtime.yaml
      templates/
      hooks/

    codex/
      runtime.yaml
      templates/
      context-map.yaml
      boundary-policy.yaml

  runtime/
    handoffs/
```

Targets materializados:

```text
CLAUDE.md
.claude/commands/kairos/agents/*.md
.claude/rules/*.md
.claude/hooks/*.cjs
.claude/settings.json

AGENTS.md
.agents/skills/kairos/SKILL.md
.codex/hooks.json
```

## Papel de `.kairos-core/runtimes/`

`runtimes/` fornece templates, hooks/scripts e receitas para materializar o
Kairos nos caminhos esperados por cada runtime.

Cada runtime deve seguir o mesmo pipeline operacional:

```text
fonte canônica Kairos
  -> template/shell do runtime
  -> target materializado
  -> manifesto com ownership e origem explícitos
```

`templates/` é camada de projeção, não fonte de verdade. Ela pode conter a casca
esperada pelo runtime, marcadores de bloco e includes declarativos. Regra,
protocolo, persona ou task do Kairos não devem ser duplicados ali.

Exemplo conceitual:

```yaml
id: codex
status: beta
materialize:
  - template: templates/AGENTS.md
    target: AGENTS.md
    type: markdown_blocks
    blocks:
      - name: kairos-codex-bootloader
        source: templates/bootloader.md
  - source: templates/SKILL.md
    target: .agents/skills/kairos/SKILL.md
    type: owned_file
  - source: templates/hooks.json
    target: .codex/hooks.json
    type: owned_file
```

`runtime.yaml` é receita de materialização e contrato de capabilities do
runtime. `manifest.yaml` continua sendo o contrato de ownership.

Todo runtime deve declarar os mesmos conceitos no `runtime.yaml`:

- `capabilities` — o que é nativo, explícito, ausente ou coberto por fallback;
- `protocol` — como o runtime entra no Kairos e onde estão as fontes canônicas;
- `materialize` — quais targets são gerados para o runtime.

A simetria é de contrato, não de arquivos idênticos. Um runtime só deve ter
arquivo auxiliar próprio quando uma capability exigir esse arquivo e ele estiver
referenciado no `runtime.yaml`.

## Contrato Framework / Instância

Framework-owned:

```text
.kairos-core/constitution.md
.kairos-core/tasks/kairos-*.md
.kairos-core/rules/*.md
.kairos-core/agents/kairos.*
.kairos-core/instructions/*.md
.kairos-core/runtimes/**
CLAUDE.md managed blocks
AGENTS.md managed blocks
.claude/** managed targets
.agents/skills/kairos/**
.codex/hooks.json
```

Instance-owned:

```text
squads/**
.kairos-core/agents/{squad-agent}/MEMORY.md
docs/scope.md
docs/stories/**
docs/qa/gates/**
data/**
src/**
.env
.mcp.json
.agents/skills/* exceto kairos
.codex/config.toml
```

Mixed:

```text
CLAUDE.md
AGENTS.md
.claude/settings.json
.kairos-core/core-config.yaml
.env.example
.gitignore
```

## Fase 1: Core Runtime-Neutral Mínimo

Fase 1 deve cobrir:

- Criar `.kairos-core/runtimes/claude/`.
- Criar `.kairos-core/runtimes/codex/`.
- Criar `.kairos-core/rules/`.
- Criar `.kairos-core/instructions/`.
- Canonicalizar rules globais do framework fora de `.claude/`.
- Canonicalizar blocos conceituais gerenciados do `CLAUDE.md` em
  `.kairos-core/instructions/`.
- Manter `CLAUDE.md`, `AGENTS.md`, `.claude/**`, `.agents/**` e `.codex/**`
  como targets materializados.
- Tratar `CLAUDE.md` e `AGENTS.md` como mixed via managed blocks.
- Atualizar `core-config.yaml` e `manifest.yaml` para conhecer runtimes e
  ownership runtime-aware.

Fase 1 resolve:

- Kairos deixa de ser Claude-native.
- Não cria duas versões paralelas.
- Preserva contrato framework/instância.
- Preserva Claude Code funcionando.
- Prepara Codex sem afetar a instância pessoal.

## Fase 2: Runtime Codex Funcional Para `@kairos`

Status: implementada e enviada para `origin/codex-beta` no commit
`c620385 Define Codex runtime operational contract`.

Fase 2 deve cobrir:

- Expandir `runtime.yaml` de Claude e Codex com `capabilities`, `protocol` e
  `sources` canônicas.
- Criar `.kairos-core/runtimes/codex/context-map.yaml`.
- Criar `.kairos-core/runtimes/codex/boundary-policy.yaml`.
- Atualizar `.agents/skills/kairos/SKILL.md` e seu template para operar pelo
  contrato declarativo do runtime Codex.
- Atualizar o manifesto para registrar os novos contratos.

Fase 2 NÃO cria:

- loader executável obrigatório;
- dependência Node/Python/CLI para operar o runtime Codex;
- arquivo persistente de agente ativo;
- cópias Codex de persona, task ou rule.

O runtime Codex deve carregar explicitamente, via `context-map.yaml`:

- constituição;
- manifesto;
- config;
- contrato do runtime;
- rules canônicas;
- instructions canônicas;
- arquivos em `devLoadAlwaysFiles`;
- persona do `@kairos` como fonte provisória na Fase 2;
- task canônica do comando.

Continuidade de agente é session-only, como no Kairos atual. A Fase 3A move a
regra detalhada de continuidade para a persona canônica do `@kairos`; runtimes
devem apenas apontar para essa fonte e aplicá-la até `*exit`. Não há arquivo
`active-agent.json`.

PreCompact não é replicado no Codex nesta fase. O Claude declara
`pre_compaction_digest: native_hook`; o Codex declara `pre_compaction_digest:
unsupported` com fallback `reload_context_on_kairos_intent`.

Critério de aceite:

```text
@kairos *help
@kairos *status
@kairos *doctor
@kairos *chat
mensagem seguinte sem repetir @kairos: *status ou *doctor
*exit
```

devem funcionar no Codex com protocolo e boundaries equivalentes ao escopo
read-only de governança do Claude Code.

## Decisões Permanentes da Fase 2

- Estado de agente, `chat_active`, `yolo_active` e `pre_push_passed` são
  session-only. Não persistir em arquivo.
- Runtime Codex é declarativo nesta etapa: sem loader executável obrigatório.
- O manifesto continua sendo a única fonte de ownership. `boundary-policy.yaml`
  apenas ensina o Codex a aplicar o manifesto.
- Codex usa `.kairos-core/rules/`, `.kairos-core/instructions/` e
  `.kairos-core/tasks/` como fontes canônicas. Não usa `.claude/rules/` como
  fonte.
- Na Fase 2, a persona `@kairos` ainda era lida de
  `.claude/commands/kairos/agents/kairos.md` como fonte provisória. A Fase 3A
  remove essa dependência.
- Hooks são capabilities de runtime. Claude possui hooks nativos; Codex não
  declara paridade de PreCompact nesta fase.

## Resultado do Teste da Fase 2

Teste manual em conversa nova do Codex:

```text
@kairos *help
@kairos *status
*doctor
*chat
*exit
```

Resultado:

- `@kairos *help` carregou skill, runtime, context-map, boundary-policy, a
  persona provisória da Fase 2 e task canônica.
- `@kairos *status` leu estado real do repo.
- `*doctor` sem repetir `@kairos` foi tratado como comando Kairos, validando
  continuidade `session_context`.
- `*chat` e `*exit` funcionaram conforme esperado.
- Nenhum `active-agent.json` foi criado.
- Nenhum loader executável foi necessário.

Achados fora do escopo da Fase 2:

- `.claude/settings.json` referencia `kairos-powershell-encoding-guard.cjs`,
  mas o arquivo não existe.
- `.kairos-core/runtime/cloud-sync.json` indica sync ativo, mas `data/outputs`
  não existe/não é symlink.
- `docs/scope.md` está em `devLoadAlwaysFiles`, mas não existe nesta checkout.

Correção aplicada durante o teste:

- `kairos-doctor.md` agora documenta o algoritmo canônico de SHA para blocos
  mixed, evitando WARN falso em `CLAUDE.md` e `AGENTS.md`.

## Fase 3: Persona Canônica e Runtime-Aware Doctor

Objetivo: remover a última dependência conceitual de `.claude/` como fonte
provisória da persona `@kairos`, e fazer o diagnóstico do framework entender
runtimes explicitamente.

Fase 3 deve planejar antes de implementar:

- Onde fica a fonte canônica da persona `@kairos` fora de `.claude/`.
- Como materializar a versão Claude da persona a partir dessa fonte.
- Como o runtime Codex consome a mesma fonte sem duplicar persona.
- Como atualizar `manifest.yaml`, `core-config.yaml` e `runtime.yaml`.
- Como tornar `kairos-doctor.md` runtime-aware:
  - validar runtime Claude;
  - validar runtime Codex;
  - distinguir checks específicos de runtime de checks canônicos do core.
- Se o materializer baseado em `runtime.yaml` entra nesta fase ou deve ficar
  para fase posterior.

Fase 3A implementa a canonicalização da persona `@kairos` sem criar um
materializer executável obrigatório:

- `.kairos-core/agents/kairos.md` passa a ser a fonte canônica.
- `.claude/commands/kairos/agents/kairos.md` passa a ser target materializado do
  runtime Claude.
- Codex passa a carregar `.kairos-core/agents/kairos.md` pelo `context-map`.
- `runtime.yaml` de Claude e Codex declaram a mesma fonte canônica.
- A continuidade do modo Kairos é declarada nos runtimes como
  `all_messages_until_exit`, mas a semântica detalhada mora apenas na persona
  canônica para evitar duplicação.

Fase 3B torna `kairos-doctor.md` runtime-aware sem criar um executor/script novo:

- Os checks passam a ser agrupados em core canônico, runtime Claude, runtime
  Codex, materialização/ownership, instância/squads e operação local.
- O doctor valida que `.kairos-core/agents/kairos.md` é a fonte canônica da
  persona `@kairos`.
- O doctor valida que `.claude/commands/kairos/agents/kairos.md` é target
  materializado de `.kairos-core/agents/kairos.md`, não fonte de verdade.
- O doctor valida que o runtime Codex aponta para `.kairos-core/agents/kairos.md`
  no `runtime.yaml` e no `context-map.yaml`.
- A ativação do `@kairos` deve preservar o envelope da persona canônica também
  no Codex: greeting archetypal, papel/status quando exigidos e assinatura final.
  Se a ativação vier com comando (`@kairos *doctor`), o comando roda depois do
  greeting e a resposta fecha com a assinatura; o runtime não redefine o texto,
  apenas obedece à persona. Nenhuma atualização visível do runtime deve sair
  antes do greeting.
- O doctor deixa explícito que squads operacionais no Codex continuam pendentes
  nesta fase.

Critério de aceite sugerido:

- `.claude/commands/kairos/agents/kairos.md` deixa de ser fonte de verdade e vira
  target materializado ou entrypoint runtime-specific.
- Codex não depende mais de `.claude/commands/.../kairos.md` como fonte
  provisória.
- `*doctor` reporta claramente checks de core, Claude e Codex.
- Nenhuma task, rule ou persona é duplicada por runtime.

## Fase 4+: Ainda Precisa Detalhar

Ainda está abstrato e precisa de planejamento separado:

- resolver agentes de squad no Codex;
- mapear tasks de squad;
- carregar memória por agente operacional;
- consumir handoffs;
- adaptar `new-squad`, `update-squad`, `regenerate-squad`, `export-squad` e
  `import-squad` para runtimes;
- canonicalizar persona `@kairos` fora de `.claude/`;
- hardening de boundary policy e drift detection;
- integração com `push-dual`/`codex-beta`.

## Regras de Design

- Não duplicar regra, protocolo, persona ou task entre Claude e Codex.
- Se é comportamento do Kairos, mora no core.
- Se é formato exigido por runtime, mora em `.kairos-core/runtimes/{runtime}/`.
- `.kairos-core/instructions/` contém apenas contexto operacional
  runtime-neutral que todo runtime pode carregar. Não deve conter regra
  normativa forte (`rules/`), comando (`tasks/`), persona (`agents/`) nem
  template/casca de runtime (`runtimes/{runtime}/templates/`).
- Targets materializados não são fonte de verdade.
- Usuário final não deve sentir `runtimes/` nem precisar sincronizar manualmente.
- Desenvolvimento do framework pode usar comandos de manutenção, mas eles devem
  ser integrados aos fluxos normais (`install`, `update`, `doctor`, `push`).
