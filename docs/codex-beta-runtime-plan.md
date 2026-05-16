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
- persona do `@kairos` como fonte provisória;
- task canônica do comando.

Continuidade de agente é session-only, como no Kairos atual. Após ativação com
`@kairos`, comandos iniciados por `*` pertencem ao Kairos até `*exit` enquanto o
contexto da conversa estiver claro. Não há arquivo `active-agent.json`.

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
- A persona `@kairos` ainda é lida de `.claude/commands/kairos/agents/kairos.md`
  como fonte provisória até canonicalização futura.
- Hooks são capabilities de runtime. Claude possui hooks nativos; Codex não
  declara paridade de PreCompact nesta fase.

## Fase 3+: Ainda Precisa Detalhar

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
- Targets materializados não são fonte de verdade.
- Usuário final não deve sentir `runtimes/` nem precisar sincronizar manualmente.
- Desenvolvimento do framework pode usar comandos de manutenção, mas eles devem
  ser integrados aos fluxos normais (`install`, `update`, `doctor`, `push`).
