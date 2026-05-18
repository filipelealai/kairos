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

## Fase 4: Paridade das Tasks do `@kairos`

Antes de squads, o próximo gargalo é a paridade das tasks do próprio `@kairos`.
O runtime Codex já sabe carregar tasks pelo padrão
`.kairos-core/tasks/kairos-{command}.md`, mas o escopo testado até agora é
apenas read-only de governança: `*help`, `*status`, `*doctor` e `*chat`.

Objetivo: expandir o conjunto de tasks Kairos suportadas no Codex sem duplicar
tasks por runtime e sem transformar Claude Code em norma implícita.

### Fase 4A — Inventário e Classificação

Classificar cada task canônica de `.kairos-core/tasks/` por nível de suporte no
Codex:

- **Suportada agora**: já testada no Codex sem restrição adicional.
- **Read-only candidata**: pode funcionar no Codex com ajustes textuais ou de
  boundary, sem escrita destrutiva.
- **Escrita controlada**: modifica framework, instância ou stories e exige
  validação explícita do contrato framework/instância.
- **Release/update sensível**: toca versionamento, update, push, cloud sync ou
  estado externo.
- **Squad-dependent**: depende de agentes de squad, memória operacional,
  handoffs ou materialização de squads.

Inventário realizado:

| Task | Classe Codex | Motivo | Próxima ação |
| --- | --- | --- | --- |
| `kairos-help.md` | Suportada agora | Exibe help em tela; sem escrita. | Manter no escopo suportado. |
| `kairos-status.md` | Suportada agora | Lê config, changelog, stories, epics, gates e handoffs; sem escrita. | Manter no escopo suportado. |
| `kairos-doctor.md` | Suportada agora | Já está runtime-aware; diagnóstico estrutural sem escrita. | Manter no escopo suportado e expandir checks conforme novas fases. |
| `kairos-chat.md` | Suportada agora | Session-only; ações concretas exigem confirmação explícita. | Manter no escopo suportado. |
| `kairos-kb.md` | Suporte parcial | `*kb` e `*kb {tópico}` são read-only; `*kb add` escreve em `.kairos-core/data/kairos-kb.md`. | Validar modos read-only em 4C; tratar `add` como escrita controlada. |
| `kairos-validate-story.md` | Read-only candidata | Valida documentos de story e exibe relatório; não verifica implementação nem escreve gate. | Validar em 4C. |
| `kairos-validate-squad.md` | Read-only candidata | Diagnóstico de conteúdo instanciado; lê squad/config/personas/tasks. | Validar em 4C, mesmo antes de squads operacionais. |
| `kairos-pre-push.md` | Read-only candidata com estado de sessão | Não commita, não faz bump e não executa doctor; usa Git para detectar escopo e seta `pre_push_passed` session-only. | Validar em 4C como diagnóstico; confirmar semântica session-only no Codex. |
| `kairos-architecture.md` | Suporte parcial por modo | Modo framework audita e pode atualizar `.kairos-core/docs/data-flow.md` e `.kairos-core/docs/agent-standards.md`; modo squad escreve `squads/{squad}/workflows/data-flow.md`. | Validar o modo framework como ele existe hoje. Se houver escrita, Codex deve aplicar o mesmo contrato de boundary/ownership do Kairos, não um modo reduzido. |
| `kairos-new-story.md` | Escrita controlada | Cria `docs/stories/{epic}.{N}.story.md` e atualiza epic. | Fase 4D, depois de contrato de escrita/story. |
| `kairos-new-epic.md` | Escrita controlada | Cria `docs/epics/epic-{N}-{slug}.md` e atualiza índice de stories. | Fase 4D. |
| `kairos-prd.md` | Escrita controlada | Cria/atualiza `docs/scope.md` e versiona o próprio PRD. | Fase 4D; também resolver divergência `docs/scope.md` vs `.kairos-core/docs/scope.md`. |
| `kairos-review.md` | Escrita controlada | Cria gate em `docs/qa/gates/` e pode transicionar story/epic para Done/In Progress. | Fase 4D, antes de `*push`. |
| `kairos-implement.md` | Escrita controlada / instance-only | Implementa stories `type: instance`, altera arquivos declarados nos ACs e move story para In Review. | Fase 4D após contrato de escrita e confirmação. |
| `kairos-version-bump.md` | Release/update sensível | Executa doctor, altera versão, changelog, README, frontmatters e hashes do manifesto. | Fase 4D tardia; exige validação forte de ownership/materialização. |
| `kairos-push.md` | Release/update sensível | Orquestra versionamento, transição Done, commit e `git push`; depende de `pre_push_passed`. | Fase 6 ou fim da 4D, junto da estratégia `codex-beta`/`push-dual`. |
| `kairos-update.md` | Release/update sensível | Usa rede/GitHub/tarball e atualiza arquivos owned/owned_sections. | Fase 6; precisa materializer/update multi-runtime. |
| `kairos-configure-cloud.md` | Release/update sensível / ambiente local | Cria symlink, mexe em `data/outputs`, pode usar rclone/systemd/PowerShell. | Fora do pacote read-only; tratar como operação local com confirmação forte. |
| `kairos-new-squad.md` | Squad-dependent | Cria árvore `squads/`, personas em `.claude/`, memória, rules, `CLAUDE.md` e story. | Fase 5; precisa canonicalizar personas de squad por runtime. |
| `kairos-update-squad.md` | Squad-dependent | Cria story de evolução de squad e ainda referencia `CLAUDE.md`. | Fase 5. |
| `kairos-regenerate-squad.md` | Squad-dependent | Regenera personas em `.claude/commands/...`; Claude-specific hoje. | Fase 5; transformar em materialização por runtime. |
| `kairos-export-squad.md` | Squad-dependent | Empacota squads, personas `.claude`, env patch e checksum. | Fase 5/6 após definir formato multi-runtime de squad. |
| `kairos-import-squad.md` | Squad-dependent | Extrai pacote, valida checksum, resolve conflitos, aplica env e registra imports em `CLAUDE.md`. | Fase 5/6 após formato multi-runtime de squad. |
| `kairos-workers.md` | Squad-dependent com capability Claude-only | Listagem é read-only, mas `new/enable/delete/run` escrevem `workers.yaml`; `schedule` depende de `/schedule` do Claude Code. | Listagem pode ser validada depois; scheduling real exige capability por runtime. |

Resultado da Fase 4A:

- O pacote imediato de 4C deve ser `*kb` read-only, `*validate-story`,
  `*validate-squad`, `*pre-push` diagnóstico e `*architecture` em modo
  framework.
- `*review`, `*implement`, `*new-story`, `*new-epic` e `*prd` ficam para escrita
  controlada em 4D.
- Release/update (`*version`, `*push`, `*update`, `*configure-cloud`) não devem
  ser tratados como suportados no Codex até o contrato de materialização,
  versionamento e ambiente local estar fechado.
- Tasks de squad continuam fora do escopo imediato porque ainda assumem personas
  `.claude`, `CLAUDE.md`, memória operacional e handoffs no formato atual.

### Fase 4B — Runtime-Neutralização das Tasks

Ajustar tasks que ainda assumem Claude Code como executor universal.

Regras:

- Se o comportamento é do Kairos, fica na própria task canônica.
- Se o runtime impõe formato/capability específica, a task deve declarar a
  diferença como capability de runtime, não criar uma task Codex paralela.
- Referências a Claude Code devem virar "runtime atual" ou "executor principal"
  quando forem conceituais.
- Referências a Claude Code permanecem apenas quando forem realmente
  específicas do runtime Claude.
- Tasks devem continuar stack-agnostic: sem dependência obrigatória de Node,
  Python, CLI externa ou servidor.
- Tasks com modos mistos devem ter o comportamento canônico explicitado por modo
  antes de entrarem no pacote 4C. O Codex não deve receber uma versão reduzida da
  task; se a task escreve no Claude, o Codex deve poder escrever também, desde
  que aplique o mesmo contrato de boundary/ownership.

Fase 4B aplicada:

- `kairos-validate-story.md`: removeu "Claude Code" como executor genérico e
  passou a validar agentes contra fontes canônicas ou targets materializados do
  runtime ativo.
- `kairos-validate-squad.md`: deixou de tratar `.claude/commands/...` como a
  única forma de persona; agora distingue definição canônica de agente e target
  materializado por runtime.
- `kairos-architecture.md`: deixou de tratar hooks/personas `.claude` como
  núcleo universal e passou a consultar capabilities e targets declarados pelos
  runtimes.

### Fase 4C — Validação do Pacote Expandido

Validar em conversa nova do Codex:

```text
@kairos *kb
@kairos *kb decisoes
@kairos *validate-story all
@kairos *validate-squad {squad-existente}
@kairos *pre-push
@kairos *architecture
*exit
```

Critério de aceite:

- Todas carregam fonte canônica em `.kairos-core/tasks/`.
- Nenhuma usa `.claude/` como fonte de task, rule ou persona.
- Escritas que já fazem parte da task canônica são permitidas no Codex quando
  respeitam o mesmo contrato de boundary/ownership aplicado no Claude.
- `*kb add` não é considerado suportado nesta etapa.
- `*architecture` deve manter a função canônica. Se atualizar docs no Claude,
  pode atualizar no Codex sob o mesmo contrato; se esse contrato estiver
  insuficiente, a correção deve ser na task canônica, não em um modo Codex-only.
- O envelope de persona do `@kairos` permanece ativo.
- O resultado no Codex é funcionalmente equivalente ao Claude para o escopo
  suportado.

Resultado do Teste A em checkout sem instância:

- `*kb`, `*kb decisoes`, `*validate-story all`, `*pre-push`, `*architecture` e
  `*exit` executaram sem quebrar no checkout sem `docs/stories/`, `squads/` ou
  `docs/scope.md`.
- A continuidade `@kairos` funcionou sem repetir `@kairos`.
- `*validate-story all` encerrou corretamente por ausência de stories.
- `*pre-push` detectou `scope=framework`, não exigiu gate por ausência de
  stories In Review e marcou `pre_push_passed = true` em sessão.
- `*architecture` reportou ressalvas coerentes: ausência de `docs/scope.md`,
  docs ainda parcialmente Claude-centric e ausência de ADR log.
- Falha encontrada: o Codex enviou preâmbulos visíveis antes do greeting inicial
  do `@kairos`. Correção aplicada no bootloader do Codex: em ativação `@kairos`,
  a primeira mensagem visível deve ser o greeting da persona canônica.
- Reteste da ativação inicial confirmou que o greeting foi corrigido.

Teste B não deve ser feito no branch `codex-beta` limpo. Para validar operação
real com stories/squads/scope, criar uma cópia temporária ou worktree descartável
do `codex-beta`, instanciar conteúdo mínimo apenas nessa cópia e descartar depois
do teste. O branch `codex-beta` deve permanecer com conteúdo de framework limpo,
sem fixtures de instância, para preservar merge limpo com `main` e evitar viés
instanciado no comportamento do framework.

Resultado do Teste B em worktree volátil:

- Worktree: `/tmp/kairos-codex-beta-test`, branch `codex-beta-volatile-test`.
- JSONL: `/home/filipe_leal/.codex/sessions/2026/05/18/rollout-2026-05-18T15-55-24-019e3c71-625a-7b11-b9fd-1f8dbaa199e8.jsonl`.
- `*validate-story all` validou `docs/stories/1.1.story.md` com score 100/100.
- `*validate-squad codex-test` validou a estrutura mínima com WARNs esperados:
  squad não registrado no core config, agente sem memória e materialização
  operacional de squad ainda ausente no runtime Codex.
- `*pre-push` detectou `scope=instance-only`, pulou gate de review e marcou
  `pre_push_passed = true` em sessão.
- `*architecture` reportou arquitetura consistente para fixture volátil, com
  lacunas esperadas de instância mínima.
- Finding corrigido após o teste: `*validate-squad` não deve citar
  `.claude/commands/...` como target ausente quando o runtime ativo é Codex. A
  task agora consulta `capabilities.squad_agent_materialization` no contrato do
  runtime ativo.

### Fase 4D — Escrita Controlada e Release

Depois do pacote read-only, avaliar separadamente:

- tasks que criam/alteram stories e epics;
- tasks que alteram framework ou instância;
- `*pre-push` completo;
- `*version-bump`;
- `*push`;
- `*update`;
- `*configure-cloud`.

Essas tasks só entram como suportadas no Codex quando o contrato de escrita,
ownership, versionamento e materialização estiver explícito no doctor e no
manifesto.

Primeiro corte da Fase 4D: `*new-story`.

Escopo:

- `kairos-new-story.md` é a menor escrita útil para retomar o ciclo operacional
  normal do Kairos no Codex.
- A task cria `docs/stories/{epic}.{N}.story.md` e atualiza
  `docs/epics/epic-{N}-*.md`; ambos são conteúdo de instância/projeto e não
  entram no manifesto como framework-owned.
- Stories `type: kairos-core` continuam sendo metadados user-owned que descrevem
  mudança futura no núcleo; elas não tornam o arquivo da story framework-owned.
- A task deve aplicar manifesto/boundary do runtime ativo antes de escrever e
  não assumir Claude Code como executor universal.

Aplicação inicial:

- `kairos-new-story.md` passa para `kairos-version: 5.0.0`.
- O formato gerado permanece sem frontmatter, igual ao padrão existente de
  stories/epics; ownership vem do manifesto/default-deny, não de metadado local
  no arquivo.
- A mensagem final fala em runtime Kairos ativo/executor apropriado, não em
  Claude Code como norma.
- O runtime Codex declara `*new-story` como escrita controlada em validação, sem
  liberar ainda `*new-epic`, `*prd`, `*implement`, `*push`, release ou squads.

Validação esperada:

- testar em worktree volátil, nunca no branch `codex-beta` limpo;
- criar uma story nova em epic existente;
- rodar `*validate-story {id}` e `*pre-push`;
- confirmar que apenas `docs/stories/` e `docs/epics/` foram alterados.

Resultado do teste inicial de `*new-story`:

- Worktree: `/tmp/kairos-codex-new-story-test`, branch
  `codex-beta-new-story-test`.
- JSONL: `/home/filipe_leal/.codex/sessions/2026/05/18/rollout-2026-05-18T16-40-59-019e3c9b-200d-7182-b865-fb10fea3b8e4.jsonl`.
- `@kairos *new-story "Criar uma story de teste para validar escrita controlada
  no runtime Codex"` derivou proposta, aguardou confirmação explícita e só então
  escreveu.
- Após confirmação, criou `docs/stories/1.1.story.md` e atualizou
  `docs/epics/epic-1-new-story-runtime-test.md`.
- `*validate-story all` validou a story criada com score 100/100.
- `*pre-push` detectou `scope=instance-only`, pulou gate de review e marcou
  `pre_push_passed = true` em sessão.
- A escrita ficou limitada a `docs/stories/` e `docs/epics/`.
- Caveat: o teste foi iniciado a partir do commit anterior à correção de
  frontmatter, então a proposta/AC ainda citou `kairos-owned: false`. O
  frontmatter foi removido manualmente da fixture e a fonte canônica já foi
  corrigida para manter stories/epics sem frontmatter.

## Fase 5: Squads no Codex

Squads ficam depois da paridade das tasks do `@kairos`, porque dependem de
contratos já estabilizados de task, persona, memória e handoff.

Itens ainda a detalhar:

- resolver agentes de squad no Codex;
- definir fonte canônica das personas de squad;
- mapear tasks de squad;
- carregar memória por agente operacional;
- consumir handoffs;
- adaptar `new-squad`, `update-squad`, `regenerate-squad`, `export-squad` e
  `import-squad` para runtimes;
- declarar o que é source canônico e o que é target materializado em Claude e
  Codex.

## Fase 6+: Materialização e Release Multi-Runtime

Itens posteriores:

- materializer integrado a `install`, `update`, `doctor` e `push`;
- hardening de boundary policy e drift detection;
- integração com `push-dual`/`codex-beta`;
- estratégia final para merge em `main` e cherry-pick para instância pessoal.

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
