#!/usr/bin/env bash
# Kairos Manifest Validator
#
# Checks:
#   1. owned_files paths exist
#   2. owned_files sha256 matches (except self-referential)
#   3. .md in owned_files missing kairos-owned: true frontmatter (WARN)
#   4. .md with kairos-owned: true frontmatter not in owned_files (WARN)
#   5. KAIROS-MANAGED markers paired + no orphans in owned_sections markdown_blocks
#   6. sync_files paths exist
#   7. owned_sections json_keys — file exists, valid JSON, owned_keys present (WARN)
#
# Stack: bash + yq (mikefarah/yq v4) + sha256sum + grep
#        (mikefarah/yq também parseia JSON via -p json — sem necessidade de python3/jq)
# Exit: 0 = all mandatory checks passed (warnings allowed); 1 = any FAIL

set -uo pipefail

MANIFEST=".kairos-core/manifest.yaml"
ERRORS=0
WARNINGS=0

# ── Output helpers ────────────────────────────────────────────────────────────

append_summary() {
  if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
    printf '%s\n' "$1" >> "$GITHUB_STEP_SUMMARY"
  fi
}

fail() {
  echo "❌ FAIL: $1"
  ERRORS=$((ERRORS + 1))
  append_summary "| ❌ FAIL | $1 |"
}

warn() {
  echo "⚠️  WARN: $1"
  WARNINGS=$((WARNINGS + 1))
  append_summary "| ⚠️  WARN | $1 |"
}

pass() {
  echo "✅ PASS: $1"
  append_summary "| ✅ PASS | $1 |"
}

section() {
  local title="$1"
  echo ""
  echo "── ${title} ──"
  if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
    append_summary ""
    append_summary "### ${title}"
    append_summary ""
    append_summary "| Status | Check |"
    append_summary "|--------|-------|"
  fi
}

# ── Preflight ─────────────────────────────────────────────────────────────────

if [ ! -f "$MANIFEST" ]; then
  echo "❌ FATAL: $MANIFEST não encontrado"
  exit 1
fi

if ! command -v yq &>/dev/null; then
  echo "❌ FATAL: yq não encontrado (requer mikefarah/yq v4)"
  exit 1
fi

if ! command -v sha256sum &>/dev/null; then
  echo "❌ FATAL: sha256sum não encontrado"
  exit 1
fi

append_summary "## Kairos Manifest Validation"
append_summary ""
append_summary "Workflow: \`validate-manifest\` | Manifest: \`${MANIFEST}\`"

# ── Check 1 & 2: owned_files — existência + sha256 ──────────────────────────

section "owned_files — existência + sha256"

while IFS='|' read -r path sha256; do
  if [ ! -f "$path" ]; then
    fail "owned_files[$path] — arquivo não encontrado"
    continue
  fi

  if [ "$sha256" = "self-referential" ]; then
    pass "owned_files[$path] — existe (sha256 self-referential, skip)"
    continue
  fi

  actual=$(sha256sum "$path" | awk '{print $1}')
  if [ "$actual" != "$sha256" ]; then
    fail "owned_files[$path] — sha256 diverge (manifest: ${sha256:0:16}…, atual: ${actual:0:16}…)"
  else
    pass "owned_files[$path] — sha256 OK"
  fi
done < <(yq -r '.owned_files[] | .path + "|" + .sha256' "$MANIFEST")

# ── Check 3 & 4: frontmatter kairos-owned ────────────────────────────────────

section "frontmatter — kairos-owned: true"

# 3: .md in owned_files without kairos-owned: true frontmatter (WARN)
while IFS= read -r path; do
  [ -f "$path" ] || continue  # já falhou no check 1
  if grep -q '^kairos-owned: true' "$path" 2>/dev/null; then
    pass "frontmatter[$path] — kairos-owned: true presente"
  else
    warn "frontmatter[$path] — em owned_files sem 'kairos-owned: true'"
  fi
done < <(yq -r '.owned_files[] | select(.path | test("\\.md$")) | .path' "$MANIFEST")

# 4: .md with kairos-owned: true not in owned_files (WARN)
owned_md_set=$(yq -r '.owned_files[] | select(.path | test("\\.md$")) | .path' "$MANIFEST" | sort)

while IFS= read -r mdfile; do
  mdfile="${mdfile#./}"
  if ! grep -qxF "$mdfile" <<< "$owned_md_set" 2>/dev/null; then
    warn "frontmatter[$mdfile] — tem 'kairos-owned: true' mas não está em owned_files"
  fi
done < <(grep -rl '^kairos-owned: true' --include='*.md' . 2>/dev/null | sed 's|^\./||' | sort)

# ── Check 5: KAIROS-MANAGED markers emparelhados e sem órfãos ────────────────

section "KAIROS-MANAGED markers — emparelhamento + órfãos"

while IFS= read -r path; do
  if [ ! -f "$path" ]; then
    fail "owned_sections[$path] — arquivo não encontrado"
    continue
  fi

  # Get declared block names for this specific path (safe via env var)
  declared_blocks=$(SECTION_PATH="$path" yq -r \
    '.owned_sections[] | select(.type == "markdown_blocks" and .path == strenv(SECTION_PATH)) | .blocks[].name' \
    "$MANIFEST")

  # Check each declared block is properly paired (START before END, exactly once each)
  while IFS= read -r block_name; do
    [ -z "$block_name" ] && continue
    start_marker="<!-- KAIROS-MANAGED-START: ${block_name} -->"
    end_marker="<!-- KAIROS-MANAGED-END: ${block_name} -->"

    start_count=$(grep -cF "$start_marker" "$path" 2>/dev/null || echo 0)
    end_count=$(grep -cF "$end_marker" "$path" 2>/dev/null || echo 0)

    if [ "$start_count" -eq 1 ] && [ "$end_count" -eq 1 ]; then
      start_line=$(grep -nF "$start_marker" "$path" | cut -d: -f1)
      end_line=$(grep -nF "$end_marker" "$path" | cut -d: -f1)
      if [ "$start_line" -lt "$end_line" ]; then
        pass "markers[$path] — bloco '$block_name' emparelhado (L${start_line}–L${end_line})"
      else
        fail "markers[$path] — bloco '$block_name': START (L${start_line}) após END (L${end_line})"
      fi
    else
      fail "markers[$path] — bloco '$block_name' desemparelhado (START:${start_count} END:${end_count})"
    fi
  done <<< "$declared_blocks"

  # Check for orphan START markers (present in file but not declared in manifest)
  while IFS= read -r found_name; do
    [ -z "$found_name" ] && continue
    if ! grep -qxF "$found_name" <<< "$declared_blocks" 2>/dev/null; then
      fail "markers[$path] — bloco órfão '$found_name' (KAIROS-MANAGED-START sem declaração no manifest)"
    fi
  done < <(grep -oE '<!-- KAIROS-MANAGED-START: [a-zA-Z0-9_-]+ -->' "$path" 2>/dev/null \
    | sed 's/<!-- KAIROS-MANAGED-START: //;s/ -->//' || true)

done < <(yq -r '.owned_sections[] | select(.type == "markdown_blocks") | .path' "$MANIFEST" | sort -u)

# ── Check 6: sync_files — existência ─────────────────────────────────────────

section "sync_files — existência"

while IFS= read -r path; do
  if [ ! -f "$path" ]; then
    fail "sync_files[$path] — arquivo não encontrado"
  else
    pass "sync_files[$path] — existe"
  fi
done < <(yq -r '.sync_files[].path' "$MANIFEST")

# ── Check 7: owned_sections json_keys — existência + JSON válido + owned_keys ──

section "owned_sections json_keys — existência + JSON válido + owned_keys"

while IFS= read -r path; do
  if [ ! -f "$path" ]; then
    fail "owned_sections/json_keys[$path] — arquivo não encontrado"
    continue
  fi

  if ! yq -p json '.' "$path" >/dev/null 2>&1; then
    fail "owned_sections/json_keys[$path] — JSON inválido"
    continue
  fi

  pass "owned_sections/json_keys[$path] — existe e é JSON válido"

  owned_keys=$(SECTION_PATH="$path" yq -r \
    '.owned_sections[] | select(.type == "json_keys" and .path == strenv(SECTION_PATH)) | .owned_keys[]' \
    "$MANIFEST")

  while IFS= read -r key; do
    [ -z "$key" ] && continue
    present=$(KEY_NAME="$key" yq -p json 'has(env(KEY_NAME))' "$path" 2>/dev/null)
    if [ "$present" = "true" ]; then
      pass "owned_sections/json_keys[$path] — owned_key '$key' presente"
    else
      warn "owned_sections/json_keys[$path] — owned_key '$key' ausente no arquivo"
    fi
  done <<< "$owned_keys"

done < <(yq -r '.owned_sections[] | select(.type == "json_keys") | .path' "$MANIFEST")

# ── Resultado ─────────────────────────────────────────────────────────────────

echo ""
echo "════════════════════════════════════════════════════════════════════════"
echo "RESULTADO: ${ERRORS} erro(s), ${WARNINGS} aviso(s)"
echo "════════════════════════════════════════════════════════════════════════"

append_summary ""
append_summary "---"
append_summary "**Resultado:** ${ERRORS} erro(s), ${WARNINGS} aviso(s)"

if [ "$ERRORS" -gt 0 ]; then
  msg="Validação falhou. Execute \`@kairos *pre-push\` localmente e corrija os problemas antes de reabrir o PR."
  append_summary ""
  append_summary "> ❌ ${msg}"
  echo "❌ ${msg}"
  exit 1
else
  if [ "$WARNINGS" -gt 0 ]; then
    msg="Todos os checks obrigatórios passaram. ⚠️  ${WARNINGS} aviso(s) — não bloqueiam o merge."
  else
    msg="Todos os checks passaram."
  fi
  append_summary ""
  append_summary "> ✅ ${msg}"
  echo "✅ ${msg}"
  exit 0
fi
