---
kairos-owned: true
kairos-version: 4.0.0
task: Kairos Pre-Push
responsavel: "@kairos"
responsavel_type: agent
atomic_layer: validation
elicit: false
Entrada: |
  Nenhuma — inspeciona o estado atual do repositório
Saida: |
  - verdict: PASS | BLOCK exibido em tela
  - pre_push_passed: true|false (guardado em sessão para *push verificar)
Checklist:
  - "[ ] Pré-check: detectar escopo (instance-only vs framework)"
  - "[ ] Passo 1: Gate de review para stories type:kairos-core In Review"
  - "[ ] Passo 2: Spot check de referências quebradas"
  - "[ ] Exibir sumário e verdict"
---

# *pre-push — Validação Pura

O `*pre-push` é o validador de pré-voo: verifica se há stories `type: kairos-core` que precisam de gate aprovado e realiza spot check de referências. É idempotente — não faz commit, não executa doctor, não faz bump. Deve ser executado antes de cada `*push`.

## Execução

### Guard de Git

**ANTES de qualquer coisa**, verificar se o Git está disponível — mas **somente se** houver story `type: kairos-core` In Review (o guard importa apenas na rota que usa Git para spot check):

```bash
git --version
```

Se o comando falhar (Git não instalado ou não encontrado no PATH):

```
🚫 HALT — Git não encontrado.

O *pre-push requer Git para operar. Instale com:
  • Linux (apt):   sudo apt install git
  • macOS (brew):  brew install git
  • Windows:       winget install --id Git.Git -e

Deseja que eu execute a instalação agora? (s/n):
```

Se `s` (ou `sim`): executar o comando de instalação correspondente ao SO detectado com confirmação explícita antes de rodar.
Se `n` (ou `não`): HALT — encerrar sem executar nada.

> Em scope=instance-only o guard é trivialmente atendido (Git não é necessário).

---

### Pré-check — Detectar Escopo

**Objetivo:** determinar se as mudanças pendentes afetam arquivos de framework ou apenas conteúdo de instância.

Execute:

```bash
git status --porcelain
git diff HEAD --name-only
git diff --cached --name-only
```

Identifique todos os arquivos modificados, adicionados ou staged (excluindo `.kairos-core/runtime/`, `data/`, `node_modules/`).

**Cruzar com o manifesto:**

Leia `.kairos-core/manifest.yaml` → lista `owned_files[].path` e `owned_sections[].path`.

- **scope = framework** — ao menos um arquivo modificado consta em `owned_files` ou `owned_sections` do manifest
- **scope = instance-only** — nenhum arquivo modificado consta no manifest

Se **scope = instance-only**:
- Pular o Passo 1 inteiramente
- Registrar: `scope: instance-only — gate de review não aplicável`
- Ir direto para o Resultado Final (PASS)

---

### Passo 1 — Gate de review

**Aplicável apenas quando scope = framework.**

**Objetivo:** garantir que stories `type: kairos-core` In Review têm gate aprovado antes de ir para `*push`.

1. Liste todos os arquivos `docs/stories/*.story.md`
2. Identifique os que têm `**Status:** In Review`
3. Para cada story em `In Review`:
   - Leia o campo `**Tipo:**` da story
   - Se `type: kairos-core`:
     - Procure gate em `docs/qa/gates/{story-id}-*.yaml` (qualquer data)
     - Leia o campo `verdict` do gate mais recente
     - Se `verdict: PASS` ou `verdict: RESSALVA` → registrar: `gate_ok[story-id] = true`
     - Se não existe gate, ou `verdict: BLOCK` → **BLOCK:**
       ```
       🚫 BLOCK — Story {id} ({título}) é type:kairos-core e não tem gate PASS.
       Rode: @kairos *review {id}
       ```
   - Se `type: instance` → pular (stories de instância são auto-revisadas pelo *implement; gate não obrigatório no *pre-push)

**BLOCK se:** qualquer story `type: kairos-core` In Review sem gate PASS ou RESSALVA.

---

### Passo 2 — Referências quebradas (spot check)

**Objetivo:** verificar links internos nos arquivos `.md` modificados antes de commitar.

Pré-condição: Passo 1 passou (ou foi pulado em scope=instance-only).

Para arquivos `.md` modificados recentemente (identificados no pré-check):
- Verificar links internos `[texto](caminho)` — o path existe no repo?
- Verificar referências a tasks em YAML — o arquivo da task existe?

**Resolução de paths relativos:** resolver o path **a partir do diretório do arquivo que contém o link** — não a partir de `docs/` nem da raiz do repositório.

Exemplo correto: link `../stories/3.1.story.md` encontrado em `docs/epics/epic-3-*.md`
→ resolver a partir de `docs/epics/` → `docs/epics/../stories/3.1.story.md` → `docs/stories/3.1.story.md` ✓

Limite: verificar até 10 arquivos. Não é revisão exaustiva.

**BLOCK se:** referência crítica quebrada (agente referencia task inexistente, story aponta para epic inexistente).

---

### Resultado Final

**Se PASS:**
```
✅ PRE-PUSH PASS

Resumo:
  Scope: {framework | instance-only}
  Branch: {branch}
  Último commit: {hash} {mensagem}

Checks:
  ✅ Pré-check — scope detectado: {framework | instance-only}
  {✅ Passo 1 — Gate de review (stories type:kairos-core com gate PASS/RESSALVA) | ⏭  Passo 1 — pulado (scope=instance-only)}
  ✅ Passo 2 — Referências verificadas

Pronto para push. Execute: @kairos *push
```

**Se BLOCK:**
```
🚫 PRE-PUSH BLOCK

Issues que precisam ser resolvidos:
  ❌ {issue 1}
  ❌ {issue 2}

Avisos (não bloqueantes):
  ⚠️ {aviso}

Resolva os issues e rode *pre-push novamente.
```

---

## Estado de Sessão

Após execução, registre internamente:
- `pre_push_passed = true` se PASS
- `pre_push_passed = false` se BLOCK

O comando `*push` verifica este estado antes de executar.
