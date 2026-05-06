# Kairos

> *καιρός — o tempo certo, o momento oportuno.*

Kairos é um framework de orquestração de agentes de IA construído sobre o Claude Code. Organiza o trabalho em **squads** — grupos de agentes especializados que executam domínios específicos — e fornece a infraestrutura de governança, memória, handoffs, workers agendados e ferramentas de desenvolvimento para criar, evoluir e operar esses squads ao longo do tempo.

**Versão atual:** `3.14.0` — ver [CHANGELOG.md](CHANGELOG.md)

---

## Como funciona

Squads são criados com `@kairos *new-squad`. Cada squad tem seus próprios agentes, integrações externas, workers e pipeline. O framework fornece a infraestrutura comum.

**Exemplo** — um squad integrando com sistema externo e fonte de dados:

```
sistema externo (operacional)  ↔  Kairos/squad  ↔  fonte de dados
```

O squad define quais sistemas externos seus agentes têm autoridade para usar. O Kairos não age diretamente sobre sistemas externos — delega para os sistemas definidos pelo squad (ver [constitution.md](.kairos-core/constitution.md)).

**Exemplo ilustrativo** — um squad de prospecção B2B integrando com n8n e Google Sheets:

```
n8n (operacional)  ↔  Kairos/squad  ↔  Google Sheets (dados)
```

---

## Stack

O Kairos é stack-agnóstico. Há duas camadas distintas:

**Framework** — o que o Kairos é:

| Componente | Tecnologia |
|------------|-----------|
| Personas de agentes, documentação e memória | Markdown (YAML frontmatter) |
| Configuração | YAML |
| Hooks | CJS (`.claude/hooks/`) |

Sem dependência de runtime de linguagem — o Kairos roda onde o Claude Code roda.

**Instância** — o que o usuário usa:

A instância é a combinação de squads, scripts e integrações que o usuário configura em seu ambiente local ou seu projeto. O Kairos interage com e governa essa stack, mas não a impõe. Exemplos comuns: Node.js + TypeScript, Python, scripts shell, n8n, Supabase — a escolha é do usuário.

O conteúdo instanciado é sempre intocado por atualizações do framework Kairos, e é responsabilidade do usuário ter um backup seguro desses arquivos e dados, uma vez que só existem no projeto/repositório do usuário.

Exemplos comuns de conteúdo instanciado incluem:

- Epics e stories
- Gates de QA das stories
- Squads, workers, agentes e suas memórias e comandos
- Outputs em `data/`
- Skills do Claude Code (`.claude/skills/` e `skills-lock.json`)
- Configurações de MCP (`.mcp.json`)
- Scripts, ferramentas etc. em `src/`
- Conteúdo fora das seções `<KAIROS-MANAGED>` em CLAUDE.md
- .env do projeto
- Arquivos específicos de stack (`package.json`, `package-lock.json`, `tsconfig.json`, `Pipfile`, `Pipfile.lock`, `tailwind.config.js`, `vite.config.ts` etc. )

---

## Pré-requisitos

- Claude CLI ou Claude Desktop App instalado
- Um software de IDE, como VSCode, instalado (recomendado, opcional)
- Git instalado (recomendado, opcional)
- Integrações externas conforme os squads que você configurar — stack, dependências e chaves de API são responsabilidade do usuário (ver [.env.example](.env.example) da sua instância quando aplicável)

---

## Instalação

```bash
git clone <repo>
cd kairos
cp .env.example .env
```

Edite `.env` com as variáveis relevantes para seus squads (ver [.env.example](.env.example) para a lista).

---

## Como usar agentes

Agentes são ativados pelo nome no Claude Code:

```
@nome-do-agente *comando
```

**Exemplos:**

```
@kairos *status            # estado geral do sistema
@kairos *new-squad         # criar novo squad
@{agente} *{comando}       # executar qualquer comando de agente do squad
```

Outputs são salvos em `data/outputs/{squad}/{tipo}/`

**Exemplo:**

```
data/outputs/{squad}/
  reports/   # relatórios e análises
  emails/    # outputs prontos para envio
  {tipo}/    # outros tipos de output que o agente gerar
```

---

## Pipeline de squad (exemplo)

Cada squad define seu próprio pipeline. Exemplo genérico de um pipeline multi-agente:

```
@{agente-1} *{comando}
        ↓  gera: {agente-1}_{output}-{INSTANCE}-YYYY-MM-DD.{ext}
@{agente-2} *{comando}
        ↓  gera: {agente-2}_{output}-{INSTANCE}-YYYY-MM-DD.{ext}
@{agente-3} *{comando}
        ↓  gera: {agente-3}_{output}-{INSTANCE}-YYYY-MM-DD.{ext}
(sistema externo de disparo lê os outputs e executa)
```

**Exemplo ilustrativo** — squad `cold-prospecting`:

```
@campaign-analyst *analyze
        ↓  gera: campaign-analyst_campaign-joão-YYYY-MM-DD.md
@lead-scorer *score
        ↓  gera: lead-scorer_scored-leads-joão-YYYY-MM-DD.csv
@niche-classifier *classify
        ↓  gera: niche-classifier_niche-map-joão-YYYY-MM-DD.json
@email-writer *write 20
        ↓  gera: email-writer_emails-joão-YYYY-MM-DD.json
(sistema externo de disparo lê os outputs e executa)
```

Execução parcial é permitida — cada agente pode ser rodado individualmente.

---

## Agentes como personas no Claude Code

O Kairos usa o Claude Code como ambiente de execução. Cada agente é uma **persona ativável** com `@nome`:

**Framework (sempre presente):**
```
@kairos   🌀  — governança do framework
```

**Squads (definidos pela instância do usuário):**
```
@{agente-a}   — responsabilidade principal do agente A
@{agente-b}   — responsabilidade principal do agente B
@{agente-c}   — responsabilidade principal do agente C
```

Exemplo ilustrativo:

```
@campaign-analyst   Clio 📊  — análise de campanha
@lead-scorer        Lex  🎯  — pontuação de leads
@niche-classifier   Nix  🗂️  — classificação de nichos
@email-writer       Eva  ✉️  — geração de e-mails
```

Cada squad define seus próprios agentes com `@kairos *new-squad`.

Para ativar, basta mencionar o agente pelo nome. Cada agente tem comandos com prefixo `*`:

```
@kairos *status            # estado geral do sistema
@kairos *new-squad         # criar novo squad
```

---

## @kairos — Governança do framework

`@kairos` é o agente que governa como o próprio Kairos evolui. Não faz trabalho operacional — planeja, valida e versiona o sistema.

Comandos principais:

| Comando | O que faz |
|---------|-----------|
| `*status` | Versão, squads, stories abertas, último gate |
| `*roadmap` | O que está em Draft / In Progress / In Review |
| `*new-epic` | Cria novo epic via elicitação guiada |
| `*new-story` | Cria nova story de desenvolvimento |
| `*new-squad` | Scaffolda novo squad completo |
| `*validate-story {id}` | Valida formato e qualidade da story |
| `*validate-squad {squad}` | Valida formato e consistência geral de um squad |
| `*update-squad {squad}` | Atualiza um squad existente |
| `*regenerate-squad {squad}` | Regenera personas desatualizadas a partir dos `.yaml` de agentes (SHA drift) |
| `*implement {id}` | Implementa story de desenvolvimento |
| `*review {id}` | Valida implementação — gate PASS / RESSALVA / BLOCK |
| `*version patch\|minor\|major "desc"` | Bump de versão semântica |
| `*pre-push` | Verificações antes do push ou PR |
| `*push` | git push — exclusivo, requer *pre-push PASS |
| `*prd` | Cria ou atualiza `docs/scope.md` |
| `*architecture [{squad}]` | Audita consistência entre docs e código — framework geral (sem argumento) ou squad específico |
| `*help [{topic}]` | Ajuda completa com fluxos e exemplos |

---

## Estrutura do repositório

```
kairos/
├── src/
│   └── agents/          # Scripts e ferramentas utilizados por agentes e squads (user-owned)
│
├── data/
│   └── outputs/         # Outputs dos agentes
│       └── {squad}/
│           └── {tipo}/  # Relatórios, outputs e dados gerados por agentes, divididos por tipo e agente
│
├── squads/
│   └── {squad}/
│       ├── squad.yaml           # Manifesto do squad
│       ├── README.md
│       ├── agents/              # Definições leves dos agentes
│       ├── tasks/               # Tasks específicas do squad
│       └── workflows/           # Pipeline documentado
│
├── docs/
│   ├── epics/                   # Epic files
│   ├── stories/                 # Stories de desenvolvimento do Kairos
│   └── qa/
│       └── gates/               # Gates de review (PASS/RESSALVA/BLOCK)
│
├── .github/                     # Templates de PR/Issue, CODEOWNERS e CI workflows
│
├── .claude/
│   ├── commands/kairos/agents/  # Personas completas dos agentes (YAML-in-Markdown)
│   ├── rules/                   # Regras cross-cutting (lifecycle, handoff, authority...)
│   └── hooks/                   # Hooks do Claude Code (PreCompact, PreToolUse)
│
├── .kairos-core/
│   ├── constitution.md          # Princípios não-negociáveis do framework (L1)
│   ├── core-config.yaml         # Configuração central e versão semântica
│   ├── manifest.yaml            # Ownership: o que é framework vs. usuário
│   ├── agents/                  # MEMORY.md persistente por agente
│   ├── tasks/                   # Definições de tasks executáveis
│   ├── data/                    # KB, workers registry e dados de configuração
│   ├── docs/                    # Documentação de arquitetura e escopo do Kairos
│   ├── runtime/                 # Handoffs e logs de execução (conteúdo gitignored)
│   └── templates/               # Templates do Kairos para criação de agentes, squads, stories etc.
│
├── CHANGELOG.md
├── CLAUDE.md                    # Instruções para o Claude Code, contendo seções gerenciadas pelo Kairos
└── .env.example
```

---

## Desenvolvimento do Kairos (para contribuidores)

O Kairos usa um modelo de governança próprio para se auto-documentar e evoluir:

**Ciclo típico de auto-desenvolvimento:**
```
@kairos *new-epic          # planejar conjunto de trabalho
@kairos *new-story [{id}]  # detalhar uma unidade de trabalho
@kairos *validate-story {id} # checar qualidade da story antes de executar
@kairos *exit              # sai da persona do Kairos, que não pode implementar a si mesmo
Claude Code, sem persona   # executor move Draft → In Progress → In Review
                           # e adiciona Execution Log na story
@kairos *review {id}       # valida implementação — gate PASS/RESSALVA/BLOCK
@kairos *version patch\|minor\|major "desc" # versiona as mudanças feitas no framework, para PR (depende de Git)
@kairos *pre-push          # verificações finais (depende de Git)
@kairos *push              # push ao remoto privado (exclusivo do @kairos, depende de Git)
ou PR                      # contribuições no repositório público do Kairos
```
Para informações detalhadas de como abrir um PR e contribuir no repositório público do Kairos, veja [CONTRIBUTING.md](CONTRIBUTING.md).

**Versionamento semântico:**
- `PATCH` — correção, bug fixes, ajuste de instrução, documentação (não exige story)
- `MINOR` — novo comando, nova task, nova rule, nova capacidade, modificações em arquivos L2 (exige story)
- `MAJOR` — novo escopo, breaking change, mudança de arquitetura, modificações em arquivos L1 (exige story)

**Stories** em `docs/stories/` rastreiam o desenvolvimento do **framework Kairos** e do conteúdo instanciado (quando modificado/criado pelo Kairos), servindo como backlog do que fazer, e logs do que está sendo feito ou do que foi feito — não são outputs operacionais dos agentes/squads. Outputs gerados por agentes vão para `data/outputs/`.

---

## Documentação

| Documento | Conteúdo |
|-----------|----------|
| [docs/scope.md](docs/scope.md) | PRD da instância, para o Kairos entender o projeto — criado e editado por `@kairos *prd` |
| [.kairos-core/docs/scope.md](.kairos-core/docs/scope.md) | PRD do framework Kairos — escopo, arquitetura, objetivos, restrições, stack |
| [.kairos-core/docs/agent-standards.md](.kairos-core/docs/agent-standards.md) | Como criar e estruturar novos agentes |
| [.kairos-core/docs/data-flow.md](.kairos-core/docs/data-flow.md) | Fluxo completo de dados, estrutura, formatos de output |
| [CHANGELOG.md](CHANGELOG.md) | Histórico de versões |
| [CLAUDE.md](CLAUDE.md) | Instruções e contexto para o Claude Code |

---

## Licença

[MIT](LICENSE)
