#!/usr/bin/env bash
# ai-cli-mcp-installer
# Installs ClickUp MCP Server for supported AI CLIs
#
# Supported: Antigravity CLI, Claude Code, OpenAI Codex CLI
set -Eeuo pipefail

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- Constants ---
SERVER_NAME="clickup"
SERVER_URL="https://mcp.clickup.com/mcp"

# Flags
DRY_RUN=0
FORCE=0
VERBOSE=0
DIAGNOSE=0

# Config Paths
# Based on reverse engineering, Antigravity uses settings.json, not mcp.json
AGY_CONFIG_FILE="$HOME/.gemini/config/mcp_config.json"

CLAUDE_CONFIG_DIR="$HOME/.claude"
CLAUDE_CONFIG_FILE="$CLAUDE_CONFIG_DIR/claude.json"
CLAUDE_ALT_CONFIG_DIR="$HOME/.config/claude"
CLAUDE_ALT_CONFIG_FILE="$CLAUDE_ALT_CONFIG_DIR/mcp.json"

CODEX_CONFIG_DIR="$HOME/.config/codex"
CODEX_CONFIG_FILE="$CODEX_CONFIG_DIR/mcp.json"

# --- Logging Functions ---
log_info() { echo -e "${BLUE}ℹ${NC} $1"; }
log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_warn() { echo -e "${YELLOW}⚠${NC} $1"; }
log_err() { echo -e "${RED}✗${NC} $1" >&2; }
log_debug() { if [[ $VERBOSE -eq 1 ]]; then echo -e "${NC}DEBUG: $1${NC}"; fi; }

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Automatically detect installed AI CLI agents and configure the official ClickUp MCP server for them.

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
            --help) usage; exit 0 ;;
            --dry-run) DRY_RUN=1 ;;
            --force) FORCE=1 ;;
            --diagnose) DIAGNOSE=1 ;;
            --verbose) VERBOSE=1 ;;
            *) log_err "Unknown option: $1"; usage; exit 1 ;;
        esac
        shift
    done
}

diagnose() {
    echo "Diagnostic Mode"
    echo "---------------"
    
    # CLI version
    if command -v agy >/dev/null 2>&1; then
        echo "✓ CLI version: $(agy --version 2>/dev/null || echo 'Unknown')"
    else
        echo "✗ CLI version: Not found"
    fi
    
    # CLI installation path
    echo "✓ CLI installation path: $(command -v agy || echo 'Not found')"
    
    # Config path
    echo "✓ Config path: $AGY_CONFIG_FILE"
    
    # Config loaded
    if [[ -f "$AGY_CONFIG_FILE" ]] && command -v jq >/dev/null 2>&1; then
        if jq . "$AGY_CONFIG_FILE" >/dev/null 2>&1; then
            echo "✓ Config loaded: Valid JSON"
        else
            echo "✗ Config loaded: Invalid JSON"
        fi
    else
        echo "⚠ Config loaded: File missing or jq not installed"
    fi
    
    # MCP storage location
    echo "✓ MCP storage location: $AGY_CONFIG_FILE"
    
    # Registered servers
    if [[ -f "$AGY_CONFIG_FILE" ]] && command -v jq >/dev/null 2>&1; then
        local servers
        servers=$(jq -r '.mcpServers | keys | join(", ") // "None"' "$AGY_CONFIG_FILE" 2>/dev/null || echo "None")
        echo "✓ Registered servers: $servers"
    else
        echo "⚠ Registered servers: Unknown (requires jq)"
    fi
    
    # Validation result
    if command -v jq >/dev/null 2>&1 && jq . "$AGY_CONFIG_FILE" >/dev/null 2>&1; then
        echo "✓ Validation result: OK"
    else
        echo "✗ Validation result: Failed"
    fi
    
    exit 0
}

check_os() {
    if [[ "$(uname -s)" != "Linux" ]]; then
        log_warn "This script is designed for Linux. It may not work properly on your OS."
    fi
}

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

validate_json() {
    local file="$1"
    if command -v jq >/dev/null 2>&1; then
        jq . "$file" >/dev/null 2>&1
        return $?
    elif command -v python3 >/dev/null 2>&1; then
        python3 -m json.tool "$file" >/dev/null 2>&1
        return $?
    else
        # No reliable way to validate JSON if neither jq nor python3 are present
        return 0
    fi
}

fallback_merge_json() {
    local file="$1"
    local schema_mode="$2"
    log_debug "Using fallback JSON merge for $file (Mode: $schema_mode)"
    
    if command -v python3 >/dev/null 2>&1; then
        if [[ "$schema_mode" == "antigravity" ]]; then
            # Antigravity uses 'url' field directly based on Go reverse engineering
            python3 -c "
import json, sys
try:
    with open(sys.argv[1], 'r') as f:
        data = json.load(f)
except Exception:
    data = {}
if 'mcpServers' not in data:
    data['mcpServers'] = {}
data['mcpServers']['$SERVER_NAME'] = {'command': 'npx', 'args': ['-y', 'mcp-remote', sys.argv[2]]}
with open(sys.argv[1], 'w') as f:
    json.dump(data, f, indent=2)
" "$file" "$SERVER_URL"
        else
            # Claude/Codex typically use 'type: sse' alongside 'url' or stdio config
            python3 -c "
import json, sys
try:
    with open(sys.argv[1], 'r') as f:
        data = json.load(f)
except Exception:
    data = {'mcpServers': {}}
if 'mcpServers' not in data:
    data['mcpServers'] = {}
data['mcpServers']['$SERVER_NAME'] = {'command': 'npx', 'args': ['-y', 'mcp-remote', sys.argv[2]]}
with open(sys.argv[1], 'w') as f:
    json.dump(data, f, indent=2)
" "$file" "$SERVER_URL"
        fi
        return $?
    else
        log_err "python3 is missing. Cannot safely modify JSON."
        return 1
    fi
}

merge_json() {
    local file="$1"
    local schema_mode="$2"
    local dir
    dir="$(dirname "$file")"
    
    if [[ $DRY_RUN -eq 1 ]]; then
        log_info "[DRY-RUN] Would create or merge ClickUp MCP in $file"
        return 0
    fi

    # Create dir if not exists
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        log_debug "Created directory $dir"
    fi

    # Create file with empty object if it doesn't exist
    if [[ ! -f "$file" ]]; then
        echo '{}' > "$file"
        log_debug "Created new config file $file"
    fi

    # Validate existing JSON
    if ! validate_json "$file"; then
        log_warn "Invalid JSON in $file. Backing up and resetting."
        backup_file "$file"
        echo '{}' > "$file"
    fi

    # Check if clickup already exists
    local exists=""
    if command -v jq >/dev/null 2>&1; then
        exists=$(jq -r ".mcpServers.$SERVER_NAME // empty" "$file")
    elif command -v python3 >/dev/null 2>&1; then
        exists=$(python3 -c "import json,sys; print(json.load(open(sys.argv[1])).get('mcpServers', {}).get('$SERVER_NAME', ''))" "$file" 2>/dev/null)
    fi
    
    if [[ -n "$exists" && "$exists" != "{}" && $FORCE -eq 0 ]]; then
        log_warn "ClickUp MCP already exists in $file. Skipping. Use --force to overwrite."
        return 0
    fi
    
    if command -v jq >/dev/null 2>&1; then
        local tmp_file
        tmp_file=$(mktemp)
        
        # Merge configuration depending on schema mode
        if [[ "$schema_mode" == "antigravity" ]]; then
            # Uses 'url' inside the 'mcpServers.clickup' object directly
            if jq ".mcpServers.$SERVER_NAME = {\"command\": \"npx\", \"args\": [\"-y\", \"mcp-remote\", \"$SERVER_URL\"]}" "$file" > "$tmp_file"; then
                mv "$tmp_file" "$file"
            else
                rm -f "$tmp_file"
                log_err "Failed to merge JSON for $file"
                return 1
            fi
        else
            # Standard generic MCP schema
            if jq ".mcpServers.$SERVER_NAME = {\"command\": \"npx\", \"args\": [\"-y\", \"mcp-remote\", \"$SERVER_URL\"]}" "$file" > "$tmp_file"; then
                mv "$tmp_file" "$file"
            else
                rm -f "$tmp_file"
                log_err "Failed to merge JSON for $file"
                return 1
            fi
        fi
        log_debug "Successfully merged config using jq into $file"
    else
        if ! fallback_merge_json "$file" "$schema_mode"; then
            log_err "Fallback merge failed for $file."
            return 1
        fi
    fi
    
    if ! validate_json "$file"; then
        log_err "Generated JSON in $file is invalid."
        return 1
    fi
    
    log_success "Configuration validated for $file"
}

detect_and_install() {
    log_info "Detecting AI CLIs..."
    
    local found_any=0

    # Antigravity CLI
    if command -v agy >/dev/null 2>&1 || [[ -f "$AGY_CONFIG_FILE" ]]; then
        log_success "Antigravity CLI found"
        found_any=1
        log_info "Installing ClickUp MCP for Antigravity CLI..."
        backup_file "$AGY_CONFIG_FILE"
        merge_json "$AGY_CONFIG_FILE" "antigravity"
    else
        log_err "Antigravity CLI not installed"
    fi

    # Claude Code
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

    # Codex CLI
    if command -v codex >/dev/null 2>&1 || [[ -d "$CODEX_CONFIG_DIR" ]]; then
        log_success "Codex CLI found"
        found_any=1
        log_info "Installing ClickUp MCP for Codex CLI..."
        backup_file "$CODEX_CONFIG_FILE"
        merge_json "$CODEX_CONFIG_FILE" "generic"
    else
        log_err "Codex CLI not installed"
    fi

    if [[ $found_any -eq 0 ]]; then
        log_warn "No supported AI CLIs were found. Nothing to install."
    else
        log_success "Installation completed. If the CLI is running, it may require a restart to pick up changes."
    fi
}

main() {
    parse_args "$@"
    
    if [[ $DIAGNOSE -eq 1 ]]; then
        diagnose
    fi
    
    check_os
    detect_and_install
}

main "$@"
