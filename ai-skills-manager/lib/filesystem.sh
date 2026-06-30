#!/usr/bin/env bash

# filesystem.sh - Filesystem wrappers and access validator utilities

# Source common setup if not yet imported
if [ -z "$PROJECT_ROOT" ]; then
    PROJECT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
    # shellcheck source=lib/common.sh
    source "${PROJECT_ROOT}/lib/common.sh"
fi

# Assert file exists
assert_file_exists() {
    local file="$1"
    local error_msg="$2"
    if [ ! -f "$file" ]; then
        log_error "${error_msg:-File not found: $file}"
        exit 1
    fi
}

# Assert directory exists
assert_dir_exists() {
    local dir="$1"
    local error_msg="$2"
    if [ ! -d "$dir" ]; then
        log_error "${error_msg:-Directory not found: $dir}"
        exit 1
    fi
}

# Verify read permissions
check_read_access() {
    local path="$1"
    if [ -r "$path" ]; then
        return 0
    else
        return 1
    fi
}

# Verify write permissions
check_write_access() {
    local path="$1"
    if [ -w "$path" ] || [ ! -e "$path" ]; then
        return 0
    else
        return 1
    fi
}

# Create directory safely, respecting dry-run settings
safe_mkdir() {
    local dir="$1"
    if [ "$DRY_RUN" = "true" ]; then
        log_info "[DRY-RUN] Would create directory: $dir"
        return 0
    fi
    
    if [ ! -d "$dir" ]; then
        if mkdir -p "$dir"; then
            if [ "$VERBOSE" = "true" ]; then
                log_info "Created directory: $dir"
            fi
            return 0
        else
            log_error "Failed to create directory: $dir"
            return 1
        fi
    fi
    return 0
}

# Delete file or directory safely, respecting dry-run settings
safe_rm() {
    local path="$1"
    if [ "$DRY_RUN" = "true" ]; then
        log_info "[DRY-RUN] Would remove: $path"
        return 0
    fi
    
    if [ -e "$path" ] || [ -L "$path" ]; then
        if rm -rf "$path"; then
            if [ "$VERBOSE" = "true" ]; then
                log_info "Removed: $path"
            fi
            return 0
        else
            log_error "Failed to remove: $path"
            return 1
        fi
    fi
    return 0
}
