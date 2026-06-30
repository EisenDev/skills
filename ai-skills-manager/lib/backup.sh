#!/usr/bin/env bash

# Source dependencies
if [ -z "$PROJECT_ROOT" ]; then
    PROJECT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
    # shellcheck source=lib/utils.sh
    source "${PROJECT_ROOT}/lib/utils.sh"
fi

BACKUP_DIR="${PROJECT_ROOT}/.backups"

# Create a backup of currently installed skills for a given CLI
backup_skills() {
    local cli="$1"
    local get_dir_func="${cli}_get_skills_dir"
    
    if ! declare -f "$get_dir_func" >/dev/null; then
        log_error "Failed to retrieve skills directory function for $cli"
        return 1
    fi
    
    local target_dir
    target_dir=$("$get_dir_func")
    
    # If the target directory doesn't exist or is empty, skip backup
    if [ ! -d "$target_dir" ] || [ -z "$(ls -A "$target_dir" 2>/dev/null)" ]; then
        log_info "No existing skills found for $cli to backup."
        return 0
    fi
    
    local timestamp
    timestamp=$(date +"%Y-%m-%d_%H%M%S")
    local cli_backup_dir="${BACKUP_DIR}/${timestamp}/${cli}"
    
    log_info "Backing up existing $cli skills to $cli_backup_dir..."
    mkdir -p "$cli_backup_dir"
    
    if cp -r "${target_dir}/." "$cli_backup_dir/"; then
        log_success "Backup completed successfully for $cli."
        echo "$timestamp" # Output backup timestamp for caller reference
        return 0
    else
        log_error "Failed to create backup for $cli."
        return 1
    fi
}

# Restore skills from a backup timestamp
restore_backup() {
    local cli="$1"
    local timestamp="$2"
    
    if [ -z "$timestamp" ]; then
        # Find latest backup timestamp if none provided
        if [ -d "$BACKUP_DIR" ]; then
            timestamp=$(ls -r "$BACKUP_DIR" | head -n 1)
        fi
    fi
    
    if [ -z "$timestamp" ] || [ ! -d "${BACKUP_DIR}/${timestamp}/${cli}" ]; then
        log_error "No valid backup found for $cli (requested timestamp: ${timestamp:-latest})"
        return 1
    fi
    
    local get_dir_func="${cli}_get_skills_dir"
    local target_dir
    target_dir=$("$get_dir_func")
    
    local source_dir="${BACKUP_DIR}/${timestamp}/${cli}"
    log_info "Restoring $cli skills from $source_dir to $target_dir..."
    
    mkdir -p "$target_dir"
    # Clean current directory before restoring
    rm -rf "${target_dir:?}"/*
    
    if cp -r "${source_dir}/." "$target_dir/"; then
        log_success "Restored backup successfully."
        return 0
    else
        log_error "Failed to restore backup."
        return 1
    fi
}
