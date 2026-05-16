---
kairos-owned: true
kairos-version: 4.2.0
---

# Kairos Knowledge Base

> Base de conhecimento curada do framework. Contém decisões arquiteturais, gotchas sistêmicos, convenções e referências rápidas genéricas ao Kairos.
> Carregada sob demanda via `@kairos *kb` ou `@kairos *kb {tópico}`.

> Este arquivo contém apenas conteúdo de framework (aplica-se a qualquer instância do Kairos). Conhecimento específico de squad vive em `squads/{squad}/data/kb.md`.

---

## Índice

- [Decisões Arquiteturais](#decisoes-arquiteturais)
- [Convenções de Naming](#convencoes-de-naming)
- [Erros Comuns](#erros-comuns)
- [Referências Rápidas](#referencias-rapidas)

---

## Decisões Arquiteturais

### Por que YAML-in-Markdown para personas?

**Decisão:** Agentes definidos em `.claude/commands/kairos/agents/*.md` usam YAML embutido em Markdown, não JSON nem YAML puro.

**Motivo:** Claude Code carrega arquivos `.md` de commands automaticamente ao mencionar `@nome`. O Markdown permite seções legíveis por humanos (guias, exemplos) ao lado do YAML estruturado que o Claude interpreta. JSON puro seria menos legível; YAML puro não suportaria as seções de guia.

**Trade-off aceito:** Parsing implícito pelo Claude (não programático) — funciona bem porque o Claude entende a estrutura, mas não há validação automática de schema.

---

### Por que `.kairos-core/` em vez de `.kairos/`?

**Decisão:** Tudo de framework vai em `.kairos-core/` — não existe mais `.kairos/` separado.

**Motivo:** `.kairos/` existia só com `.gitignore` — era um placeholder sem propósito claro. Consolidar em `.kairos-core/runtime/` para handoffs e `.kairos-core/data/` para configs elimina um diretório sem semântica definida.

---

### Por que `data/outputs/{squad}/{tipo}/` com prefixo de agente?

**Decisão:** Outputs seguem o padrão `data/outputs/{squad}/{tipo}/{agent-id}_{filename}-YYYY-MM-DD.{ext}`.

**Motivo:** Permite que `data/` sirva para outros fins além de outputs (datasets, fixtures), separa por squad para quando houver múltiplos squads, e o prefixo de agente torna óbvio qual agente gerou cada arquivo ao listar o diretório.

---

### Quando agents devem ser script puro sem AI?

**Princípio:** Agentes cujo trabalho é computação determinística (métricas, scoring, agregação) devem ser implementados como scripts puros, sem chamadas à Claude API. Agentes que precisam de interpretação semântica (classificação natural, geração de texto) usam AI.

**Motivo:** Computação determinística com AI é mais lenta, mais cara e menos auditável. Reservar AI para o que realmente exige linguagem natural reduz custo e aumenta reprodutibilidade.

---

### Por que `pre_push_passed` é estado de sessão e não arquivo?

**Decisão:** O guard de `*push` é um estado em memória da sessão, não um arquivo em disco.

**Motivo:** Se fosse um arquivo, uma sessão poderia fazer `*pre-push`, encerrar, abrir nova sessão e fazer `*push` sem re-verificar. O estado de sessão força re-execução do `*pre-push` a cada nova sessão — mais seguro.

**Trade-off aceito:** Não persiste entre sessões (comportamento intencional).

---

### Por que sync_files é separado de owned_files?

**Decisão:** Arquivos sincronizados para `origin/main` mas não gerenciados por updates vivem em `sync_files`, não em `owned_files`.

**Motivo:** `README.md` precisa ir para o repositório público do GitHub (documentação visível), mas seu conteúdo é instância-específico (nome do projeto, squads ativos, owner). Em `owned_files`, um `kairos update` futuro poderia sobrescrevê-lo. `sync_files` separa os dois concerns: "vai para main" e "é atualizado pelo framework" — um arquivo pode satisfazer o primeiro sem o segundo.

**Trade-off aceito:** Arquivos em `sync_files` não têm SHA tracking — não há "drift" a detectar. O `*doctor` valida existência, não conteúdo.

---

### Framework stack-agnóstico

**Decisão:** O Kairos é um framework stack-agnóstico. O núcleo é markdown + YAML + CJS. `src/` é user-owned e pode conter scripts em qualquer linguagem.

**O que o Kairos É:** markdown (personas, rules, docs), YAML (config, squads, manifesto), CJS (hooks em `.claude/hooks/`). O núcleo roda sem dependências de runtime de agente — o único runtime exigido pelo framework é Node.js para os hooks CJS.

**O que `src/` é:** conteúdo do usuário, por instância, linguagem definida pelo usuário. O framework interage via comandos e lê outputs — não gerencia dependências de runtime da instância (npm, pip, etc.).

**Estrutura proposta para multi-stack:** quando múltiplas linguagens coexistirem em `src/`, a estrutura será `src/agents/ts/`, `src/agents/python/`, `src/tools/ts/`, `src/tools/python/`. Migração para essa estrutura é futura e não afeta o framework.

**O que NÃO é responsabilidade do framework:** instalar dependências (`npm install`, `pip install`), gerenciar versões de runtime, garantir que scripts de instância funcionem em ambientes arbitrários.

**Motivo:** A imposição de TypeScript em documentação de framework anterior era artefato da primeira instância de referência, não requisito arquitetural. Kairos foi concebido como agnóstico — a stack da instância é separação de concerns.

---

### Por que manifesto de ownership e não convenção por path?

**Decisão:** A fronteira framework/usuário é definida por `.kairos-core/manifest.yaml`, não por localização de arquivo.

**Motivo:** Um arquivo pode estar em `.kairos-core/rules/` e ser framework-shipped, user-criado ou pré-existente de um brownfield install — path sozinho não distingue origem. O manifesto é a fonte autoritativa; default-deny (arquivo fora do manifesto é do usuário) garante que updates nunca toquem conteúdo do usuário.

**Trade-off aceito:** Manifesto precisa ser mantido consistente com o filesystem — validado pelo `*doctor`.

---

## Convenções de Naming

| Item | Convenção | Exemplo |
|------|-----------|---------|
| ID de agente | `kebab-case` | `email-writer` |
| Persona (nome) | `PascalCase` | `Eva` |
| Task file | `kebab-case.md` | `write-emails.md` |
| Output file | `{agent-id}_{tipo}-{INSTANCE}-YYYY-MM-DD.{ext}` | `lead-scorer_scored-leads-joao-2026-04-14.csv` |
| Story file | `{epic}.{N}.story.md` | `5.1.story.md` |
| Epic file | `epic-{N}-{slug}.md` | `epic-5-arquitetura-do-framework.md` |
| Handoff file | `handoff-{from}-to-{to}-{ts}.yaml` | `handoff-agent-a-to-agent-b-20260414.yaml` |
| Gate file | `{story-id}-YYYY-MM-DD.yaml` | `5.1-2026-04-14.yaml` |

---

## Erros Comuns

### "Cannot read property of undefined" em script TS de agent

**Causa:** Campo de fonte externa (webhook, CSV, API) retornado como null/undefined.
**Solução:** Sempre fazer `String(campo || "")` para strings e `parseFloat(String(campo || 0))` para números ao consumir dados externos.

---

### Agente não detecta handoff na ativação

**Causa:** Handoff marcado como `consumed: true` ou diretório de handoffs vazio.
**Verificação:** `ls .kairos-core/runtime/handoffs/` — arquivo existe e tem `consumed: false`?

---

### `*push` recusado com "pré-push não executado"

**Causa:** Sessão reiniciada após `*pre-push` — o estado de sessão foi perdido.
**Solução:** Rodar `*pre-push` novamente na sessão atual antes de `*push`.

---

## Referências Rápidas

### Ciclo de desenvolvimento do Kairos

```
@kairos *new-epic → @kairos *new-story → @kairos *validate-story
→ Claude Code implementa → @kairos *review
→ @kairos *pre-push → @kairos *push
```

### Versioning rules

| Tipo | Quando | Story obrigatória? |
|------|--------|-------------------|
| PATCH | Correção de bugs, ajuste de instrução, documentação | Não |
| MINOR | Novo comando, nova task, nova rule, nova capacidade ou expansão significativa de capacidade | Sim |
| MAJOR | Novo escopo, breaking change, mudança de arquitetura, modificações em arquivos L1 | Sim |

### Ownership

| Localização | Propriedade |
|-------------|-------------|
| Listado em `manifest.yaml` | Framework (atualizável por update) |
| Fora do manifesto | Usuário (nunca tocado por update) |
| Dentro de bloco `<!-- KAIROS-MANAGED-START/END -->` | Framework dentro de arquivo misto |
| Fora de blocos managed em arquivo misto | Usuário |

---

## Modo contribuidor vs uso local

Quando `*push` detecta mudanças em arquivos do framework (listados no manifesto) **sem** story `type:kairos-core` In Review, pergunta a intenção do usuário (Passo 0c-bis):

- **Contribuidor** → BLOCK até criar story retroativa + gate `*review` + `*pre-push` PASS. É o caminho exigido para PRs ao Kairos público.
- **Local** → warning persistente no commit (`⚠️  framework files modified outside contributor flow`) + prossegue. Quem usa Kairos como fork local tem liberdade total mas assume responsabilidade.
- **Abortar** → encerra o `*push` sem mudanças.

Razão: governança obrigatória (story + gate + bump) só faz sentido para quem está contribuindo upstream. Antes desta decisão, havia um loophole — quem mexia direto em arquivos de framework sem criar story pulava todos os guards de governança. O prompt torna a intenção explícita.

O termo "modo contribuidor" substituiu o termo anterior "modo dev" para deixar claro que esse fluxo serve para contribuir upstream com o Kairos público — não é um modo de desenvolvimento genérico.

---

*Última atualização: 2026-05-12*
