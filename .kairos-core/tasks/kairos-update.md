---
kairos-owned: true
kairos-version: 4.3.0
id: kairos-update
title: Atualizar o framework Kairos para a versão mais recente
agent: kairos
command: "*update"
version: 1
---

# Task: kairos-update

## Propósito

Atualizar o framework Kairos da instância atual para a versão semver mais recente publicada
no repositório público (`filipelealweb/kairos`), sem exigir Git instalado.

Apenas arquivos declarados no `manifest.yaml` (owned_files e owned_sections) são atualizados.
Conteúdo user-owned é preservado integralmente.

---

## Pré-condições

- `core-config.yaml` existe e tem campo `version`
- `core-config.yaml` tem campo `update_source` (fallback: `https://github.com/filipelealweb/kairos`)
- Acesso de rede à API GitHub e download de tarball

---

## Fluxo de Execução

### Passo 1 — Consultar versão remota

```
GET https://api.github.com/repos/filipelealweb/kairos/releases/latest
```

Extrair campo `tag_name` (ex: `v3.14.0`) → versão remota sem o `v`.

Se a request falhar (rede, rate limit, repositório não encontrado):
→ HALT com mensagem: "❌ Não foi possível verificar versão remota. Verifique a conexão ou tente novamente."

### Passo 2 — Comparar versões

Ler `version` de `.kairos-core/core-config.yaml`.

Se `versão_local == versão_remota`:
→ Exibir: "✅ Kairos já está na versão mais recente (v{versão_local})." e encerrar.

Se `versão_local > versão_remota` (improvável mas possível em fork):
→ Exibir aviso: "⚠️ Versão local ({versão_local}) é mais recente que o remoto ({versão_remota}). Nenhuma ação necessária."
→ Encerrar.

### Passo 3 — Detectar drift local antes do update

**`owned_files`:** para cada entrada no `manifest.yaml` local:
- Calcular sha256 do arquivo local
- Comparar com o `sha256` declarado no manifesto local

**`owned_sections` tipo `markdown_blocks`:** para cada entrada com blocos declarados:
- Para cada bloco com `sha256`: extrair o conteúdo interno entre os markers START e END (excluindo as linhas de marker), calcular sha256 da string extraída e comparar com o registrado

**`owned_sections` tipo `yaml_keys`:** para cada entrada com `sha256_by_key`:
- Para cada chave com SHA registrado: ler o valor da chave no YAML local, serializar usando o algoritmo descrito em `sha_method`, calcular sha256 e comparar com o registrado

**`owned_sections` tipo `comment_blocks`:** para cada entrada com seções declaradas:
- Para cada seção com `sha256`: extrair o conteúdo interno entre `# KAIROS-MANAGED-START: {nome}` e `# KAIROS-MANAGED-END: {nome}` (excluindo as linhas de marker), calcular sha256 e comparar com o registrado

**`owned_sections` tipo `json_keys`:** para cada entrada com `sha256_by_key`:
- Parse do JSON local
- Para cada chave com SHA registrado: serializar com `json.dumps(value, sort_keys=True, separators=(',', ':'))`, calcular sha256 e comparar com o registrado

Se qualquer arquivo, bloco, chave ou seção local diverge do sha esperado pelo manifesto local:
→ HALT com mensagem:
```
❌ Drift detectado antes do update — o arquivo local foi modificado fora do ciclo kairos:
   {lista de arquivos/blocos/chaves com drift}
Revise as modificações antes de atualizar. O update não foi executado.
```

> Isso protege modificações locais intencionais em seções framework de arquivos mistos.

### Passo 4 — Baixar tarball da tag remota

URL de download:
```
https://github.com/filipelealweb/kairos/archive/refs/tags/v{versão_remota}.tar.gz
```

Download para pasta temporária local (ex: `/tmp/kairos-update-{versão_remota}/`).
Extrair tarball.

Se download falhar:
→ HALT: "❌ Falha no download do tarball v{versão_remota}. Verifique a conexão."

### Passo 5 — Ler manifest.yaml da versão remota

Localizar `manifest.yaml` no tarball extraído.

Se não encontrado:
→ HALT: "❌ manifest.yaml não encontrado no tarball v{versão_remota}. O release pode estar incompleto."

### Passo 6 — Atualizar owned_files

Para cada entrada em `owned_files` do manifesto **remoto**:
1. Localizar o arquivo correspondente no tarball extraído
2. Calcular sha256 do arquivo remoto
3. Calcular sha256 do arquivo local (se existir)
4. Se sha256 local == sha256 remoto → skip (nada a fazer)
5. Se sha256 local != sha256 remoto (ou arquivo não existe localmente):
   - Copiar arquivo remoto para o path local
   - Registrar na lista de arquivos atualizados

### Passo 7 — Atualizar owned_sections

Para cada entrada em `owned_sections` do manifesto **remoto**:

**Tipo `markdown_blocks`** (blocos `<!-- KAIROS-MANAGED-START/END: nome -->`):
1. Localizar o arquivo local
2. Para cada bloco declarado no manifesto remoto:
   - Extrair o conteúdo do bloco no arquivo remoto (tarball)
   - Substituir apenas o conteúdo entre `<!-- KAIROS-MANAGED-START: {nome} -->` e `<!-- KAIROS-MANAGED-END: {nome} -->` no arquivo local
   - Conteúdo fora dos marcadores: intocado

**Tipo `yaml_keys`** (chaves YAML declaradas):
1. Para cada `owned_key` declarada:
   - Extrair o valor da chave no arquivo remoto
   - Substituir apenas essa chave no arquivo local (parser YAML simples — linha a linha se necessário)
   - Chaves fora da lista: intocadas

**Tipo `json_keys`** (chaves JSON declaradas — ex: `.claude/settings.json`):
1. Parse do JSON local (se inválido → HALT: "JSON inválido em {path} — impossível aplicar patch")
2. Parse do JSON remoto (do tarball)
3. Para cada `owned_key` em `owned_keys` declarada no manifesto **remoto**:
   - Copiar `remote[key]` para `local[key]` (substituição total da chave, independente do valor atual)
4. Chaves fora da lista (`owned_keys`) no arquivo local: **intocadas**
5. Serializar o objeto resultante como JSON formatado (indent 2 espaços) e escrever no arquivo local

Se encontrar conflito (seção marcada localmente com conteúdo que não pode ser substituído seguramente):
→ HALT com descrição do conflito e arquivo afetado.

### Passo 8 — Atualizar kairos-version no frontmatter

Para cada arquivo que foi efetivamente modificado nos passos 6-7:
- Localizar linha `kairos-version:` no frontmatter YAML (`---` delimitadores)
- Substituir pelo valor da versão remota

### Passo 9 — Limpar pasta temporária

Remover `/tmp/kairos-update-{versão_remota}/` (ou equivalente do OS).

### Passo 10 — Rodar *doctor

Executar `*doctor` para verificar integridade após o update.

Se `*doctor` retornar CRITICAL:
→ HALT: "⚠️ Update aplicado, mas *doctor encontrou issues críticos. Revise o output acima antes de continuar."

### Passo 11 — Reportar resultado

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🌀 Kairos atualizado: v{versão_anterior} → v{versão_remota}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Arquivos atualizados ({N}):
{lista de paths, um por linha, ou "Nenhum arquivo alterado" se já estava atualizado}

*doctor: {HEALTHY | WARNING — ver detalhes acima}

Conteúdo user-owned: preservado integralmente.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Condições de HALT

| Condição | Mensagem |
|----------|---------|
| Falha de rede na consulta de versão | ❌ Não foi possível verificar versão remota |
| Drift local detectado pré-update | ❌ Drift detectado — revise antes de atualizar |
| Falha no download do tarball | ❌ Falha no download |
| manifest.yaml não encontrado no tarball | ❌ Release pode estar incompleto |
| Conflito em owned_section | ❌ Conflito em seção gerenciada — descrição detalhada |
| *doctor CRITICAL após update | ⚠️ Update aplicado com issues críticos |

---

## Notas

- `*update` **não** escreve em `CHANGELOG.md` — o changelog da nova versão já é sobrescrito
  pelo update dos owned_files.
- `*update` **não** faz bump de versão local — a versão é atualizada pela substituição do
  `core-config.yaml` (campo `version` é owned_key).
- O update nunca toca em `src/`, `data/`, `squads/`, `.env`, MEMORY.md ou qualquer
  arquivo não listado no manifesto remoto.
- `sync_files` do manifesto remoto são copiados para a instância local sem verificação de sha
  (comportamento idêntico ao instalador).
