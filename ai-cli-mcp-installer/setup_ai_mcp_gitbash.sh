#!/usr/bin/env bash
# setup_ai_mcp_gitbash.sh - Git Bash (MINGW64/MSYS2) compatible MCP installer
# Installs ClickUp MCP Server for supported AI CLIs on Windows via Git Bash.
#
# WHY THIS EXISTS:
#   setup_ai_mcp.sh uses $HOME paths which Git Bash expands as POSIX (/c/Users/...)
#   but Python on Windows needs Windows paths (C:\Users\...). This script resolves
#   all paths to Windows format before passing them to Python.
#
# Supported: Antigravity CLI (AGY), Claude Code, OpenAI Codex CLI

set -Eeuo pipefail

# ─────────────────────────────────────────────────────────────
# Path conversion: MINGW POSIX → Windows (for Python)
# ─────────────────────────────────────────────────────────────
to_win_path() {
    local p="$1"
    if command -v cygpath &>/dev/null; then
        cygpath -w "$p"
    else
        # Fallback: /c/foo/bar -> C:/foo/bar
        echo "$p" | sed 's|^/\([a-zA-Z]\)/|\1:/|'
    fi
}

# ─────────────────────────────────────────────────────────────
# Colors (ANSI — Git Bash supports them)
# ─────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ─────────────────────────────────────────────────────────────
# Constants
# ─────────────────────────────────────────────────────────────
SERVER_NAME="clickup"
SERVER_URL="https://mcp.clickup.com/mcp"

# ─────────────────────────────────────────────────────────────
# Flags
# ─────────────────────────────────────────────────────────────
DRY_RUN=0
FORCE=0
VERBOSE=0
DIAGNOSE=0

# ─────────────────────────────────────────────────────────────
# Config Paths  (POSIX — for bash file tests; converted on Python calls)
# ─────────────────────────────────────────────────────────────
AGY_CONFIG_FILE="$HOME/.gemini/config/mcp_config.json"

CLAUDE_CONFIG_DIR="$HOME/.claude"
CLAUDE_CONFIG_FILE="$CLAUDE_CONFIG_DIR/claude.json"
CLAUDE_ALT_CONFIG_DIR="$HOME/.config/claude"
CLAUDE_ALT_CONFIG_FILE="$CLAUDE_ALT_CONFIG_DIR/mcp.json"

CODEX_CONFIG_DIR="$HOME/.config/codex"
CODEX_CONFIG_FILE="$CODEX_CONFIG_DIR/mcp.json"

# ─────────────────────────────────────────────────────────────
# Logging
# ─────────────────────────────────────────────────────────────
log_info()    { echo -e "${BLUE}ℹ${NC} $1"; }
log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_warn()    { echo -e "${YELLOW}⚠${NC} $1"; }
log_err()     { echo -e "${RED}✗${NC} $1" >&2; }
log_debug()   { if [[ $VERBOSE -eq 1 ]]; then echo -e "DEBUG: $1"; fi; }

# ─────────────────────────────────────────────────────────────
# Usage
# ─────────────────────────────────────────────────────────────
usage() {
    cat <<EOF

AI CLI MCP Installer — Git Bash Edition
Usage: $(basename "$0") [OPTIONS]

Automatically detect installed AI CLI agents and configure the official ClickUp MCP server.

Options:
  --help       Show this help message and exit
  --dry-run    Run without making any changes
  --force      Force installation even if already configured
  --diagnose   Print diagnostic information and exit
  --verbose    Enable verbose output

EOF
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help)     usage; exit 0 ;;
            --dry-run)  DRY_RUN=1 ;;
            --force)    FORCE=1 ;;
            --diagnose) DIAGNOSE=1 ;;
            --verbose)  VERBOSE=1 ;;
            *) log_err "Unknown option: $1"; usage; exit 1 ;;
        esac
        shift
    done
}

# ─────────────────────────────────────────────────────────────
# Python detection (prefer python3, fallback to python)
# ─────────────────────────────────────────────────────────────
detect_python() {
    if command -v python3 &>/dev/null; then
        echo "python3"
    elif command -v python &>/dev/null; then
        echo "python"
    else
        log_err "Python 3 is required but not found. Install Python from https://python.org"
        exit 1
    fi
}

PYTHON_CMD=$(detect_python)

# ─────────────────────────────────────────────────────────────
# Diagnose
# ─────────────────────────────────────────────────────────────
diagnose() {
    echo "Diagnostic Mode (Git Bash Edition)"
    echo "-----------------------------------"

    if command -v agy &>/dev/null 2>&1; then
        echo "✓ agy: $(agy --version 2>/dev/null || echo 'found')"
    else
        echo "✗ agy: Not found"
    fi

    echo "✓ AGY config path : $AGY_CONFIG_FILE"
    echo "✓ AGY config (win): $(to_win_path "$AGY_CONFIG_FILE")"

    if [[ -f "$AGY_CONFIG_FILE" ]]; then
        if $PYTHON_CMD -m json.tool "$(to_win_path "$AGY_CONFIG_FILE")" > /dev/null 2>&1; then
            echo "✓ AGY config JSON : Valid"
        else
            echo "✗ AGY config JSON : Invalid"
        fi
        echo "✓ Registered servers: $($PYTHON_CMD -c "
import json, sys
try:
    d = json.load(open(r'$(to_win_path "$AGY_CONFIG_FILE")'))
    print(', '.join(d.get('mcpServers', {}).keys()) or 'None')
except: print('Unknown')
")"
    else
        echo "⚠ AGY config : File does not exist yet"
    fi

    echo ""
    echo "✓ Python : $PYTHON_CMD ($($PYTHON_CMD --version 2>&1))"
    echo "✓ HOME (POSIX) : $HOME"
    echo "✓ HOME (Windows): $(to_win_path "$HOME")"
    exit 0
}

# ─────────────────────────────────────────────────────────────
# Backup a config file (using POSIX path for cp)
# ─────────────────────────────────────────────────────────────
backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        local backup="${file}.backup-$(date +%Y%m%d-%H%M%S).json"
        if [[ $DRY_RUN -eq 1 ]]; then
            log_info "[DRY-RUN] Would backup $file to $backup"
        else
            cp "$file" "$backup"
            log_debug "Backed up $file to $backup"
        fi
    fi
}

# ─────────────────────────────────────────────────────────────
# Validate JSON (uses Windows path for Python)
# ─────────────────────────────────────────────────────────────
validate_json() {
    local file="$1"
    local win_file; win_file=$(to_win_path "$file")
    $PYTHON_CMD -m json.tool "$win_file" > /dev/null 2>&1
}

# ─────────────────────────────────────────────────────────────
# Merge ClickUp MCP entry into a config JSON file
# Uses Windows-native paths for Python, POSIX paths for bash ops
# ─────────────────────────────────────────────────────────────
merge_json() {
    local file="$1"       # POSIX path
    local schema_mode="$2"
    local dir; dir="$(dirname "$file")"
    local win_file; win_file=$(to_win_path "$file")

    if [[ $DRY_RUN -eq 1 ]]; then
        log_info "[DRY-RUN] Would create or merge ClickUp MCP in $file"
        return 0
    fi

    # Ensure directory exists
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        log_debug "Created directory: $dir"
    fi

    # Create empty JSON file if missing
    if [[ ! -f "$file" ]]; then
        echo '{}' > "$file"
        log_debug "Created new config file: $file"
    fi

    # Validate existing JSON; reset if broken
    if ! validate_json "$file"; then
        log_warn "Invalid JSON in $file. Backing up and resetting."
        backup_file "$file"
        echo '{}' > "$file"
    fi

    # Check if ClickUp entry already exists
    local exists
    exists=$($PYTHON_CMD -c "
import json, sys
try:
    d = json.load(open(r'${win_file}'))
    print(json.dumps(d.get('mcpServers', {}).get('${SERVER_NAME}', '')))
except: print('')
" 2>/dev/null)

    if [[ -n "$exists" && "$exists" != '""' && "$exists" != '{}' && $FORCE -eq 0 ]]; then
        log_warn "ClickUp MCP already configured in $file. Skipping (use --force to overwrite)."
        return 0
    fi

    # Merge using Python with Windows path
    $PYTHON_CMD - << PYEOF
import json, sys

win_file = r'${win_file}'
server_name = '${SERVER_NAME}'
server_url  = '${SERVER_URL}'

try:
    with open(win_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
except Exception:
    data = {}

if 'mcpServers' not in data:
    data['mcpServers'] = {}

data['mcpServers'][server_name] = {
    'command': 'npx',
    'args': ['-y', 'mcp-remote', server_url]
}

with open(win_file, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2)

print('OK')
PYEOF

    if ! validate_json "$file"; then
        log_err "Generated JSON in $file is invalid."
        return 1
    fi

    log_success "Configuration validated for $file"
}

# ─────────────────────────────────────────────────────────────
# Detect and install for each supported CLI
# ─────────────────────────────────────────────────────────────
detect_and_install() {
    log_info "Detecting AI CLIs..."
    local found_any=0

    # ── Antigravity CLI ──
    if command -v agy &>/dev/null || [[ -f "$AGY_CONFIG_FILE" ]] || [[ -d "$HOME/.gemini/config" ]]; then
        log_success "Antigravity CLI found"
        found_any=1
        log_info "Installing ClickUp MCP for Antigravity CLI..."
        mkdir -p "$(dirname "$AGY_CONFIG_FILE")"
        backup_file "$AGY_CONFIG_FILE"
        merge_json "$AGY_CONFIG_FILE" "antigravity"
    else
        log_err "Antigravity CLI not installed"
    fi

    # ── Claude Code ──
    if [[ -d "$CLAUDE_CONFIG_DIR" ]] || [[ -d "$CLAUDE_ALT_CONFIG_DIR" ]]; then
        log_success "Claude Code found"
        found_any=1
        log_info "Installing ClickUp MCP for Claude Code..."
        local target_file="$CLAUDE_ALT_CONFIG_FILE"
        if [[ -d "$CLAUDE_CONFIG_DIR" && ! -d "$CLAUDE_ALT_CONFIG_DIR" ]]; then
            target_file="$CLAUDE_CONFIG_FILE"
        fi
        backup_file "$target_file"
        merge_json "$target_file" "generic"
    else
        log_err "Claude Code not installed"
    fi

    # ── OpenAI Codex CLI ──
    if command -v codex &>/dev/null || [[ -d "$CODEX_CONFIG_DIR" ]]; then
        log_success "Codex CLI found"
        found_any=1
        log_info "Installing ClickUp MCP for Codex CLI..."
        mkdir -p "$CODEX_CONFIG_DIR"
        backup_file "$CODEX_CONFIG_FILE"
        merge_json "$CODEX_CONFIG_FILE" "generic"
    else
        log_err "Codex CLI not installed"
    fi

    if [[ $found_any -eq 0 ]]; then
        log_warn "No supported AI CLIs found. Nothing to install."
    else
        log_success "Installation completed. Restart any running CLI to pick up changes."
    fi
}

# ─────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────
main() {
    parse_args "$@"
    [[ $DIAGNOSE -eq 1 ]] && diagnose
    detect_and_install
}

main "$@"
