#!/usr/bin/env bash

# symlink.sh - Symbolic link creator with fallback copies and verification

# Source common and filesystem helpers
if [ -z "$PROJECT_ROOT" ]; then
    PROJECT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
    # shellcheck source=lib/common.sh
    source "${PROJECT_ROOT}/lib/common.sh"
fi
# shellcheck source=lib/filesystem.sh
source "${PROJECT_ROOT}/lib/filesystem.sh"

# Create a symbolic link from source to target with copy fallback
create_symlink() {
    local source="$1"
    local target="$2"
    
    if [ ! -f "$source" ]; then
        log_error "Source file does not exist: $source"
        return 1
    fi
    
    if [ "$DRY_RUN" = "true" ]; then
        log_info "[DRY-RUN] Would link $source -> $target"
        return 0
    fi
    
    # Ensure target parent directory exists
    local parent_dir
    parent_dir=$(dirname "$target")
    safe_mkdir "$parent_dir"
    
    # Clean existing target
    if [ -e "$target" ] || [ -L "$target" ]; then
        local current_source=""
        if [ -L "$target" ]; then
            current_source=$(readlink -f "$target" 2>/dev/null || echo "")
        fi
        
        local source_resolved
        source_resolved=$(readlink -f "$source" 2>/dev/null || echo "")
        
        if [ "$current_source" = "$source_resolved" ] && [ -n "$current_source" ] && [ "$FORCE" != "true" ]; then
            if [ "$VERBOSE" = "true" ]; then
                log_info "Target already correctly linked: $target -> $source"
            fi
            return 0
        fi
        
        # Remove mismatched target or regular file
        safe_rm "$target"
    fi
    
    # Attempt symlink creation
    if ln -sf "$source" "$target" 2>/dev/null; then
        if [ "$VERBOSE" = "true" ]; then
            log_info "Created symlink: $target -> $source"
        fi
        return 0
    else
        log_warn "Failed to create symlink at $target. Falling back to file copy..."
        if cp "$source" "$target"; then
            if [ "$VERBOSE" = "true" ]; then
                log_info "Copied file: $target <- $source"
            fi
            return 0
        else
            log_error "Failed copy fallback for target: $target"
            return 1
        fi
    fi
}

# Verify if path is a valid non-broken symlink
verify_symlink() {
    local path="$1"
    if [ -L "$path" ]; then
        # Check if the target of the link exists
        if [ -e "$path" ]; then
            return 0 # Healthy symlink
        else
            return 2 # Broken symlink
        fi
    else
        return 1 # Not a symlink
    fi
}
