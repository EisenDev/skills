#!/usr/bin/env bash

# doctor.sh - Health check and diagnostics CLI tool for the AI Skills Manager

PROJECT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib/common.sh
source "${PROJECT_ROOT}/lib/common.sh"
# shellcheck source=lib/cli_detector.sh
source "${PROJECT_ROOT}/lib/cli_detector.sh"
# shellcheck source=lib/manifest.sh
source "${PROJECT_ROOT}/lib/manifest.sh"
# shellcheck source=lib/validator.sh
source "${PROJECT_ROOT}/lib/validator.sh"
# shellcheck source=lib/filesystem.sh
source "${PROJECT_ROOT}/lib/filesystem.sh"
# shellcheck source=lib/symlink.sh
source "${PROJECT_ROOT}/lib/symlink.sh"

show_help() {
    echo "AI Skills Doctor CLI"
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

check_unknown_skills() {
    log_bold "Checking for unregistered skills in skillset/..."
    local skills
    skills=$(get_manifest_skills)
    local found_unknown=false
    
    for category_dir in "${PROJECT_ROOT}/skillset"/*; do
        if [ -d "$category_dir" ]; then
            for file in "${category_dir}"/*.md; do
                if [ -f "$file" ]; then
                    local id
                    id=$(basename "$file" .md)
                    if [[ ! " ${skills} " =~ [[:space:]]${id}[[:space:]] ]]; then
                        log_warn "Unregistered skill markdown file found: $file (Not defined in manifest)"
                        found_unknown=true
                    fi
                fi
            done
        fi
    done
    
    if [ "$found_unknown" = "false" ]; then
        log_success "No unregistered skill files found."
    fi
}

main() {
    log_bold "========================================"
    log_bold "AI Skills Manager - Health Report"
    log_bold "========================================"
    echo ""

    # 1. Check Manifest and skillset file validity
    log_bold "1. Manifest & Skillset Integrity"
    log_bold "----------------------------------------"
    local manifest_ok=true
    if ! validate_manifest_structure 2>/dev/null; then
        log_error "Manifest parsing failed or file is corrupted."
        manifest_ok=false
    fi
    
    if ! validate_skillset; then
        log_error "Validation errors detected in local skillsets."
        manifest_ok=false
    fi
    
    if [ "$manifest_ok" = "true" ]; then
        log_success "Manifest structure, duplicate checks, and metadata headers are healthy."
    fi
    
    # Check for files not listed in the manifest
    check_unknown_skills
    echo ""

    # 2. Check each adapter target CLI
    log_bold "2. Target CLI Integrations"
    log_bold "----------------------------------------"
    local adapters
    adapters=$(get_adapters)
    
    for cli in $adapters; do
        log_bold "[Target: $cli]"
        if is_cli_installed "$cli"; then
            log_success "  - CLI Status: Detected"
            
            # Check version
            local version="unknown"
            local ver_func="${cli}_get_version"
            # Fallback version command check
            if command -v "$cli" &>/dev/null; then
                version=$("$cli" --version 2>/dev/null | head -n 1)
            fi
            log_info "  - CLI Version: ${version:-N/A}"

            # Check target directory
            local target_dir
            target_dir=$(dispatch_cli "$cli" get_skill_directory)
            if [ -n "$target_dir" ]; then
                log_info "  - Target Path: $target_dir"
                if [ -d "$target_dir" ]; then
                    if check_write_access "$target_dir" && check_read_access "$target_dir"; then
                        log_success "  - Permissions: Read/Write Access OK"
                    else
                        log_error "  - Permissions: ✗ Read/Write access denied to $target_dir"
                    fi
                else
                    log_info "  - Target Path: (Not yet created/initialized)"
                fi
            else
                log_info "  - Target Path: N/A (Not supported)"
            fi

            # Call adapter doctor diagnostics
            dispatch_cli "$cli" doctor
        else
            log_warn "  - CLI Status: ✗ Not installed/detected"
        fi
        echo ""
    done
    
    log_bold "----------------------------------------"
    log_success "Doctor diagnostics run complete."
}

main "$@"
