#!/usr/bin/env bash
# uninstall_ai_mcp_gitbash.sh - Git Bash (MINGW64/MSYS2) compatible MCP uninstaller
# Removes the ClickUp MCP Server configuration for supported AI CLIs on Windows.
# Leaves every other MCP server completely untouched.

set -Eeuo pipefail

# ─────────────────────────────────────────────────────────────
# Path conversion: MINGW POSIX → Windows (for Python)
# ─────────────────────────────────────────────────────────────
to_win_path() {
    local p="$1"
    if command -v cygpath &>/dev/null; then
        cygpath -w "$p"
    else
        echo "$p" | sed 's|^/\([a-zA-Z]\)/|\1:/|'
    fi
}

# ─────────────────────────────────────────────────────────────
# Colors
# ─────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ─────────────────────────────────────────────────────────────
# Constants & Flags
# ─────────────────────────────────────────────────────────────
SERVER_NAME="clickup"
DRY_RUN=0
VERBOSE=0

# ─────────────────────────────────────────────────────────────
# Config Paths (POSIX for bash ops)
# ─────────────────────────────────────────────────────────────
AGY_CONFIG_FILE="$HOME/.gemini/config/mcp_config.json"
CLAUDE_CONFIG_FILE="$HOME/.claude/claude.json"
CLAUDE_ALT_CONFIG_FILE="$HOME/.config/claude/mcp.json"
CODEX_CONFIG_FILE="$HOME/.config/codex/mcp.json"

# ─────────────────────────────────────────────────────────────
# Logging
# ─────────────────────────────────────────────────────────────
log_info()    { echo -e "${BLUE}ℹ${NC} $1"; }
log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_warn()    { echo -e "${YELLOW}⚠${NC} $1"; }
log_err()     { echo -e "${RED}✗${NC} $1" >&2; }
log_debug()   { if [[ $VERBOSE -eq 1 ]]; then echo -e "DEBUG: $1"; fi; }

usage() {
    cat <<EOF

AI CLI MCP Uninstaller — Git Bash Edition
Usage: $(basename "$0") [OPTIONS]

Removes the ClickUp MCP server configuration from all detected AI CLI agents.

Options:
  --help       Show this help message and exit
  --dry-run    Preview what would be removed (no changes made)
  --verbose    Enable verbose debug output

EOF
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help)    usage; exit 0 ;;
            --dry-run) DRY_RUN=1 ;;
            --verbose) VERBOSE=1 ;;
            *) log_err "Unknown option: $1"; usage; exit 1 ;;
        esac
        shift
    done
}

# ─────────────────────────────────────────────────────────────
# Python detection
# ─────────────────────────────────────────────────────────────
detect_python() {
    if command -v python3 &>/dev/null; then echo "python3"
    elif command -v python &>/dev/null; then echo "python"
    else
        log_err "Python 3 is required but not found."
        exit 1
    fi
}
PYTHON_CMD=$(detect_python)

# ─────────────────────────────────────────────────────────────
# Backup
# ─────────────────────────────────────────────────────────────
backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        local backup="${file}.uninstall-backup-$(date +%Y%m%d-%H%M%S).json"
        if [[ $DRY_RUN -eq 1 ]]; then
            log_info "[DRY-RUN] Would backup $file to $backup"
        else
            cp "$file" "$backup"
            log_debug "Backed up $file to $backup"
        fi
    fi
}

# ─────────────────────────────────────────────────────────────
# Validate JSON
# ─────────────────────────────────────────────────────────────
validate_json() {
    local file="$1"
    local win_file; win_file=$(to_win_path "$file")
    $PYTHON_CMD -m json.tool "$win_file" > /dev/null 2>&1
}

# ─────────────────────────────────────────────────────────────
# Remove ClickUp MCP entry from a config file
# ─────────────────────────────────────────────────────────────
remove_mcp() {
    local file="$1"
    local label="$2"
    local win_file; win_file=$(to_win_path "$file")

    if [[ ! -f "$file" ]]; then
        log_debug "Config not found, skipping: $file"
        return 0
    fi

    # Check if entry exists
    local exists
    exists=$($PYTHON_CMD -c "
import json, sys
try:
    d = json.load(open(r'${win_file}'))
    print(json.dumps(d.get('mcpServers', {}).get('${SERVER_NAME}', '')))
except: print('')
" 2>/dev/null)

    if [[ -z "$exists" || "$exists" == '""' || "$exists" == '{}' ]]; then
        log_info "ClickUp MCP not found in $label. Skipping."
        return 0
    fi

    log_info "Removing ClickUp MCP from $label..."
    backup_file "$file"

    if [[ $DRY_RUN -eq 1 ]]; then
        log_info "[DRY-RUN] Would remove '$SERVER_NAME' from $file"
        return 0
    fi

    $PYTHON_CMD - << PYEOF
import json, sys

win_file    = r'${win_file}'
server_name = '${SERVER_NAME}'

try:
    with open(win_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
except Exception as e:
    print(f'Error reading {win_file}: {e}', file=sys.stderr)
    sys.exit(1)

if 'mcpServers' in data and server_name in data['mcpServers']:
    del data['mcpServers'][server_name]

with open(win_file, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2)

print('OK')
PYEOF

    if ! validate_json "$file"; then
        log_err "JSON validation failed after removing entry from $file."
        return 1
    fi

    log_success "Successfully removed ClickUp MCP from $label"
}

# ─────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────
main() {
    parse_args "$@"
    log_info "Detecting AI CLIs for uninstallation..."

    remove_mcp "$AGY_CONFIG_FILE"        "Antigravity CLI"

    if [[ -f "$CLAUDE_ALT_CONFIG_FILE" ]]; then
        remove_mcp "$CLAUDE_ALT_CONFIG_FILE" "Claude Code"
    elif [[ -f "$CLAUDE_CONFIG_FILE" ]]; then
        remove_mcp "$CLAUDE_CONFIG_FILE"     "Claude Code"
    fi

    remove_mcp "$CODEX_CONFIG_FILE"      "Codex CLI"

    log_success "Uninstallation completed."
}

main "$@"
