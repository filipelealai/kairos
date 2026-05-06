---
kairos-owned: true
kairos-version: 3.13.0
task: Kairos Version Bump
responsavel: "@kairos"
responsavel_type: agent
atomic_layer: governance
elicit: false
Entrada: |
  - bump_type: patch | minor | major
  - description: descrição curta da mudança (string)
Saida: |
  - .kairos-core/core-config.yaml atualizado (version + updatedAt)
  - CHANGELOG.md com nova entrada
  - README.md atualizado (linha "Versão atual")
Checklist:
  - "[ ] Validar que bump_type e description foram fornecidos"
  - "[ ] Ler versão atual de .kairos-core/core-config.yaml"
  - "[ ] Calcular nova versão semântica"
  - "[ ] Verificar se story é obrigatória (MAJOR/MINOR) e se existe"
  - "[ ] Atualizar version e updatedAt em .kairos-core/core-config.yaml"
  - "[ ] Adicionar entrada no CHANGELOG.md"
  - "[ ] Atualizar linha 'Versão atual' no README.md"
  - "[ ] SHA sync: atualizar sha256 em manifest.yaml para arquivos com drift"
  - "[ ] Confirmar mudanças ao usuário"
---

# *version — Bump de Versão Semântica

## Guard de Git

**ANTES de qualquer coisa**, verificar se o Git está disponível:

```bash
git --version
```

Se o comando falhar (Git não instalado ou não encontrado no PATH):

```
🚫 HALT — Git não encontrado.

O *version requer Git para operar. Instale com:
  • Linux (apt):   sudo apt install git
  • macOS (brew):  brew install git
  • Windows:       winget install --id Git.Git -e

Deseja que eu execute a instalação agora? (s/n):
```

Se `s` (ou `sim`): executar o comando de instalação correspondente ao SO detectado com confirmação explícita antes de rodar.
Se `n` (ou `não`): HALT — encerrar sem executar nada.

---

## Validação

Antes de executar, verifique:

- `bump_type` é um de: `patch`, `minor`, `major`
- `description` não está vazia
- Se `minor` ou `major`: existe story Done ou In Progress que justifica o bump?
  - Se não existe story → **BLOCK**: instrua a criar story primeiro com `*new-story`

## Cálculo da Nova Versão

Leia `version` de `.kairos-core/core-config.yaml`.

Separe em `[MAJOR, MINOR, PATCH]` e aplique:
- `patch` → incrementa PATCH, zera nada
- `minor` → incrementa MINOR, zera PATCH
- `major` → incrementa MAJOR, zera MINOR e PATCH

## Atualização do core-config.yaml

Atualize dois campos:
```yaml
version: {nova versão}
updatedAt: '{ISO 8601 timestamp}'
```

## Entrada no CHANGELOG.md

Adicione no topo (após o cabeçalho), antes da entrada mais recente:

```markdown
## [{nova versão}] — {YYYY-MM-DD}

### {Categoria}
- {description}
```

Categorias: `Adicionado`, `Mudado`, `Corrigido`, `Removido`, `Segurança`

## Atualização do README.md

Localize a linha que começa com `**Versão atual:**` e substitua a versão:

```
**Versão atual:** `{nova versão}` — ver [CHANGELOG.md](CHANGELOG.md)
```

## SHA Sync

Após atualizar o `core-config.yaml`, sincronize os SHAs do manifesto:

1. Leia `.kairos-core/manifest.yaml` → lista `owned_files`
2. Para cada entrada em `owned_files`:
   - Execute `sha256sum {path}` para calcular o SHA atual
   - Compare com o campo `sha256` registrado
   - Se divergir → atualize o campo `sha256` no manifesto
3. Confirme: `✓ SHA sync: {N} arquivo(s) atualizado(s)` (ou `já atualizado` se nenhum divergiu)

## Confirmação

Exiba:
```
✓ Versão bumped: {antiga} → {nova}
✓ core-config.yaml atualizado
✓ CHANGELOG.md atualizado
✓ README.md atualizado
✓ SHA sync: {N} arquivo(s) atualizado(s) em manifest.yaml

Próximo passo: *pre-push → *push
```
