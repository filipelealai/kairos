#Requires -Version 5.1
# Kairos - Instalador Interativo (Windows PowerShell nativo)
# Instala o framework Kairos sem necessidade de Git.
#
# Uso:
#   Baixe o arquivo e execute no PowerShell:
#   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#   .\install.ps1
#
# Ou via PowerShell (uma linha):
#   Set-Content "$env:TEMP\kairos.ps1" (Invoke-WebRequest "https://raw.githubusercontent.com/filipelealweb/kairos/main/install.ps1").Content -Encoding UTF8; & "$env:TEMP\kairos.ps1"

[CmdletBinding()]
param(
    [string]$InstallDir = "",
    [switch]$NoPrompt   = $false
)

# Auto-fix encoding: GitHub CDN entrega .ps1 sem BOM; PS 5.1 leria como Windows-1252.
# Se não há BOM, adiciona e reinicia — a segunda execução lê como UTF-8 corretamente.
$ScriptFile = if ($PSCommandPath) { $PSCommandPath } elseif ($MyInvocation.MyCommand.Path) { $MyInvocation.MyCommand.Path } else { $MyInvocation.ScriptName }
if ($ScriptFile -and [System.IO.File]::Exists($ScriptFile)) {
    $raw = [System.IO.File]::ReadAllBytes($ScriptFile)
    if (-not ($raw.Length -ge 3 -and $raw[0] -eq 0xEF -and $raw[1] -eq 0xBB -and $raw[2] -eq 0xBF)) {
        [System.IO.File]::WriteAllBytes($ScriptFile, ([byte[]](0xEF,0xBB,0xBF) + $raw))
        & $ScriptFile @PSBoundParameters
        exit
    }
}
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$KairosRepo   = "filipelealweb/kairos"
$KairosApi    = "https://api.github.com/repos/$KairosRepo/releases/latest"
$DefaultDir   = Join-Path $env:USERPROFILE "kairos"

# --- Helpers ------------------------------------------------------------------
function Write-Ok   { param($msg) Write-Host "  $(([char]0x2705))  $msg" -ForegroundColor Green }
function Write-Warn { param($msg) Write-Host "  $(([char]0x26A0))   $msg" -ForegroundColor Yellow }
function Write-Err  { param($msg) Write-Host "  $(([char]0x274C))  $msg" -ForegroundColor Red }
function Write-Info { param($msg) Write-Host "  -> $msg" -ForegroundColor Cyan }
function Ask        { param($prompt, $default = "N") Read-Host "$prompt [$default]" }

# --- Banner -------------------------------------------------------------------
Clear-Host
Write-Host ""
$BB = [char]0x2588; $BT = [char]0x2557; $BV = [char]0x2551
$TL = [char]0x2554; $BR = [char]0x255D; $BL = [char]0x255A; $BH = [char]0x2550
$DH = [char]0x2500

Write-Host "   $BB$BB$BT  $BB$BB$BT $BB$BB$BB$BB$BB$BT $BB$BB$BT$BB$BB$BB$BB$BB$BB$BT  $BB$BB$BB$BB$BB$BB$BT $BB$BB$BB$BB$BB$BB$BB$BT" -ForegroundColor Cyan
Write-Host "   $BB$BB$BV $BB$BB$TL$BR$BB$BB$TL$BH$BH$BB$BB$BT$BB$BB$BV$BB$BB$TL$BH$BH$BB$BB$BT$BB$BB$TL$BH$BH$BH$BB$BB$BT$BB$BB$TL$BH$BH$BH$BH$BR" -ForegroundColor Cyan
Write-Host "   $BB$BB$BB$BB$BB$TL$BR $BB$BB$BB$BB$BB$BB$BB$BV$BB$BB$BV$BB$BB$BB$BB$BB$BB$TL$BR$BB$BB$BV   $BB$BB$BV$BB$BB$BB$BB$BB$BB$BB$BT" -ForegroundColor Cyan
Write-Host "   $BB$BB$TL$BH$BB$BB$BT $BB$BB$TL$BH$BH$BB$BB$BV$BB$BB$BV$BB$BB$TL$BH$BH$BB$BB$BT$BB$BB$BV   $BB$BB$BV$BL$BH$BH$BH$BH$BB$BB$BV" -ForegroundColor Cyan
Write-Host "   $BB$BB$BV  $BB$BB$BT$BB$BB$BV  $BB$BB$BV$BB$BB$BV$BB$BB$BV  $BB$BB$BV$BL$BB$BB$BB$BB$BB$BB$TL$BR$BB$BB$BB$BB$BB$BB$BB$BV" -ForegroundColor Cyan
Write-Host "   $BL$BH$BR  $BL$BH$BR$BL$BH$BR  $BL$BH$BR$BL$BH$BR$BL$BH$BR  $BL$BH$BR $BL$BH$BH$BH$BH$BH$BR $BL$BH$BH$BH$BH$BH$BH$BR" -ForegroundColor Cyan
Write-Host ""
Write-Host "   Framework de Orquestração de Agentes de IA" -ForegroundColor White
Write-Host "   Instalador v1.0 - Windows" -ForegroundColor White
Write-Host ""
$div = "   " + ([string]$DH * 57)
Write-Host $div -ForegroundColor DarkGray
Write-Host "   Vamos instalar o Kairos na sua máquina."
Write-Host "   Isso vai criar uma pasta de projeto com o framework"
Write-Host "   pronto para uso com o Claude Code. Sem Git necessário."
Write-Host $div -ForegroundColor DarkGray
Write-Host ""

# --- Verificar WSL2 -----------------------------------------------------------
$HasWSL = $false
try {
    $wslCheck = wsl.exe --status 2>$null
    if ($LASTEXITCODE -eq 0) { $HasWSL = $true }
} catch { }

if ($HasWSL) {
    Write-Host "  WSL2 detectado!" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Recomendamos rodar o Kairos dentro do WSL2 para a melhor"
    Write-Host "  experiência (melhor compatibilidade com Claude Code CLI)."
    Write-Host ""
    $wslAnswer = Read-Host "  Continuar pela rota WSL2? [S/n]"
    if ([string]::IsNullOrEmpty($wslAnswer) -or $wslAnswer -match '^[Ss]') {
        Write-Host ""
        Write-Info "Iniciando instalador WSL2..."
        Write-Host ""
        $branch = if ($env:KAIROS_BRANCH) { $env:KAIROS_BRANCH } else { "main" }
        $rawUrl = "https://raw.githubusercontent.com/$KairosRepo/$branch/install.sh"
        $tagExport = if ($env:KAIROS_TAG) { "KAIROS_TAG='$($env:KAIROS_TAG)' " } else { "" }
        $wslCmd = "curl -fsSL '$rawUrl' > /tmp/kairos-install.sh && ${tagExport}bash /tmp/kairos-install.sh"
        wsl.exe -- bash -l -c $wslCmd
        exit 0
    }
    Write-Host ""
    Write-Info "Prosseguindo com instalação nativa no Windows..."
    Write-Host ""
}

# --- Verificar Claude Code ----------------------------------------------------
Write-Host "  Verificando pre-requisitos..." -ForegroundColor White
Write-Host ""

$ClaudeCmd = Get-Command claude -ErrorAction SilentlyContinue
$ClaudeDesktopFound = $false
if (-not $ClaudeCmd) {
    # 1. Windows Store: filtrar por publisher Anthropic (ID do pacote varia por máquina)
    $claudeAppx = Get-AppxPackage -ErrorAction SilentlyContinue |
        Where-Object { $_.Publisher -like "*Anthropic*" } |
        Select-Object -First 1

    # 2. Instalador .exe direto: chave de desinstalação no registry (HKCU e HKLM)
    $regPaths = @(
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    $claudeReg = $regPaths | ForEach-Object {
        Get-ItemProperty $_ -ErrorAction SilentlyContinue |
            Where-Object { $_.PSObject.Properties['DisplayName'] -and $_.DisplayName -like "Claude*" -and $_.PSObject.Properties['Publisher'] -and $_.Publisher -like "*Anthropic*" }
    } | Select-Object -First 1

    # 3. Caminho padrão do instalador Squirrel (electron)
    $claudeExe = @(
        "$env:LOCALAPPDATA\Programs\Claude\Claude.exe",
        "$env:LOCALAPPDATA\Programs\AnthropicClaude\Claude.exe"
    ) | Where-Object { Test-Path $_ } | Select-Object -First 1

    $ClaudeDesktopFound = [bool]($claudeAppx -or $claudeReg -or $claudeExe)
}
if ($ClaudeCmd) {
    try { $claudeVer = & claude --version 2>$null | Select-Object -First 1 }
    catch { $claudeVer = "instalado" }
    Write-Ok "Claude Code encontrado: $claudeVer"
} elseif ($ClaudeDesktopFound) {
    Write-Ok "Claude Desktop encontrado - aba 'Claude Code' disponível no app"
} else {
    Write-Err "Claude Code não encontrado."
    Write-Host ""
    Write-Host "  O Kairos requer o Claude Code. Instale antes de continuar:"
    Write-Host ""
    Write-Host "  Opção 1 - Claude Desktop (recomendado para Windows):"
    Write-Host "    https://claude.ai/download" -ForegroundColor Cyan
    Write-Host "    Após instalar, ative a aba 'Claude Code' no app."
    Write-Host ""
    Write-Host "  Opção 2 - CLI via npm (requer Node.js):"
    Write-Host "    npm install -g @anthropic-ai/claude-code" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Após instalar, execute este instalador novamente."
    Read-Host "  Pressione Enter para sair"
    exit 1
}

# --- Git (opcional) -----------------------------------------------------------
$GitCmd = Get-Command git -ErrorAction SilentlyContinue
if ($GitCmd) {
    $gitVer = & git --version | Select-Object -First 1
    Write-Ok "Git encontrado: $gitVer"
} else {
    Write-Warn "Git não encontrado."
    Write-Host ""
    Write-Host "  Git não é necessário para usar o Kairos no dia a dia."
    Write-Host "  É necessário apenas para contribuir com o framework."
    Write-Host ""
    $installGit = Read-Host "  Quer instalar Git? [s/N]"
    if ($installGit -match '^[Ss]') {
        Write-Host ""
        Write-Host "  Opções para instalar o Git no Windows:"
        Write-Host "    winget install Git.Git" -ForegroundColor Yellow
        Write-Host "    ou: https://git-scm.com/download/win" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  Instale o Git e execute este instalador novamente se precisar."
        Write-Host "  Continuando instalação do Kairos sem Git..."
    }
}
Write-Host ""

# --- Pasta de instalação ------------------------------------------------------
Write-Host "  Pasta de instalação" -ForegroundColor White
Write-Host ""
Write-Host "  Onde instalar o Kairos? (pasta onde ficará o projeto)"
$dirInput = Read-Host "  [$DefaultDir]"
if ([string]::IsNullOrEmpty($dirInput)) { $dirInput = $DefaultDir }
$dirInput = $dirInput.TrimEnd('\').TrimEnd('/')

# Expandir variáveis de ambiente
$dirInput = [System.Environment]::ExpandEnvironmentVariables($dirInput)

if (Test-Path $dirInput) {
    $items = @(Get-ChildItem $dirInput -ErrorAction SilentlyContinue)
    if ($items.Count -gt 0) {
        Write-Host ""
        Write-Warn "A pasta '$dirInput' já existe e não está vazia."
        Write-Host ""
        Write-Host "  O instalador não sobrescreve conteúdo user-owned existente."
        Write-Host "  Apenas arquivos do framework serão atualizados."
        Write-Host ""
        $cont = Read-Host "  Continuar mesmo assim? [s/N]"
        if ($cont -notmatch '^[Ss]') {
            Write-Info "Instalação cancelada."
            exit 0
        }
    }
}

New-Item -ItemType Directory -Path $dirInput -Force | Out-Null
Write-Ok "Pasta de instalação: $dirInput"
Write-Host ""

# --- Buscar versão mais recente -----------------------------------------------
Write-Host "  Baixando o Kairos..." -ForegroundColor White
Write-Host ""
$EnvTag = $env:KAIROS_TAG
if (-not [string]::IsNullOrEmpty($EnvTag)) {
    $LatestTag = $EnvTag
    Write-Info "Tag override: $LatestTag"
} else {
    Write-Info "Buscando versão mais recente..."
    try {
        $headers = @{ "Accept" = "application/vnd.github+json"; "User-Agent" = "Kairos-Installer" }
        $release = Invoke-RestMethod -Uri $KairosApi -Headers $headers -ErrorAction Stop
        $LatestTag = $release.tag_name
    } catch {
        Write-Err "Não foi possível obter a versão mais recente."
        Write-Host "  Verifique sua conexão com a internet e tente novamente."
        Write-Host "  Se o problema persistir, baixe manualmente em:"
        Write-Host "  https://github.com/$KairosRepo/releases" -ForegroundColor Cyan
        Read-Host "  Pressione Enter para sair"
        exit 1
    }
}

Write-Ok "Versão encontrada: $LatestTag"

# --- Baixar e extrair zipball -------------------------------------------------
$ZipUrl   = "https://github.com/$KairosRepo/archive/refs/tags/$LatestTag.zip"
$TempDir  = Join-Path $env:TEMP "kairos-install-$([System.Guid]::NewGuid().ToString('N').Substring(0,8))"
$ZipPath  = Join-Path $TempDir "kairos.zip"

New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

Write-Info "Baixando Kairos $LatestTag..."
try {
    Invoke-WebRequest -Uri $ZipUrl -OutFile $ZipPath -UseBasicParsing -ErrorAction Stop
} catch {
    Write-Err "Falha no download. Erro: $_"
    Remove-Item -Recurse -Force $TempDir -ErrorAction SilentlyContinue
    Read-Host "  Pressione Enter para sair"
    exit 1
}

Write-Info "Extraindo arquivos..."
Expand-Archive -Path $ZipPath -DestinationPath $TempDir -Force

$ExtractedDir = Get-ChildItem $TempDir -Directory | Select-Object -First 1
if (-not $ExtractedDir) {
    Write-Err "Falha ao extrair o arquivo. Pode estar corrompido."
    Remove-Item -Recurse -Force $TempDir -ErrorAction SilentlyContinue
    Read-Host "  Pressione Enter para sair"
    exit 1
}

# --- Ler manifesto e copiar arquivos ------------------------------------------
$ManifestPath = Join-Path $ExtractedDir.FullName ".kairos-core\manifest.yaml"
if (-not (Test-Path $ManifestPath)) {
    Write-Err "manifest.yaml não encontrado no arquivo baixado."
    Remove-Item -Recurse -Force $TempDir -ErrorAction SilentlyContinue
    Read-Host "  Pressione Enter para sair"
    exit 1
}

Write-Info "Instalando arquivos do framework (via manifest.yaml)..."

# Extrair paths apenas de owned_files e owned_sections (não sync_files)
$manifestLines = Get-Content $ManifestPath
$relPaths = [System.Collections.Generic.List[string]]::new()
$currentSection = ''
foreach ($line in $manifestLines) {
    $trimmed = $line.TrimEnd()
    if ($trimmed -match '^(\w[\w_-]*):\s*$') { $currentSection = $Matches[1] }
    if ($currentSection -in @('owned_files','owned_sections') -and $trimmed -match '^\s*-\s*path:\s*(.+)$') {
        $relPaths.Add($Matches[1].Trim())
    }
}

$installCount = 0
foreach ($relPath in $relPaths) {
    # Normalizar separadores de caminho
    $relPathNorm = $relPath.Replace('/', '\')
    $src = Join-Path $ExtractedDir.FullName $relPathNorm
    $dst = Join-Path $dirInput $relPathNorm

    if (Test-Path $src -PathType Leaf) {
        $dstDir = Split-Path $dst -Parent
        if (-not (Test-Path $dstDir)) {
            New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
        }
        Copy-Item -Path $src -Destination $dst -Force
        $installCount++
    }
}

# Pastas obrigatórias vazias
foreach ($specialDir in @(".kairos-core\runtime", "data", "data\outputs", "docs", "squads")) {
    $p = Join-Path $dirInput $specialDir
    if (-not (Test-Path $p)) { New-Item -ItemType Directory -Path $p -Force | Out-Null }
}

# Apenas LICENSE dos sync_files — o resto (README, CONTRIBUTING etc.) fica no repo público
$syncFiles = @("LICENSE")
foreach ($sf in $syncFiles) {
    $src = Join-Path $ExtractedDir.FullName $sf
    $dst = Join-Path $dirInput $sf
    if (Test-Path $src) { Copy-Item -Path $src -Destination $dst -Force }
}

# .env.example — necessário para gerar o .env durante a instalação
$envExSrc = Join-Path $ExtractedDir.FullName ".env.example"
$envExDst = Join-Path $dirInput ".env.example"
if (Test-Path $envExSrc) { Copy-Item -Path $envExSrc -Destination $envExDst -Force }

Write-Ok "$installCount arquivos de framework instalados."
Write-Host ""

# --- Elicitação — configuração da instância -----------------------------------
Write-Host "  Configurando sua instância" -ForegroundColor White
Write-Host ""
Write-Host "  -----------------------------------------------------" -ForegroundColor DarkGray
Write-Host "  O Kairos identifica seus outputs com um nome de instância."
Write-Host "  Isso evita colisões quando mais de uma pessoa do time"
Write-Host "  roda o Kairos no mesmo dia com os mesmos dados."
Write-Host ""
$instanceRaw = Read-Host "  Qual o seu nome ou apelido? (ex: joao, maria, dev1) ->"
if ([string]::IsNullOrWhiteSpace($instanceRaw)) { $instanceRaw = "default" }

# Normalizar: minúsculas, NFD + remover diacríticos, espaços → hifens, remover especiais
$instanceNorm = $instanceRaw.ToLower().Trim()
$nfd = $instanceNorm.Normalize([System.Text.NormalizationForm]::FormD)
$instanceNorm = -join ($nfd.ToCharArray() | Where-Object {
    [System.Globalization.CharUnicodeInfo]::GetUnicodeCategory($_) -ne
    [System.Globalization.UnicodeCategory]::NonSpacingMark
})
$instanceNorm = [regex]::Replace($instanceNorm, '\s+', '-')
$instanceNorm = [regex]::Replace($instanceNorm, '[^a-z0-9\-]', '')
$instanceNorm = [regex]::Replace($instanceNorm, '-{2,}', '-').Trim('-')
if ([string]::IsNullOrEmpty($instanceNorm)) { $instanceNorm = "default" }

Write-Ok "Nome de instância: $instanceNorm"
Write-Host ""

# --- Gerar .env ---------------------------------------------------------------
$envExamplePath = Join-Path $dirInput ".env.example"
$envFilePath    = Join-Path $dirInput ".env"

if (-not (Test-Path $envFilePath)) {
    if (Test-Path $envExamplePath) {
        Copy-Item $envExamplePath $envFilePath
    } else {
        Set-Content $envFilePath @"
# Kairos - Variaveis de Ambiente
# Gerado pelo instalador em $(Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ')

# KAIROS-MANAGED-START: framework
KAIROS_INSTANCE_NAME=
# KAIROS-MANAGED-END: framework
"@
    }
}

$envContent = Get-Content $envFilePath -Raw
if ($envContent -match '(?m)^KAIROS_INSTANCE_NAME=') {
    $envContent = $envContent -replace '(?m)^KAIROS_INSTANCE_NAME=.*', "KAIROS_INSTANCE_NAME=$instanceNorm"
} elseif ($envContent -match 'KAIROS-MANAGED-START: framework') {
    $envContent = $envContent -replace '(KAIROS-MANAGED-START: framework\r?\n)', "`$1KAIROS_INSTANCE_NAME=$instanceNorm`n"
} else {
    $envContent += "`nKAIROS_INSTANCE_NAME=$instanceNorm`n"
}
Set-Content $envFilePath $envContent -NoNewline

Write-Ok ".env criado com KAIROS_INSTANCE_NAME=$instanceNorm"
Write-Host ""

# --- Cloud sync (opcional) ----------------------------------------------------
# Helper: criar symlink com elevação se necessário
function New-KairosSymlink {
    param([string]$LinkPath, [string]$TargetPath)
    $result = $false
    try {
        New-Item -ItemType SymbolicLink -Path $LinkPath -Target $TargetPath -ErrorAction Stop | Out-Null
        $result = $true
    } catch {
        Write-Host ""
        Write-Warn "Criar symlink requer permissão de administrador."
        $elevate = Read-Host "  Tentar novamente com permissão elevada? [S/n]"
        if ([string]::IsNullOrEmpty($elevate) -or $elevate -match '^[Ss]') {
            $ep = $LinkPath   -replace "'","''"
            $cp = $TargetPath -replace "'","''"
            $rf = (Join-Path $env:TEMP "kairos-sym.txt") -replace "'","''"
            $symlinkScript = @"
`$ErrorActionPreference = 'Stop'
try {
    if (Test-Path '$ep') { Remove-Item -Path '$ep' -Recurse -Force }
    New-Item -ItemType SymbolicLink -Path '$ep' -Target '$cp' | Out-Null
    'OK' | Out-File '$rf' -Encoding UTF8
} catch {
    `$_.Exception.Message | Out-File '$rf' -Encoding UTF8
}
"@
            $encoded = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($symlinkScript))
            Start-Process powershell -Verb RunAs -Wait -ArgumentList "-NoProfile", "-EncodedCommand", $encoded
            $symResultFile = Join-Path $env:TEMP "kairos-sym.txt"
            $elevResult = if (Test-Path $symResultFile) { (Get-Content $symResultFile -Raw).Trim() } else { '' }
            Remove-Item $symResultFile -ErrorAction SilentlyContinue
            if ($elevResult -eq 'OK' -and (Test-Path $LinkPath)) {
                $result = $true
            } elseif (-not [string]::IsNullOrEmpty($elevResult) -and $elevResult -ne 'OK') {
                Write-Warn "Erro ao criar symlink: $elevResult"
            } else {
                Write-Warn "Não foi possível criar o symlink."
            }
        }
    }
    return $result
}

Write-Host "  -----------------------------------------------------" -ForegroundColor DarkGray
Write-Host "  Sincronização de outputs com a nuvem (opcional)"
Write-Host "  -----------------------------------------------------" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  O Kairos pode sincronizar os outputs dos agentes para"
Write-Host "  uma pasta compartilhada. Zero OAuth - usa o app nativo"
Write-Host "  do seu provedor."
Write-Host ""
$doCloud = Read-Host "  Quer configurar o sync de outputs agora? [s/N]"

$cloudMode     = "skip"
$cloudRoot     = ""
$cloudProvider = ""

if ($doCloud -match '^[Ss]') {

    # --- Detectar provedores Windows ---
    $detectedNames     = [System.Collections.Generic.List[string]]::new()
    $detectedRoots     = [System.Collections.Generic.List[string]]::new()
    $detectedProviders = [System.Collections.Generic.List[string]]::new()

    # Google Drive
    $gdCandidates = @(
        (Join-Path $env:USERPROFILE "Google Drive\Meu Drive"),
        (Join-Path $env:USERPROFILE "Google Drive\My Drive"),
        "G:\Meu Drive", "G:\My Drive",
        "H:\Meu Drive", "H:\My Drive"
    )
    foreach ($p in $gdCandidates) {
        if (Test-Path $p -PathType Container) {
            $detectedNames.Add("Google Drive ($p)")
            $detectedRoots.Add($p)
            $detectedProviders.Add("Google Drive")
            break
        }
    }

    # OneDrive
    $odEnv = $env:OneDrive
    if (-not [string]::IsNullOrEmpty($odEnv) -and (Test-Path $odEnv -PathType Container)) {
        $detectedNames.Add("OneDrive ($odEnv)")
        $detectedRoots.Add($odEnv)
        $detectedProviders.Add("OneDrive")
    } else {
        $odCandidates = @(Get-Item (Join-Path $env:USERPROFILE "OneDrive*") -ErrorAction SilentlyContinue)
        foreach ($od in $odCandidates) {
            if (Test-Path $od.FullName -PathType Container) {
                $detectedNames.Add("OneDrive ($($od.Name))")
                $detectedRoots.Add($od.FullName)
                $detectedProviders.Add("OneDrive")
                break
            }
        }
    }

    # Dropbox
    $dbInfo = Join-Path $env:LOCALAPPDATA "Dropbox\info.json"
    if (Test-Path $dbInfo) {
        try {
            $dbData = Get-Content $dbInfo -Raw | ConvertFrom-Json
            $dbPath = $dbData.personal.path
            if (-not [string]::IsNullOrEmpty($dbPath) -and (Test-Path $dbPath -PathType Container)) {
                $detectedNames.Add("Dropbox ($dbPath)")
                $detectedRoots.Add($dbPath)
                $detectedProviders.Add("Dropbox")
            }
        } catch { }
    } elseif (Test-Path (Join-Path $env:USERPROFILE "Dropbox") -PathType Container) {
        $dbPath = Join-Path $env:USERPROFILE "Dropbox"
        $detectedNames.Add("Dropbox ($dbPath)")
        $detectedRoots.Add($dbPath)
        $detectedProviders.Add("Dropbox")
    }

    # --- Menu de escolha ---
    Write-Host ""
    if ($detectedNames.Count -eq 0) {
        Write-Host "  Nenhum app de nuvem detectado automaticamente."
        Write-Host ""
        Write-Host "  1) Instalar app de nuvem e executar este instalador novamente"
        Write-Host "  2) Informar path manualmente"
        Write-Host "  3) Pular - configurar depois com: @kairos *configure-cloud"
        Write-Host ""
        $ch = Read-Host "  Escolha [1-3]"
        switch ($ch) {
            '1' {
                Write-Host ""
                Write-Info "Instale um dos apps abaixo e execute este instalador novamente:"
                Write-Host "    OneDrive:             ja incluido no Windows"
                Write-Host "    Google Drive Desktop: https://drive.google.com/drive/download" -ForegroundColor Cyan
                Write-Host "    Dropbox:              https://www.dropbox.com/install" -ForegroundColor Cyan
                $cloudMode = "skip"
            }
            '2' { $cloudMode = "manual" }
            default { $cloudMode = "skip" }
        }
    } else {
        Write-Host "  Apps de nuvem detectados:"
        Write-Host ""
        for ($i = 0; $i -lt $detectedNames.Count; $i++) {
            Write-Host "  $($i+1)) $($detectedNames[$i])"
        }
        $mnIdx = $detectedNames.Count + 1
        $skIdx = $detectedNames.Count + 2
        Write-Host "  $mnIdx) Outro/Custom (informar path manualmente)"
        Write-Host "  $skIdx) Pular - configurar depois com: @kairos *configure-cloud"
        Write-Host ""
        $ch = Read-Host "  Escolha [1-$skIdx]"
        $chInt = 0
        if ([int]::TryParse($ch, [ref]$chInt) -and $chInt -ge 1 -and $chInt -le $detectedNames.Count) {
            $cloudMode     = "detected"
            $cloudRoot     = $detectedRoots[$chInt - 1]
            $cloudProvider = $detectedProviders[$chInt - 1]
        } elseif ($ch -eq "$mnIdx") {
            $cloudMode = "manual"
        } else {
            $cloudMode = "skip"
        }
    }

    # --- Path manual ---
    if ($cloudMode -eq "manual") {
        Write-Host ""
        $cloudRoot = Read-Host "  Caminho absoluto da pasta sincronizada"
        $cloudRoot = $cloudRoot.TrimEnd('\').TrimEnd('/')
        if ([string]::IsNullOrWhiteSpace($cloudRoot)) {
            Write-Warn "Nenhum caminho informado - pulando."
            $cloudMode = "skip"
        } else {
            $cloudProvider = "custom"
            $cloudMode = "detected"
        }
    }

    # --- Subpasta + symlink ---
    if ($cloudMode -eq "detected" -and -not [string]::IsNullOrEmpty($cloudRoot)) {
        Write-Host ""
        Write-Host "  Qual nome de subpasta usar dentro de:"
        Write-Host "  $cloudRoot"
        $subfolder = Read-Host "  [Kairos Outputs]"
        if ([string]::IsNullOrWhiteSpace($subfolder)) { $subfolder = "Kairos Outputs" }
        $cloudPath = Join-Path $cloudRoot $subfolder

        if (-not (Test-Path $cloudPath -PathType Container)) {
            New-Item -ItemType Directory -Path $cloudPath -Force -ErrorAction SilentlyContinue | Out-Null
        }

        $outputsPath  = Join-Path $dirInput "data\outputs"
        $skipSymlink  = $false

        $existingItem = Get-Item $outputsPath -ErrorAction SilentlyContinue
        if ($existingItem -and $existingItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
            $oldTarget = $existingItem.Target
            if ($oldTarget -eq $cloudPath) {
                Write-Ok "Symlink já aponta para $cloudPath - mantendo."
                $skipSymlink = $true
            } else {
                Write-Warn "data\outputs já é um symlink (-> $oldTarget)."
                $reconf = Read-Host "  Reconfigurar para $cloudPath? [s/N]"
                if ($reconf -match '^[Ss]') {
                    Remove-Item $outputsPath -Force -ErrorAction SilentlyContinue
                } else {
                    $skipSymlink = $true
                    Write-Warn "Mantendo symlink anterior. Configure com: @kairos *configure-cloud"
                }
            }
        } elseif (Test-Path $outputsPath -PathType Container) {
            $children = @(Get-ChildItem $outputsPath -ErrorAction SilentlyContinue)
            foreach ($c in $children) {
                Move-Item $c.FullName $cloudPath -ErrorAction SilentlyContinue
            }
            Remove-Item $outputsPath -Recurse -Force -ErrorAction SilentlyContinue
        }

        if (-not $skipSymlink) {
            $symlinkOk = New-KairosSymlink -LinkPath $outputsPath -TargetPath $cloudPath
            if ($symlinkOk) {
                Write-Ok "Cloud sync configurado: data\outputs -> $cloudPath"
                $runtimeDir = Join-Path $dirInput ".kairos-core\runtime"
                New-Item -ItemType Directory -Path $runtimeDir -Force -ErrorAction SilentlyContinue | Out-Null
                $cloudSyncState = [ordered]@{
                    configured     = $true
                    symlink_target = $cloudPath
                    provider       = $cloudProvider
                    configured_at  = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
                }
                Set-Content -Path (Join-Path $runtimeDir "cloud-sync.json") `
                    -Value ($cloudSyncState | ConvertTo-Json -Depth 3) -Encoding UTF8
            } else {
                Write-Warn "Configure depois: @kairos *configure-cloud"
            }
        }
    }
}
Write-Host ""

# --- Limpeza ------------------------------------------------------------------
Remove-Item -Recurse -Force $TempDir -ErrorAction SilentlyContinue

# --- Tela final ---------------------------------------------------------------
Write-Host "   +=======================================================+" -ForegroundColor Green
Write-Host "   |  $([char]0x2705)  Kairos $LatestTag instalado com sucesso!          |" -ForegroundColor Green
Write-Host "   +=======================================================+" -ForegroundColor Green
Write-Host ""
Write-Host "   Pasta:     $dirInput"
Write-Host "   Instância: $instanceNorm"
Write-Host ""
Write-Host "   -----------------------------------------------------" -ForegroundColor DarkGray
Write-Host "   Como abrir" -ForegroundColor White
Write-Host "   -----------------------------------------------------" -ForegroundColor DarkGray
Write-Host ""
Write-Host "   Via Claude Desktop:"
Write-Host "     Abra o app -> aba 'Claude Code'"
Write-Host "     -> Abrir projeto -> selecione '$dirInput'" -ForegroundColor Yellow
Write-Host ""
Write-Host "   Via terminal PowerShell:"
Write-Host "     cd '$dirInput'; claude" -ForegroundColor Yellow
Write-Host ""
Write-Host "   -----------------------------------------------------" -ForegroundColor DarkGray
Write-Host "   Primeiros passos" -ForegroundColor White
Write-Host "   -----------------------------------------------------" -ForegroundColor DarkGray
Write-Host ""
Write-Host "     @kairos *status      -> ver estado do sistema" -ForegroundColor Yellow
Write-Host "     @kairos *help        -> todos os comandos disponíveis" -ForegroundColor Yellow
Write-Host "     @kairos *new-squad   -> criar seu primeiro squad" -ForegroundColor Yellow
Write-Host ""
Write-Host "   Documentação completa: .kairos-core\docs\install.md"
Write-Host ""
Read-Host "  Pressione Enter para sair"
