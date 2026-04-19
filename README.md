# Kairos

> *καιρός — o tempo certo, o momento oportuno.*

Kairos é um framework de orquestração de agentes de IA construído sobre o Claude Code. Organiza o trabalho em **squads** — grupos de agentes especializados que executam domínios específicos — e fornece a infraestrutura de governança, memória, handoffs, workers agendados e ferramentas de desenvolvimento para criar, evoluir e operar esses squads ao longo do tempo.

**Versão atual:** `3.4.1` — ver [CHANGELOG.md](CHANGELOG.md)

---

## Como funciona

Squads são criados com `@kairos *new-squad`. Cada squad tem seus próprios agentes, integrações externas e pipeline. O framework fornece a infraestrutura comum.

**Exemplo** — um squad de prospecção B2B integrando com n8n e Google Sheets:

```
n8n (operacional)  ↔  Kairos/squad  ↔  Google Sheets (dados)
```

O squad define quais sistemas externos seus agentes têm autoridade para usar. O Kairos não age diretamente sobre sistemas externos — delega para os sistemas definidos pelo squad (ver `constitution.md`).

---

## Stack

| Camada | Tecnologia |
|--------|-----------|
| Runtime | Node.js (ESM) |
| Linguagem | TypeScript |
| AI | `@anthropic-ai/sdk` — `claude-sonnet-4-6` |
| Runner | `tsx` (sem etapa de build) |
| Integrações externas | Definidas por squad (n8n, Supabase, APIs, etc.) |

---

## Pré-requisitos

- Node.js 18+
- Uma chave de API da Anthropic ([console.anthropic.com](https://console.anthropic.com))
- Integrações externas opcionais conforme os squads que você configurar (ver `.env.example`)

---

## Instalação

```bash
git clone <repo>
cd kairos
npm install
cp .env.example .env
```

Edite `.env` com as variáveis relevantes para seus squads (ver `.env.example` para a lista completa).

---

## Como rodar um agente

Cada agente é um script TypeScript autossuficiente:

```bash
npx tsx src/agents/{nome-do-agente}.ts
```

Os outputs são salvos em `data/outputs/{squad}/{tipo}/` com prefixo do agente gerador:

```
data/outputs/{squad}/
  reports/   # relatórios gerados pelo squad
  emails/    # outputs prontos para envio (quando aplicável)
```

---

## Pipeline de squad (exemplo)

Cada squad define seu próprio pipeline. **Exemplo** — squad `cold-prospecting`:

```
@campaign-analyst *analyze
        ↓  gera: campaign-analyst_campaign-YYYY-MM-DD.md
@lead-scorer *score
        ↓  gera: lead-scorer_scored-leads-YYYY-MM-DD.csv
@niche-classifier *classify
        ↓  gera: niche-classifier_niche-map-YYYY-MM-DD.json
@email-writer *write 20
        ↓  gera: email-writer_emails-YYYY-MM-DD.json
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

**Squads (definidos pelo usuário — exemplo):**
```
@campaign-analyst   Clio 📊  — análise de campanha
@lead-scorer        Lex  🎯  — pontuação de leads
@niche-classifier   Nix  🗂️  — classificação de nichos
@email-writer       Eva  ✉️  — geração de e-mails
```

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
| `*review [{id}]` | Valida implementação — gate PASS / RESSALVA / BLOCK |
| `*version patch\|minor\|major "desc"` | Bump de versão semântica |
| `*pre-push` | Verificações antes do push |
| `*push` | git push — exclusivo, requer *pre-push PASS |
| `*prd` | Cria ou atualiza `docs/scope.md` |
| `*architecture` | Audita consistência entre docs e código |
| `*help [{topic}]` | Ajuda completa com fluxos e exemplos |

---

## Estrutura do repositório

```
kairos/
├── src/
│   ├── agents/          # Scripts TypeScript dos agentes (adicionados por squad)
│   └── tools/
│       └── claude.ts    # Wrapper da Anthropic SDK — usar sempre este, nunca instanciar diretamente
│
├── data/
│   └── outputs/         # Outputs dos agentes (gitignored por conteúdo)
│       └── {squad}/
│           ├── reports/ # Relatórios gerados pelo squad
│           └── emails/  # Outputs prontos para envio (quando aplicável)
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
│   ├── scope.md                 # PRD — escopo, arquitetura, objetivos, restrições
│   ├── epics/                   # Epic files
│   ├── stories/                 # Stories de desenvolvimento do Kairos
│   ├── framework/
│   │   ├── agent-standards.md   # Padrões obrigatórios para criação de agentes
│   │   └── data-flow.md         # Fluxo completo de dados pelo sistema
│   └── qa/
│       └── gates/               # Gates de review (PASS/RESSALVA/BLOCK)
│
├── .claude/
│   ├── commands/kairos/agents/  # Personas completas dos agentes (YAML-in-Markdown)
│   ├── rules/                   # Regras cross-cutting (lifecycle, handoff, authority...)
│   └── skills/                  # Skills configuradas pelo usuário/equipe
│
├── .kairos-core/
│   ├── core-config.yaml         # Configuração central e versão semântica
│   ├── agents/                  # MEMORY.md persistente por agente
│   ├── tasks/                   # Definições de tasks executáveis
│   ├── data/                    # KB, workers registry e dados de configuração
│   └── runtime/                 # Handoffs e logs de execução (conteúdo gitignored)
│
├── CHANGELOG.md
├── CLAUDE.md                    # Instruções para o Claude Code
└── .env.example
```

---

## Desenvolvimento do Kairos

O Kairos usa um modelo de governança próprio para se auto-documentar e evoluir:

**Ciclo típico:**
```
@kairos *new-epic          # planejar conjunto de trabalho
@kairos *new-story "título" # detalhar uma unidade de trabalho
@kairos *validate-story {id} # checar qualidade da story antes de executar
(Claude Code implementa)   # executor move Draft → In Progress → In Review
                           # e adiciona Execution Log na story
@kairos *review            # valida implementação — gate PASS/RESSALVA/BLOCK
@kairos *version minor "…" # bump de versão
@kairos *pre-push          # verificações finais
@kairos *push              # push ao remoto (exclusivo do @kairos)
```

**Versionamento semântico:**
- `PATCH` — correção, ajuste de instrução, atualização de memória (não exige story)
- `MINOR` — novo agente, nova task, nova rule, nova capacidade (exige story)
- `MAJOR` — novo squad/escopo, breaking change (exige story)

**Stories** em `docs/stories/` rastreiam o desenvolvimento do **framework Kairos** — não são outputs operacionais. E-mails gerados, relatórios e scores vão para `data/outputs/`.

---

## Documentação

| Documento | Conteúdo |
|-----------|----------|
| [docs/scope.md](docs/scope.md) | PRD — escopo, arquitetura, objetivos, restrições, stack |
| [.kairos-core/docs/agent-standards.md](.kairos-core/docs/agent-standards.md) | Como criar e estruturar novos agentes |
| [.kairos-core/docs/data-flow.md](.kairos-core/docs/data-flow.md) | Fluxo completo de dados, campos do webhook, formatos de output |
| [docs/stories/README.md](docs/stories/README.md) | Epics e stories de desenvolvimento do Kairos |
| [CHANGELOG.md](CHANGELOG.md) | Histórico de versões |
| [CLAUDE.md](CLAUDE.md) | Instruções e contexto para o Claude Code |

---

## Licença

MIT
