---
kairos-owned: true
kairos-version: 3.15.0
id: kairos-export-squad
title: Exportar Squad em Arquivo Distribuível
agent: kairos
command: "*export-squad"
version: 1
---

# Task: kairos-export-squad

## Propósito

Empacotar um squad completo (personas, tasks, memórias, vars de ambiente declaradas e dependências externas) em um único arquivo distribuível — `kairos-squad-{nome}-{versão-framework}.tar.gz` ou `.zip`.

Permite que membros do time compartilhem squads por qualquer canal (e-mail, Drive, pendrive) sem depender do Git como meio de distribuição.

---

## Sintaxe

```
*export-squad {nome-do-squad} [--format tar.gz|zip]
```

- `{nome-do-squad}` — obrigatório. Deve corresponder a um diretório em `squads/`.
- `--format` — opcional. Default: `tar.gz`. Aceita `tar.gz` ou `zip`.

---

## Execução

### Passo 1 — Validação de entrada

1. Verificar que `squads/{nome}/squad.yaml` existe
   → Se não existir: HALT com "Squad '{nome}' não encontrado. Squads disponíveis: {lista}"
2. Ler `squad.yaml` do squad
3. Ler versão atual do framework em `.kairos-core/core-config.yaml` (campo `framework.version`)

### Passo 2 — Coleta de artefatos

Montar lista de arquivos a incluir no pacote:

**Obrigatório:**
- Pasta `squads/{nome}/` inteira (exceto `squads/{nome}/.gitkeep` se vazio)

**Tasks do squad:**
- Ler `components.tasks` de `squads/{nome}/squad.yaml`
- Para cada task listada, verificar se existe como `squads/{nome}/tasks/{task-file}` OU `.kairos-core/tasks/{task-file}`
- Incluir as que existirem em `.kairos-core/tasks/` (user-created, não as framework-owned)
  → As tasks framework-owned (listadas em `manifest.yaml`) são excluídas — o receptor já as tem

**Personas dos agentes:**
- Ler `components.agents` de `squad.yaml`
- Para cada agent YAML em `squads/{nome}/agents/*.yaml`, extrair campo `id:`
- Para cada `id`: incluir `.claude/commands/kairos/agents/{id}.md` se existir
  → Excluir `kairos.md` — é framework-owned

**Memórias dos agentes:**
- Para cada `id` de agente: incluir `.kairos-core/agents/{id}/MEMORY.md` se existir

**Total a incluir:** squad/ + tasks user-owned + personas + MEMORYs

### Passo 3 — Gerar manifesto local do export

Criar arquivo `export-manifest.yaml` que será incluído na raiz do pacote:

```yaml
kairos_export:
  squad: "{nome}"
  exported_at: "{ISO 8601}"
  framework_version: "{versão atual}"
  framework_version_major: {N}
  included_files:
    - {lista de todos os arquivos incluídos, com path relativo à raiz do repo}
  agents: [{lista de ids dos agentes}]
external_dependencies:
  - {cópia do campo external_dependencies de squad.yaml, ou [] se ausente}
```

### Passo 4 — Patch de vars de ambiente

1. Ler `squad.yaml` campo `external_dependencies` — extrair variáveis de ambiente mencionadas nos campos `note:` e `install.note:`
2. Ler `.env.example` e identificar se já existe um bloco `# --- squad:{nome} - START ---`
3. Gerar patch de vars de ambiente delimitado:

```
# --- squad:{nome} - START ---
# Vars de ambiente para o squad {nome}
# Copie as variáveis relevantes para seu .env e preencha os valores

{variáveis extraídas de external_dependencies, uma por linha com valor vazio}
# --- squad:{nome} - END ---
```

4. Incluir o patch como `squad-env-patch.env` na raiz do pacote

### Passo 5 — Calcular checksum

1. Montar estrutura de diretório temporária com todos os arquivos coletados
2. Calcular SHA-256 usando **paths relativos** ao diretório temporário — o path absoluto não pode entrar no hash pois difere entre export e import:
   ```bash
   cd {dir-temp} && find . -type f | sort | xargs sha256sum | sha256sum | cut -d' ' -f1
   ```
3. Registrar o checksum no `export-manifest.yaml` campo `checksum`

> **Por que paths relativos:** `sha256sum` inclui o nome do arquivo na sua saída antes de gerar o hash combinado. Se o cálculo usar o path absoluto do diretório temporário, o receptor nunca consegue reproduzir o mesmo valor — o nome do diretório temporário é diferente. O `cd` garante que os paths aparecem como `./squads/sales-pipeline/squad.yaml` em ambos os lados.

### Passo 6 — Empacotar

**Se `--format tar.gz` (default):**
```bash
tar -czf kairos-squad-{nome}-{versão}.tar.gz -C {dir-temp} .
```

**Se `--format zip`:**
```bash
cd {dir-temp} && zip -r {cwd}/kairos-squad-{nome}-{versão}.zip .
```

Nome final: `kairos-squad-{nome}-{versão-framework}.{ext}`
Exemplo: `kairos-squad-sales-pipeline-3.14.0.tar.gz`

Salvar na raiz do repo (`.`).

### Passo 7 — Output

Exibir resumo:

```
✅ Squad '{nome}' exportado com sucesso.

Arquivo: kairos-squad-{nome}-{versão}.tar.gz
Tamanho: {X} KB
Checksum SHA-256: {hash}

Conteúdo:
  📁 squads/{nome}/       — squad completo
  📄 {N} personas         — .claude/commands/kairos/agents/*.md
  🧠 {N} memórias         — .kairos-core/agents/*/MEMORY.md
  📋 {N} tasks de squad   — .kairos-core/tasks/{squad}-*.md
  🔧 {N} dependências ext — ver export-manifest.yaml

Para importar em outra instância:
  @kairos *import-squad ./kairos-squad-{nome}-{versão}.tar.gz
```

---

## Tratamento de Casos Especiais

**Squad sem agentes com persona gerada:**
→ WARN "Agentes sem persona: {lista}. Considere rodar *regenerate-squad {nome} antes de exportar."

**Squad sem external_dependencies declaradas:**
→ Incluir `external_dependencies: []` no manifesto, sem bloco no patch de env

**Arquivo de saída já existe:**
→ Perguntar: "Arquivo kairos-squad-{nome}-{versão}.tar.gz já existe. Sobrescrever? (s/n)"

---

## Completion

Sem handoff. Export é operação pontual.
