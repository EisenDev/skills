#!/usr/bin/env bash

# validate-skills.sh - Main validator script for local skillset directories

PROJECT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib/common.sh
source "${PROJECT_ROOT}/lib/common.sh"
# shellcheck source=lib/validator.sh
source "${PROJECT_ROOT}/lib/validator.sh"

show_help() {
    echo "AI Skills Validator CLI"
    echo "Usage: $0 [options]"
    echo ""
    echo "Common Options:"
    echo "  --verbose   Show detailed execution logs"
    echo "  --version   Print version information"
    echo "  -h, --help  Show this help menu"
    exit 0
}

if [ "$HELP" = "true" ]; then
    show_help
fi

main() {
    log_bold "========================================"
    log_bold "AI Skills Framework Validation Tool"
    log_bold "========================================"
    echo ""

    if validate_skillset; then
        log_bold "----------------------------------------"
        log_success "Validation report: All checks passed. Framework is fully healthy!"
        exit 0
    else
        log_bold "----------------------------------------"
        log_error "Validation report: Found errors in framework metadata or files."
        exit 1
    fi
}

main "$@"
