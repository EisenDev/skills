#!/usr/bin/env bash

# common.sh - Shared logic, project variables, and CLI argument parsers

# Resolve project root directory
get_project_root() {
    local target
    target=$(dirname "${BASH_SOURCE[0]}")/..
    cd "$target" && pwd
}

PROJECT_ROOT=$(get_project_root)
MANIFEST_PATH="${PROJECT_ROOT}/skill-manifest.yaml"
CACHE_DIR="${PROJECT_ROOT}/cache"
TEMPLATES_DIR="${PROJECT_ROOT}/templates"

# Create cache and templates directories if missing
mkdir -p "$CACHE_DIR" "$TEMPLATES_DIR"

# Source logger library
if [ -f "${PROJECT_ROOT}/lib/logger.sh" ]; then
    # shellcheck source=lib/logger.sh
    source "${PROJECT_ROOT}/lib/logger.sh"
else
    echo "[ERROR] Logger library not found at ${PROJECT_ROOT}/lib/logger.sh" >&2
    exit 1
fi

# Global flags
VERBOSE=false
DRY_RUN=false
FORCE=false
HELP=false

# Parse common flags from argument list
CLI_ARGS=()
for arg in "$@"; do
    case "$arg" in
        --verbose)
            VERBOSE=true
            ;;
        --dry-run)
            DRY_RUN=true
            ;;
        --force)
            FORCE=true
            ;;
        --version)
            echo "AI Skills Manager v2.0.0"
            exit 0
            ;;
        --help|-h)
            HELP=true
            ;;
        *)
            CLI_ARGS+=("$arg")
            ;;
    esac
done

if [ "$VERBOSE" = "true" ]; then
    log_info "Verbose mode enabled."
fi

if [ "$DRY_RUN" = "true" ]; then
    log_info "Dry-run mode enabled. No file changes will be written."
fi
