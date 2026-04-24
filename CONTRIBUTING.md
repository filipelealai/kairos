# Contribuindo para o Kairos

Obrigado por contribuir! O Kairos é um framework de orquestração de agentes de IA construído sobre o Claude Code, feito para se auto-aprimorar com direção do usuário. Antes de abrir um PR, leia este guia.

---

## Quick Start para contribuir ao framework

O núcleo do Kairos é composto por markdown, YAML e CJS com docs, rules, tasks e templates — **não exige stack para contribuir**.

```bash
git clone https://github.com/filipelealweb/kairos
cd kairos
```

Para validar suas mudanças localmente, ative o `@kairos` no Claude Code e execute:

```
@kairos *doctor
```

O `*doctor` verifica integridade do manifesto, frontmatter e ownership. Se retornar PASS, seu PR está apto a ser enviado.

---

## Tipos de contribuição

O Kairos distingue entre **conteúdo de framework** e **conteúdo de instância** (conteúdo do usuário). A fronteira é definida em `.kairos-core/manifest.yaml` — ver [`.claude/rules/ownership.md`](.claude/rules/ownership.md) para o modelo completo.

### 1. Docs, rules e tasks de framework

Arquivos em `.kairos-core/tasks/`, `.claude/rules/`, `.kairos-core/templates/` e similares listados no manifesto como `owned_files`.

- Abra uma issue descrevendo o problema ou melhoria
- Implemente a mudança
- Execute `@kairos *doctor` para validar
- Abra um PR contra `main`

### 2. Novo squad ou agente

Squads e agentes são conteúdo de instância — criados pelo `@kairos *new-squad` a partir do scaffold em `.kairos-core/templates/squad-template/`. PRs com novos squads genéricos e reutilizáveis são bem-vindos como templates.

### 3. Mudança estrutural no framework (type: kairos-core)

Para mudanças que impactam o núcleo (novas camadas, protocolo de handoff, modelo de autoridade), o fluxo é:

```
@kairos *new-story → implementação com o Claude Core → @kairos *review → @kairos *doctor → @kairos *pre-push → PR
```

NOTA: Idealmente, `@kairos *push` só é utilizado para fazer push em branches e repos do usuário, como para salvar todo o Kairos **com** o seu conteúdo instanciado.

Stories de tipo `kairos-core` são executadas pelo Claude Code normal (sem persona ativa, pois @kairos não pode implementar mudanças em si próprio, só implementa mudanças instanciadas em squads, workers, agentes do usuário etc.). Ver [`.claude/rules/story-lifecycle.md`](.claude/rules/story-lifecycle.md). 

### 4. Scripts em `src/` (user-content, per-instance)

Arquivos em `src/agents/` e `src/tools/` são conteúdo de instância — não são gerenciados por updates de framework e variam por projeto. **O Kairos não impõe linguagem: scripts podem ser TypeScript, Python ou qualquer outra linguagem — o usuário escolhe e gerencia suas próprias dependências de runtime.** Contribuições genéricas e reutilizáveis são bem-vindas como exemplos ou templates.

### 5. Conteúdo instanciado

O conteúdo instanciado (ver [`.claude/rules/ownership.md`](.claude/rules/ownership.md)) deve ser limpo antes de qualquer PR para não poluir o framework com dados pessoais e por questões de segurança. Como dito anteriormente, contribuições de templates e exemplos genéricos são bem-vindos, mas devem ir para o `manifest.yaml` e para o `ownership.md`, respeitando as regras do framework, e devem ficar alocados em pasta própria em `.kairos-core/` (ainda a desenvolver).

---

## Branch naming

```
feat/descricao-curta
fix/descricao-curta
docs/descricao-curta
chore/descricao-curta
```

---

## Conventional Commits

```
feat: nova capacidade ou artefato
fix: correção de bug
docs: documentação pura
chore: manutenção sem impacto funcional
refactor: refatoração sem mudança de comportamento
```

Exemplos:

```
feat: kairos-doctor valida frontmatter em owned_files
fix: *push passo 2b corrige skip incorreto em arquivos mistos
docs: CONTRIBUTING.md adicionado com fluxo de PR
```

---

## Fluxo de PR

Ao abrir um PR, use o template em [`.github/PULL_REQUEST_TEMPLATE.md`](.github/PULL_REQUEST_TEMPLATE.md) — ele é carregado automaticamente pelo GitHub. O template inclui checklist de manifest, `*doctor` e `*review`.

O Kairos, idealmente, usa dois remotes:

| Remote | Repo | Conteúdo |
|--------|------|----------|
| `origin` | `filipelealweb/kairos` (público) ou seu branch fork | Framework puro — apenas artefatos listados no manifesto |
| `private` | `{seu-usuario}/kairos-pessoal` (privado) | Instância completa para uso pessoal — framework + squads + dados do usuário |

**Para contribuidores externos:**

1. Fork de `filipelealweb/kairos` (branch `main`)
2. Implemente na sua branch
3. Abra PR contra `main` do repositório público

PRs externos aprovados são integrados ao `main` público.

---

## Contrato de ownership

O Kairos distingue dois domínios:

- **Framework-owned** — listado em `.kairos-core/manifest.yaml` (`owned_files`, `owned_sections`, `sync_files`). Gerenciado por updates de framework.
- **User-owned** — tudo que não está no manifesto. O updater nunca toca.

Antes de contribuir com mudanças estruturais, leia [`.claude/rules/ownership.md`](.claude/rules/ownership.md).

---

## Validação local

```
@kairos *doctor      # integridade do manifesto e frontmatter
@kairos *review      # gate de qualidade da story (se aplicável)
```

`*doctor` retorna PASS, RESSALVA ou BLOCK. PRs com BLOCK não são aceitos sem resolução dos issues.

---

## Reportar issues

Use os templates em [`.github/ISSUE_TEMPLATE/`](.github/ISSUE_TEMPLATE/):

- **Bug report** — comportamento incorreto ou inesperado do framework
- **Feature request** — nova capacidade ou melhoria

Os templates já incluem os campos necessários (versão do Kairos, passos de reprodução, escopo sugerido). Se nenhum template se encaixar, abra uma issue em branco com título descritivo.

---

## Código de conduta

Ver [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

---

## Roadmap multi-stack

O Kairos foi projetado como framework **stack-agnóstico**: o núcleo é markdown + YAML + CJS. A camada de scripts (`src/`) é opcional e per-instance.

Roadmap informativo de suporte multi-stack:

| Camada | Status |
|--------|--------|
| Núcleo (markdown + YAML + CJS) | Estável |
| Scripts TypeScript em `src/agents/` e `src/tools/` | Instância de referência (estável, user-managed) |
| Scripts Python em `src/agents/` e `src/tools/` | Suportado (user-managed) |
| Estrutura multi-stack (`src/agents/ts/`, `src/agents/python/`, `src/tools/ts/`, `src/tools/python/`) | Planejado (migração futura) |
| CLI `npx install kairos` | Planejado |
| Publicação `@kairos/core` no npm | Planejado |

Contribuições são bem-vindas — abra uma issue para discutir antes de implementar.
