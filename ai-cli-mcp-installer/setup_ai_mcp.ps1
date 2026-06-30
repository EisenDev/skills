# setup_ai_mcp.ps1 - Windows PowerShell MCP Installer
# Installs ClickUp MCP Server for supported AI CLIs on Windows.
# Supported: Antigravity CLI (AGY), Claude Code, OpenAI Codex CLI
#
# Usage: .\setup_ai_mcp.ps1 [OPTIONS]
# Requires: Python 3 on PATH

[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$Force,
    [switch]$Diagnose,
    [switch]$Help
)

#region ─── Constants ──────────────────────────────────────────────────────────
$script:SERVER_NAME = "clickup"
$script:SERVER_URL  = "https://mcp.clickup.com/mcp"
#endregion

#region ─── Config Paths ───────────────────────────────────────────────────────
$HOME_DIR = $env:USERPROFILE

$script:AGY_CONFIG_FILE      = Join-Path $HOME_DIR ".gemini\config\mcp_config.json"

$script:CLAUDE_CONFIG_DIR    = Join-Path $HOME_DIR ".claude"
$script:CLAUDE_CONFIG_FILE   = Join-Path $HOME_DIR ".claude\claude.json"
$script:CLAUDE_ALT_CONFIG_DIR  = Join-Path $HOME_DIR ".config\claude"
$script:CLAUDE_ALT_CONFIG_FILE = Join-Path $HOME_DIR ".config\claude\mcp.json"

$script:CODEX_CONFIG_DIR  = Join-Path $HOME_DIR ".config\codex"
$script:CODEX_CONFIG_FILE = Join-Path $HOME_DIR ".config\codex\mcp.json"
#endregion

#region ─── Logging ────────────────────────────────────────────────────────────
function Write-LogInfo    { param([string]$Msg) Write-Host "ℹ " -ForegroundColor Cyan    -NoNewline; Write-Host $Msg }
function Write-LogSuccess { param([string]$Msg) Write-Host "✓ " -ForegroundColor Green   -NoNewline; Write-Host $Msg }
function Write-LogWarn    { param([string]$Msg) Write-Host "⚠ " -ForegroundColor Yellow  -NoNewline; Write-Host $Msg }
function Write-LogError   { param([string]$Msg) Write-Host "✗ " -ForegroundColor Red     -NoNewline; Write-Host $Msg -ForegroundColor Red }
function Write-LogDebug   { param([string]$Msg) if ($Verbose) { Write-Host "DEBUG: $Msg" -ForegroundColor DarkGray } }
#endregion

#region ─── Help ───────────────────────────────────────────────────────────────
function Show-Help {
    Write-Host ""
    Write-Host "  AI CLI MCP Installer — Windows PowerShell Edition" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Usage:" -ForegroundColor Yellow
    Write-Host "    .\setup_ai_mcp.ps1 [OPTIONS]"
    Write-Host ""
    Write-Host "  Options:" -ForegroundColor Yellow
    Write-Host "    -Help      Show this help message"
    Write-Host "    -DryRun    Run without making any changes (preview mode)"
    Write-Host "    -Force     Force installation even if already configured"
    Write-Host "    -Diagnose  Print diagnostic information and exit"
    Write-Host "    -Verbose   Enable verbose debug output"
    Write-Host ""
    Write-Host "  Examples:" -ForegroundColor Yellow
    Write-Host "    .\setup_ai_mcp.ps1"
    Write-Host "    .\setup_ai_mcp.ps1 -DryRun -Verbose"
    Write-Host "    .\setup_ai_mcp.ps1 -Force"
    Write-Host "    .\setup_ai_mcp.ps1 -Diagnose"
    Write-Host ""
    exit 0
}
#endregion

#region ─── Python Check ───────────────────────────────────────────────────────
function Get-PythonCmd {
    if (Get-Command python3 -ErrorAction SilentlyContinue) { return "python3" }
    if (Get-Command python  -ErrorAction SilentlyContinue) { return "python" }
    Write-LogError "Python 3 is required but not found. Install from https://python.org"
    exit 1
}
#endregion

#region ─── Diagnose ───────────────────────────────────────────────────────────
function Invoke-Diagnose {
    param([string]$PythonCmd)

    Write-Host ""
    Write-Host "Diagnostic Mode (PowerShell Edition)" -ForegroundColor Cyan
    Write-Host "-------------------------------------"

    if (Get-Command agy -ErrorAction SilentlyContinue) {
        $ver = & agy --version 2>$null; Write-Host "✓ agy: $ver" -ForegroundColor Green
    } else {
        Write-Host "✗ agy: Not found" -ForegroundColor Red
    }

    Write-Host "  AGY config path : $script:AGY_CONFIG_FILE"

    if (Test-Path $script:AGY_CONFIG_FILE) {
        $result = & $PythonCmd -m json.tool $script:AGY_CONFIG_FILE 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ AGY config JSON : Valid" -ForegroundColor Green
        } else {
            Write-Host "✗ AGY config JSON : Invalid" -ForegroundColor Red
        }

        $servers = & $PythonCmd -c @"
import json
try:
    d = json.load(open(r'$($script:AGY_CONFIG_FILE.Replace('\','\\'))'))
    print(', '.join(d.get('mcpServers', {}).keys()) or 'None')
except: print('Unknown')
"@
        Write-Host "  Registered servers: $servers"
    } else {
        Write-Host "⚠  AGY config : File does not exist yet" -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "  Python : $PythonCmd ($( & $PythonCmd --version 2>&1 ))"
    Write-Host "  USERPROFILE : $env:USERPROFILE"
    Write-Host ""
    exit 0
}
#endregion

#region ─── Backup ─────────────────────────────────────────────────────────────
function Backup-ConfigFile {
    param([string]$FilePath)
    if (Test-Path $FilePath) {
        $ts     = Get-Date -Format "yyyyMMdd-HHmmss"
        $backup = "${FilePath}.backup-${ts}.json"
        if ($DryRun) {
            Write-LogInfo "[DRY-RUN] Would backup $FilePath -> $backup"
        } else {
            Copy-Item $FilePath $backup
            Write-LogDebug "Backed up $FilePath to $backup"
        }
    }
}
#endregion

#region ─── Validate JSON ──────────────────────────────────────────────────────
function Test-JsonValid {
    param([string]$PythonCmd, [string]$FilePath)
    $out = & $PythonCmd -m json.tool $FilePath 2>&1
    return $LASTEXITCODE -eq 0
}
#endregion

#region ─── Merge JSON ─────────────────────────────────────────────────────────
function Merge-McpConfig {
    param([string]$PythonCmd, [string]$FilePath)

    if ($DryRun) {
        Write-LogInfo "[DRY-RUN] Would create or merge ClickUp MCP in $FilePath"
        return
    }

    # Ensure parent directory exists
    $dir = Split-Path $FilePath -Parent
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-LogDebug "Created directory: $dir"
    }

    # Create empty JSON if missing
    if (-not (Test-Path $FilePath)) {
        '{}' | Set-Content -Path $FilePath -Encoding UTF8
        Write-LogDebug "Created new config file: $FilePath"
    }

    # Validate / reset if broken
    if (-not (Test-JsonValid -PythonCmd $PythonCmd -FilePath $FilePath)) {
        Write-LogWarn "Invalid JSON in $FilePath. Backing up and resetting."
        Backup-ConfigFile -FilePath $FilePath
        '{}' | Set-Content -Path $FilePath -Encoding UTF8
    }

    # Check if ClickUp already exists
    $fileEsc = $FilePath.Replace('\', '\\')
    $existing = & $PythonCmd -c @"
import json
try:
    d = json.load(open(r'$fileEsc'))
    v = d.get('mcpServers', {}).get('$($script:SERVER_NAME)', None)
    print('exists' if v else '')
except: print('')
"@

    if ($existing -eq 'exists' -and -not $Force) {
        Write-LogWarn "ClickUp MCP already configured in $FilePath. Skipping (use -Force to overwrite)."
        return
    }

    # Perform the merge
    $result = & $PythonCmd -c @"
import json, sys

file_path   = r'$fileEsc'
server_name = '$($script:SERVER_NAME)'
server_url  = '$($script:SERVER_URL)'

try:
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
except Exception:
    data = {}

if 'mcpServers' not in data:
    data['mcpServers'] = {}

data['mcpServers'][server_name] = {
    'command': 'npx',
    'args': ['-y', 'mcp-remote', server_url]
}

with open(file_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2)

print('OK')
"@ 2>&1

    if ($result -ne 'OK') {
        Write-LogError "Failed to merge config: $result"
        return
    }

    if (-not (Test-JsonValid -PythonCmd $PythonCmd -FilePath $FilePath)) {
        Write-LogError "Generated JSON in $FilePath is invalid."
        return
    }

    Write-LogSuccess "Configuration validated for $FilePath"
}
#endregion

#region ─── Detect and Install ─────────────────────────────────────────────────
function Invoke-DetectAndInstall {
    param([string]$PythonCmd)

    Write-LogInfo "Detecting AI CLIs..."
    $foundAny = $false

    # ── Antigravity CLI ──
    $agyFound = (Get-Command agy -ErrorAction SilentlyContinue) -or
                (Test-Path $script:AGY_CONFIG_FILE) -or
                (Test-Path (Join-Path $HOME_DIR ".gemini\config")) -or
                ($env:MOCK_AGY_INSTALLED -eq "1")

    if ($agyFound) {
        Write-LogSuccess "Antigravity CLI found"
        $foundAny = $true
        Write-LogInfo "Installing ClickUp MCP for Antigravity CLI..."
        Backup-ConfigFile -FilePath $script:AGY_CONFIG_FILE
        Merge-McpConfig   -PythonCmd $PythonCmd -FilePath $script:AGY_CONFIG_FILE
    } else {
        Write-LogError "Antigravity CLI not installed"
    }

    # ── Claude Code ──
    $claudeFound = (Test-Path $script:CLAUDE_CONFIG_DIR) -or (Test-Path $script:CLAUDE_ALT_CONFIG_DIR)
    if ($claudeFound) {
        Write-LogSuccess "Claude Code found"
        $foundAny = $true
        Write-LogInfo "Installing ClickUp MCP for Claude Code..."
        $targetFile = $script:CLAUDE_ALT_CONFIG_FILE
        if ((Test-Path $script:CLAUDE_CONFIG_DIR) -and (-not (Test-Path $script:CLAUDE_ALT_CONFIG_DIR))) {
            $targetFile = $script:CLAUDE_CONFIG_FILE
        }
        Backup-ConfigFile -FilePath $targetFile
        Merge-McpConfig   -PythonCmd $PythonCmd -FilePath $targetFile
    } else {
        Write-LogError "Claude Code not installed"
    }

    # ── OpenAI Codex CLI ──
    $codexFound = (Get-Command codex -ErrorAction SilentlyContinue) -or (Test-Path $script:CODEX_CONFIG_DIR)
    if ($codexFound) {
        Write-LogSuccess "Codex CLI found"
        $foundAny = $true
        Write-LogInfo "Installing ClickUp MCP for Codex CLI..."
        Backup-ConfigFile -FilePath $script:CODEX_CONFIG_FILE
        Merge-McpConfig   -PythonCmd $PythonCmd -FilePath $script:CODEX_CONFIG_FILE
    } else {
        Write-LogError "Codex CLI not installed"
    }

    if (-not $foundAny) {
        Write-LogWarn "No supported AI CLIs found. Nothing to install."
    } else {
        Write-LogSuccess "Installation completed. Restart any running CLI to pick up changes."
    }
}
#endregion

#region ─── Main ───────────────────────────────────────────────────────────────
if ($Help) { Show-Help }

$pythonCmd = Get-PythonCmd
if ($Diagnose) { Invoke-Diagnose -PythonCmd $pythonCmd }

Invoke-DetectAndInstall -PythonCmd $pythonCmd
#endregion
