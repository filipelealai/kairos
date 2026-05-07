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

# Extrair paths de owned_files e owned_sections usando python3 ou grep
extract_paths() {
  local manifest="$1"
  if command -v python3 &>/dev/null; then
    python3 - <<PYEOF
import re, sys
paths = []
with open('${manifest}') as f:
    content = f.read()
# Find all "- path:" entries
for m in re.finditer(r'^\s*-\s*path:\s*(.+)$', content, re.MULTILINE):
    p = m.group(1).strip()
    if not p.startswith('#'):
        paths.append(p)
for p in paths:
    print(p)
PYEOF
  else
    grep -E '^\s*-\s*path:' "$manifest" | sed 's/.*path: //' | tr -d "'"
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
echo "   ─────────────────────────────────────────────────────"
echo "   Sincronização de outputs com a nuvem (opcional)"
echo "   ─────────────────────────────────────────────────────"
echo ""
echo "   O Kairos pode sincronizar os outputs gerados pelos agentes"
echo "   automaticamente para uma pasta compartilhada com o time"
echo "   via Google Drive Desktop, OneDrive ou Dropbox."
echo "   Zero OAuth — o sync é delegado ao app do seu provedor."
echo ""
read -rp "   Quer configurar o sync de outputs agora? [s/N] → " do_cloud </dev/tty

if [[ "${do_cloud,,}" == "s" ]]; then
  echo ""
  echo "   Certifique-se de que o app do seu provedor está instalado e sincronizando:"
  echo "   • Google Drive Desktop → https://drive.google.com/drive/download"
  echo "   • OneDrive             → disponível para Mac/Linux; já incluído no Windows"
  echo "   • Dropbox              → https://www.dropbox.com/install"
  echo ""
  echo "   Informe o caminho da pasta compartilhada com o time"
  echo "   (a pasta já deve existir no seu computador)."
  echo ""
  read -rp "   Caminho da pasta (ex: ~/Google Drive/Kairos Outputs): " CLOUD_PATH </dev/tty
  # Expandir ~ manualmente
  CLOUD_PATH="${CLOUD_PATH/#\~/$HOME}"
  CLOUD_PATH="${CLOUD_PATH%/}"

  if [[ -z "$CLOUD_PATH" ]]; then
    warn "Nenhum caminho informado — pulando cloud sync."
    warn "Configure depois com: @kairos *configure-cloud"
  elif [[ ! -d "$CLOUD_PATH" ]]; then
    warn "Pasta não encontrada: $CLOUD_PATH"
    warn "Crie a pasta no seu app de nuvem e configure depois: @kairos *configure-cloud"
  else
    OUTPUTS_DIR="${INSTALL_DIR}/data/outputs"
    # Remover symlink ou diretório vazio existente
    if [[ -L "$OUTPUTS_DIR" ]]; then
      rm "$OUTPUTS_DIR"
    elif [[ -d "$OUTPUTS_DIR" ]]; then
      CONTENT=$(ls -A "$OUTPUTS_DIR" 2>/dev/null)
      if [[ -n "$CONTENT" ]]; then
        mv "$OUTPUTS_DIR"/* "$CLOUD_PATH/" 2>/dev/null || true
      fi
      rmdir "$OUTPUTS_DIR" 2>/dev/null || rm -rf "$OUTPUTS_DIR"
    fi
    if ln -s "$CLOUD_PATH" "$OUTPUTS_DIR" 2>/dev/null; then
      ok "Cloud sync configurado: data/outputs → $CLOUD_PATH"
    else
      warn "Não foi possível criar o symlink."
      warn "Configure depois com: @kairos *configure-cloud"
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
if [[ "${do_cloud,,}" == "s" ]]; then
  echo "   Quando o Claude Code estiver aberto:"
  echo "     @kairos *configure-cloud  → configurar sync com a nuvem"
  echo ""
fi
echo "   Documentação completa: .kairos-core/docs/install.md"
echo ""
