#!/usr/bin/env bash

# install-skills-gitbash.sh - Git Bash (MINGW64/MSYS2) compatible install script
# Fixes Windows path translation issues when running on Git Bash for Windows.
# Usage: ./install-skills-gitbash.sh [targets] [options]

# ─────────────────────────────────────────────
# Resolve true Windows-compatible project root
# Git Bash translates /c/Users/... but Python needs C:/Users/...
# ─────────────────────────────────────────────
PROJECT_ROOT_BASH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Convert MINGW/MSYS POSIX path -> Windows path for Python compatibility
to_win_path() {
    local posix_path="$1"
    if command -v cygpath &>/dev/null; then
        cygpath -w "$posix_path"
    else
        # Fallback: manual conversion /c/foo -> C:/foo
        echo "$posix_path" | sed 's|^/\([a-zA-Z]\)/|\1:/|'
    fi
}

PROJECT_ROOT=$(to_win_path "$PROJECT_ROOT_BASH")
export PROJECT_ROOT PROJECT_ROOT_BASH

# ─────────────────────────────────────────────
# ANSI Colors (Git Bash supports ANSI sequences)
# ─────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

START_TIME=$(date +%s)
get_elapsed() { local now; now=$(date +%s); echo "[$(( now - START_TIME ))s]"; }

log_info()     { printf "${CYAN}ℹ Info${NC} %s %s\n"      "$(get_elapsed)" "$*"; }
log_success()  { printf "${GREEN}✓ Success${NC} %s %s\n"   "$(get_elapsed)" "$*"; }
log_installed(){ printf "${GREEN}✓ Installed${NC} %s %s\n" "$(get_elapsed)" "$*"; }
log_warn()     { printf "${YELLOW}⚠ Warning${NC} %s %s\n"  "$(get_elapsed)" "$*"; }
log_error()    { printf "${RED}✗ Error${NC} %s %s\n"       "$(get_elapsed)" "$*" >&2; }
log_bold()     { printf "${BOLD}%s${NC}\n" "$*"; }

# ─────────────────────────────────────────────
# Flags
# ─────────────────────────────────────────────
VERBOSE=false
DRY_RUN=false
FORCE=false
CLI_ARGS=()

show_help() {
    echo ""
    echo "  AI Skills Installer — Git Bash Edition"
    echo ""
    echo "  Usage: ./install-skills-gitbash.sh [targets] [options]"
    echo ""
    echo "  Targets:"
    echo "    --agy       Install to Antigravity CLI (AGY)"
    echo "    --claude    Install to Claude Code"
    echo "    --codex     Install to Codex CLI"
    echo "    --gemini    Install to Gemini CLI"
    echo "    --cursor    Install to Cursor CLI"
    echo "    --all       Install to all detected CLIs"
    echo ""
    echo "  Options:"
    echo "    --verbose   Show detailed execution logs"
    echo "    --dry-run   Simulate without modifying files"
    echo "    --force     Force overwrite and bypass checks"
    echo "    --version   Print version information"
    echo "    -h, --help  Show this help menu"
    echo ""
    exit 0
}

for arg in "$@"; do
    case "$arg" in
        --verbose)  VERBOSE=true ;;
        --dry-run)  DRY_RUN=true ;;
        --force)    FORCE=true ;;
        --version)  echo "AI Skills Manager v2.0.0 (Git Bash Edition)"; exit 0 ;;
        -h|--help)  show_help ;;
        *)          CLI_ARGS+=("$arg") ;;
    esac
done

[ "$VERBOSE" = "true" ] && log_info "Verbose mode enabled."
[ "$DRY_RUN" = "true" ] && log_info "Dry-run mode enabled. No file changes will be written."

# ─────────────────────────────────────────────
# Python detection
# ─────────────────────────────────────────────
check_python() {
    if command -v python3 &>/dev/null; then
        PYTHON_CMD="python3"
    elif command -v python &>/dev/null; then
        PYTHON_CMD="python"
    else
        log_error "Python 3 is required but not found. Install Python and add it to PATH."
        exit 1
    fi
}

# ─────────────────────────────────────────────
# Validate manifest + skillset
# Uses Windows-style paths (r'...') so Python can open them on Windows
# ─────────────────────────────────────────────
validate_skillset() {
    log_info "Starting skillset validation..."

    local win_manifest win_skillset
    win_manifest=$(to_win_path "${PROJECT_ROOT_BASH}/skill-manifest.yaml")
    win_skillset=$(to_win_path "${PROJECT_ROOT_BASH}/skillset")

    local result
    result=$($PYTHON_CMD - << PYEOF 2>&1
import yaml, os, sys, re

manifest_path = r'${win_manifest}'
skillset_dir  = r'${win_skillset}'

try:
    with open(manifest_path, encoding='utf-8') as f:
        manifest = yaml.safe_load(f)
except Exception as e:
    print(f'Error: Manifest parsing failed: {e}', file=sys.stderr)
    sys.exit(1)

skills = manifest.get('skills', [])
ids    = [s['id']   for s in skills]
names  = [s['name'] for s in skills]

dup_ids   = set(x for x in ids   if ids.count(x)   > 1)
dup_names = set(x for x in names if names.count(x) > 1)

if dup_ids:
    print(f'Error: Duplicate skill IDs: {list(dup_ids)}',    file=sys.stderr); sys.exit(1)
if dup_names:
    print(f'Error: Duplicate skill names: {list(dup_names)}', file=sys.stderr); sys.exit(1)

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
    if not has_title:    missing.append('Title (#)')
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
PYEOF
)

    if [ "$result" != "OK" ]; then
        log_error "Validation failed: $result"
        return 1
    fi

    log_success "Validation complete. All skills, names, folders, and links are healthy."
    return 0
}

# ─────────────────────────────────────────────
# Get topological install order
# ─────────────────────────────────────────────
get_install_order() {
    local win_manifest
    win_manifest=$(to_win_path "${PROJECT_ROOT_BASH}/skill-manifest.yaml")

    $PYTHON_CMD - << PYEOF
import yaml, sys

try:
    with open(r'${win_manifest}', encoding='utf-8') as f:
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
PYEOF
}

# ─────────────────────────────────────────────
# Get a skill field from manifest
# ─────────────────────────────────────────────
get_skill_field() {
    local skill_id="$1"
    local field="$2"
    local win_manifest
    win_manifest=$(to_win_path "${PROJECT_ROOT_BASH}/skill-manifest.yaml")

    $PYTHON_CMD - << PYEOF
import yaml
try:
    with open(r'${win_manifest}', encoding='utf-8') as f:
        data = yaml.safe_load(f)
    for s in data.get('skills', []):
        if s['id'] == '${skill_id}':
            val = s.get('${field}', '')
            print(' '.join(val) if isinstance(val, list) else val)
            break
except Exception as e:
    import sys; print(f'Error: {e}', file=sys.stderr); sys.exit(1)
PYEOF
}

# ─────────────────────────────────────────────
# CLI Detection
# ─────────────────────────────────────────────
is_cli_installed() {
    local cli="$1"
    case "$cli" in
        agy)    command -v agy &>/dev/null || [ -d "$HOME/.gemini/config" ] || [ "${MOCK_AGY_INSTALLED}" = "1" ] ;;
        claude) command -v claude &>/dev/null ;;
        codex)  command -v codex  &>/dev/null ;;
        gemini) command -v gemini &>/dev/null ;;
        cursor) command -v cursor &>/dev/null ;;
        *)      return 1 ;;
    esac
}

# ─────────────────────────────────────────────
# AGY Install
# ─────────────────────────────────────────────
agy_install_skill() {
    local source_path="$1"
    local skill_id="$2"
    local mode="$3"

    local target_dir="$HOME/.gemini/config/skills"
    local dest_dir="${target_dir}/${skill_id}"
    local dest_file="${dest_dir}/SKILL.md"

    if [ "$DRY_RUN" = "true" ]; then
        log_info "[DRY-RUN] [AGY] Would install $skill_id -> $dest_file (Mode: $mode)"
        return 0
    fi

    mkdir -p "$dest_dir"

    if [ "$mode" = "symlink" ]; then
        if [ -e "$dest_file" ] || [ -L "$dest_file" ]; then
            if [ "$FORCE" = "true" ]; then
                rm -f "$dest_file"
            else
                local cur; cur=$(readlink -f "$dest_file" 2>/dev/null || echo "")
                local src; src=$(readlink -f "$source_path" 2>/dev/null || echo "")
                if [ "$cur" = "$src" ] && [ -n "$cur" ]; then
                    [ "$VERBOSE" = "true" ] && log_info "[AGY] Already linked: $dest_file"
                    return 0
                fi
                rm -f "$dest_file"
            fi
        fi

        if ln -sf "$source_path" "$dest_file" 2>/dev/null; then
            [ "$VERBOSE" = "true" ] && log_info "[AGY] Symlinked: $dest_file"
        else
            log_warn "[AGY] Symlink failed (enable Windows Developer Mode for symlinks). Using copy..."
            cp "$source_path" "$dest_file" || { log_error "[AGY] Copy failed for: $skill_id"; return 1; }
        fi
    else
        if [ -e "$dest_file" ] && [ "$FORCE" != "true" ]; then
            [ "$VERBOSE" = "true" ] && log_info "[AGY] $dest_file exists, skipping (use --force)."
            return 0
        fi
        rm -f "$dest_file"
        cp "$source_path" "$dest_file" || { log_error "[AGY] Copy failed for: $skill_id"; return 1; }
    fi

    log_installed "[AGY] Installed: $skill_id ($mode)"
    return 0
}

install_skill_to_cli() {
    local cli="$1" source_path="$2" skill_id="$3" mode="$4"
    case "$cli" in
        agy) agy_install_skill "$source_path" "$skill_id" "$mode" ;;
        *)   log_warn "Adapter for '$cli' not implemented in Git Bash edition."; return 1 ;;
    esac
}

# ─────────────────────────────────────────────
# Install all skills into a target CLI
# ─────────────────────────────────────────────
install_to_target_cli() {
    local cli="$1"

    log_bold "========================================"
    log_info  "Initiating install procedure for: $cli"
    log_bold  "----------------------------------------"

    if ! is_cli_installed "$cli"; then
        log_error "✗ Target CLI '$cli' not detected on this system."
        return 1
    fi

    local install_sequence
    install_sequence=$(get_install_order)
    if [ $? -ne 0 ] || [ -z "$install_sequence" ]; then
        log_error "Failed to resolve dependency graph. Aborting."
        return 1
    fi

    [ "$VERBOSE" = "true" ] && log_info "Install sequence: $install_sequence"

    local failures=0
    for skill_id in $install_sequence; do
        local folder install_mode supported
        folder=$(get_skill_field "$skill_id" "directory")
        install_mode=$(get_skill_field "$skill_id" "install_mode")
        supported=$(get_skill_field "$skill_id" "supported_clis")

        if [[ ! " ${supported} " =~ [[:space:]]${cli}[[:space:]] ]]; then
            if [ "$FORCE" != "true" ]; then
                log_warn "Skill '$skill_id' doesn't support '$cli'. Skipping (use --force)."
                continue
            fi
            log_warn "Forcing unsupported skill '$skill_id' onto '$cli'."
        fi

        local source_path="${PROJECT_ROOT_BASH}/skillset/${folder}/${skill_id}.md"
        if ! install_skill_to_cli "$cli" "$source_path" "$skill_id" "$install_mode"; then
            log_error "Failed to install skill '$skill_id' to '$cli'."
            failures=$(( failures + 1 ))
        fi
    done

    if [ "$failures" -eq 0 ]; then
        log_success "Successfully completed installation to: $cli"
        return 0
    else
        log_error "Installation to '$cli' completed with $failures error(s)."
        return 1
    fi
}

# ─────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────
main() {
    check_python

    local target_clis=()
    local install_all=false

    for arg in "${CLI_ARGS[@]}"; do
        case "$arg" in
            --agy)    target_clis+=("agy") ;;
            --claude) target_clis+=("claude") ;;
            --codex)  target_clis+=("codex") ;;
            --gemini) target_clis+=("gemini") ;;
            --cursor) target_clis+=("cursor") ;;
            --all)    install_all=true ;;
            *)
                log_error "Unknown argument: $arg"
                show_help
                ;;
        esac
    done

    if [ ${#target_clis[@]} -eq 0 ] && [ "$install_all" = "false" ]; then
        log_info "No targets specified. Auto-detecting installed CLIs..."
        install_all=true
    fi

    if [ "$install_all" = "true" ]; then
        for cli in agy claude codex gemini cursor; do
            if is_cli_installed "$cli"; then
                target_clis+=("$cli")
            fi
        done
        if [ ${#target_clis[@]} -eq 0 ]; then
            log_error "No supported AI CLIs were detected on this system."
            exit 1
        fi
    fi

    if ! validate_skillset; then
        log_error "Skillset validation failed. Aborting installation."
        exit 1
    fi

    local failures=0
    for cli in "${target_clis[@]}"; do
        if ! install_to_target_cli "$cli"; then
            failures=$(( failures + 1 ))
        fi
    done

    log_bold "----------------------------------------"
    if [ "$failures" -eq 0 ]; then
        log_success "AI Skills installation report: All targets configured successfully!"
        exit 0
    else
        log_error "AI Skills installation report: Completed with $failures failure(s)."
        exit 1
    fi
}

main "$@"
