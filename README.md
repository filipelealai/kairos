# Kairos

> *καιρός — o tempo certo, o momento oportuno.*

Kairos é um sistema pessoal de automação e inteligência construído em torno dos fluxos de trabalho reais de Filipe Leal. Não é uma plataforma genérica — é um conjunto de agentes de IA que fazem trabalho específico, no momento certo, com total rastreabilidade.

**Versão atual:** `1.2.0` — ver [CHANGELOG.md](CHANGELOG.md)

---

## O que o Kairos faz

O escopo ativo é **prospecção B2B fria** para a Agência Vendoteca:

```
n8n (operacional)  ↔  Kairos (inteligência)  ↔  Google Sheets (dados)
```

- **n8n** raspa CNPJs da Receita Federal, popula a planilha, dispara e-mails, atualiza status
- **Kairos** analisa a campanha, pontua leads, classifica nichos, gera e-mails personalizados
- A ponte entre os dois é um webhook (`N8N_LEADS_URL`) que expõe os leads da planilha

O Kairos nunca envia e-mails diretamente e nunca escreve na planilha — essas responsabilidades são exclusivas do n8n.

---

## Stack

| Camada | Tecnologia |
|--------|-----------|
| Runtime | Node.js (ESM) |
| Linguagem | TypeScript |
| AI | `@anthropic-ai/sdk` — `claude-sonnet-4-6` |
| Runner | `tsx` (sem etapa de build) |
| Automação | n8n (self-hosted) |
| Dados externos | Google Sheets via webhook n8n |

---

## Pré-requisitos

- Node.js 18+
- Uma chave de API da Anthropic ([console.anthropic.com](https://console.anthropic.com))
- Acesso ao webhook n8n com os leads (ou uma URL compatível)

---

## Instalação

```bash
git clone <repo>
cd kairos
npm install
cp .env.example .env
```

Edite `.env`:

```env
ANTHROPIC_API_KEY=sk-ant-...
N8N_LEADS_URL=https://seu-n8n.com/webhook/kairos-leads
```

---

## Como rodar um agente

Cada agente é um script TypeScript autossuficiente:

```bash
npx tsx src/agents/campaign-analyst.ts
npx tsx src/agents/lead-scorer.ts
npx tsx src/agents/niche-classifier.ts
npx tsx src/agents/email-writer.ts
```

Os outputs são salvos em `data/outputs/{squad}/{tipo}/` com prefixo do agente gerador:

```
data/outputs/cold-prospecting/
  reports/
    campaign-analyst_campaign-2026-04-06.md
    lead-scorer_scored-leads-2026-04-06.csv
    niche-classifier_niche-map-2026-04-06.json
  emails/
    email-writer_emails-2026-04-06.json
```

---

## Pipeline completo (squad cold-prospecting)

```
@campaign-analyst *analyze
        ↓  gera: campaign-analyst_campaign-YYYY-MM-DD.md
@lead-scorer *score
        ↓  gera: lead-scorer_scored-leads-YYYY-MM-DD.csv
@niche-classifier *classify
        ↓  gera: niche-classifier_niche-map-YYYY-MM-DD.json
@email-writer *write 20
        ↓  gera: email-writer_emails-YYYY-MM-DD.json
n8n lê emails e dispara
```

Execução parcial é permitida — cada agente pode ser rodado individualmente.

---

## Agentes como personas no Claude Code

O Kairos usa o Claude Code como ambiente de execução. Cada agente é uma **persona ativável** no chat:

```
@campaign-analyst   Clio 📊  — análise de campanha
@lead-scorer        Lex  🎯  — pontuação de leads
@niche-classifier   Nix  🗂️  — classificação de nichos
@email-writer       Eva  ✉️  — geração de e-mails
@kairos             🌀       — governança do framework
```

Para ativar, basta mencionar o agente pelo nome em uma sessão do Claude Code. Cada agente tem comandos próprios com prefixo `*`:

```
@email-writer *write 10    # gera 10 e-mails
@campaign-analyst *analyze # analisa campanha atual
@lead-scorer *score        # pontua leads pendentes
@kairos *status            # estado geral do sistema
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
│   ├── agents/          # Scripts TypeScript — computação pura (sem AI) ou geração
│   │   ├── campaign-analyst.ts
│   │   ├── lead-scorer.ts
│   │   ├── niche-classifier.ts
│   │   └── email-writer.ts
│   └── tools/
│       └── claude.ts    # Wrapper da Anthropic SDK — usar sempre este, nunca instanciar diretamente
│
├── data/
│   └── outputs/         # Outputs dos agentes (gitignored por conteúdo)
│       └── cold-prospecting/
│           ├── reports/ # Relatórios de campanha, scoring, nichos
│           └── emails/  # E-mails gerados, prontos para o n8n
│
├── squads/
│   └── cold-prospecting/
│       ├── squad.yaml           # Manifesto do squad
│       ├── README.md
│       ├── agents/              # Definições leves dos agentes
│       ├── tasks/               # Tasks específicas do squad
│       └── workflows/           # Pipeline documentado
│
├── docs/
│   ├── scope.md                 # PRD — escopo, arquitetura, objetivos, restrições
│   ├── epics/                   # Epic files (epic-1 a epic-4)
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
│   └── skills/                  # Skills do Claude Code (n8n, UI, etc.)
│
├── .kairos-core/
│   ├── core-config.yaml         # Configuração central e versão semântica
│   ├── agents/                  # MEMORY.md persistente por agente
│   ├── tasks/                   # Definições de tasks executáveis
│   ├── data/                    # workflow-chains.yaml e dados de configuração
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
| [docs/framework/agent-standards.md](docs/framework/agent-standards.md) | Como criar e estruturar novos agentes |
| [docs/framework/data-flow.md](docs/framework/data-flow.md) | Fluxo completo de dados, campos do webhook, formatos de output |
| [docs/stories/README.md](docs/stories/README.md) | Epics e stories de desenvolvimento do Kairos |
| [CHANGELOG.md](CHANGELOG.md) | Histórico de versões |
| [CLAUDE.md](CLAUDE.md) | Instruções e contexto para o Claude Code |

---

## Licença

MIT — uso pessoal de Filipe Leal.
