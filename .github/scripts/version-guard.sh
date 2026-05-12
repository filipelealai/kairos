#!/usr/bin/env bash
# Kairos Version Guard
#
# Gate canônico de versionamento para PRs para origin/main.
# Verifica que mudanças de framework têm bump, frontmatter, CHANGELOG e gate de review.
#
# Checks:
#   A. Bump: core-config.yaml version foi bumped em relação a main
#   B. Frontmatter: arquivos framework modificados têm kairos-version atualizado
#   C. CHANGELOG: versão mais recente em CHANGELOG.md bate com core-config.yaml
#   D. Gate: stories type:kairos-core modificadas no PR têm gate PASS/RESSALVA
#
# Pula todos os checks se a interseção entre arquivos do PR e paths do manifest for vazia.
#
# Stack: bash + git + yq (mikefarah/yq v4) + grep + python3
# Exit: 0 = PASS (ou sem arquivos framework no PR); 1 = ao menos 1 FAIL

set -uo pipefail

MANIFEST=".kairos-core/manifest.yaml"
ERRORS=0
BASE="${BASE:-origin/main}"

# ─── Utilitários ──────────────────────────────────────────────────────────────

pass()  { echo "✅ CHECK $1 — $2"; }
fail()  { echo "❌ CHECK $1 — $2"; ERRORS=$((ERRORS + 1)); }
info()  { echo "ℹ️  $1"; }

# ─── Verificar dependências ───────────────────────────────────────────────────

if ! command -v yq &>/dev/null; then
  echo "❌ HALT — 'yq' não encontrado. Instale com: pip install yq ou brew install yq"
  exit 1
fi

if [ ! -f "$MANIFEST" ]; then
  echo "❌ HALT — manifest.yaml não encontrado: $MANIFEST"
  exit 1
fi

# ─── Coletar arquivos do PR ───────────────────────────────────────────────────

# Arquivos modificados/adicionados em relação à base
PR_FILES=$(git diff --name-only "$BASE"...HEAD 2>/dev/null || git diff --name-only HEAD~1 HEAD 2>/dev/null || true)

if [ -z "$PR_FILES" ]; then
  info "Nenhum arquivo modificado detectado — skipping version-guard."
  exit 0
fi

# ─── Coletar paths do manifest ────────────────────────────────────────────────

MANIFEST_OWNED=$(yq e '.owned_files[].path' "$MANIFEST" 2>/dev/null | sort)
MANIFEST_SECTIONS=$(yq e '.owned_sections[].path' "$MANIFEST" 2>/dev/null | sort)
ALL_MANIFEST_PATHS=$(printf "%s\n%s" "$MANIFEST_OWNED" "$MANIFEST_SECTIONS" | sort -u | grep -v '^$')

# ─── Verificar interseção ─────────────────────────────────────────────────────

FRAMEWORK_FILES_IN_PR=""
while IFS= read -r pr_file; do
  if echo "$ALL_MANIFEST_PATHS" | grep -qxF "$pr_file" 2>/dev/null; then
    FRAMEWORK_FILES_IN_PR="${FRAMEWORK_FILES_IN_PR}${pr_file}"$'\n'
  fi
done <<< "$PR_FILES"

FRAMEWORK_FILES_IN_PR="${FRAMEWORK_FILES_IN_PR%$'\n'}"

if [ -z "$FRAMEWORK_FILES_IN_PR" ]; then
  info "Nenhum arquivo de framework (manifest) no PR — version-guard não aplicável."
  info "Arquivos no PR são todos de instância (fora do manifest). PASS implícito."
  exit 0
fi

info "Arquivos de framework no PR:"
while IFS= read -r f; do
  info "  $f"
done <<< "$FRAMEWORK_FILES_IN_PR"

echo ""

# ─── Check A: Bump de versão ──────────────────────────────────────────────────

VERSION_CURRENT=$(yq e '.version' "$MANIFEST" 2>/dev/null || grep -m1 '^version:' .kairos-core/core-config.yaml | awk '{print $2}')
VERSION_CURRENT=$(grep -m1 '^version:' .kairos-core/core-config.yaml | awk '{print $2}')

# Versão em main
VERSION_MAIN=$(git show "$BASE:.kairos-core/core-config.yaml" 2>/dev/null | grep -m1 '^version:' | awk '{print $2}')

if [ -z "$VERSION_MAIN" ]; then
  fail "A" "Não foi possível obter versão de $BASE — verifique se .kairos-core/core-config.yaml existe em $BASE"
elif [ "$VERSION_CURRENT" = "$VERSION_MAIN" ]; then
  fail "A" "Versão não foi bumped: core-config.yaml em ambos os branches = $VERSION_CURRENT. Execute @kairos *version antes de abrir PR para main."
else
  pass "A" "Bump detectado: $VERSION_MAIN → $VERSION_CURRENT"
fi

# ─── Check B: Frontmatter kairos-version ──────────────────────────────────────

CHECK_B_ERRORS=0
while IFS= read -r f; do
  # Apenas arquivos .md
  if [[ "$f" != *.md ]]; then
    continue
  fi
  if [ ! -f "$f" ]; then
    continue
  fi
  # Verificar se tem frontmatter com kairos-version
  if ! grep -q '^kairos-version:' "$f" 2>/dev/null; then
    # Arquivo sem kairos-version — ignorar (backfill não obrigatório)
    continue
  fi
  # Verificar se kairos-version bate com a versão atual
  FILE_KV=$(grep -m1 '^kairos-version:' "$f" | awk '{print $2}')
  if [ "$FILE_KV" != "$VERSION_CURRENT" ]; then
    echo "  ⚠️  CHECK B — $f: kairos-version=$FILE_KV (esperado $VERSION_CURRENT)"
    CHECK_B_ERRORS=$((CHECK_B_ERRORS + 1))
  fi
done <<< "$FRAMEWORK_FILES_IN_PR"

if [ "$CHECK_B_ERRORS" -gt 0 ]; then
  fail "B" "$CHECK_B_ERRORS arquivo(s) com kairos-version desatualizado. Execute @kairos *version para sincronizar."
else
  pass "B" "kairos-version atualizado em todos os arquivos framework modificados"
fi

# ─── Check C: CHANGELOG sincronizado ──────────────────────────────────────────

CHANGELOG_VERSION=$(grep -m1 '^## \[' CHANGELOG.md 2>/dev/null | sed 's/## \[//;s/\].*//')

if [ -z "$CHANGELOG_VERSION" ]; then
  fail "C" "CHANGELOG.md não encontrado ou sem entradas válidas (formato: ## [versão] — data)"
elif [ "$CHANGELOG_VERSION" != "$VERSION_CURRENT" ]; then
  fail "C" "CHANGELOG.md versão mais recente ($CHANGELOG_VERSION) diverge de core-config.yaml ($VERSION_CURRENT). Execute @kairos *version."
else
  pass "C" "CHANGELOG.md ($CHANGELOG_VERSION) sincronizado com core-config.yaml ($VERSION_CURRENT)"
fi

# ─── Check D: Gate de review para stories type:kairos-core ───────────────────

GATES_DIR="docs/qa/gates"
STORIES_DIR="docs/stories"

# Identificar stories type:kairos-core modificadas no PR
KAIROS_CORE_STORIES_WITHOUT_GATE=0

while IFS= read -r f; do
  # Apenas story files modificados no PR
  if [[ "$f" != docs/stories/*.story.md ]]; then
    continue
  fi
  if [ ! -f "$f" ]; then
    continue
  fi

  # Verificar se é type: kairos-core
  story_type=$(grep -m1 '^\*\*Tipo:\*\*' "$f" | sed 's/\*\*Tipo:\*\*[[:space:]]*//')
  if [ "$story_type" != "kairos-core" ]; then
    continue
  fi

  # Verificar status
  story_status=$(grep -m1 '^\*\*Status:\*\*' "$f" | sed 's/\*\*Status:\*\*[[:space:]]*//')
  if [ "$story_status" != "In Review" ] && [ "$story_status" != "Done" ]; then
    continue
  fi

  # Extrair ID da story (basename sem .story.md)
  story_id=$(basename "$f" .story.md)

  # Verificar se há gate PASS ou RESSALVA
  gate_found=0
  if [ -d "$GATES_DIR" ]; then
    for gate_file in "$GATES_DIR"/${story_id}-*.yaml; do
      if [ -f "$gate_file" ]; then
        gate_verdict=$(grep -m1 '^verdict:' "$gate_file" | awk '{print $2}')
        if [ "$gate_verdict" = "PASS" ] || [ "$gate_verdict" = "RESSALVA" ]; then
          gate_found=1
          break
        fi
      fi
    done
  fi

  if [ "$gate_found" -eq 0 ]; then
    echo "  ❌ CHECK D — Story $story_id (type:kairos-core) sem gate PASS/RESSALVA. Rode: @kairos *review $story_id"
    KAIROS_CORE_STORIES_WITHOUT_GATE=$((KAIROS_CORE_STORIES_WITHOUT_GATE + 1))
    ERRORS=$((ERRORS + 1))
  fi

done <<< "$PR_FILES"

if [ "$KAIROS_CORE_STORIES_WITHOUT_GATE" -eq 0 ]; then
  pass "D" "Todas as stories type:kairos-core no PR têm gate PASS/RESSALVA (ou não há stories kairos-core)"
fi

# ─── Resultado final ──────────────────────────────────────────────────────────

echo ""
if [ "$ERRORS" -gt 0 ]; then
  echo "🚫 VERSION GUARD BLOCK — $ERRORS check(s) falharam."
  echo "   Corrija os issues acima e atualize o PR."
  exit 1
else
  echo "✅ VERSION GUARD PASS — todos os checks aprovados."
  exit 0
fi
