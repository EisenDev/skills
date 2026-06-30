#!/usr/bin/env bash
# ai-cli-mcp-installer - Uninstaller
# Removes the ClickUp MCP Server for supported AI CLIs
# Leaves every other MCP server untouched.
set -Eeuo pipefail

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# --- Constants ---
SERVER_NAME="clickup"

# Flags
DRY_RUN=0
VERBOSE=0

# Config Paths
AGY_CONFIG_FILE="$HOME/.gemini/config/mcp_config.json"
CLAUDE_CONFIG_FILE="$HOME/.claude/claude.json"
CLAUDE_ALT_CONFIG_FILE="$HOME/.config/claude/mcp.json"
CODEX_CONFIG_FILE="$HOME/.config/codex/mcp.json"

log_info() { echo -e "${BLUE}ℹ${NC} $1"; }
log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_warn() { echo -e "${YELLOW}⚠${NC} $1"; }
log_err() { echo -e "${RED}✗${NC} $1" >&2; }
log_debug() { if [[ $VERBOSE -eq 1 ]]; then echo -e "${NC}DEBUG: $1${NC}"; fi; }

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Automatically detect installed AI CLI agents and remove the ClickUp MCP server configuration.

Options:
  --help       Show this help message and exit
  --dry-run    Run without making any changes
  --verbose    Enable verbose output
EOF
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help) usage; exit 0 ;;
            --dry-run) DRY_RUN=1 ;;
            --verbose) VERBOSE=1 ;;
            *) log_err "Unknown option: $1"; usage; exit 1 ;;
        esac
        shift
    done
}

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

validate_json() {
    local file="$1"
    if command -v jq >/dev/null 2>&1; then
        jq . "$file" >/dev/null 2>&1
        return $?
    elif command -v python3 >/dev/null 2>&1; then
        python3 -m json.tool "$file" >/dev/null 2>&1
        return $?
    else
        return 0
    fi
}

fallback_remove_json() {
    local file="$1"
    if command -v python3 >/dev/null 2>&1; then
        python3 -c "
import json, sys
try:
    with open(sys.argv[1], 'r') as f:
        data = json.load(f)
except Exception:
    sys.exit(0)
if 'mcpServers' in data and '$SERVER_NAME' in data['mcpServers']:
    del data['mcpServers']['$SERVER_NAME']
    with open(sys.argv[1], 'w') as f:
        json.dump(data, f, indent=2)
" "$file"
        return $?
    else
        log_err "python3 is missing. Cannot safely remove JSON without jq."
        return 1
    fi
}

remove_mcp() {
    local file="$1"
    local name="$2"

    if [[ ! -f "$file" ]]; then
        log_debug "Config file not found: $file"
        return 0
    fi

    local exists=""
    if command -v jq >/dev/null 2>&1; then
        exists=$(jq -r ".mcpServers.$SERVER_NAME // empty" "$file")
    elif command -v python3 >/dev/null 2>&1; then
        exists=$(python3 -c "import json,sys; print(json.load(open(sys.argv[1])).get('mcpServers', {}).get('$SERVER_NAME', ''))" "$file" 2>/dev/null)
    fi

    if [[ -z "$exists" || "$exists" == "{}" ]]; then
        log_info "ClickUp MCP not found in $name. Skipping."
        return 0
    fi

    log_info "Removing ClickUp MCP from $name..."
    backup_file "$file"

    if [[ $DRY_RUN -eq 1 ]]; then
        log_info "[DRY-RUN] Would remove $SERVER_NAME from $file"
        return 0
    fi

    if command -v jq >/dev/null 2>&1; then
        local tmp_file
        tmp_file=$(mktemp)
        if jq "del(.mcpServers.$SERVER_NAME)" "$file" > "$tmp_file"; then
            mv "$tmp_file" "$file"
            log_debug "Successfully removed config using jq from $file"
        else
            rm -f "$tmp_file"
            log_err "Failed to remove JSON for $file"
            return 1
        fi
    else
        if ! fallback_remove_json "$file"; then
            log_err "Fallback remove failed for $file."
            return 1
        fi
    fi

    if ! validate_json "$file"; then
        log_err "Generated JSON in $file is invalid. Restoring backup."
        return 1
    fi

    log_success "Successfully uninstalled from $name"
}

main() {
    parse_args "$@"
    log_info "Detecting AI CLIs for uninstallation..."

    remove_mcp "$AGY_CONFIG_FILE" "Antigravity CLI"
    
    if [[ -f "$CLAUDE_ALT_CONFIG_FILE" ]]; then
        remove_mcp "$CLAUDE_ALT_CONFIG_FILE" "Claude Code"
    elif [[ -f "$CLAUDE_CONFIG_FILE" ]]; then
        remove_mcp "$CLAUDE_CONFIG_FILE" "Claude Code"
    fi

    remove_mcp "$CODEX_CONFIG_FILE" "Codex CLI"

    log_success "Uninstallation completed."
}

main "$@"
