#Requires -Version 5.1
# Kairos - Desinstalador Interativo (Windows PowerShell nativo)
# Remove apenas conteudo declarado no manifesto.
# Preserva, por padrao, outputs e .env do usuario.
#
# Uso (executar de dentro da pasta de instalacao do Kairos):
#   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#   .\uninstall.ps1

[CmdletBinding()]
param()

# Auto-fix encoding: GitHub CDN entrega .ps1 sem BOM; PS 5.1 leria como Windows-1252.
# Se não há BOM, adiciona e reinicia — a segunda execução lê como UTF-8 corretamente.
if ($MyInvocation.ScriptName -and [System.IO.File]::Exists($MyInvocation.ScriptName)) {
    $raw = [System.IO.File]::ReadAllBytes($MyInvocation.ScriptName)
    if (-not ($raw.Length -ge 3 -and $raw[0] -eq 0xEF -and $raw[1] -eq 0xBB -and $raw[2] -eq 0xBF)) {
        [System.IO.File]::WriteAllBytes($MyInvocation.ScriptName, ([byte[]](0xEF,0xBB,0xBF) + $raw))
        & $MyInvocation.ScriptName @PSBoundParameters
        exit
    }
}
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# --- Helpers ------------------------------------------------------------------
function Write-Ok   { param($msg) Write-Host "  $([char]0x2705)  $msg" -ForegroundColor Green }
function Write-Warn { param($msg) Write-Host "  $([char]0x26A0)   $msg" -ForegroundColor Yellow }
function Write-Err  { param($msg) Write-Host "  $([char]0x274C)  $msg" -ForegroundColor Red }
function Write-Info { param($msg) Write-Host "  -> $msg" -ForegroundColor Cyan }

# --- Verificar que estamos na pasta correta ------------------------------------
$installDir = (Get-Location).Path
$scriptPath = $MyInvocation.ScriptName

$ManifestPath = ".kairos-core\manifest.yaml"
if (-not (Test-Path $ManifestPath)) {
    Write-Err "manifest.yaml não encontrado em '$(Get-Location)'."
    Write-Host ""
    Write-Host "  Execute este script de dentro da pasta de instalação do Kairos."
    Write-Host "  Exemplo:"
    Write-Host "    cd ~\kairos; .\uninstall.ps1" -ForegroundColor Yellow
    Read-Host "  Pressione Enter para sair"
    exit 1
}

# --- Banner ------------------------------------------------------------------
Clear-Host
Write-Host ""
$BB = [char]0x2588; $BT = [char]0x2557; $BV = [char]0x2551
$TL = [char]0x2554; $BR = [char]0x255D; $BL = [char]0x255A; $BH = [char]0x2550
$DH = [char]0x2500

Write-Host "   $BB$BB$BT  $BB$BB$BT $BB$BB$BB$BB$BB$BT $BB$BB$BT$BB$BB$BB$BB$BB$BB$BT  $BB$BB$BB$BB$BB$BB$BT $BB$BB$BB$BB$BB$BB$BB$BT" -ForegroundColor Red
Write-Host "   $BB$BB$BV $BB$BB$TL$BR$BB$BB$TL$BH$BH$BB$BB$BT$BB$BB$BV$BB$BB$TL$BH$BH$BB$BB$BT$BB$BB$TL$BH$BH$BH$BB$BB$BT$BB$BB$TL$BH$BH$BH$BH$BR" -ForegroundColor Red
Write-Host "   $BB$BB$BB$BB$BB$TL$BR $BB$BB$BB$BB$BB$BB$BB$BV$BB$BB$BV$BB$BB$BB$BB$BB$BB$TL$BR$BB$BB$BV   $BB$BB$BV$BB$BB$BB$BB$BB$BB$BB$BT" -ForegroundColor Red
Write-Host "   $BB$BB$TL$BH$BB$BB$BT $BB$BB$TL$BH$BH$BB$BB$BV$BB$BB$BV$BB$BB$TL$BH$BH$BB$BB$BT$BB$BB$BV   $BB$BB$BV$BL$BH$BH$BH$BH$BB$BB$BV" -ForegroundColor Red
Write-Host "   $BB$BB$BV  $BB$BB$BT$BB$BB$BV  $BB$BB$BV$BB$BB$BV$BB$BB$BV  $BB$BB$BV$BL$BB$BB$BB$BB$BB$BB$TL$BR$BB$BB$BB$BB$BB$BB$BB$BV" -ForegroundColor Red
Write-Host "   $BL$BH$BR  $BL$BH$BR$BL$BH$BR  $BL$BH$BR$BL$BH$BR$BL$BH$BR  $BL$BH$BR $BL$BH$BH$BH$BH$BH$BR $BL$BH$BH$BH$BH$BH$BH$BR" -ForegroundColor Red
Write-Host ""
Write-Host "   Framework de Orquestração de Agentes de IA" -ForegroundColor White
Write-Host "   Desinstalador - Windows" -ForegroundColor White
Write-Host ""
$sep = "   " + ([string]$DH * 57)
Write-Host $sep -ForegroundColor DarkGray
Write-Host "   Este desinstalador remove apenas o conteúdo do"
Write-Host "   framework Kairos (declarado em manifest.yaml)."
Write-Host "   Seus dados, squads, scripts e .env são preservados"
Write-Host "   por padrão - você decide o que remover."
Write-Host $sep -ForegroundColor DarkGray
Write-Host ""
Write-Host "   Pasta: $(Get-Location)"
Write-Host ""

$startConfirm = Read-Host "   Continuar com a desinstalação? [s/N]"
if ($startConfirm -notmatch '^[Ss]') {
    Write-Info "Desinstalação cancelada."
    exit 0
}
Write-Host ""

# --- Perguntas sobre o que preservar -----------------------------------------
Write-Host "  O que você quer preservar?" -ForegroundColor White
Write-Host ""

$keepOutputs = Read-Host "  Preservar seus outputs em data\outputs\? [S/n]"
$KeepOutputs = ($keepOutputs -notmatch '^[Nn]')

$keepEnv = Read-Host "  Preservar seu .env (caso reinstale depois)? [S/n]"
$KeepEnv = ($keepEnv -notmatch '^[Nn]')

$nukeAllInput = Read-Host "  Apagar TUDO da pasta (inclusive arquivos fora do framework)? [s/N]"
$NukeAll = $false
if ($nukeAllInput -match '^[Ss]') {
    Write-Host ""
    Write-Warn "Isso vai remover TUDO na pasta, incluindo seus squads, scripts e dados."
    $nukeConfirm = Read-Host "  Tem certeza? Digite 'APAGAR TUDO' para confirmar"
    if ($nukeConfirm -eq 'APAGAR TUDO') {
        $NukeAll = $true
    } else {
        Write-Warn "Confirmação inválida - operação destrutiva cancelada."
    }
}
Write-Host ""

# --- Extrair paths do manifesto -----------------------------------------------
$manifestContent = Get-Content $ManifestPath -Raw

function Get-AbsolutePath {
    param([string]$filePath)
    if ([System.IO.Path]::IsPathRooted($filePath)) { return $filePath }
    return Join-Path (Get-Location).Path $filePath
}

function Read-TextUtf8 {
    param([string]$filePath)
    return [System.IO.File]::ReadAllText((Get-AbsolutePath $filePath), [System.Text.Encoding]::UTF8)
}

function Write-TextUtf8 {
    param([string]$filePath, [string]$content)
    [System.IO.File]::WriteAllText((Get-AbsolutePath $filePath), $content, [System.Text.Encoding]::UTF8)
}

function Get-OwnedFilePaths {
    param([string]$content)
    $paths = @()
    $inOwned = $false
    foreach ($line in ($content -split "`n")) {
        if ($line -match '^owned_files:') { $inOwned = $true; continue }
        if ($inOwned -and ($line -match '^owned_sections:|^sync_files:|^notes:')) { $inOwned = $false }
        if ($inOwned -and ($line -match '^\s*-\s*path:\s*(.+)')) {
            $paths += $Matches[1].Trim()
        }
    }
    return $paths
}

function Get-OwnedSectionEntries {
    param([string]$content)
    $entries = [System.Collections.Generic.List[PSCustomObject]]::new()
    $inSections = $false
    $current = $null
    $inKeys = $false
    foreach ($rawLine in ($content -split "`n")) {
        $line = $rawLine.TrimEnd("`r")
        if ($line -match '^owned_sections:') { $inSections = $true; continue }
        # End of section: top-level YAML key starts with a letter at col 0
        if ($inSections -and $line.Length -gt 0 -and [char]::IsLetter($line[0])) {
            if ($current) { $entries.Add($current); $current = $null }
            $inSections = $false; break
        }
        if ($inSections) {
            # List items start at col 0: "- path: ..."
            if ($line -match '^- path:\s*(.+)') {
                if ($current) { $entries.Add($current) }
                $current = [PSCustomObject]@{ Path=$Matches[1].Trim(); Type=''; Keys=@() }
                $inKeys = $false; continue
            }
            if ($current) {
                if ($inKeys) {
                    # owned_keys items at 2-space indent: "  - key"
                    if ($line -match '^  - (.+)') {
                        $current.Keys += $Matches[1].Trim(); continue
                    } else {
                        $inKeys = $false
                        # fall through to check other attributes
                    }
                }
                if ($line -match '^  type:\s*(.+)')            { $current.Type = $Matches[1].Trim(); continue }
                if ($line -match '^  owned_keys:\s*\[(.+)\]')  {
                    $current.Keys = ($Matches[1] -split ',') | ForEach-Object { $_.Trim() }
                    $inKeys = $false; continue
                }
                if ($line -match '^  owned_keys:\s*$')         { $inKeys = $true; continue }
            }
        }
    }
    if ($current) { $entries.Add($current) }
    return $entries
}

function Get-SyncFilePaths {
    param([string]$content)
    $paths = @()
    $inSync = $false
    foreach ($line in ($content -split "`n")) {
        if ($line -match '^sync_files:') { $inSync = $true; continue }
        if ($inSync -and ($line -match '^owned_sections:|^notes:')) { $inSync = $false }
        if ($inSync -and ($line -match '^[A-Za-z_][A-Za-z0-9_]*:' -and $line -notmatch '^sync_files:')) { $inSync = $false }
        if ($inSync -and ($line -match '^\s*-\s*path:\s*(.+)')) {
            $paths += $Matches[1].Trim()
        }
    }
    return $paths
}

function Format-JsonStable {
    param([string]$Json)

    $sb = [System.Text.StringBuilder]::new()
    $indent = 0
    $inString = $false
    $escaped = $false

    for ($i = 0; $i -lt $Json.Length; $i++) {
        $ch = $Json[$i]

        if ($escaped) {
            [void]$sb.Append($ch)
            $escaped = $false
            continue
        }
        if ($ch -eq '\') {
            [void]$sb.Append($ch)
            if ($inString) { $escaped = $true }
            continue
        }
        if ($ch -eq '"') {
            [void]$sb.Append($ch)
            $inString = -not $inString
            continue
        }
        if ($inString) {
            [void]$sb.Append($ch)
            continue
        }

        if (($ch -eq '{' -and ($i + 1) -lt $Json.Length -and $Json[$i + 1] -eq '}') -or
            ($ch -eq '[' -and ($i + 1) -lt $Json.Length -and $Json[$i + 1] -eq ']')) {
            [void]$sb.Append("$ch$($Json[$i + 1])")
            $i++
            continue
        }

        switch ($ch) {
            { $_ -eq '{' -or $_ -eq '[' } {
                [void]$sb.Append($ch)
                $indent++
                [void]$sb.Append("`n" + (' ' * ($indent * 2)))
                continue
            }
            { $_ -eq '}' -or $_ -eq ']' } {
                $indent--
                [void]$sb.Append("`n" + (' ' * ($indent * 2)) + $ch)
                continue
            }
            ',' {
                [void]$sb.Append(",`n" + (' ' * ($indent * 2)))
                continue
            }
            ':' {
                [void]$sb.Append(": ")
                continue
            }
            default {
                if (-not [char]::IsWhiteSpace($ch)) { [void]$sb.Append($ch) }
            }
        }
    }

    return $sb.ToString()
}

function Remove-ManagedSections {
    param(
        [string]$filePath,
        [string]$sectionType = '',
        [string[]]$ownedKeys = @()
    )
    if (-not (Test-Path $filePath)) { return }

    if ($sectionType -eq 'markdown_blocks' -or $filePath -like '*.md') {
        $lines = (Read-TextUtf8 $filePath) -split '\r?\n'
        $result = [System.Collections.Generic.List[string]]::new()
        $inBlock = $false
        foreach ($line in $lines) {
            if ($line -match '<!--\s*KAIROS-MANAGED-START:') { $inBlock = $true; continue }
            if ($line -match '<!--\s*KAIROS-MANAGED-END:')   { $inBlock = $false; continue }
            if (-not $inBlock) { $result.Add($line) }
        }
        $cleaned = ($result -join "`n").Trim()
        if ([string]::IsNullOrWhiteSpace($cleaned)) {
            Remove-Item $filePath -Force; Write-Info "Removido (ficou vazio): $filePath"; return
        }
        Write-TextUtf8 $filePath ($cleaned + "`n")

    } elseif ($sectionType -eq 'comment_blocks') {
        $lines = (Read-TextUtf8 $filePath) -split '\r?\n'
        $result = [System.Collections.Generic.List[string]]::new()
        $inBlock = $false
        foreach ($line in $lines) {
            if ($line -match '#\s*KAIROS-MANAGED-START:') { $inBlock = $true; continue }
            if ($line -match '#\s*KAIROS-MANAGED-END:')   { $inBlock = $false; continue }
            if (-not $inBlock) { $result.Add($line) }
        }
        $cleaned = ($result -join "`n").Trim()
        if ([string]::IsNullOrWhiteSpace($cleaned)) {
            Remove-Item $filePath -Force; Write-Info "Removido (ficou vazio): $filePath"; return
        }
        Write-TextUtf8 $filePath ($cleaned + "`n")

    } elseif ($sectionType -eq 'json_keys' -and $ownedKeys.Count -gt 0) {
        try {
            $json = Read-TextUtf8 $filePath | ConvertFrom-Json
            $remainingKeys = @($json.PSObject.Properties.Name | Where-Object { $_ -notin $ownedKeys })
            if ($remainingKeys.Count -eq 0) {
                Remove-Item $filePath -Force; Write-Info "Removido (ficou vazio): $filePath"; return
            }
            $newObj = $json | Select-Object $remainingKeys
            $formattedJson = Format-JsonStable ($newObj | ConvertTo-Json -Depth 20 -Compress)
            Write-TextUtf8 $filePath ($formattedJson + "`n")
        } catch { Write-Warn "Nao foi possivel processar JSON: $filePath" }

    } elseif ($sectionType -eq 'yaml_keys') {
        Remove-Item $filePath -Force; Write-Info "Removido: $filePath"; return
    }

    # Se ficou vazio após qualquer processamento
    if ((Test-Path $filePath) -and [string]::IsNullOrWhiteSpace((Read-TextUtf8 $filePath))) {
        Remove-Item $filePath -Force; Write-Info "Removido (ficou vazio): $filePath"
    }
}

# --- Contadores ---------------------------------------------------------------
$deletedFiles    = 0
$cleanedSections = 0
$deletedDirs     = 0
$skipped         = 0

# --- Remover owned_files ------------------------------------------------------
Write-Info "Removendo arquivos do framework (owned_files)..."
$ownedPaths = Get-OwnedFilePaths $manifestContent
foreach ($relPath in $ownedPaths) {
    $relPathWin = $relPath.Replace('/', '\')

    # Deixar manifest.yaml por último
    if ($relPathWin -eq '.kairos-core\manifest.yaml') { continue }

    if ($KeepOutputs -and $relPathWin.StartsWith('data\outputs')) { $skipped++; continue }
    if ($KeepEnv -and $relPathWin -eq '.env') { $skipped++; continue }

    if (Test-Path $relPathWin -PathType Leaf) {
        Remove-Item $relPathWin -Force
        $deletedFiles++
    }
}

# Remover manifest.yaml por último
if (Test-Path $ManifestPath) {
    Remove-Item $ManifestPath -Force
    $deletedFiles++
}

# --- Limpar seções em owned_sections -----------------------------------------
Write-Info "Limpando seções gerenciadas (owned_sections)..."
$sectionEntries = Get-OwnedSectionEntries $manifestContent
foreach ($entry in $sectionEntries) {
    $relPathWin = $entry.Path.Replace('/', '\')
    if (Test-Path $relPathWin) {
        Remove-ManagedSections $relPathWin $entry.Type $entry.Keys
        $cleanedSections++
    }
}

# --- Remover sync_files (apenas se nuke_all) ---------------------------------
if ($NukeAll) {
    Write-Info "Removendo sync_files..."
    $syncPaths = Get-SyncFilePaths $manifestContent
    foreach ($relPath in $syncPaths) {
        $relPathWin = $relPath.Replace('/', '\')
        if ($KeepOutputs -and $relPathWin.StartsWith('data\outputs')) { continue }
        if (Test-Path $relPathWin -PathType Leaf) {
            Remove-Item $relPathWin -Force
            $deletedFiles++
        }
    }
}

# --- Remover .env se o usuário não quer preservar -----------------------------
if (-not $KeepEnv -and (Test-Path '.env' -PathType Leaf)) {
    Remove-Item '.env' -Force
    $deletedFiles++
}

# --- Apagar tudo se nuke_all --------------------------------------------------
if ($NukeAll) {
    Write-Info "Removendo pasta completa..."
    $currentDir = (Get-Location).Path
    $parentDir  = Split-Path $currentDir -Parent
    if ($currentDir -ne $env:USERPROFILE -and $currentDir -ne 'C:\') {
        Set-Location $parentDir
        if ($KeepOutputs) {
            Write-Warn "Outputs preservados - impossível apagar tudo E preservar outputs simultaneamente."
            Set-Location $currentDir
        } else {
            Remove-Item -Recurse -Force $currentDir -ErrorAction SilentlyContinue
            Write-Ok "Pasta '$currentDir' removida."
        }
    } else {
        Write-Err "Recusando remover '$currentDir' - parece ser o diretório home."
        Set-Location $currentDir
    }
} else {
    # --- Remover symlinks antes de testar pastas vazias ----------------------
    $symlinks = Get-ChildItem -Recurse -ErrorAction SilentlyContinue |
                Where-Object { $_.Attributes -band [System.IO.FileAttributes]::ReparsePoint }
    foreach ($sym in $symlinks) {
        $relSym = $sym.FullName.Replace((Get-Location).Path + '\', '')
        if ($KeepOutputs -and $relSym.StartsWith('data\outputs')) { continue }
        try { Remove-Item $sym.FullName -Force -ErrorAction Stop; $deletedFiles++ } catch { }
    }
    # --- Remover pastas vazias (bottom-up, multi-pass) -----------------------
    Write-Info "Removendo pastas vazias..."
    $passRemoved = 1
    while ($passRemoved -gt 0) {
        $passRemoved = 0
        $dirs = Get-ChildItem -Recurse -Directory -ErrorAction SilentlyContinue |
                Sort-Object { $_.FullName.Length } -Descending
        foreach ($dir in $dirs) {
            $items = Get-ChildItem $dir.FullName -ErrorAction SilentlyContinue
            if (@($items).Count -eq 0) {
                $relPath = $dir.FullName.Replace((Get-Location).Path + '\', '')
                if ($KeepOutputs -and $relPath.StartsWith('data\outputs')) { continue }
                try {
                    Remove-Item $dir.FullName -Force -ErrorAction Stop
                    $deletedDirs++
                    $passRemoved++
                } catch { }
            }
        }
    }
}

# --- Resumo -------------------------------------------------------------------
Write-Host ""
Write-Host $sep -ForegroundColor DarkGray
Write-Host "   Desinstalação concluída" -ForegroundColor White
Write-Host $sep -ForegroundColor DarkGray
Write-Host ""
Write-Ok "$deletedFiles arquivos de framework removidos"
Write-Ok "$cleanedSections seções gerenciadas limpas de arquivos mistos"
if ($deletedDirs -gt 0) { Write-Ok "$deletedDirs pastas vazias removidas" }
if ($skipped -gt 0) { Write-Info "$skipped itens preservados (outputs / .env)" }
Write-Host ""
if ($KeepOutputs) { Write-Info "Seus outputs em data\outputs\ foram preservados." }
if ($KeepEnv)     { Write-Info "Seu .env foi preservado." }
Write-Host ""
Write-Host "   Para reinstalar, execute install.ps1 novamente."
Write-Host ""
Read-Host "  Pressione Enter para sair"

# --- Auto-delete do script + pasta vazia --------------------------------------
if ($scriptPath -and (Test-Path $scriptPath)) {
    Remove-Item $scriptPath -Force -ErrorAction SilentlyContinue
}
$remaining = @(Get-ChildItem $installDir -ErrorAction SilentlyContinue)
if ($remaining.Count -eq 0) {
    $parentDir = Split-Path $installDir -Parent
    Set-Location $parentDir
    Remove-Item $installDir -Force -ErrorAction SilentlyContinue
    if (-not (Test-Path $installDir)) {
        Write-Ok "Pasta '$(Split-Path $installDir -Leaf)' removida (ficou vazia)."
    }
}
