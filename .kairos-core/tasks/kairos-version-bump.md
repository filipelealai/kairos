---
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
Checklist:
  - "[ ] Validar que bump_type e description foram fornecidos"
  - "[ ] Ler versão atual de .kairos-core/core-config.yaml"
  - "[ ] Calcular nova versão semântica"
  - "[ ] Verificar se story é obrigatória (MAJOR/MINOR) e se existe"
  - "[ ] Atualizar version e updatedAt em .kairos-core/core-config.yaml"
  - "[ ] Adicionar entrada no CHANGELOG.md"
  - "[ ] Confirmar mudanças ao usuário"
---

# *version — Bump de Versão Semântica

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

## Confirmação

Exiba:
```
✓ Versão bumped: {antiga} → {nova}
✓ CHANGELOG.md atualizado
✓ core-config.yaml atualizado

Próximo passo: *pre-push → *push
```
