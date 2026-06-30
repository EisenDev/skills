# uninstall_ai_mcp.ps1 - Windows PowerShell MCP Uninstaller
# Removes the ClickUp MCP Server configuration from supported AI CLIs.
# Leaves every other MCP server completely untouched.
#
# Usage: .\uninstall_ai_mcp.ps1 [OPTIONS]
# Requires: Python 3 on PATH

[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$Help
)

#region ─── Constants ──────────────────────────────────────────────────────────
$script:SERVER_NAME = "clickup"
#endregion

#region ─── Config Paths ───────────────────────────────────────────────────────
$HOME_DIR = $env:USERPROFILE

$script:AGY_CONFIG_FILE        = Join-Path $HOME_DIR ".gemini\config\mcp_config.json"
$script:CLAUDE_CONFIG_FILE     = Join-Path $HOME_DIR ".claude\claude.json"
$script:CLAUDE_ALT_CONFIG_FILE = Join-Path $HOME_DIR ".config\claude\mcp.json"
$script:CODEX_CONFIG_FILE      = Join-Path $HOME_DIR ".config\codex\mcp.json"
#endregion

#region ─── Logging ────────────────────────────────────────────────────────────
function Write-LogInfo    { param([string]$Msg) Write-Host "ℹ " -ForegroundColor Cyan   -NoNewline; Write-Host $Msg }
function Write-LogSuccess { param([string]$Msg) Write-Host "✓ " -ForegroundColor Green  -NoNewline; Write-Host $Msg }
function Write-LogWarn    { param([string]$Msg) Write-Host "⚠ " -ForegroundColor Yellow -NoNewline; Write-Host $Msg }
function Write-LogError   { param([string]$Msg) Write-Host "✗ " -ForegroundColor Red    -NoNewline; Write-Host $Msg -ForegroundColor Red }
function Write-LogDebug   { param([string]$Msg) if ($Verbose) { Write-Host "DEBUG: $Msg" -ForegroundColor DarkGray } }
#endregion

#region ─── Help ───────────────────────────────────────────────────────────────
function Show-Help {
    Write-Host ""
    Write-Host "  AI CLI MCP Uninstaller — Windows PowerShell Edition" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Usage:" -ForegroundColor Yellow
    Write-Host "    .\uninstall_ai_mcp.ps1 [OPTIONS]"
    Write-Host ""
    Write-Host "  Options:" -ForegroundColor Yellow
    Write-Host "    -Help      Show this help message"
    Write-Host "    -DryRun    Preview what would be removed (no changes made)"
    Write-Host "    -Verbose   Enable verbose debug output"
    Write-Host ""
    Write-Host "  Examples:" -ForegroundColor Yellow
    Write-Host "    .\uninstall_ai_mcp.ps1"
    Write-Host "    .\uninstall_ai_mcp.ps1 -DryRun"
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

#region ─── Backup ─────────────────────────────────────────────────────────────
function Backup-ConfigFile {
    param([string]$FilePath)
    if (Test-Path $FilePath) {
        $ts     = Get-Date -Format "yyyyMMdd-HHmmss"
        $backup = "${FilePath}.uninstall-backup-${ts}.json"
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
    & $PythonCmd -m json.tool $FilePath > $null 2>&1
    return $LASTEXITCODE -eq 0
}
#endregion

#region ─── Remove MCP Entry ───────────────────────────────────────────────────
function Remove-McpEntry {
    param([string]$PythonCmd, [string]$FilePath, [string]$Label)

    if (-not (Test-Path $FilePath)) {
        Write-LogDebug "Config not found, skipping: $FilePath"
        return
    }

    $fileEsc = $FilePath.Replace('\', '\\')

    # Check if ClickUp entry exists
    $existing = & $PythonCmd -c @"
import json
try:
    d = json.load(open(r'$fileEsc'))
    v = d.get('mcpServers', {}).get('$($script:SERVER_NAME)', None)
    print('exists' if v else '')
except: print('')
"@ 2>&1

    if ($existing -ne 'exists') {
        Write-LogInfo "ClickUp MCP not found in $Label. Skipping."
        return
    }

    Write-LogInfo "Removing ClickUp MCP from $Label..."
    Backup-ConfigFile -FilePath $FilePath

    if ($DryRun) {
        Write-LogInfo "[DRY-RUN] Would remove '$($script:SERVER_NAME)' from $FilePath"
        return
    }

    $result = & $PythonCmd -c @"
import json, sys

file_path   = r'$fileEsc'
server_name = '$($script:SERVER_NAME)'

try:
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
except Exception as e:
    print(f'Error reading file: {e}', file=sys.stderr)
    sys.exit(1)

if 'mcpServers' in data and server_name in data['mcpServers']:
    del data['mcpServers'][server_name]

with open(file_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2)

print('OK')
"@ 2>&1

    if ($result -ne 'OK') {
        Write-LogError "Failed to remove entry from $Label : $result"
        return
    }

    if (-not (Test-JsonValid -PythonCmd $PythonCmd -FilePath $FilePath)) {
        Write-LogError "JSON validation failed after removing entry from $FilePath."
        return
    }

    Write-LogSuccess "Successfully removed ClickUp MCP from $Label"
}
#endregion

#region ─── Main ───────────────────────────────────────────────────────────────
if ($Help) { Show-Help }

$pythonCmd = Get-PythonCmd

Write-LogInfo "Detecting AI CLIs for uninstallation..."

Remove-McpEntry -PythonCmd $pythonCmd -FilePath $script:AGY_CONFIG_FILE -Label "Antigravity CLI"

if (Test-Path $script:CLAUDE_ALT_CONFIG_FILE) {
    Remove-McpEntry -PythonCmd $pythonCmd -FilePath $script:CLAUDE_ALT_CONFIG_FILE -Label "Claude Code"
} elseif (Test-Path $script:CLAUDE_CONFIG_FILE) {
    Remove-McpEntry -PythonCmd $pythonCmd -FilePath $script:CLAUDE_CONFIG_FILE     -Label "Claude Code"
}

Remove-McpEntry -PythonCmd $pythonCmd -FilePath $script:CODEX_CONFIG_FILE -Label "Codex CLI"

Write-LogSuccess "Uninstallation completed."
#endregion
