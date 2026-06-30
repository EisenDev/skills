#!/usr/bin/env bash

# agy.sh - Antigravity CLI (AGY) Adapter Module

agy_detect_cli() {
    if command -v agy &>/dev/null || [ -d "$HOME/.gemini/config" ] || [ "${MOCK_AGY_INSTALLED}" = "1" ]; then
        return 0
    fi
    return 1
}

agy_get_skill_directory() {
    echo "$HOME/.gemini/config/skills"
}

agy_install_skill() {
    local source_path="$1"
    local skill_id="$2"
    local mode="$3"
    
    local target_dir
    target_dir=$(agy_get_skill_directory)
    local dest_dir="${target_dir}/${skill_id}"
    local dest_file="${dest_dir}/SKILL.md"
    
    if [ "$DRY_RUN" = "true" ]; then
        log_info "[DRY-RUN] [AGY] Would install $skill_id to $dest_file (Mode: $mode)"
        return 0
    fi
    
    safe_mkdir "$dest_dir"
    
    if [ "$mode" = "symlink" ]; then
        # symlink helper from lib/symlink.sh
        if ! create_symlink "$source_path" "$dest_file"; then
            return 1
        fi
    else
        # Copy mode
        if [ -e "$dest_file" ] && [ "$FORCE" != "true" ]; then
            if [ "$VERBOSE" = "true" ]; then
                log_info "[AGY] $dest_file already exists, skipping copy (use --force to overwrite)."
            fi
            return 0
        fi
        
        safe_rm "$dest_file"
        if ! cp "$source_path" "$dest_file"; then
            log_error "[AGY] Failed to copy $source_path to $dest_file"
            return 1
        fi
    fi
    
    log_installed "[AGY] Installed skill: $skill_id ($mode)"
    return 0
}

agy_remove_skill() {
    local skill_id="$1"
    local target_dir
    target_dir=$(agy_get_skill_directory)
    local dest_dir="${target_dir}/${skill_id}"
    
    if [ "$DRY_RUN" = "true" ]; then
        log_info "[DRY-RUN] [AGY] Would remove $dest_dir"
        return 0
    fi
    
    if [ -d "$dest_dir" ]; then
        safe_rm "$dest_dir"
        log_success "[AGY] Removed skill: $skill_id"
    fi
    return 0
}

agy_reload_cli() {
    log_info "[AGY] Reloading Antigravity CLI customizations..."
    log_success "[AGY] Customizations successfully reloaded (auto-load active)."
    return 0
}

agy_doctor() {
    local target_dir
    target_dir=$(agy_get_skill_directory)
    
    log_info "[AGY] Diagnostics running..."
    
    if [ ! -d "$target_dir" ]; then
        log_warn "[AGY] Target skills directory not initialized at $target_dir"
        return 0
    fi
    
    # Check permissions
    if ! check_write_access "$target_dir"; then
        log_error "[AGY] Skills directory is not writable: $target_dir"
    fi
    
    # Check for broken symlinks
    for dir in "$target_dir"/*; do
        if [ -d "$dir" ]; then
            local file="${dir}/SKILL.md"
            if [ -L "$file" ]; then
                local verify_res
                verify_symlink "$file"
                verify_res=$?
                if [ "$verify_res" -eq 2 ]; then
                    log_error "[AGY] Broken symlink detected at: $file"
                fi
            fi
        fi
    done
    return 0
}

agy_validate() {
    local target_dir
    target_dir=$(agy_get_skill_directory)
    if [ -d "$target_dir" ]; then
        return 0
    else
        return 1
    fi
}
