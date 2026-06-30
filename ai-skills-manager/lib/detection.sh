#!/usr/bin/env bash

# Source utilities if not already sourced
if [ -z "$PROJECT_ROOT" ]; then
    PROJECT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
    # shellcheck source=lib/utils.sh
    source "${PROJECT_ROOT}/lib/utils.sh"
fi

# Load all installer modules dynamically
load_installers() {
    local installer_dir="${PROJECT_ROOT}/installers"
    if [ -d "$installer_dir" ]; then
        for installer in "$installer_dir"/*.sh; do
            if [ -f "$installer" ]; then
                # shellcheck disable=SC1090
                source "$installer"
            fi
        done
    else
        log_error "Installers directory not found at $installer_dir"
        exit 1
    fi
}

# Get list of supported target CLIs from the loaded installers
get_supported_clis() {
    local clis=()
    local installer_dir="${PROJECT_ROOT}/installers"
    for installer in "$installer_dir"/*.sh; do
        if [ -f "$installer" ]; then
            local name
            name=$(basename "$installer" .sh)
            clis+=("$name")
        fi
    done
    echo "${clis[@]}"
}

# Check if a specific CLI is installed on the host system
check_cli_installed() {
    local cli="$1"
    local detect_func="${cli}_detect"
    
    if declare -f "$detect_func" >/dev/null; then
        if "$detect_func"; then
            return 0
        else
            return 1
        fi
    else
        log_warn "Detection function $detect_func not found for $cli"
        return 1
    fi
}

# Print system CLI installation status report
print_cli_status_report() {
    log_info "Detecting installed AI CLIs..."
    local supported
    supported=$(get_supported_clis)
    
    for cli in $supported; do
        local version_func="${cli}_get_version"
        if check_cli_installed "$cli"; then
            local version="unknown version"
            if declare -f "$version_func" >/dev/null; then
                version=$("$version_func")
            fi
            log_success "Detected $cli ($version)"
        else
            log_warn "✗ $cli is not installed on this system"
        fi
    done
}

# Load the installer modules immediately upon sourcing detection.sh
load_installers
