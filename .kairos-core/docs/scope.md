---
kairos-owned: true
kairos-version: 4.0.0
---

# Kairos — Escopo e Arquitetura do Framework

**Versão:** 4.0
**Atualizado em:** 2026-05-06

---

## Visão Geral

Kairos é um framework de orquestração de agentes de IA construído sobre o Claude Code. O nome vem do grego καιρός — o tempo certo, o momento oportuno. Cada agente age quando faz sentido, não em qualquer momento.

O framework organiza trabalho em **squads**: grupos de agentes especializados que operam um domínio. Cada squad define seu próprio pipeline, integrações externas e agentes — o Kairos fornece a infraestrutura comum: governança, memória persistente, handoffs, workers agendados e ferramentas para criar e evoluir squads ao longo do tempo.

**Kairos não é uma aplicação** — é um framework de orquestração. Cada instância define seus próprios squads e objetivos.

**Kairos é stack-agnóstico.** O framework não impõe linguagem, runtime ou SDK. Scripts de agentes, ferramentas e integrações são definidos pela instância. Ver `CONTRIBUTING.md` para a posição stack-agnóstica completa.

---

## Propósito

O Kairos existe para resolver o problema de contexto e coordenação em sistemas multi-agente:

- **Coordenação:** agentes especializados colaboram em pipelines via handoffs estruturados
- **Memória persistente:** cada agente acumula padrões aprendidos entre sessões (MEMORY.md)
- **Governança:** um modelo claro de autoridade define quem pode fazer o quê
- **Evolução controlada:** versionamento semântico e stories rastreiam a evolução do framework
- **Fronteira framework/usuário:** o manifesto define exatamente o que é framework e o que é conteúdo do usuário

---

## Arquitetura de Agentes

### Dois Tipos de Agentes

```
@kairos (governança do framework)
      ↓ autoridade sobre
squads/* (trabalho operacional — definido pelo usuário por instância)
      ↓ implementado por
Claude Code na conversa principal (constrói e mantém o Kairos)
```

**@kairos — Governança:**
- Versiona o framework, cria squads e epics, gerencia stories
- Emite gates de review (PASS/RESSALVA/BLOCK)
- Controle exclusivo de git push
- Implementa stories `type: instance` via `*implement`
- Gerencia workers agendados via `*workers`
- Valida squads e stories via `*validate-squad` e `*validate-story`
- Inspeciona saúde do framework via `*doctor`
- Atualiza o framework via `*update` (sem necessidade de Git)
- Configura sync de outputs para nuvem via `*configure-cloud`
- Exporta e importa squads via `*export-squad` / `*import-squad`
- Modo autônomo de sessão via `*yolo` (afeta apenas stories `type: instance`; encadeia `*implement` automaticamente; pipeline de release separado)

**Agentes de squad — Operacionais:**
- Criados via `@kairos *new-squad`
- Especializados por domínio (análise, pontuação, geração, classificação, etc.)
- Operam dentro da autoridade definida em `squads/{squad}/rules/agent-authority.md`
- Memória persistente em `.kairos-core/agents/{id}/MEMORY.md`

### Modelo de Dois Executores

Stories do Kairos têm dois tipos com executores distintos:

| Tipo de Story | Executor | Como |
|---------------|----------|------|
| `type: kairos-core` | Claude Code plain (sem persona ativa) | Implementação direta na conversa principal; @kairos governa e revisa |
| `type: instance` | @kairos via `*implement` | @kairos permanece ativo durante toda a implementação |

`*implement all` executa todas as stories `type: instance` pendentes em sequência.

### Protocolo de Handoff

Ao completar uma fase, cada agente gera um handoff compacto (< 500 tokens) em `.kairos-core/runtime/handoffs/`. O próximo agente detecta o handoff na ativação e sugere o próximo comando automaticamente.

```yaml
handoff:
  from_agent: "{agente que completou}"
  to_agent: "{próximo agente}"
  last_command: "{último comando}"
  context: { output_file, totais, insight_principal }
  next_action: "{o que o agente entrante deve fazer}"
```

### Workers

Agentes podem ser agendados como workers recorrentes via `/schedule` do Claude Code. O registro de workers ativos vive em `.kairos-core/data/workers.yaml`. Gerenciados por `@kairos *workers`.

---

## Modelo de Governança

### Camadas de Imutabilidade

```
L1 — Fundação    (não modifica sem bump MAJOR + justificativa)
L2 — Controlado  (apenas @kairos, exige story MINOR/MAJOR)
L3 — Gerenciado  (governança normal, pode ser PATCH)
L4 — Volátil     (efêmero, gitignored, sem versionamento)
```

A classificação de cada arquivo é declarada em `.kairos-core/manifest.yaml`. Path não determina camada — o manifesto sim.

### Fronteira Framework/Usuário

O manifesto é autoritativo. Regra default-deny:

> Se um arquivo **não** está no manifesto → é do usuário → não pode ser tocado por updates do framework.

Arquivos mistos usam blocos `<!-- KAIROS-MANAGED-START -->` (markdown) ou `owned_keys` (YAML/JSON) para demarcar o que é framework.

### Versionamento Semântico

```
PATCH  — correção de bugs, ajuste de instrução, documentação
MINOR  — novo comando, nova task, nova rule, nova capacidade ou expansão significativa de capacidade (exige story)
MAJOR  — novo escopo, breaking change, mudança de arquitetura, modificações em arquivos L1 (exige story)
```

Autoridade exclusiva de versionamento: `@kairos *version` (standalone ou embutido no `*push` via modo dev).

### CI/CD

O workflow `validate-manifest` (`.github/workflows/validate-manifest.yml`) valida a integridade do manifesto em PRs para `origin/main`, bloqueando contribuições que violem a fronteira framework/usuário.

O workflow `version-guard` (`.github/workflows/version-guard.yml`) é o gate canônico de versionamento: verifica bump (Check A), frontmatter `kairos-version` (Check B), sincronização do CHANGELOG (Check C) e gate de review para stories `type: kairos-core` (Check D). Pula todos os checks se nenhum arquivo de framework constar no PR.

---

## Comandos do @kairos

| Comando | Descrição | Depende de Git? |
|---------|-----------|------|
| `*help` | Lista comandos disponíveis | — |
| `*status` | Versão atual, squads ativos, stories em andamento | — |
| `*new-story` | Cria nova story de desenvolvimento | — |
| `*new-epic` | Cria novo epic | — |
| `*new-squad` | Scaffolda novo squad completo | — |
| `*update-squad` | Atualiza estrutura de squad existente | — |
| `*validate-squad` | Valida integridade de um squad | — |
| `*validate-story` | Valida se uma story está bem formada | — |
| `*implement` | Implementa story `type: instance`; oferece marcar Done diretamente ao concluir | — |
| `*implement all` | Implementa todas as stories `type: instance` pendentes | — |
| `*review` | Emite gate de qualidade (PASS/RESSALVA/BLOCK); para `type: instance` oferece marcar Done sem Git | — |
| `*update` | Atualiza o framework Kairos (sem Git) | — |
| `*configure-cloud` | Configura o sync de outputs via symlink para nuvem | — |
| `*export-squad` | Empacota squad em arquivo distribuível | — |
| `*import-squad` | Instala squad de arquivo na instância | — |
| `*architecture` | Gera ou atualiza documentação de arquitetura | — |
| `*prd` | Gerencia o PRD do framework | — |
| `*workers` | Gerencia workers agendados | — |
| `*kb` | Adiciona ou consulta o Knowledge Base do framework | — |
| `*doctor` | Inspeciona saúde e integridade do framework | — |
| `*yolo on/off` | Liga/desliga modo autônomo de sessão (apenas `type: instance`; encadeia `*implement`; pipeline de release separado) | — |
| `*version` | Bump de versão semântica (com *doctor como Passo 1) | **Git** |
| `*pre-push` | Valida gate de review (type:kairos-core) e spot check | **Git** |
| `*push` | Orquestrador de release: doctor, drift, modo dev e transição Done (type:kairos-core); commit e push. Pula transição Done para stories `type: instance` já marcadas via `*implement`/`*review` | **Git** |

> Comandos **Git** são exclusivos para usuários que mantêm repositório Git (contribuidores ou quem faz push para repo privado).

---

## Estrutura de Diretórios

```
install.sh / install.ps1     # Instaladores interativos (L2) — Linux/Mac/WSL e Windows
uninstall.sh / uninstall.ps1 # Desinstaladores (L2) — preservam conteúdo user-owned

.github/
  workflows/       # CI: validate-manifest e outros
  ISSUE_TEMPLATE/  # Templates de PR/Issue
  CODEOWNERS       # Ownership de código para revisão

.claude/
  commands/kairos/agents/  # Personas completas (YAML-in-Markdown)
  hooks/                   # PreCompact, PreToolUse e SessionStart hooks, que o Kairos usa
  rules/                   # Rules cross-cutting (lifecycle, authority, handoff, layers, output-naming)

.kairos-core/
  agents/       # Memória persistente por agente (MEMORY.md)
  tasks/        # Tasks de governança (kairos-*) e operacionais (squad-*)
  data/         # kairos-kb.md, workers.yaml, dados de configuração
  docs/         # Documentação do framework: scope.md, data-flow.md, agent-standards.md, install.md
  templates/    # Scaffolds para squads e agentes
  constitution.md  # Princípios não-negociáveis (L1)
  manifest.yaml    # Fonte autoritativa de ownership (L1)
  runtime/      # Handoffs, logs e cloud-sync.json (L4, gitignored)

docs/
  stories/     # Stories de desenvolvimento do framework
  epics/       # Planejamento de alto nível
  qa/gates/    # Gates de review emitidos por *review (histórico de auditoria)

squads/
  {squad}/
    squad.yaml          # Manifesto do squad (inclui external_dependencies)
    agents/             # Definições leves dos agentes
    tasks/              # Tasks operacionais do squad
    workflows/          # Pipeline documentado
    rules/              # Regras específicas do squad (lifecycle, authority, memory-imports)

data/outputs/  # Outputs dos agentes — pode ser symlink para pasta de nuvem via *configure-cloud
               # Formato de nome: {agent}_{tipo}-{INSTANCE}-YYYY-MM-DD.{ext}
               # {INSTANCE} vem de KAIROS_INSTANCE_NAME (.env)
```

> `src/` não faz parte do framework. É conteúdo do usuário: scripts de agentes, ferramentas e utilitários são definidos pela instância em linguagem e stack de sua escolha. Ver constituição VI.25.

---

## Princípios de Design

1. **IDS — Reutilizar > Adaptar > Criar:** antes de criar um novo artefato, verificar se algo existente cobre o caso
2. **Clareza sobre elegância:** código simples e direto; sem abstrações prematuras
3. **Governança explícita:** toda mudança estrutural gera bump de versão + entrada no CHANGELOG
4. **Fronteira clara:** framework e conteúdo do usuário são separados pelo manifesto — sem ambiguidade
5. **Handoffs compactos:** a troca de contexto entre agentes usa artefatos < 500 tokens
6. **Stack-agnóstico:** o framework não impõe linguagem, runtime ou SDK à instância

---

## Change Log

| Versão | Data | Mudança |
|--------|------|---------|
| 1.0 | 2026-04-16 | Criação inicial — escopo e arquitetura do framework |
| 2.0 | 2026-04-26 | Reescrita para v3.9.x: seção Stack de Referência removida; src/ removido do diagrama; .github/, docs/qa/gates/, docs/epics/ adicionados; comandos do @kairos atualizados; modelo de dois executores; CI/CD; workers; modo yolo |
| 3.0 | 2026-05-06 | Epic 7: instaladores, *update, *configure-cloud, *export-squad/*import-squad, KAIROS_INSTANCE_NAME, output naming; coluna Git na tabela de comandos; install.md; cloud-sync.json; SessionStart hook; external_dependencies em squad.yaml |
| 4.0 | 2026-05-08 | Remoção de referências instanciadas a stories; ajuste do versionamento semântico |
| 5.0 | 2026-05-11 | Story 3.31: refatoração *pre-push/*push/*version; CI version-guard; separação de responsabilidades |
