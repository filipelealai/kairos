# Kairos

> *καιρός — o tempo certo, o momento oportuno.*

Kairos é um framework de orquestração de agentes de IA construído sobre o Claude Code. Organiza o trabalho em **squads** — grupos de agentes especializados que executam domínios específicos — e fornece a infraestrutura de governança, memória, handoffs, workers agendados e ferramentas de desenvolvimento para criar, evoluir e operar esses squads ao longo do tempo.

**Versão atual:** `4.0.0` — ver [CHANGELOG.md](CHANGELOG.md)

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

| Requisito | Status |
|-----------|--------|
| Claude Code (CLI ou aba "Claude Code" do Claude Desktop) | **Obrigatório** |
| Git | Opcional — apenas para contribuir com o framework ou usar `*push` |
| App de nuvem (Google Drive Desktop, OneDrive, Dropbox) | Opcional — para sync de outputs com o time |

---

## Instalação

### Sem Git (recomendado para usuários)

**Linux / macOS / WSL:**

```bash
curl -fsSL https://raw.githubusercontent.com/filipelealweb/kairos/main/install.sh | bash
```

**Windows (PowerShell):**

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/filipelealweb/kairos/main/install.ps1" -OutFile "$env:TEMP\install-kairos.ps1"
& "$env:TEMP\install-kairos.ps1"
```

O instalador guia você pelo processo: detecta o SO, valida pré-requisitos, pergunta onde instalar, solicita seu nome de instância e gera o `.env`. Sem Git necessário.

Para instruções completas, troubleshooting e setup de cloud sync, ver [`.kairos-core/docs/install.md`](.kairos-core/docs/install.md).

### Com Git (contribuidores)

```bash
git clone https://github.com/filipelealweb/kairos
cd kairos
cp .env.example .env
```

Edite `.env` com as variáveis relevantes para seus squads (ver [.env.example](.env.example) para a lista).

Para instruções completas sobre como contribuir e abrir PRs, ver [CONTRIBUTING.md](CONTRIBUTING.md).

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

## Colaboração em equipe

O Kairos suporta times onde cada pessoa roda sua própria instância local. Dois mecanismos de colaboração plug-and-play:

### Outputs identificáveis por instância

Cada membro configura seu `KAIROS_INSTANCE_NAME` no `.env`. Os outputs gerados carregam esse identificador no nome do arquivo:

```
data/outputs/cold-prospecting/emails/email-writer_emails-joao-2026-05-05.json
data/outputs/cold-prospecting/emails/email-writer_emails-maria-2026-05-05.json
```

Dois membros rodando o mesmo agente no mesmo dia não colidem.

### Sync de outputs via app de nuvem

Pode ser configurado automaticamente no instalador, ou manualmente depois:

```
@kairos *configure-cloud
```

Cria um symlink `data/outputs/ → /Drive/Equipe/Kairos Outputs/`. A partir daí, todos os outputs aparecem automaticamente na nuvem compartilhada — via Google Drive Desktop, OneDrive ou Dropbox. Zero OAuth necessário.

### Squads compartilháveis em arquivo único

Squads podem ser compartilhados via exportação e importação. Ao exportar, o squad levará consigo suas memórias, personas, tasks e dependências que precisa para funcionar.

```
@kairos *export-squad {nome-do-squad}   # gera kairos-squad-{nome}-{versão}.tar.gz
@kairos *import-squad {arquivo.tar.gz}  # instala na instância destino
```

Envie o arquivo por e-mail, Drive, pendrive, WhatsApp (ou por que meio preferir). O importador valida as dependências disponíveis e faltantes, e configura tudo automaticamente no lugar.

---

## @kairos — Governança do framework

`@kairos` é o agente que governa como o próprio Kairos evolui. Não faz trabalho operacional — planeja, valida e versiona o sistema.

Comandos principais:

| Comando | O que faz | Depende de Git? |
|---------|-----------|------|
| `*status` | Versão, squads, stories abertas, último gate | — |
| `*roadmap` | O que está em Draft / In Progress / In Review | — |
| `*new-epic` | Cria novo epic via elicitação guiada | — |
| `*new-story` | Cria nova story de desenvolvimento | — |
| `*new-squad` | Scaffolda novo squad completo | — |
| `*validate-story {id}` | Valida formato e qualidade da story | — |
| `*validate-squad {squad}` | Valida formato e consistência geral de um squad | — |
| `*update-squad {squad}` | Atualiza um squad existente | — |
| `*regenerate-squad {squad}` | Regenera personas desatualizadas a partir dos `.yaml` de agentes (SHA drift) | — |
| `*implement {id}` | Implementa story de desenvolvimento; oferece marcar Done para stories `type: instance` | — |
| `*review {id}` | Valida implementação — gate PASS / RESSALVA / BLOCK; oferece marcar Done para stories `type: instance` | — |
| `*configure-cloud` | Configura o sync de outputs via symlink para Google Drive / OneDrive / Dropbox | — |
| `*export-squad {squad}` | Empacota squad completo em arquivo distribuível | — |
| `*import-squad {arquivo}` | Instala squad de arquivo na instância local | — |
| `*update` | Atualiza o framework para a versão mais recente (sem Git) | — |
| `*doctor` | Health check do framework — arquivos, hooks, ownership | — |
| `*prd` | Cria ou atualiza `docs/scope.md` | — |
| `*architecture [{squad}]` | Audita consistência entre docs e código | — |
| `*help [{topic}]` | Ajuda completa com fluxos e exemplos | — |
| `*version patch\|minor\|major` | Bump de versão semântica (com *doctor como Passo 1); somente para `type: kairos-core` | **Git** |
| `*pre-push` | Valida gate de review (type:kairos-core) e referências — idempotente | **Git** |
| `*push` | Orquestrador de releases de framework e de instância. Framework: doctor via *version, modo dev e transição Done (type:kairos-core); framework ou instância: verifica drift de agentes, commit e push. Pula transição Done para stories `type: instance` já marcadas via `*implement`/`*review` | **Git** |

> Comandos marcados com **Git** dependem de Git instalado e são voltados para contribuidores do framework ou quem mantém repo privado.

---

## Estrutura do repositório

```
kairos/
├── install.sh / install.ps1     # Instaladores interativos (Linux/Mac/WSL e Windows)
├── uninstall.sh / uninstall.ps1 # Desinstaladores (preservam conteúdo user-owned)
│
├── src/
│   └── agents/          # Scripts e ferramentas utilizados por agentes e squads (user-owned)
│
├── data/
│   └── outputs/         # Outputs dos agentes (pode ser symlink para nuvem via *configure-cloud)
│       └── {squad}/
│           └── {tipo}/  # Relatórios, outputs e dados gerados por agentes — nomeados com {INSTANCE}
│
├── squads/
│   └── {squad}/
│       ├── squad.yaml           # Manifesto do squad (inclui external_dependencies)
│       ├── README.md
│       ├── agents/              # Definições leves dos agentes
│       ├── tasks/               # Tasks específicas do squad
│       ├── workflows/           # Pipeline documentado
│       └── rules/               # Regras específicas do squad
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
│   └── hooks/                   # Hooks do Claude Code usados pelo Kairos (PreCompact, PreToolUse, SessionStart)
│
├── .kairos-core/
│   ├── constitution.md          # Princípios não-negociáveis do framework (L1)
│   ├── core-config.yaml         # Configuração central e versão semântica
│   ├── manifest.yaml            # Ownership: o que é framework vs. usuário
│   ├── agents/                  # MEMORY.md persistente por agente
│   ├── tasks/                   # Definições de tasks executáveis
│   ├── data/                    # KB, workers registry e dados de configuração
│   ├── docs/                    # Documentação de arquitetura e escopo do Kairos
│   │   └── install.md           # Guia completo de instalação e troubleshooting
│   ├── runtime/                 # Handoffs e logs de execução (conteúdo gitignored)
│   └── templates/               # Templates do Kairos para criação de agentes, squads, stories etc.
│
├── CHANGELOG.md
├── CLAUDE.md                    # Instruções para o Claude Code, contendo seções gerenciadas pelo Kairos
└── .env.example
```

---

## Git-first, mas funciona sem Git

O Kairos é "Git-first" no sentido de que usa Git internamente para versionamento e push, e funciona melhor num time que trabalhe utilizando um repositório central no GitHub (ou outra ferramenta), e sigam boas práticas de commit e merge — mas **não exige Git do usuário final** para instalação, uso ou atualização.

| Operação | Git necessário? |
|----------|----------------|
| Instalar o Kairos | **Não** — use `install.sh` / `install.ps1` |
| Usar agentes e squads | **Não** |
| Atualizar o framework (`*update`) | **Não** |
| Compartilhar squads (`*export-squad` / `*import-squad`) | **Não** |
| Sync de outputs com a nuvem (`*configure-cloud`) | **Não** |
| Versionar e fazer push para repo privado | **Sim** (`*push`, `*pre-push`, `*version`) |
| Contribuir com o framework público | **Sim** (abrir PR no GitHub) |

---

## Desenvolvimento do Kairos (para contribuidores)

O Kairos usa um modelo de governança próprio para se auto-documentar e evoluir:

**Ciclo típico de auto-desenvolvimento do framework:**
```
@kairos *new-epic          # planejar conjunto de trabalho
@kairos *new-story [{id}]  # detalhar uma unidade de trabalho
@kairos *validate-story {id} # checar qualidade da story antes de executar
@kairos *exit              # sai da persona do Kairos, que não pode implementar a si mesmo
Claude Code, sem persona   # executor move Draft → In Progress → In Review
                           # e adiciona Execution Log na story
@kairos *review {id}       # valida implementação — gate PASS/RESSALVA/BLOCK
@kairos *pre-push          # valida gate de review e referências (depende de Git)
@kairos *push              # orquestrador: doctor/drift/modo dev→*version/Done/commit/push (depende de Git)
PR                         # contribuições no repositório público do Kairos
```
Para informações detalhadas de como abrir um PR e contribuir no repositório público do Kairos, veja [CONTRIBUTING.md](CONTRIBUTING.md).

**Versionamento semântico:**
- `PATCH` — Correção, bug fixes, ajuste de instrução, documentação (não exige story)
- `MINOR` — Novo comando, nova task, nova rule, nova capacidade ou expansão significativa de capacidade (exige story)
- `MAJOR` — Novo escopo, breaking change, mudança de arquitetura, modificações em arquivos L1 (exige story)

**Stories** em `docs/stories/` rastreiam o desenvolvimento do **framework Kairos** e do conteúdo instanciado (quando modificado/criado pelo Kairos), servindo como backlog do que fazer, e logs do que está sendo feito ou do que foi feito — não são outputs operacionais dos agentes/squads. Outputs gerados por agentes vão para `data/outputs/`.

---

## Documentação

| Documento | Conteúdo |
|-----------|----------|
| [docs/scope.md](docs/scope.md) | PRD da instância, para o Kairos entender o projeto — criado e editado por `@kairos *prd` |
| [.kairos-core/docs/scope.md](.kairos-core/docs/scope.md) | PRD do framework Kairos — escopo, arquitetura, objetivos, restrições, stack |
| [.kairos-core/docs/agent-standards.md](.kairos-core/docs/agent-standards.md) | Como criar e estruturar novos agentes |
| [.kairos-core/docs/data-flow.md](.kairos-core/docs/data-flow.md) | Fluxo completo de dados, estrutura, formatos de output |
| [.kairos-core/docs/install.md](.kairos-core/docs/install.md) | Guia completo de instalação, cloud sync, troubleshooting e desinstalação |
| [CHANGELOG.md](CHANGELOG.md) | Histórico de versões |
| [CLAUDE.md](CLAUDE.md) | Instruções e contexto para o Claude Code |

---

## Licença

[MIT](LICENSE)
