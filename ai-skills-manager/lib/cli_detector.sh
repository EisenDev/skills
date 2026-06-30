#!/usr/bin/env bash

# cli_detector.sh - Dynamically loads CLI adapters and dispatches operations

if [ -z "$PROJECT_ROOT" ]; then
    PROJECT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
    # shellcheck source=lib/common.sh
    source "${PROJECT_ROOT}/lib/common.sh"
fi
# shellcheck source=lib/filesystem.sh
source "${PROJECT_ROOT}/lib/filesystem.sh"


# Load all adapters from installers/
load_installers() {
    local installer_dir="${PROJECT_ROOT}/installers"
    assert_dir_exists "$installer_dir" "Installers directory not found"
    
    for file in "${installer_dir}"/*.sh; do
        if [ -f "$file" ]; then
            # shellcheck disable=SC1090
            source "$file"
        fi
    done
}

# Fetch list of installer adapter names
get_adapters() {
    local list=()
    local installer_dir="${PROJECT_ROOT}/installers"
    for file in "${installer_dir}"/*.sh; do
        if [ -f "$file" ]; then
            local name
            name=$(basename "$file" .sh)
            list+=("$name")
        fi
    done
    echo "${list[@]}"
}

# Polymorphic dispatcher to execute commands on CLI adapters
dispatch_cli() {
    local cli="$1"
    local command="$2"
    shift 2
    
    local func="${cli}_${command}"
    if declare -f "$func" >/dev/null; then
        "$func" "$@"
    else
        log_error "Adapter function $func is not implemented for $cli."
        return 1
    fi
}

# Check if a CLI exists and is detected
is_cli_installed() {
    local cli="$1"
    if dispatch_cli "$cli" detect_cli; then
        return 0
    else
        return 1
    fi
}

# Load adapters instantly upon sourcing cli_detector.sh
load_installers
