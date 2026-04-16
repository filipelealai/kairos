---
kairos-owned: true
kairos-version: 2.0.0
task: Kairos Help
responsavel: "@kairos"
responsavel_type: agent
atomic_layer: meta
elicit: false
Entrada: |
  - topic: tópico específico (opcional)
    Valores: "flows" | "commands" | "stories" | "versioning" | "push" | "squads" | "review"
    Se omitido: exibe o help completo
Saida: |
  - help exibido em tela — sem arquivos criados
---

# *help — Central de Ajuda do @kairos

---

## Pré-passo — Detectar argumento

Se `*help {topic}` foi chamado com tópico → ir direto para a seção correspondente.
Se `*help` sem argumento → exibir help completo (todas as seções abaixo).

---

## Exibição

### Cabeçalho

```
🌀 @kairos — Orquestrador e Governador do Framework Kairos
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Versão: {ler de .kairos-core/core-config.yaml}
```

---

### Seção 1 — O que é o @kairos

```
O QUE É O @kairos
─────────────────
@kairos é o agente de governança do Kairos — ele não faz o trabalho operacional
(isso são os squads: @campaign-analyst, @email-writer, etc.), mas governa como
o próprio Kairos evolui.

Responsabilidades exclusivas:
  • Versionar o sistema (nenhum outro agente versiona)
  • Criar e validar stories de desenvolvimento
  • Revisar implementações com gates PASS/RESSALVA/BLOCK
  • Criar novos squads e epics
  • Fazer git push (nenhum outro agente pode fazer isso)
  • Manter o PRD (docs/scope.md) e auditar a arquitetura

Quem executa: Claude Code na conversa principal.
Quem governa: @kairos.
```

---

### Seção 2 — Referência de Comandos

```
COMANDOS
─────────────────────────────────────────────────────────────

INSPEÇÃO
  *status               Estado do sistema: versão, squads ativos, stories abertas,
                        último gate, últimas entradas do CHANGELOG.
                        → Bom ponto de partida ao retomar uma sessão.

  *roadmap              Lista stories por status (Draft / In Progress / In Review).
                        → "O que ainda precisa ser feito?"

QUALIDADE E VALIDAÇÃO
  *validate-story {id}  Valida o DOCUMENTO da story: formato, campos obrigatórios,
                        qualidade dos ACs (específicos? testáveis?), consistência de ID.
                        Resultado: VÁLIDA / RESSALVA / INVÁLIDA.
                        → Rodar antes de entregar a story ao executor.

  *review [{id}]        Valida a IMPLEMENTAÇÃO: ACs implementados, arquivos existem,
                        governança (versão, changelog). Lê o Execution Log do executor.
                        Resultado: PASS / RESSALVA / BLOCK.
                        → Se omitir {id}: detecta stories com Status "In Review".
                        → Gate salvo em docs/qa/gates/.

DESENVOLVIMENTO
  *new-epic             Cria um novo epic via perguntas guiadas. Elicita tema, objetivo,
                        critérios de conclusão, status inicial e stories candidatas.
                        Ao final: handoff condicional para *new-story.
                        → Quando há um novo conjunto de trabalho a planejar.

  *new-story            Cria uma nova story de desenvolvimento do Kairos via elicitação
                        guiada: lista epics disponíveis, gera ID automático, elicita
                        título, o que fazer, ACs (≥3), fora de escopo, complexidade,
                        dependências.
                        → EXCLUSIVO para desenvolvimento do Kairos. Não para outputs
                           operacionais (emails gerados, leads pontuados).

  *new-squad            Cria um novo squad via elicitação guiada (4 blocos: propósito,
                        agentes, dados, pipeline). Scaffolda toda a estrutura:
                        squad.yaml, agents/, tasks/ (stubs), workflows/, MEMORY.md.
                        Ao final: handoff para *new-story de implementação.

VERSIONAMENTO E PUSH
  *version {tipo} "{desc}"
                        Bump de versão semântica avulso. Tipos: patch | minor | major.
                        Valida que existe story justificando MINOR e MAJOR.
                        Atualiza core-config.yaml e CHANGELOG.md.
                        → Uso avulso (ex: patch rápido sem story associada).
                          No ciclo normal, o bump ocorre dentro do *pre-push.

  *pre-push             Pré-voo completo: verifica gate de review (MINOR/MAJOR), executa
                        bump de versão interativo (pergunta tipo e aplica), realiza commit
                        dos changes relevantes, spot check de referências, consistência
                        final (core-config vs CHANGELOG). Seta pre_push_passed=true na sessão.
                        → Obrigatório antes de *push. Substitui *version no ciclo normal.

  *push                 git push ao remoto. EXCLUSIVO do @kairos.
                        RECUSA se *pre-push não passou na sessão atual.

DOCUMENTAÇÃO
  *prd                  Cria ou atualiza docs/scope.md (o PRD do Kairos).
                        Detecta se já existe e adapta o modo (create vs update).
                        Elicita escopo, arquitetura, objetivos, restrições, stack.

  *architecture         Auditoria de consistência: stack (package.json vs docs),
                        agentes (core-config vs arquivos), tasks (commands vs arquivos),
                        data-flow (campos do webhook vs código TS).
                        Dono de .kairos-core/docs/data-flow.md — propõe atualizações
                        se encontrar divergências.

META
  *help [{topic}]       Esta ajuda. Topics: flows | commands | stories |
                        versioning | push | squads | review
  *guide                Guia completo com modelo de governança e diagramas.
  *exit                 Sair do modo @kairos.
```

---

### Seção 3 — Fluxos Comuns

```
FLUXOS COMUNS
─────────────────────────────────────────────────────────────

① Verificar o estado do sistema ao iniciar
  *status
  *roadmap           ← se quiser ver só o que está pendente

② Planejar novo trabalho
  *new-epic          ← novo conjunto de trabalho
   └→ *new-story     ← história específica (handoff automático do *new-epic,
                        ou chamar diretamente)
   └→ *validate-story {id}  ← checar se a story está bem escrita antes de executar

③ Ciclo de desenvolvimento (do planejamento ao push)
  *new-story                   ← @kairos elicita e cria a story (sem argumento)
  (Claude Code implementa)     ← executor move Draft → In Progress → In Review
                                  e adiciona Execution Log na story
  *review                      ← auto-detecta "In Review"; gate PASS/RESSALVA/BLOCK
  *pre-push                    ← pré-voo: versão + commit + verificações finais
  *push                        ← push ao remoto

  Nota: *version disponível para uso avulso (ex: patch rápido sem story)

④ Novo squad
  *new-squad                   ← elicitação guiada (4 blocos)
   └→ *new-story               (handoff automático — @kairos elicita o conteúdo)
  (Claude Code implementa personas + scripts TS)
  *review {story-id}
  *pre-push                    ← detecta bump pendente e pergunta o tipo
  *push

⑤ Revisar implementação que o executor acabou de entregar
  *review                      ← sem argumento: detecta In Review automaticamente
  → Se PASS/RESSALVA:
      *pre-push                ← inclui versionamento interativo + commit
      *push
  → Se BLOCK:
      (Claude Code corrige os issues listados)
      *review {id}             ← rodar novamente

⑥ Manter a documentação em dia
  *prd                         ← quando o escopo muda (novo squad, novas restrições)
  *architecture                ← quando suspeitar que docs e código divergiram
                                  (ex: após várias mudanças rápidas)
```

---

### Seção 4 — Quando NÃO usar @kairos

```
QUANDO NÃO USAR @kairos
─────────────────────────────────────────────────────────────
Use os agentes de squad para trabalho operacional.
Cada squad define seus próprios agentes e comandos — ver squads/{squad}/README.md.

@kairos não faz trabalho de negócio — só governa como o Kairos evolui.

Regra rápida:
  "Estou tentando executar trabalho operacional de um squad?" → squad
  "Estou tentando evoluir o próprio Kairos?"                 → @kairos
```

---

### Seção 5 — Regras que você precisa saber

```
REGRAS IMPORTANTES
─────────────────────────────────────────────────────────────
• *push sem *pre-push → recusado. Sempre.

• MINOR e MAJOR exigem story. *version minor sem story → BLOCK.
  PATCH não exige story (correções, ajustes de instrução).

• Stories em docs/stories/ = desenvolvimento do KAIROS.
  Outputs operacionais (emails, relatórios, scores) vão para data/.

• *review sem argumento detecta automaticamente stories com
  Status: In Review. Se houver mais de uma, pede para escolher.

• O executor (Claude Code) DEVE adicionar ## Execution Log
  na story ao mover para "In Review". *review lê esse log
  na avaliação — story sem log gera penalidade no quality_score.

• *validate-story valida o DOCUMENTO; *review valida a IMPLEMENTAÇÃO.
  São duas coisas diferentes e complementares.

• docs/scope.md e .kairos-core/docs/ são gerenciados por @kairos.
  Nenhum agente de squad modifica esses arquivos.
```

---

### Seção 6 — Referência Rápida (cheat sheet)

```
CHEAT SHEET
─────────────────────────────────────────────────────────────
Ver estado          *status | *roadmap
Novo planejamento   *new-epic → *new-story → *validate-story {id}
Revisar entrega     *review [{id}]
Publicar            *pre-push → *push   (*version disponível para uso avulso)
Novo squad          *new-squad
Documentar          *prd | *architecture
Ajuda               *help [{topic}] | *guide
Sair                *exit

Topics de *help:
  flows       Fluxos comuns detalhados
  commands    Referência completa de comandos
  stories     Como stories funcionam (estados, executor, Execution Log)
  versioning  Regras de versionamento semântico
  push        Fluxo de push e guards
  squads      O que são squads e como criar
  review      Diferença entre *validate-story e *review, gates
```

---

## Help por tópico

### `*help flows`
Exibir apenas a Seção 3 (Fluxos Comuns).

### `*help commands`
Exibir apenas a Seção 2 (Referência de Comandos).

### `*help stories`
```
STORIES — Como funcionam
─────────────────────────────────────────────────────────────
Stories em docs/stories/ rastreiam o desenvolvimento do KAIROS.
NÃO são stories: emails gerados, leads pontuados, relatórios de campanha.

Estados:
  Draft       → criada por @kairos, aguardando executor
  In Progress → executor iniciou o trabalho
  In Review   → executor terminou + adicionou Execution Log
  Done        → *pre-push confirmou gate e executou commit

Transições:
  Draft → In Progress      executor ao começar
  In Progress → In Review  executor ao terminar (+ Execution Log obrigatório)
  In Review → Done         *pre-push (após gate PASS/RESSALVA + commit)
  In Review → In Progress  @kairos após *review BLOCK (executor corrige)

Execution Log (obrigatório ao mover para In Review):
  ## Execution Log
  - O que foi feito (itens concretos)
  - Decisões tomadas (alternativas descartadas e por quê)
  - Arquivos criados/modificados (path + o que mudou)
  - Pendências / questões abertas
  - Notas para @kairos

Nomenclatura: {epic}.{N}.story.md  → ex: 3.1.story.md
Criação: exclusivamente via *new-story
```

### `*help versioning`
```
VERSIONAMENTO SEMÂNTICO
─────────────────────────────────────────────────────────────
Formato: MAJOR.MINOR.PATCH  (ex: 1.2.0)

PATCH — não exige story
  Correção de bug, ajuste de instrução, atualização de MEMORY.md
  ex: *version patch "Corrigir typo na task kairos-review"

MINOR — exige story existente (Draft ou superior)
  Novo agente, nova task, nova rule, nova capacidade
  ex: *version minor "Novo squad lead-followup"

MAJOR — exige story existente (Draft ou superior)
  Novo squad/escopo, breaking change em agente existente
  ex: *version major "Breaking change no protocolo de handoff"

Arquivos atualizados:
  .kairos-core/core-config.yaml  → campo version
  CHANGELOG.md                   → nova entrada no topo

Autoridade: exclusiva do @kairos. Nenhum outro agente versiona.
```

### `*help push`
```
PUSH — Fluxo e Guards
─────────────────────────────────────────────────────────────
*push é EXCLUSIVO do @kairos. Nenhum outro agente faz push.

Fluxo obrigatório:
  *pre-push → (deve retornar PASS) → *push

*pre-push executa:
  1. Gate de review — MINOR/MAJOR têm gate PASS ou RESSALVA? Se não → BLOCK
  2. Versionamento — detecta bump pendente; pergunta tipo e executa se necessário
  3. Commit — sugere mensagem e executa commit dos changes relevantes
  4. Referências quebradas — spot check em arquivos .md modificados
  5. Consistência final — core-config.yaml vs CHANGELOG.md mesma versão?

Se *pre-push retornar BLOCK:
  → Resolver os issues listados
  → Rodar *pre-push novamente
  → Só então *push

Se tentar *push sem *pre-push PASS na sessão:
  → @kairos recusa e instrui a rodar *pre-push primeiro.
  (Isso inclui se o *pre-push foi em uma sessão anterior — o guard é por sessão.)
```

### `*help squads`
```
SQUADS — O que são e como criar
─────────────────────────────────────────────────────────────
Squad = grupo de agentes especializados para um fluxo de trabalho específico.

Squads ativos: listados em .kairos-core/core-config.yaml (campo agents.squads)
  Cada squad define seu próprio pipeline em squads/{squad}/workflows/

Criar novo squad:
  *new-squad
  → Elicitação em 4 blocos: propósito, agentes, dados, pipeline
  → Confirmação antes de criar qualquer arquivo
  → Scaffolda: squad.yaml, README, agents/, tasks/ (stubs), workflows/, MEMORY.md
  → Handoff para *new-story de implementação

Estrutura de um squad:
  squads/{nome}/
    squad.yaml           manifesto (agentes, pipeline, dados, dependências)
    README.md            como usar
    agents/{id}.md       definição leve (aponta para persona completa)
    tasks/{task}.md      tasks específicas do squad
    workflows/           pipeline documentado

Personas completas ficam em:
  .claude/commands/kairos/agents/{id}.md

Scripts de computação ficam em:
  src/agents/{id}.ts
```

### `*help review`
```
REVISÃO — *validate-story vs *review
─────────────────────────────────────────────────────────────
São dois comandos diferentes para dois momentos diferentes:

*validate-story {id}  — antes de executar
  Valida o DOCUMENTO da story:
  • Campos obrigatórios (Epic, Status, Complexidade, Data)
  • Seções obrigatórias (Objetivo, ACs, Change Log)
  • Qualidade dos ACs (específicos? testáveis? ≥3?)
  • Consistência de ID e nomenclatura
  • Referências cruzadas (epic file, dependências)
  Resultado: VÁLIDA / RESSALVA / INVÁLIDA

*review [{id}]  — após executor entregar (Status: In Review)
  Valida a IMPLEMENTAÇÃO:
  • Cada AC foi implementado? (evidência no repo)
  • Arquivos declarados existem?
  • Versão/changelog atualizados (MINOR/MAJOR)?
  • Execution Log presente e informativo?
  Resultado: PASS / RESSALVA / BLOCK
  Gate salvo em: docs/qa/gates/{id}-{data}.yaml

  PASS     → implementação completa, tudo verificado
  RESSALVA → aceita, mas com observações não bloqueantes
             (conta como PASS para *pre-push)
  BLOCK    → issues críticos; executor precisa corrigir

Auto-detect: *review sem argumento busca Status "In Review"
```
