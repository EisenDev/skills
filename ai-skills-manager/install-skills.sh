#!/usr/bin/env bash

# install-skills.sh - Main install script for the AI Skills Manager

PROJECT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib/common.sh
source "${PROJECT_ROOT}/lib/common.sh"
# shellcheck source=lib/cli_detector.sh
source "${PROJECT_ROOT}/lib/cli_detector.sh"
# shellcheck source=lib/validator.sh
source "${PROJECT_ROOT}/lib/validator.sh"
# shellcheck source=lib/installer.sh
source "${PROJECT_ROOT}/lib/installer.sh"

show_help() {
    echo "AI Skills Installer CLI"
    echo "Usage: $0 [targets] [options]"
    echo ""
    echo "Targets:"
    echo "  --agy       Install to Antigravity CLI (AGY)"
    echo "  --claude    Install to Claude Code"
    echo "  --codex     Install to Codex CLI"
    echo "  --gemini    Install to Gemini CLI"
    echo "  --cursor    Install to Cursor CLI"
    echo "  --all       Install to all detected CLIs"
    echo ""
    echo "Common Options:"
    echo "  --verbose   Show detailed execution logs"
    echo "  --dry-run   Simulate execution without modifying files"
    echo "  --force     Force overwrite files and bypass checks"
    echo "  --version   Print version information"
    echo "  -h, --help  Show this help menu"
    exit 0
}

# Check if help was requested via common flag
if [ "$HELP" = "true" ]; then
    show_help
fi

main() {
    local target_clis=()
    local install_all=false

    # Parse target CLIs from remaining CLI_ARGS
    for arg in "${CLI_ARGS[@]}"; do
        case "$arg" in
            --agy) target_clis+=("agy") ;;
            --claude) target_clis+=("claude") ;;
            --codex) target_clis+=("codex") ;;
            --gemini) target_clis+=("gemini") ;;
            --cursor) target_clis+=("cursor") ;;
            --all) install_all=true ;;
            *)
                log_error "Unknown argument: $arg"
                show_help
                ;;
        esac
    done

    # If no targets specified, auto-detect
    if [ ${#target_clis[@]} -eq 0 ] && [ "$install_all" = "false" ]; then
        log_info "No targets specified. Auto-detecting installed CLIs..."
        install_all=true
    fi

    if [ "$install_all" = "true" ]; then
        local adapters
        adapters=$(get_adapters)
        for cli in $adapters; do
            if is_cli_installed "$cli"; then
                target_clis+=("$cli")
            fi
        done
        if [ ${#target_clis[@]} -eq 0 ]; then
            log_error "No supported AI CLIs were detected on this system."
            exit 1
        fi
    fi

    # Step 1: Validate skillset before installing
    if ! validate_skillset; then
        log_error "Skillset validation failed. Aborting installation."
        exit 1
    fi

    # Step 2: Install to each target CLI
    local failures=0
    for cli in "${target_clis[@]}"; do
        if ! install_to_target_cli "$cli"; then
            failures=$((failures + 1))
        fi
    done

    # Report results
    log_bold "----------------------------------------"
    if [ "$failures" -eq 0 ]; then
        log_success "AI Skills installation report: All targets configured successfully!"
        exit 0
    else
        log_error "AI Skills installation report: Completed with $failures failures."
        exit 1
    fi
}

main "$@"
