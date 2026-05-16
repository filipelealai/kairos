#!/usr/bin/env bash
# Kairos — Desinstalador Interativo (Linux / macOS / WSL)
# Remove apenas conteúdo declarado no manifesto.
# Preserva, por padrão, outputs e .env do usuário.
#
# Uso:
#   bash uninstall.sh
#   (executar de dentro da pasta de instalação do Kairos)

set -euo pipefail

# ─── Cores ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; BOLD='\033[1m'; RESET='\033[0m'
ok()   { echo -e "  ${GREEN}✅${RESET}  $*"; }
warn() { echo -e "  ${YELLOW}⚠️${RESET}   $*"; }
err()  { echo -e "  ${RED}❌${RESET}  $*"; }
info() { echo -e "  ${BLUE}→${RESET}  $*"; }

# ─── Caminhos absolutos salvos antes de qualquer cd ──────────────────────────
SCRIPT_PATH="$(realpath "$0" 2>/dev/null || readlink -f "$0" 2>/dev/null || echo "$(pwd)/uninstall.sh")"
INSTALL_DIR_ABS="$(pwd)"

# ─── Verificar que estamos na pasta correta ────────────────────────────────────
MANIFEST=".kairos-core/manifest.yaml"
if [[ ! -f "$MANIFEST" ]]; then
  err "manifest.yaml não encontrado em '$(pwd)'."
  echo ""
  echo "   Execute este script de dentro da pasta de instalação do Kairos."
  echo "   Exemplo: cd ~/kairos && bash uninstall.sh"
  exit 1
fi

# ─── Banner ───────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}"
cat << 'BANNER'
   ██╗  ██╗ █████╗ ██╗██████╗  ██████╗ ███████╗
   ██║ ██╔╝██╔══██╗██║██╔══██╗██╔═══██╗██╔════╝
   █████╔╝ ███████║██║██████╔╝██║   ██║███████╗
   ██╔═██╗ ██╔══██║██║██╔══██╗██║   ██║╚════██║
   ██║  ██╗██║  ██║██║██║  ██║╚██████╔╝███████║
   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝
BANNER
echo -e "${RESET}"
echo "   Desinstalador — Kairos Framework"
echo ""
echo "   ─────────────────────────────────────────────────────"
echo "   Este desinstalador remove apenas o conteúdo do"
echo "   framework Kairos (declarado em manifest.yaml)."
echo "   Seus dados, squads, scripts e .env são preservados"
echo "   por padrão — você decide o que remover."
echo "   ─────────────────────────────────────────────────────"
echo ""
echo "   Pasta: $(pwd)"
echo ""

read -rp "   Continuar com a desinstalação? [s/N] → " start_confirm
if [[ "${start_confirm,,}" != "s" ]]; then
  info "Desinstalação cancelada."
  exit 0
fi
echo ""

# ─── Perguntas sobre o que preservar ─────────────────────────────────────────
echo -e "  ${BOLD}O que você quer preservar?${RESET}"
echo ""

read -rp "   Preservar seus outputs em data/outputs/? [S/n] → " keep_outputs
KEEP_OUTPUTS=true
[[ "${keep_outputs,,}" == "n" ]] && KEEP_OUTPUTS=false

read -rp "   Preservar seu .env (caso reinstale depois)? [S/n] → " keep_env
KEEP_ENV=true
[[ "${keep_env,,}" == "n" ]] && KEEP_ENV=false

read -rp "   Apagar TUDO da pasta (inclusive arquivos fora do framework)? [s/N] → " nuke_all
NUKE_ALL=false
if [[ "${nuke_all,,}" == "s" ]]; then
  echo ""
  warn "Isso vai remover TUDO na pasta, incluindo seus squads, scripts e dados."
  read -rp "   Tem certeza? Digite 'APAGAR TUDO' para confirmar → " nuke_confirm
  [[ "$nuke_confirm" == "APAGAR TUDO" ]] && NUKE_ALL=true || warn "Confirmação inválida — operação destrutiva cancelada."
fi
echo ""

# ─── Extrair paths do manifesto ───────────────────────────────────────────────
extract_owned_files() {
  local manifest="$1"
  if command -v python3 &>/dev/null; then
    python3 - <<PYEOF
import re
with open('$manifest') as f:
    content = f.read()
# Pegar apenas owned_files (antes de owned_sections e sync_files)
in_owned = False
paths = []
for line in content.split('\n'):
    if line.startswith('owned_files:'):
        in_owned = True
        continue
    if in_owned and (line.startswith('owned_sections:') or line.startswith('sync_files:') or line.startswith('notes:')):
        in_owned = False
    if in_owned:
        m = re.match(r'\s*-\s*path:\s*(.+)', line)
        if m:
            paths.append(m.group(1).strip())
for p in paths:
    print(p)
PYEOF
  else
    # Fallback: pegar todas as linhas "- path:" antes de "owned_sections:"
    awk '/^owned_files:/{f=1} /^owned_sections:|^sync_files:/{f=0} f && /^\s*-\s*path:/{
      gsub(/^\s*-\s*path:\s*/, ""); print
    }' "$manifest"
  fi
}

extract_owned_sections_full() {
  local manifest="$1"
  if command -v python3 &>/dev/null; then
    python3 - "$manifest" <<'PYEOF'
import sys, re

manifest = sys.argv[1]
with open(manifest) as f:
    content = f.read()

in_sections = False
entries = []
current = None
in_keys = False

for line in content.split('\n'):
    if line.startswith('owned_sections:'):
        in_sections = True
        continue
    # End of owned_sections: top-level YAML key (starts with letter at col 0)
    if in_sections and line and line[0].isalpha():
        if current:
            entries.append(current)
            current = None
        break
    if in_sections:
        # List items start at col 0 with "- path:"
        m = re.match(r'^- path:\s*(.+)', line)
        if m:
            if current:
                entries.append(current)
            current = {'path': m.group(1).strip(), 'type': '', 'keys': []}
            in_keys = False
            continue
        if current:
            if in_keys:
                # owned_keys items are at 2-space indent: "  - key"
                mk = re.match(r'^  - (.+)', line)
                if mk:
                    current['keys'].append(mk.group(1).strip())
                    continue
                else:
                    in_keys = False
                    # fall through to check other attributes
            m = re.match(r'^  type:\s*(.+)', line)
            if m:
                current['type'] = m.group(1).strip()
                continue
            m = re.match(r'^  owned_keys:\s*\[(.+)\]', line)
            if m:
                current['keys'] = [k.strip() for k in m.group(1).split(',')]
                in_keys = False
                continue
            m = re.match(r'^  owned_keys:\s*$', line)
            if m:
                in_keys = True
                continue

if current:
    entries.append(current)

for e in entries:
    print(f"{e['path']}|{e['type']}|{','.join(e['keys'])}")
PYEOF
  else
    # Fallback awk: retorna apenas path — só processa markdown_blocks
    awk '/^owned_sections:/{f=1} /^[a-zA-Z]/{if(f && !/^owned_sections:/)f=0} f && /^- path:/{
      gsub(/^- path:\s*/, ""); print $0 "|markdown_blocks|"
    }' "$manifest"
  fi
}

extract_sync_files() {
  local manifest="$1"
  if command -v python3 &>/dev/null; then
    python3 - <<PYEOF
import re
with open('$manifest') as f:
    content = f.read()
in_sync = False
paths = []
for line in content.split('\n'):
    if line.startswith('sync_files:'):
        in_sync = True
        continue
    if in_sync and line and line[0].isalpha():
        in_sync = False
    if in_sync:
        m = re.match(r'\s*-\s*path:\s*(.+)', line)
        if m:
            paths.append(m.group(1).strip())
for p in paths:
    print(p)
PYEOF
  else
    awk '/^sync_files:/{f=1} /^notes:/{f=0} f && /^\s*-\s*path:/{
      gsub(/^\s*-\s*path:\s*/, ""); print
    }' "$manifest"
  fi
}

# ─── Remover marcadores KAIROS-MANAGED de arquivo misto ──────────────────────
clean_managed_sections() {
  local file="$1"
  local stype="${2:-}"
  local keys="${3:-}"
  if [[ ! -f "$file" ]]; then return; fi

  if command -v python3 &>/dev/null; then
    python3 - "$file" "$stype" "$keys" <<'PYEOF'
import sys, re, json, os

filepath, stype, keys_str = sys.argv[1], sys.argv[2], sys.argv[3]
keys = [k for k in keys_str.split(',') if k]

if stype == 'markdown_blocks' or (not stype and filepath.endswith('.md')):
    with open(filepath, 'r') as f:
        content = f.read()
    cleaned = re.sub(
        r'<!-- KAIROS-MANAGED-START:[^>]+ -->\n.*?<!-- KAIROS-MANAGED-END:[^>]+ -->\n?',
        '', content, flags=re.DOTALL
    )
    if not cleaned.strip():
        os.remove(filepath)
    else:
        with open(filepath, 'w') as f:
            f.write(cleaned)

elif stype == 'comment_blocks':
    with open(filepath, 'r') as f:
        content = f.read()
    cleaned = re.sub(
        r'# KAIROS-MANAGED-START:[^\n]*\n.*?# KAIROS-MANAGED-END:[^\n]*\n?',
        '', content, flags=re.DOTALL
    )
    if not cleaned.strip():
        os.remove(filepath)
    else:
        with open(filepath, 'w') as f:
            f.write(cleaned)

elif stype == 'json_keys' and keys:
    try:
        with open(filepath, 'r') as f:
            data = json.load(f)
        for k in keys:
            data.pop(k, None)
        if not data:
            os.remove(filepath)
        else:
            with open(filepath, 'w') as f:
                json.dump(data, f, indent=2, ensure_ascii=False)
                f.write('\n')
    except Exception as e:
        print(f'WARN: nao foi possivel processar JSON {filepath}: {e}', file=sys.stderr)

elif stype == 'yaml_keys':
    os.remove(filepath)
PYEOF
  else
    # Fallback sem python3: só markdown e env
    if [[ "$stype" == "markdown_blocks" ]] || [[ "$file" == *.md ]]; then
      sed -i '/<!-- KAIROS-MANAGED-START:/,/<!-- KAIROS-MANAGED-END:.*-->/d' "$file"
    elif [[ "$stype" == "comment_blocks" ]]; then
      sed -i '/# KAIROS-MANAGED-START:/,/# KAIROS-MANAGED-END:/d' "$file"
    fi
  fi

  # Se o arquivo ficar vazio ou só whitespace, deletar
  if [[ -f "$file" ]] && [[ -z "$(tr -d '[:space:]' < "$file")" ]]; then
    rm -f "$file"
    info "Removido (ficou vazio): $file"
  fi
}

# ─── Pré-extrair listas ANTES de qualquer remoção ────────────────────────────
OWNED_FILES_LIST=$(extract_owned_files "$MANIFEST")
OWNED_SECTIONS_LIST=$(extract_owned_sections_full "$MANIFEST")
SYNC_FILES_LIST=$(extract_sync_files "$MANIFEST")

# ─── Contadores ───────────────────────────────────────────────────────────────
DELETED_FILES=0
CLEANED_SECTIONS=0
DELETED_DIRS=0
SKIPPED=0

# ─── Remover owned_files ──────────────────────────────────────────────────────
info "Removendo arquivos do framework (owned_files)..."
while IFS= read -r rel_path; do
  [[ -z "$rel_path" ]] && continue
  [[ "$rel_path" == ".kairos-core/manifest.yaml" ]] && continue

  if [[ "$KEEP_OUTPUTS" == "true" ]] && [[ "$rel_path" == data/outputs* ]]; then
    SKIPPED=$((SKIPPED + 1))
    continue
  fi
  if [[ "$KEEP_ENV" == "true" ]] && [[ "$rel_path" == ".env" ]]; then
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  if [[ -f "$rel_path" ]]; then
    rm -f "$rel_path"
    DELETED_FILES=$((DELETED_FILES + 1))
  fi
done <<< "$OWNED_FILES_LIST"

# Remover manifest.yaml por último (owned_files)
if [[ -f "$MANIFEST" ]]; then
  rm -f "$MANIFEST"
  DELETED_FILES=$((DELETED_FILES + 1))
fi

# ─── Limpar seções em owned_sections ─────────────────────────────────────────
info "Limpando seções gerenciadas (owned_sections)..."
while IFS='|' read -r rel_path stype keys; do
  [[ -z "$rel_path" ]] && continue
  if [[ -f "$rel_path" ]]; then
    clean_managed_sections "$rel_path" "$stype" "$keys"
    CLEANED_SECTIONS=$((CLEANED_SECTIONS + 1))
  fi
done <<< "$OWNED_SECTIONS_LIST"

# ─── Remover sync_files (sempre — são conteúdo do framework instalado) ────────
while IFS= read -r rel_path; do
  [[ -z "$rel_path" ]] && continue
  if [[ -f "$rel_path" ]]; then
    rm -f "$rel_path"
    DELETED_FILES=$((DELETED_FILES + 1))
  fi
done <<< "$SYNC_FILES_LIST"

# ─── Remover .env se o usuário não quer preservar ─────────────────────────────
if [[ "$KEEP_ENV" != "true" ]] && [[ -f ".env" ]]; then
  rm -f ".env"
  DELETED_FILES=$((DELETED_FILES + 1))
fi

# ─── Apagar tudo se nuke_all ──────────────────────────────────────────────────
if [[ "$NUKE_ALL" == "true" ]]; then
  info "Removendo pasta completa..."
  cd ..
  INSTALL_DIR_ABS="$(realpath -m "$(pwd)/$(basename "$OLDPWD")" 2>/dev/null || echo "$OLDPWD")"
  # Não remover home do usuário por engano
  if [[ "$INSTALL_DIR_ABS" != "$HOME" ]] && [[ "$INSTALL_DIR_ABS" != "/" ]]; then
    if [[ "$KEEP_OUTPUTS" == "true" ]]; then
      warn "Outputs preservados — apagando o resto da pasta."
      # Não é possível apagar tudo e preservar outputs ao mesmo tempo
      # Voltamos ao modo de remoção seletiva
      cd "$INSTALL_DIR_ABS" 2>/dev/null || true
    else
      rm -rf "$INSTALL_DIR_ABS"
      ok "Pasta '$INSTALL_DIR_ABS' removida."
    fi
  else
    err "Recusando remover '$INSTALL_DIR_ABS' — parece ser o diretório home."
  fi
fi

# ─── Remover pastas vazias (bottom-up) ───────────────────────────────────────
if [[ "$NUKE_ALL" == "false" ]]; then
  # Remover symlinks antes de testar pastas vazias (symlink impede rmdir)
  # Symlink não é dado — o conteúdo está no destino. Remove sempre.
  while IFS= read -r sym; do
    [[ -z "$sym" ]] && continue
    rm -f "$sym"
    DELETED_FILES=$((DELETED_FILES + 1))
  done < <(find . -mindepth 1 -type l 2>/dev/null)
  info "Removendo pastas vazias..."
  while true; do
    _pass_removed=0
    while IFS= read -r dir; do
      if [[ "$KEEP_OUTPUTS" == "true" ]] && [[ "$dir" == ./data/outputs* ]]; then
        continue
      fi
      if rmdir "$dir" 2>/dev/null; then
        DELETED_DIRS=$((DELETED_DIRS + 1))
        _pass_removed=1
      fi
    done < <(find . -mindepth 1 -type d -empty 2>/dev/null | sort -r)
    [[ $_pass_removed -eq 0 ]] && break
  done
fi

# ─── Resumo ───────────────────────────────────────────────────────────────────
echo ""
echo "   ─────────────────────────────────────────────────────"
echo -e "   ${BOLD}Desinstalação concluída${RESET}"
echo "   ─────────────────────────────────────────────────────"
echo ""
ok "$DELETED_FILES arquivos de framework removidos"
ok "$CLEANED_SECTIONS seções gerenciadas limpas de arquivos mistos"
[[ $DELETED_DIRS -gt 0 ]] && ok "$DELETED_DIRS pastas vazias removidas"
[[ $SKIPPED -gt 0 ]] && info "$SKIPPED itens preservados (outputs / .env)"
echo ""
if [[ "$KEEP_OUTPUTS" == "true" ]]; then
  info "Seus outputs em data/outputs/ foram preservados."
fi
if [[ "$KEEP_ENV" == "true" ]]; then
  info "Seu .env foi preservado."
fi
echo ""
echo "   Para reinstalar: bash install.sh"
echo "   (ou: curl -fsSL https://raw.githubusercontent.com/filipelealweb/kairos/main/install.sh | bash)"
echo ""

# ─── Auto-deleção do script ───────────────────────────────────────────────────
if [[ -f "$SCRIPT_PATH" ]]; then
  rm -f "$SCRIPT_PATH"
fi

# ─── Remover pasta do projeto se ficou vazia ──────────────────────────────────
PARENT_DIR="$(dirname "$INSTALL_DIR_ABS")"
if [[ -z "$(ls -A "$INSTALL_DIR_ABS" 2>/dev/null)" ]]; then
  cd "$PARENT_DIR"
  rmdir "$INSTALL_DIR_ABS" 2>/dev/null && ok "Pasta '$(basename "$INSTALL_DIR_ABS")' removida (ficou vazia)."
fi
