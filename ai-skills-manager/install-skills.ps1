# install-skills.ps1 - Windows PowerShell install script for AI Skills Manager
# Usage: .\install-skills.ps1 [targets] [options]
# Requires: Python 3 on PATH (with PyYAML: pip install pyyaml)

[CmdletBinding()]
param(
    [switch]$Agy,
    [switch]$Claude,
    [switch]$Codex,
    [switch]$Gemini,
    [switch]$Cursor,
    [switch]$All,
    [switch]$Verbose,
    [switch]$DryRun,
    [switch]$Force,
    [switch]$Version,
    [switch]$Help
)

#region ─── Config ────────────────────────────────────────────────────────────
$script:VERSION      = "2.0.0"
$script:ProjectRoot  = $PSScriptRoot
$script:ManifestPath = Join-Path $ProjectRoot "skill-manifest.yaml"
$script:SkillsetDir  = Join-Path $ProjectRoot "skillset"
$script:StartTime    = [System.Diagnostics.Stopwatch]::StartNew()
#endregion

#region ─── Logger ────────────────────────────────────────────────────────────
function Get-Elapsed {
    return "[{0}s]" -f [int]$script:StartTime.Elapsed.TotalSeconds
}

function Write-LogInfo    { param([string]$Msg) Write-Host "$(Get-Elapsed) " -NoNewline; Write-Host "ℹ Info  " -ForegroundColor Cyan -NoNewline; Write-Host $Msg }
function Write-LogSuccess { param([string]$Msg) Write-Host "$(Get-Elapsed) " -NoNewline; Write-Host "✓ Success " -ForegroundColor Green -NoNewline; Write-Host $Msg }
function Write-LogInstalled { param([string]$Msg) Write-Host "$(Get-Elapsed) " -NoNewline; Write-Host "✓ Installed " -ForegroundColor Green -NoNewline; Write-Host $Msg }
function Write-LogWarn    { param([string]$Msg) Write-Host "$(Get-Elapsed) " -NoNewline; Write-Host "⚠ Warning " -ForegroundColor Yellow -NoNewline; Write-Host $Msg }
function Write-LogError   { param([string]$Msg) Write-Host "$(Get-Elapsed) " -NoNewline; Write-Host "✗ Error   " -ForegroundColor Red -NoNewline; Write-Host $Msg -ForegroundColor Red }
function Write-LogBold    { param([string]$Msg) Write-Host $Msg -ForegroundColor White }
#endregion

#region ─── Help ──────────────────────────────────────────────────────────────
function Show-Help {
    Write-Host ""
    Write-Host "  AI Skills Installer — Windows PowerShell Edition" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Usage:" -ForegroundColor Yellow
    Write-Host "    .\install-skills.ps1 [targets] [options]"
    Write-Host ""
    Write-Host "  Targets:" -ForegroundColor Yellow
    Write-Host "    -Agy       Install to Antigravity CLI (AGY)"
    Write-Host "    -Claude    Install to Claude Code"
    Write-Host "    -Codex     Install to Codex CLI"
    Write-Host "    -Gemini    Install to Gemini CLI"
    Write-Host "    -Cursor    Install to Cursor CLI"
    Write-Host "    -All       Install to all detected CLIs"
    Write-Host ""
    Write-Host "  Options:" -ForegroundColor Yellow
    Write-Host "    -Verbose   Show detailed execution logs"
    Write-Host "    -DryRun    Simulate without modifying files"
    Write-Host "    -Force     Force overwrite and bypass checks"
    Write-Host "    -Version   Print version information"
    Write-Host "    -Help      Show this help menu"
    Write-Host ""
    Write-Host "  Examples:" -ForegroundColor Yellow
    Write-Host "    .\install-skills.ps1 -Agy"
    Write-Host "    .\install-skills.ps1 -Agy -Claude -Verbose"
    Write-Host "    .\install-skills.ps1 -All -DryRun"
    Write-Host "    .\install-skills.ps1 -Agy -Force"
    Write-Host ""
    exit 0
}
#endregion

#region ─── Python Check ──────────────────────────────────────────────────────
function Get-PythonCmd {
    if (Get-Command python3 -ErrorAction SilentlyContinue) { return "python3" }
    if (Get-Command python  -ErrorAction SilentlyContinue) { return "python" }
    Write-LogError "Python 3 is required but not found. Install Python from https://python.org and ensure it's on PATH."
    exit 1
}
#endregion

#region ─── PyYAML Check ──────────────────────────────────────────────────────
function Test-PyYaml {
    param([string]$PythonCmd)
    $result = & $PythonCmd -c "import yaml; print('OK')" 2>&1
    if ($result -ne "OK") {
        Write-LogError "PyYAML is not installed. Run: pip install pyyaml"
        exit 1
    }
}
#endregion

#region ─── Manifest Helpers ──────────────────────────────────────────────────
function Invoke-PythonManifest {
    param([string]$PythonCmd, [string]$Code)
    $result = & $PythonCmd -c $Code 2>&1
    return $result
}

function Get-InstallOrder {
    param([string]$PythonCmd)
    $code = @"
import yaml, sys

try:
    with open(r'$($script:ManifestPath.Replace('\','\\'))', encoding='utf-8') as f:
        data = yaml.safe_load(f)
except Exception as e:
    print(f'Error reading manifest: {e}', file=sys.stderr); sys.exit(1)

skills  = data.get('skills', [])
graph   = {s['id']: s.get('dependencies', []) for s in skills}
visited = {}
order   = []

def dfs(node):
    visited[node] = 1
    for dep in graph.get(node, []):
        if dep not in graph:
            print(f'Error: Dependency "{dep}" not in manifest!', file=sys.stderr); sys.exit(1)
        if visited.get(dep, 0) == 1:
            print(f'Error: Circular dependency: "{node}" <-> "{dep}"', file=sys.stderr); sys.exit(1)
        elif visited.get(dep, 0) == 0:
            dfs(dep)
    visited[node] = 2
    order.append(node)

for skill in graph:
    if visited.get(skill, 0) == 0:
        dfs(skill)

print(' '.join(order))
"@
    return Invoke-PythonManifest -PythonCmd $PythonCmd -Code $code
}

function Get-SkillField {
    param([string]$PythonCmd, [string]$SkillId, [string]$Field)
    $manifestEsc = $script:ManifestPath.Replace('\', '\\')
    $code = @"
import yaml
try:
    with open(r'$manifestEsc', encoding='utf-8') as f:
        data = yaml.safe_load(f)
    for s in data.get('skills', []):
        if s['id'] == '$SkillId':
            val = s.get('$Field', '')
            print(' '.join(val) if isinstance(val, list) else val)
            break
except Exception as e:
    import sys; print(f'Error: {e}', file=sys.stderr); sys.exit(1)
"@
    return (Invoke-PythonManifest -PythonCmd $PythonCmd -Code $code) -join " "
}
#endregion

#region ─── Validation ────────────────────────────────────────────────────────
function Invoke-ValidateSkillset {
    param([string]$PythonCmd)
    Write-LogInfo "Starting skillset validation..."

    $manifestEsc  = $script:ManifestPath.Replace('\', '\\')
    $skillsetEsc  = $script:SkillsetDir.Replace('\', '\\')

    $code = @"
import yaml, os, sys, re

manifest_path = r'$manifestEsc'
skillset_dir  = r'$skillsetEsc'

try:
    with open(manifest_path, encoding='utf-8') as f:
        manifest = yaml.safe_load(f)
except Exception as e:
    print(f'Error: Manifest parsing failed: {e}', file=sys.stderr); sys.exit(1)

skills = manifest.get('skills', [])
ids    = [s['id']   for s in skills]
names  = [s['name'] for s in skills]
dup_ids   = set(x for x in ids   if ids.count(x)   > 1)
dup_names = set(x for x in names if names.count(x) > 1)

if dup_ids:   print(f'Error: Duplicate skill IDs: {list(dup_ids)}',   file=sys.stderr); sys.exit(1)
if dup_names: print(f'Error: Duplicate names: {list(dup_names)}',      file=sys.stderr); sys.exit(1)

errors = []
for s in skills:
    sid     = s['id']
    folder  = s['directory']
    md_path = os.path.join(skillset_dir, folder, f'{sid}.md')

    if not os.path.isfile(md_path):
        errors.append(f'Missing skill file: {md_path}'); continue

    with open(md_path, 'r', encoding='utf-8') as f:
        content = f.read()

    lines    = content.split('\n')
    headings = [re.match(r'^#+\s+(.*)$', l.strip()).group(1).strip()
                for l in lines if re.match(r'^#+\s+', l.strip())]

    has_title    = any(l.startswith('# ') for l in lines)
    has_summary  = any(h in ['Overview','Summary','Description','Purpose'] for h in headings)
    has_purpose  = 'Purpose' in headings
    has_triggers = any(h in ['When to Use','Triggers','When NOT to Use'] for h in headings)
    has_workflow = any(h in ['Workflow','Execution Workflow','Principles','Rules','Investigation Phase','Project Configuration','Constraints'] for h in headings)
    has_output   = any(h in ['Completion Checklist','Expected Outputs','Output'] for h in headings)
    has_deps     = any(h in ['Required Prerequisite Skills','Dependencies','Required Skills'] for h in headings)
    has_examples = any(h in ['Examples','Example','Usage','Completion Checklist'] for h in headings)

    if s['category'] != 'workflow':
        has_deps = True

    missing = []
    if not has_title:    missing.append('Title')
    if not has_summary:  missing.append('Summary')
    if not has_purpose:  missing.append('Purpose')
    if not has_triggers: missing.append('Triggers')
    if not has_workflow: missing.append('Workflow')
    if not has_output:   missing.append('Output')
    if not has_deps:     missing.append('Dependencies')
    if not has_examples: missing.append('Examples')

    if missing:
        errors.append(f'Skill "{sid}" missing sections: {missing}')

if errors:
    for e in errors: print(e, file=sys.stderr)
    sys.exit(1)

print('OK')
"@

    $result = Invoke-PythonManifest -PythonCmd $PythonCmd -Code $code
    if ($result -ne "OK") {
        Write-LogError "Validation failed: $result"
        return $false
    }

    Write-LogSuccess "Validation complete. All skills, names, folders, and links are healthy."
    return $true
}
#endregion

#region ─── CLI Detection ─────────────────────────────────────────────────────
function Test-CliInstalled {
    param([string]$Cli)
    switch ($Cli) {
        "agy" {
            $agyCfg = Join-Path $env:USERPROFILE ".gemini\config"
            return (Get-Command agy -ErrorAction SilentlyContinue) -or (Test-Path $agyCfg) -or ($env:MOCK_AGY_INSTALLED -eq "1")
        }
        "claude" { return [bool](Get-Command claude -ErrorAction SilentlyContinue) }
        "codex"  { return [bool](Get-Command codex  -ErrorAction SilentlyContinue) }
        "gemini" { return [bool](Get-Command gemini -ErrorAction SilentlyContinue) }
        "cursor" { return [bool](Get-Command cursor -ErrorAction SilentlyContinue) }
        default  { return $false }
    }
}
#endregion

#region ─── AGY Installer ─────────────────────────────────────────────────────
function Install-SkillToAgy {
    param(
        [string]$SourcePath,
        [string]$SkillId,
        [string]$Mode
    )

    $targetDir = Join-Path $env:USERPROFILE ".gemini\config\skills"
    $destDir   = Join-Path $targetDir $SkillId
    $destFile  = Join-Path $destDir "SKILL.md"

    if ($DryRun) {
        Write-LogInfo "[DRY-RUN] [AGY] Would install $SkillId -> $destFile (Mode: $Mode)"
        return $true
    }

    # Ensure destination directory exists
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }

    if ($Mode -eq "symlink") {
        # Remove existing if Force or mismatched
        if (Test-Path $destFile) {
            $existing = Get-Item $destFile -ErrorAction SilentlyContinue
            $isLink   = $existing.LinkType -eq "SymbolicLink"
            $linkTarget = if ($isLink) { (Get-Item $destFile).Target } else { "" }

            if ($isLink -and ($linkTarget -eq $SourcePath) -and -not $Force) {
                if ($Verbose) { Write-LogInfo "[AGY] Already linked: $destFile" }
                return $true
            }
            Remove-Item $destFile -Force
        }

        # Create junction/symlink (requires Developer Mode or Admin on Windows)
        try {
            New-Item -ItemType SymbolicLink -Path $destFile -Target $SourcePath -Force -ErrorAction Stop | Out-Null
            if ($Verbose) { Write-LogInfo "[AGY] Symlinked: $destFile -> $SourcePath" }
        } catch {
            Write-LogWarn "[AGY] Symlink creation failed (enable Developer Mode or run as Admin). Falling back to copy..."
            try {
                Copy-Item -Path $SourcePath -Destination $destFile -Force
                if ($Verbose) { Write-LogInfo "[AGY] Copied: $destFile" }
            } catch {
                Write-LogError "[AGY] Copy also failed for: $SkillId — $_"
                return $false
            }
        }
    } else {
        if ((Test-Path $destFile) -and -not $Force) {
            if ($Verbose) { Write-LogInfo "[AGY] $destFile exists, skipping (use -Force)." }
            return $true
        }
        try {
            Copy-Item -Path $SourcePath -Destination $destFile -Force
        } catch {
            Write-LogError "[AGY] Copy failed for: $SkillId — $_"
            return $false
        }
    }

    Write-LogInstalled "[AGY] Installed: $SkillId ($Mode)"
    return $true
}
#endregion

#region ─── Install Dispatcher ────────────────────────────────────────────────
function Install-SkillToCli {
    param([string]$Cli, [string]$SourcePath, [string]$SkillId, [string]$Mode)
    switch ($Cli) {
        "agy"   { return Install-SkillToAgy -SourcePath $SourcePath -SkillId $SkillId -Mode $Mode }
        default { Write-LogWarn "Adapter for '$Cli' not yet implemented in PowerShell edition."; return $false }
    }
}
#endregion

#region ─── Install to Target CLI ─────────────────────────────────────────────
function Install-ToTargetCli {
    param([string]$Cli, [string]$PythonCmd)

    Write-LogBold "========================================"
    Write-LogInfo  "Initiating install procedure for: $Cli"
    Write-LogBold  "----------------------------------------"

    if (-not (Test-CliInstalled -Cli $Cli)) {
        Write-LogError "Target CLI '$Cli' is not detected on this system."
        return $false
    }

    $installSequence = Get-InstallOrder -PythonCmd $PythonCmd
    if (-not $installSequence) {
        Write-LogError "Failed to resolve dependency graph. Aborting."
        return $false
    }

    if ($Verbose) { Write-LogInfo "Install sequence: $installSequence" }

    $skillIds = $installSequence -split '\s+'
    $failures = 0

    foreach ($skillId in $skillIds) {
        if ([string]::IsNullOrWhiteSpace($skillId)) { continue }

        $folder      = Get-SkillField -PythonCmd $PythonCmd -SkillId $skillId -Field "directory"
        $installMode = Get-SkillField -PythonCmd $PythonCmd -SkillId $skillId -Field "install_mode"
        $supported   = Get-SkillField -PythonCmd $PythonCmd -SkillId $skillId -Field "supported_clis"

        if ($supported -notmatch "\b$Cli\b") {
            if (-not $Force) {
                Write-LogWarn "Skill '$skillId' doesn't support '$Cli'. Skipping (use -Force)."
                continue
            }
            Write-LogWarn "Forcing unsupported skill '$skillId' onto '$Cli'."
        }

        $sourcePath = Join-Path $script:SkillsetDir "$folder\$skillId.md"

        if (-not (Install-SkillToCli -Cli $Cli -SourcePath $sourcePath -SkillId $skillId -Mode $installMode)) {
            Write-LogError "Failed to install skill '$skillId' to '$Cli'."
            $failures++
        }
    }

    if ($failures -eq 0) {
        Write-LogSuccess "Successfully completed installation to: $Cli"
        return $true
    } else {
        Write-LogError "Installation to '$Cli' completed with $failures error(s)."
        return $false
    }
}
#endregion

#region ─── Main ──────────────────────────────────────────────────────────────
function Main {
    if ($Version) { Write-Host "AI Skills Manager v$script:VERSION (PowerShell Edition)"; exit 0 }
    if ($Help)    { Show-Help }

    $pythonCmd = Get-PythonCmd
    Test-PyYaml -PythonCmd $pythonCmd

    if ($Verbose) { Write-LogInfo "Verbose mode enabled." }
    if ($DryRun)  { Write-LogInfo "Dry-run mode enabled. No file changes will be written." }

    # Collect target CLIs
    $targetClis = [System.Collections.Generic.List[string]]::new()
    if ($Agy)    { $targetClis.Add("agy") }
    if ($Claude) { $targetClis.Add("claude") }
    if ($Codex)  { $targetClis.Add("codex") }
    if ($Gemini) { $targetClis.Add("gemini") }
    if ($Cursor) { $targetClis.Add("cursor") }

    $detectAll = $All -or ($targetClis.Count -eq 0)
    if (-not $All -and $targetClis.Count -eq 0) {
        Write-LogInfo "No targets specified. Auto-detecting installed CLIs..."
    }

    if ($detectAll) {
        foreach ($cli in @("agy","claude","codex","gemini","cursor")) {
            if (Test-CliInstalled -Cli $cli) { $targetClis.Add($cli) }
        }
        if ($targetClis.Count -eq 0) {
            Write-LogError "No supported AI CLIs were detected on this system."
            exit 1
        }
    }

    # Validate
    if (-not (Invoke-ValidateSkillset -PythonCmd $pythonCmd)) {
        Write-LogError "Skillset validation failed. Aborting installation."
        exit 1
    }

    # Install
    $failures = 0
    foreach ($cli in $targetClis) {
        if (-not (Install-ToTargetCli -Cli $cli -PythonCmd $pythonCmd)) {
            $failures++
        }
    }

    Write-LogBold "----------------------------------------"
    if ($failures -eq 0) {
        Write-LogSuccess "AI Skills installation report: All targets configured successfully!"
        exit 0
    } else {
        Write-LogError "AI Skills installation report: Completed with $failures failure(s)."
        exit 1
    }
}

Main
#endregion
