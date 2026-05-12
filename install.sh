#!/usr/bin/env bash
# Kairos — Instalador Interativo (Linux / macOS / WSL)
# Instala o framework Kairos sem necessidade de Git.
#
# Uso:
#   curl -fsSL https://raw.githubusercontent.com/filipelealweb/kairos/main/install.sh | bash
#   ou: bash install.sh

set -euo pipefail

KAIROS_REPO="filipelealweb/kairos"
KAIROS_API="https://api.github.com/repos/${KAIROS_REPO}/releases/latest"
DEFAULT_INSTALL_DIR="${HOME}/kairos"

# ─── Cores ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; BOLD='\033[1m'; RESET='\033[0m'
ok()   { echo -e "  ${GREEN}✅${RESET}  $*"; }
warn() { echo -e "  ${YELLOW}⚠️${RESET}   $*"; }
err()  { echo -e "  ${RED}❌${RESET}  $*"; }
info() { echo -e "  ${BLUE}→${RESET}  $*"; }

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
echo "   Framework de Orquestração de Agentes de IA"
echo "   Instalador v1.0 — Linux / macOS / WSL"
echo ""
echo "   ─────────────────────────────────────────────────────"
echo "   Vamos instalar o Kairos na sua máquina."
echo "   Isso vai criar uma pasta de projeto com o framework"
echo "   pronto para uso com o Claude Code. Sem Git necessário."
echo "   ─────────────────────────────────────────────────────"
echo ""

# ─── Detectar SO ──────────────────────────────────────────────────────────────
detect_os() {
  if [[ -f /proc/sys/fs/binfmt_misc/WSLInterop ]] || grep -qi microsoft /proc/version 2>/dev/null; then
    echo "wsl"
  elif [[ "$(uname)" == "Darwin" ]]; then
    echo "mac"
  else
    echo "linux"
  fi
}

OS=$(detect_os)
case "$OS" in
  wsl)   info "Sistema detectado: Windows com WSL2" ;;
  mac)   info "Sistema detectado: macOS" ;;
  linux) info "Sistema detectado: Linux" ;;
esac
echo ""

# ─── Verificar Claude Code ────────────────────────────────────────────────────
echo -e "  ${BOLD}Verificando pré-requisitos...${RESET}"
echo ""

CLAUDE_CMD=""
if command -v claude &>/dev/null; then
  CLAUDE_CMD="claude"
elif [[ "$OS" == "wsl" ]] && command -v claude.exe &>/dev/null; then
  CLAUDE_CMD="claude.exe"
fi

# Fallback: tentar carregar node managers sem depender do .bashrc
# (necessário em shells não-interativos onde o guard "case $- in *i*" pula a inicialização)
if [[ -z "$CLAUDE_CMD" ]]; then
  # fnm
  _fnm="${HOME}/.local/share/fnm/fnm"
  if [[ -x "$_fnm" ]]; then
    eval "$($_fnm env 2>/dev/null)" 2>/dev/null || true
    command -v claude &>/dev/null && CLAUDE_CMD="claude"
  fi
  # nvm
  if [[ -z "$CLAUDE_CMD" ]] && [[ -f "${NVM_DIR:-$HOME/.nvm}/nvm.sh" ]]; then
    source "${NVM_DIR:-$HOME/.nvm}/nvm.sh" 2>/dev/null
    command -v claude &>/dev/null && CLAUDE_CMD="claude"
  fi
fi

if [[ -n "$CLAUDE_CMD" ]]; then
  CLAUDE_VER=$($CLAUDE_CMD --version 2>/dev/null | head -1 || echo "instalado")
  ok "Claude Code encontrado: $CLAUDE_VER"
else
  err "Claude Code não encontrado."
  echo ""
  echo "   O Kairos requer o Claude Code (CLI ou aba 'Claude Code'"
  echo "   do Claude Desktop). Instale antes de continuar."
  echo ""
  if [[ "$OS" == "mac" ]]; then
    echo "   macOS — opções:"
    echo "     • Claude Desktop: https://claude.ai/download"
    echo "     • CLI via npm:    npm install -g @anthropic-ai/claude-code"
  else
    echo "   Linux / WSL — opções:"
    echo "     • CLI via npm:    npm install -g @anthropic-ai/claude-code"
    echo "     • Claude Desktop: https://claude.ai/download (instala claude.exe acessível no WSL)"
  fi
  echo ""
  echo "   Após instalar, execute este script novamente."
  exit 1
fi

# ─── Git (opcional) ───────────────────────────────────────────────────────────
if command -v git &>/dev/null; then
  ok "Git encontrado: $(git --version | head -1)"
else
  warn "Git não encontrado."
  echo ""
  echo "   Git não é necessário para usar o Kairos no dia a dia."
  echo "   É necessário apenas para contribuir com o framework."
  echo ""
  read -rp "   Quer instalar Git? [s/N] " install_git </dev/tty
  if [[ "${install_git,,}" == "s" ]]; then
    if [[ "$OS" == "mac" ]]; then
      echo "   Execute: brew install git"
      echo "   (Instale o Homebrew primeiro em https://brew.sh se necessário)"
    elif [[ "$OS" == "wsl" ]]; then
      echo "   Execute no WSL: sudo apt-get install -y git"
    else
      echo "   Ubuntu/Debian:  sudo apt-get install -y git"
      echo "   Fedora/RHEL:    sudo dnf install -y git"
      echo "   Arch:           sudo pacman -S git"
    fi
    echo ""
    echo "   Instale o Git e execute este script novamente se precisar dele."
    echo "   Continuando instalação do Kairos sem Git..."
  fi
fi
echo ""

# ─── Pasta de instalação ──────────────────────────────────────────────────────
echo -e "  ${BOLD}Pasta de instalação${RESET}"
echo ""
echo "   Onde instalar o Kairos? (pasta onde ficará o projeto)"
read -rp "   [${DEFAULT_INSTALL_DIR}] → " INSTALL_DIR </dev/tty
INSTALL_DIR="${INSTALL_DIR:-$DEFAULT_INSTALL_DIR}"
INSTALL_DIR="${INSTALL_DIR/#\~/$HOME}"
INSTALL_DIR="${INSTALL_DIR%/}"   # remover trailing slash

if [[ -d "$INSTALL_DIR" ]] && [[ -n "$(ls -A "$INSTALL_DIR" 2>/dev/null)" ]]; then
  echo ""
  warn "A pasta '${INSTALL_DIR}' já existe e não está vazia."
  echo ""
  echo "   O instalador não sobrescreve conteúdo user-owned existente."
  echo "   Apenas arquivos do framework serão atualizados."
  echo ""
  read -rp "   Continuar mesmo assim? [s/N] → " cont </dev/tty
  if [[ "${cont,,}" != "s" ]]; then
    echo ""
    info "Instalação cancelada."
    exit 0
  fi
fi

mkdir -p "$INSTALL_DIR"
ok "Pasta de instalação: $INSTALL_DIR"
echo ""

# ─── Buscar versão mais recente ───────────────────────────────────────────────
echo -e "  ${BOLD}Baixando o Kairos...${RESET}"
echo ""
if [[ -n "${KAIROS_TAG:-}" ]]; then
  LATEST_TAG="$KAIROS_TAG"
  info "Tag override: ${LATEST_TAG}"
else
  info "Buscando versão mais recente..."
  LATEST_TAG=$(curl -fsSL "$KAIROS_API" \
    -H "Accept: application/vnd.github+json" 2>/dev/null \
    | grep '"tag_name"' | head -1 | cut -d'"' -f4) || true

  if [[ -z "$LATEST_TAG" ]]; then
    # Fallback: tentar via tags API
    LATEST_TAG=$(curl -fsSL "https://api.github.com/repos/${KAIROS_REPO}/tags" \
      -H "Accept: application/vnd.github+json" 2>/dev/null \
      | grep '"name"' | head -1 | cut -d'"' -f4) || true
  fi
fi

if [[ -z "$LATEST_TAG" ]]; then
  err "Não foi possível obter a versão mais recente."
  echo "   Verifique sua conexão com a internet e tente novamente."
  echo "   Se o problema persistir, baixe manualmente em:"
  echo "   https://github.com/${KAIROS_REPO}/releases"
  exit 1
fi

ok "Versão encontrada: $LATEST_TAG"

# ─── Baixar tarball ───────────────────────────────────────────────────────────
TARBALL_URL="https://github.com/${KAIROS_REPO}/archive/refs/tags/${LATEST_TAG}.tar.gz"
TMPDIR_EXTRACT=$(mktemp -d)
TARBALL_PATH="${TMPDIR_EXTRACT}/kairos.tar.gz"

info "Baixando Kairos ${LATEST_TAG}..."

if ! curl -fsSL -o "$TARBALL_PATH" "$TARBALL_URL"; then
  err "Falha no download. Verifique sua conexão."
  rm -rf "$TMPDIR_EXTRACT"
  exit 1
fi

info "Extraindo arquivos..."
tar -xzf "$TARBALL_PATH" -C "$TMPDIR_EXTRACT"
EXTRACTED_DIR=$(find "$TMPDIR_EXTRACT" -mindepth 1 -maxdepth 1 -type d | head -1)

if [[ -z "$EXTRACTED_DIR" ]]; then
  err "Falha ao extrair o tarball. Arquivo pode estar corrompido."
  rm -rf "$TMPDIR_EXTRACT"
  exit 1
fi

# ─── Ler manifesto e copiar arquivos ──────────────────────────────────────────
MANIFEST="${EXTRACTED_DIR}/.kairos-core/manifest.yaml"
if [[ ! -f "$MANIFEST" ]]; then
  err "manifest.yaml não encontrado no tarball."
  rm -rf "$TMPDIR_EXTRACT"
  exit 1
fi

info "Instalando arquivos do framework (via manifest.yaml)..."

# Extrair paths apenas de owned_files e owned_sections (não sync_files)
extract_paths() {
  local manifest="$1"
  if command -v python3 &>/dev/null; then
    python3 - <<PYEOF
import sys
paths = []
with open('${manifest}') as f:
    lines = f.readlines()
section = None
for line in lines:
    stripped = line.rstrip()
    if stripped and not stripped[0].isspace() and stripped.endswith(':'):
        section = stripped.rstrip(':')
    if section in ('owned_files', 'owned_sections') and stripped.lstrip().startswith('- path:'):
        p = stripped.split('- path:')[1].strip()
        if p:
            paths.append(p)
for p in paths:
    print(p)
PYEOF
  else
    awk '/^owned_files:|^owned_sections:/{p=1} /^sync_files:|^notes:/{p=0} p && /- path:/{gsub(/.*path: /,""); print}' "$manifest"
  fi
}

INSTALL_COUNT=0
SKIP_COUNT=0

while IFS= read -r rel_path; do
  [[ -z "$rel_path" ]] && continue
  src="${EXTRACTED_DIR}/${rel_path}"
  dst="${INSTALL_DIR}/${rel_path}"
  if [[ -f "$src" ]]; then
    mkdir -p "$(dirname "$dst")"
    cp -p "$src" "$dst"
    INSTALL_COUNT=$((INSTALL_COUNT + 1))
  else
    SKIP_COUNT=$((SKIP_COUNT + 1))
  fi
done < <(extract_paths "$MANIFEST")

# Pastas obrigatórias vazias (runtime, data, docs, squads)
for special_dir in ".kairos-core/runtime" "data" "data/outputs" "docs" "squads"; do
  mkdir -p "${INSTALL_DIR}/${special_dir}"
done

# Apenas LICENSE dos sync_files — o resto (README, CONTRIBUTING etc.) fica no repo público
for sync_file in "LICENSE"; do
  src="${EXTRACTED_DIR}/${sync_file}"
  dst="${INSTALL_DIR}/${sync_file}"
  if [[ -f "$src" ]]; then
    cp -p "$src" "$dst"
  fi
done

# .env.example (para gerar o .env)
if [[ -f "${EXTRACTED_DIR}/.env.example" ]]; then
  cp -p "${EXTRACTED_DIR}/.env.example" "${INSTALL_DIR}/.env.example"
fi

ok "$INSTALL_COUNT arquivos de framework instalados."
echo ""

# ─── Elicitação — configuração da instância ──────────────────────────────────
echo -e "  ${BOLD}Configurando sua instância${RESET}"
echo ""
echo "   ─────────────────────────────────────────────────────"
echo "   O Kairos identifica seus outputs com um nome de instância."
echo "   Isso evita colisões quando mais de uma pessoa do time"
echo "   roda o Kairos no mesmo dia com os mesmos dados."
echo ""
read -rp "   Qual o seu nome ou apelido? (ex: joao, maria, dev1) → " INSTANCE_NAME_RAW </dev/tty
# Normalizar: minúsculas, espaços → hífens, remover caracteres especiais
INSTANCE_NAME=$(echo "${INSTANCE_NAME_RAW:-default}" \
  | tr '[:upper:]' '[:lower:]' \
  | { iconv -f UTF-8 -t ASCII//TRANSLIT 2>/dev/null || cat; } \
  | tr ' ' '-' \
  | tr -cd '[:alnum:]-' \
  | sed 's/-\{2,\}/-/g; s/^-//; s/-$//')
INSTANCE_NAME="${INSTANCE_NAME:-default}"

ok "Nome de instância: $INSTANCE_NAME"
echo ""

# ─── Gerar .env ───────────────────────────────────────────────────────────────
ENV_EXAMPLE="${INSTALL_DIR}/.env.example"
ENV_FILE="${INSTALL_DIR}/.env"

if [[ ! -f "$ENV_FILE" ]]; then
  if [[ -f "$ENV_EXAMPLE" ]]; then
    cp "$ENV_EXAMPLE" "$ENV_FILE"
  else
    cat > "$ENV_FILE" << ENVEOF
# Kairos — Variáveis de Ambiente
# Gerado pelo instalador em $(date -u +%Y-%m-%dT%H:%M:%SZ)

# KAIROS-MANAGED-START: framework
KAIROS_INSTANCE_NAME=
# KAIROS-MANAGED-END: framework
ENVEOF
  fi
fi

# Definir KAIROS_INSTANCE_NAME no .env
if grep -q "^KAIROS_INSTANCE_NAME=" "$ENV_FILE" 2>/dev/null; then
  sed -i "s|^KAIROS_INSTANCE_NAME=.*|KAIROS_INSTANCE_NAME=${INSTANCE_NAME}|" "$ENV_FILE"
elif grep -q "^KAIROS_INSTANCE_NAME" "$ENV_FILE" 2>/dev/null; then
  sed -i "s|^KAIROS_INSTANCE_NAME.*|KAIROS_INSTANCE_NAME=${INSTANCE_NAME}|" "$ENV_FILE"
else
  # Inserir após a linha do marcador framework se existir
  if grep -q "KAIROS-MANAGED-START: framework" "$ENV_FILE" 2>/dev/null; then
    sed -i "/KAIROS-MANAGED-START: framework/a KAIROS_INSTANCE_NAME=${INSTANCE_NAME}" "$ENV_FILE"
  else
    echo "KAIROS_INSTANCE_NAME=${INSTANCE_NAME}" >> "$ENV_FILE"
  fi
fi

ok ".env criado com KAIROS_INSTANCE_NAME=${INSTANCE_NAME}"
echo ""

# ─── Cloud sync (opcional) ────────────────────────────────────────────────────

# Helpers de persistência rclone
_rclone_add_bashrc() {
  local remote="$1" mount_pt="$2"
  local marker="# KAIROS-RCLONE-MOUNT"
  if grep -q "$marker" "${HOME}/.bashrc" 2>/dev/null; then
    info "Bloco rclone já existe em ~/.bashrc — não duplicando."
  else
    cat >> "${HOME}/.bashrc" <<BASHBLOCK

${marker}
if ! mount 2>/dev/null | grep -qE "type fuse\.rclone.*${mount_pt}|${mount_pt}.*fuse\.rclone"; then
  mkdir -p "${mount_pt}"
  rclone mount "${remote}": "${mount_pt}" \\
    --vfs-cache-mode writes --dir-cache-time 5s \\
    --poll-interval 5s --daemon 2>/dev/null || true
fi
${marker}-END
BASHBLOCK
    ok "Bloco rclone adicionado ao ~/.bashrc"
    warn "Nota: ~/.bashrc só executa em terminais interativos — não funciona com hooks/cron."
  fi
}

_rclone_systemd_user() {
  local remote="$1" mount_pt="$2"
  local unit="rclone-kairos-${remote}.service"
  local udir="${HOME}/.config/systemd/user"
  mkdir -p "$udir"
  cat > "${udir}/${unit}" <<UNIT
[Unit]
Description=rclone mount — kairos ${remote}
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStartPre=/bin/mkdir -p ${mount_pt}
ExecStart=/usr/bin/rclone mount ${remote}: ${mount_pt} --vfs-cache-mode writes --dir-cache-time 5s --poll-interval 5s
ExecStop=/bin/fusermount -uz ${mount_pt}
Restart=on-failure

[Install]
WantedBy=default.target
UNIT
  systemctl --user daemon-reload 2>/dev/null || true
  systemctl --user enable "$unit" 2>/dev/null && systemctl --user start "$unit" 2>/dev/null || true
  ok "systemd --user unit criado e habilitado: ${unit}"
}

_rclone_systemd_system() {
  local remote="$1" mount_pt="$2"
  local unit="rclone-kairos-${remote}.service"
  sudo tee "/etc/systemd/system/${unit}" > /dev/null <<UNIT
[Unit]
Description=rclone mount — kairos ${remote}
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=${USER}
ExecStartPre=/bin/mkdir -p ${mount_pt}
ExecStart=/usr/bin/rclone mount ${remote}: ${mount_pt} --vfs-cache-mode writes --dir-cache-time 5s --poll-interval 5s
ExecStop=/bin/fusermount -uz ${mount_pt}
Restart=on-failure

[Install]
WantedBy=multi-user.target
UNIT
  sudo systemctl daemon-reload 2>/dev/null || true
  sudo systemctl enable "$unit" 2>/dev/null && sudo systemctl start "$unit" 2>/dev/null || true
  ok "systemd system unit criado e habilitado: ${unit}"
}

echo "   ─────────────────────────────────────────────────────"
echo "   Sincronização de outputs com a nuvem (opcional)"
echo "   ─────────────────────────────────────────────────────"
echo ""
echo "   O Kairos pode sincronizar os outputs dos agentes para"
echo "   uma pasta compartilhada. Zero OAuth — usa o app nativo"
echo "   do seu provedor ou rclone."
echo ""
read -rp "   Quer configurar o sync de outputs agora? [s/N] → " do_cloud </dev/tty

CLOUD_MODE="skip"
CLOUD_ROOT=""
CLOUD_PROVIDER=""

if [[ "${do_cloud,,}" == "s" ]]; then

  # --- Detectar provedores por OS ---
  DETECTED_NAMES=()
  DETECTED_ROOTS=()
  DETECTED_PROVIDERS=()

  if [[ "$OS" == "mac" ]]; then
    _icloud="${HOME}/Library/Mobile Documents/com~apple~CloudDocs"
    if [[ -d "$_icloud" ]]; then
      DETECTED_NAMES+=("iCloud Drive")
      DETECTED_ROOTS+=("$_icloud")
      DETECTED_PROVIDERS+=("iCloud")
    fi
    for _gd in "${HOME}/Library/CloudStorage/GoogleDrive-"*/; do
      [[ -d "$_gd" ]] || continue
      _acct=$(basename "$_gd" | sed 's/^GoogleDrive-//')
      DETECTED_NAMES+=("Google Drive (${_acct})")
      DETECTED_ROOTS+=("${_gd%/}")
      DETECTED_PROVIDERS+=("Google Drive")
    done
    if [[ -d "${HOME}/Google Drive" ]]; then
      DETECTED_NAMES+=("Google Drive")
      DETECTED_ROOTS+=("${HOME}/Google Drive")
      DETECTED_PROVIDERS+=("Google Drive")
    fi
    for _od in "${HOME}/Library/CloudStorage/OneDrive-"*/; do
      [[ -d "$_od" ]] || continue
      _acct=$(basename "$_od" | sed 's/^OneDrive-//')
      DETECTED_NAMES+=("OneDrive (${_acct})")
      DETECTED_ROOTS+=("${_od%/}")
      DETECTED_PROVIDERS+=("OneDrive")
    done
    if [[ -d "${HOME}/OneDrive" ]]; then
      DETECTED_NAMES+=("OneDrive")
      DETECTED_ROOTS+=("${HOME}/OneDrive")
      DETECTED_PROVIDERS+=("OneDrive")
    fi
    for _db in "${HOME}/Dropbox" "${HOME}/Library/CloudStorage/Dropbox"; do
      if [[ -d "$_db" ]]; then
        DETECTED_NAMES+=("Dropbox")
        DETECTED_ROOTS+=("$_db")
        DETECTED_PROVIDERS+=("Dropbox")
        break
      fi
    done
  fi
  # Linux/WSL: sem detecção de apps nativos

  # --- Menu de escolha ---
  if [[ "$OS" == "linux" ]] || [[ "$OS" == "wsl" ]]; then
    echo ""
    echo "   Em Linux/WSL o sync é feito via rclone (mount FUSE)."
    echo ""
    echo "   1) Configurar com rclone"
    echo "   2) Pular — configurar depois com: @kairos *configure-cloud"
    echo ""
    read -rp "   Escolha [1-2] → " _ch </dev/tty
    [[ "$_ch" == "1" ]] && CLOUD_MODE="rclone" || CLOUD_MODE="skip"

  elif [[ ${#DETECTED_NAMES[@]} -eq 0 ]]; then
    echo ""
    echo "   Nenhum app de nuvem detectado automaticamente."
    echo ""
    echo "   1) Instalar app de nuvem e executar este script novamente"
    echo "   2) Configurar com rclone"
    echo "   3) Informar path manualmente"
    echo "   4) Pular — configurar depois com: @kairos *configure-cloud"
    echo ""
    read -rp "   Escolha [1-4] → " _ch </dev/tty
    case "$_ch" in
      1)
        echo ""
        info "Instale um dos apps abaixo e execute este script novamente:"
        echo "   • Google Drive Desktop → https://drive.google.com/drive/download"
        echo "   • OneDrive             → https://www.microsoft.com/pt-br/microsoft-365/onedrive"
        echo "   • Dropbox              → https://www.dropbox.com/install"
        echo "   • iCloud Drive         → incluso no macOS — abra Ajustes do Sistema"
        CLOUD_MODE="skip"
        ;;
      2) CLOUD_MODE="rclone" ;;
      3) CLOUD_MODE="manual" ;;
      *) CLOUD_MODE="skip" ;;
    esac

  else
    echo ""
    echo "   Apps de nuvem detectados:"
    echo ""
    for _i in "${!DETECTED_NAMES[@]}"; do
      echo "   $((_i+1))) ${DETECTED_NAMES[$_i]}"
    done
    _rc_idx=$(( ${#DETECTED_NAMES[@]} + 1 ))
    _mn_idx=$(( ${#DETECTED_NAMES[@]} + 2 ))
    _sk_idx=$(( ${#DETECTED_NAMES[@]} + 3 ))
    echo "   ${_rc_idx}) Configurar com rclone"
    echo "   ${_mn_idx}) Outro/Custom (informar path manualmente)"
    echo "   ${_sk_idx}) Pular — configurar depois com: @kairos *configure-cloud"
    echo ""
    read -rp "   Escolha [1-${_sk_idx}] → " _ch </dev/tty
    if [[ "$_ch" =~ ^[0-9]+$ ]] && (( _ch >= 1 && _ch <= ${#DETECTED_NAMES[@]} )); then
      CLOUD_MODE="detected"
      CLOUD_ROOT="${DETECTED_ROOTS[$((_ch-1))]}"
      CLOUD_PROVIDER="${DETECTED_PROVIDERS[$((_ch-1))]}"
    elif [[ "$_ch" == "$_rc_idx" ]]; then
      CLOUD_MODE="rclone"
    elif [[ "$_ch" == "$_mn_idx" ]]; then
      CLOUD_MODE="manual"
    else
      CLOUD_MODE="skip"
    fi
  fi

  # --- Wizard rclone ---
  if [[ "$CLOUD_MODE" == "rclone" ]]; then
    if ! command -v rclone &>/dev/null; then
      echo ""
      warn "rclone não encontrado."
      echo ""
      if [[ "$OS" == "mac" ]]; then
        echo "   Instale com: brew install rclone"
      else
        echo "   Instale com: curl https://rclone.org/install.sh | sudo bash"
      fi
      echo ""
      echo "   Após instalar, execute este script novamente ou:"
      echo "   configure depois com: @kairos *configure-cloud"
      CLOUD_MODE="skip"
    else
      _remotes=$(rclone listremotes 2>/dev/null | sed 's/:$//' || true)
      if [[ -z "$_remotes" ]]; then
        echo ""
        warn "Nenhum remote rclone configurado."
        echo ""
        echo "   Execute: rclone config"
        echo "   (OAuth interativo — siga as instruções na tela)"
        echo ""
        echo "   Após configurar, use: @kairos *configure-cloud"
        CLOUD_MODE="skip"
      else
        echo ""
        echo "   Remotes rclone disponíveis:"
        _remote_arr=()
        _ri=1
        while IFS= read -r _r; do
          echo "   ${_ri}) ${_r}"
          _remote_arr+=("$_r")
          _ri=$((_ri+1))
        done <<< "$_remotes"
        echo ""
        read -rp "   Escolha o remote [1-$((_ri-1))] → " _rc </dev/tty

        if [[ "$_rc" =~ ^[0-9]+$ ]] && (( _rc >= 1 && _rc <= ${#_remote_arr[@]} )); then
          RCLONE_REMOTE="${_remote_arr[$((_rc-1))]}"
          _mount_line=$(mount 2>/dev/null | grep -E 'type fuse\.rclone' | grep -i "${RCLONE_REMOTE}" | head -1 || true)
          if [[ -z "$_mount_line" ]]; then
            echo ""
            warn "Nenhum mount ativo para '${RCLONE_REMOTE}'."
            echo ""
            echo "   Para montar, execute em outro terminal:"
            echo "   mkdir -p ~/rclone/${RCLONE_REMOTE}"
            echo "   rclone mount ${RCLONE_REMOTE}: ~/rclone/${RCLONE_REMOTE} \\"
            echo "     --vfs-cache-mode writes --dir-cache-time 5s \\"
            echo "     --poll-interval 5s --daemon"
            echo ""
            read -rp "   Pressione Enter após montar (Ctrl+C para cancelar) → " </dev/tty
            _mount_line=$(mount 2>/dev/null | grep -E 'type fuse\.rclone' | grep -i "${RCLONE_REMOTE}" | head -1 || true)
          fi

          if [[ -n "$_mount_line" ]]; then
            CLOUD_ROOT=$(echo "$_mount_line" | awk '{print $3}')
            CLOUD_PROVIDER="rclone:${RCLONE_REMOTE}"
            CLOUD_MODE="detected"
            echo ""
            ok "Mount ativo: ${CLOUD_ROOT}"

            # Persistência
            echo ""
            if systemctl is-system-running &>/dev/null 2>&1; then
              echo "   systemd detectado. Deseja persistir o mount?"
              echo "   1) systemd --user (sem sudo, recomendado)"
              echo "   2) system-wide (com sudo)"
              echo "   3) Pular"
              read -rp "   Escolha [1-3] → " _persist </dev/tty
              if   [[ "$_persist" == "1" ]]; then _rclone_systemd_user   "$RCLONE_REMOTE" "$CLOUD_ROOT"
              elif [[ "$_persist" == "2" ]]; then _rclone_systemd_system "$RCLONE_REMOTE" "$CLOUD_ROOT"
              fi
            else
              echo "   systemd não está ativo."
              echo "   1) Adicionar ao ~/.bashrc (apenas terminais interativos)"
              echo "   2) Ver instruções para habilitar systemd no WSL"
              echo "   3) Pular"
              read -rp "   Escolha [1-3] → " _persist </dev/tty
              if [[ "$_persist" == "1" ]]; then
                _rclone_add_bashrc "$RCLONE_REMOTE" "$CLOUD_ROOT"
              elif [[ "$_persist" == "2" ]]; then
                echo ""
                info "Para habilitar systemd no WSL:"
                echo "   1. Edite /etc/wsl.conf (como root) e adicione:"
                echo "      [boot]"
                echo "      systemd=true"
                echo "   2. No Windows: wsl --shutdown"
                echo "   3. Reabra o WSL e execute: @kairos *configure-cloud"
              fi
            fi
          else
            warn "Mount ainda não detectado. Configure depois: @kairos *configure-cloud"
            CLOUD_MODE="skip"
          fi
        else
          warn "Escolha inválida — pulando rclone."
          CLOUD_MODE="skip"
        fi
      fi
    fi
  fi

  # --- Path manual ---
  if [[ "$CLOUD_MODE" == "manual" ]]; then
    echo ""
    read -rp "   Caminho absoluto da pasta sincronizada → " CLOUD_ROOT </dev/tty
    CLOUD_ROOT="${CLOUD_ROOT/#\~/$HOME}"
    CLOUD_ROOT="${CLOUD_ROOT%/}"
    if [[ -z "$CLOUD_ROOT" ]]; then
      warn "Nenhum caminho informado — pulando."
      CLOUD_MODE="skip"
    else
      CLOUD_PROVIDER="custom"
      CLOUD_MODE="detected"
    fi
  fi

  # --- Subpasta + symlink ---
  if [[ "$CLOUD_MODE" == "detected" ]] && [[ -n "$CLOUD_ROOT" ]]; then
    echo ""
    echo "   Qual nome de subpasta usar dentro de:"
    echo "   ${CLOUD_ROOT}"
    read -rp "   [Kairos Outputs] → " _subfolder </dev/tty
    _subfolder="${_subfolder:-Kairos Outputs}"
    CLOUD_PATH="${CLOUD_ROOT}/${_subfolder}"

    [[ ! -d "$CLOUD_PATH" ]] && mkdir -p "$CLOUD_PATH"

    OUTPUTS_DIR="${INSTALL_DIR}/data/outputs"
    _skip_symlink=false

    if [[ -L "$OUTPUTS_DIR" ]]; then
      _old=$(readlink -f "$OUTPUTS_DIR" 2>/dev/null || readlink "$OUTPUTS_DIR")
      if [[ "$_old" == "$CLOUD_PATH" ]]; then
        ok "Symlink já aponta para ${CLOUD_PATH} — mantendo."
        _skip_symlink=true
      else
        warn "data/outputs já é um symlink (→ ${_old})."
        read -rp "   Reconfigurar para ${CLOUD_PATH}? [s/N] → " _reconf </dev/tty
        if [[ "${_reconf,,}" == "s" ]]; then
          rm "$OUTPUTS_DIR"
        else
          _skip_symlink=true
          warn "Mantendo symlink anterior. Configure com: @kairos *configure-cloud"
        fi
      fi
    elif [[ -d "$OUTPUTS_DIR" ]]; then
      _content=$(ls -A "$OUTPUTS_DIR" 2>/dev/null)
      [[ -n "$_content" ]] && mv "${OUTPUTS_DIR}"/* "${CLOUD_PATH}/" 2>/dev/null || true
      rmdir "$OUTPUTS_DIR" 2>/dev/null || rm -rf "$OUTPUTS_DIR"
    fi

    if [[ "$_skip_symlink" == "false" ]]; then
      if ln -s "$CLOUD_PATH" "$OUTPUTS_DIR" 2>/dev/null; then
        ok "Cloud sync configurado: data/outputs → ${CLOUD_PATH}"
        RUNTIME_DIR="${INSTALL_DIR}/.kairos-core/runtime"
        mkdir -p "$RUNTIME_DIR"
        _ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
        _pj="${CLOUD_PATH//\\/\\\\}"; _pj="${_pj//\"/\\\"}"
        _pvj="${CLOUD_PROVIDER//\"/\\\"}"
        cat > "${RUNTIME_DIR}/cloud-sync.json" <<EOF
{
  "configured": true,
  "symlink_target": "${_pj}",
  "provider": "${_pvj}",
  "configured_at": "${_ts}"
}
EOF
      else
        warn "Não foi possível criar o symlink."
        warn "Configure depois com: @kairos *configure-cloud"
      fi
    fi
  fi

fi
echo ""

# ─── Limpeza ──────────────────────────────────────────────────────────────────
rm -rf "$TMPDIR_EXTRACT"

# ─── Tela final ───────────────────────────────────────────────────────────────
echo "   ╔═══════════════════════════════════════════════════════╗"
echo -e "   ║  ${GREEN}${BOLD}✅  Kairos ${LATEST_TAG} instalado com sucesso!${RESET}          ║"
echo "   ╚═══════════════════════════════════════════════════════╝"
echo ""
echo "   Pasta:     $INSTALL_DIR"
echo "   Instância: $INSTANCE_NAME"
echo ""
echo "   ─────────────────────────────────────────────────────"
echo -e "   ${BOLD}Como abrir${RESET}"
echo "   ─────────────────────────────────────────────────────"
echo ""
echo "   Via terminal:"
echo "     cd '${INSTALL_DIR}' && claude"
echo ""
echo "   Via Claude Desktop:"
echo "     Abra o app → aba 'Claude Code'"
echo "     → Abrir projeto → selecione '${INSTALL_DIR}'"
echo ""
echo "   ─────────────────────────────────────────────────────"
echo -e "   ${BOLD}Primeiros passos${RESET}"
echo "   ─────────────────────────────────────────────────────"
echo ""
echo "     @kairos *status      → ver estado do sistema"
echo "     @kairos *help        → todos os comandos disponíveis"
echo "     @kairos *new-squad   → criar seu primeiro squad"
echo ""
if [[ "${CLOUD_MODE:-skip}" == "skip" ]] && [[ "${do_cloud,,}" == "s" ]]; then
  echo "   Quando o Claude Code estiver aberto:"
  echo "     @kairos *configure-cloud  → configurar sync com a nuvem"
  echo ""
fi
echo "   Documentação completa: .kairos-core/docs/install.md"
echo ""
