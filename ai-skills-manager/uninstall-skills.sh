#!/usr/bin/env bash

# uninstall-skills.sh - Main uninstaller script for the AI Skills Manager

PROJECT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib/common.sh
source "${PROJECT_ROOT}/lib/common.sh"
# shellcheck source=lib/cli_detector.sh
source "${PROJECT_ROOT}/lib/cli_detector.sh"
# shellcheck source=lib/installer.sh
source "${PROJECT_ROOT}/lib/installer.sh"

show_help() {
    echo "AI Skills Uninstaller CLI"
    echo "Usage: $0 [targets] [options]"
    echo ""
    echo "Targets:"
    echo "  --agy       Remove from Antigravity CLI (AGY)"
    echo "  --claude    Remove from Claude Code"
    echo "  --codex     Remove from Codex CLI"
    echo "  --gemini    Remove from Gemini CLI"
    echo "  --cursor    Remove from Cursor CLI"
    echo "  --all       Remove from all detected CLIs"
    echo ""
    echo "Common Options:"
    echo "  --verbose   Show detailed execution logs"
    echo "  --dry-run   Simulate execution without modifying files"
    echo "  --version   Print version information"
    echo "  -h, --help  Show this help menu"
    exit 0
}

if [ "$HELP" = "true" ]; then
    show_help
fi

main() {
    local target_clis=()
    local uninstall_all=false

    for arg in "${CLI_ARGS[@]}"; do
        case "$arg" in
            --agy) target_clis+=("agy") ;;
            --claude) target_clis+=("claude") ;;
            --codex) target_clis+=("codex") ;;
            --gemini) target_clis+=("gemini") ;;
            --cursor) target_clis+=("cursor") ;;
            --all) uninstall_all=true ;;
            *)
                log_error "Unknown argument: $arg"
                show_help
                ;;
        esac
    done

    if [ ${#target_clis[@]} -eq 0 ] && [ "$uninstall_all" = "false" ]; then
        log_error "No target CLIs specified for uninstallation."
        show_help
    fi

    if [ "$uninstall_all" = "true" ]; then
        local adapters
        adapters=$(get_adapters)
        for cli in $adapters; do
            if is_cli_installed "$cli"; then
                target_clis+=("$cli")
            fi
        done
    fi

    local failures=0
    for cli in "${target_clis[@]}"; do
        if ! uninstall_from_target_cli "$cli"; then
            failures=$((failures + 1))
        fi
    done

    log_bold "----------------------------------------"
    if [ "$failures" -eq 0 ]; then
        log_success "AI Skills uninstallation report: Complete!"
        exit 0
    else
        log_error "AI Skills uninstallation report: Completed with $failures failures."
        exit 1
    fi
}

main "$@"
