#!/usr/bin/env bash

# codex.sh - Codex CLI Adapter Module
#
# Codex CLI supports two complementary loading mechanisms:
#
# 1. ~/.codex/skills/<skill-id>/SKILL.md  — modular skills shown in the Skills panel
#    (triggered on-demand; Codex only loads the full SKILL.md when the skill is relevant)
#
# 2. ~/.codex/AGENTS.md — global persistent context loaded at every session start
#    (permanent system prompt / engineering standards baseline)
#
# Install strategy: Symlink each skill into ~/.codex/skills/<skill-id>/SKILL.md
# This makes skills visible in the Codex Skills panel AND keeps them in sync via symlinks.

codex_detect_cli() {
    if command -v codex &>/dev/null || [ -d "$HOME/.codex" ] || [ "${MOCK_CODEX_INSTALLED}" = "1" ]; then
        return 0
    fi
    return 1
}

codex_get_skill_directory() {
    echo "$HOME/.codex/skills"
}

codex_install_skill() {
    local source_path="$1"
    local skill_id="$2"
    local mode="$3"

    local target_dir
    target_dir=$(codex_get_skill_directory)
    local dest_dir="${target_dir}/${skill_id}"
    local dest_file="${dest_dir}/SKILL.md"

    if [ "$DRY_RUN" = "true" ]; then
        log_info "[DRY-RUN] [Codex] Would install '$skill_id' to $dest_file (Mode: $mode)"
        return 0
    fi

    safe_mkdir "$dest_dir"

    if [ "$mode" = "symlink" ]; then
        if ! create_symlink "$source_path" "$dest_file"; then
            return 1
        fi
    else
        # Copy mode
        if [ -e "$dest_file" ] && [ "$FORCE" != "true" ]; then
            if [ "$VERBOSE" = "true" ]; then
                log_info "[Codex] $dest_file already exists, skipping copy (use --force to overwrite)."
            fi
            return 0
        fi

        safe_rm "$dest_file"
        if ! cp "$source_path" "$dest_file"; then
            log_error "[Codex] Failed to copy $source_path to $dest_file"
            return 1
        fi
    fi

    log_installed "[Codex] Installed skill: $skill_id ($mode)"
    return 0
}

codex_remove_skill() {
    local skill_id="$1"
    local target_dir
    target_dir=$(codex_get_skill_directory)
    local dest_dir="${target_dir}/${skill_id}"

    if [ "$DRY_RUN" = "true" ]; then
        log_info "[DRY-RUN] [Codex] Would remove $dest_dir"
        return 0
    fi

    if [ -d "$dest_dir" ]; then
        safe_rm "$dest_dir"
        log_success "[Codex] Removed skill: $skill_id"
    fi
    return 0
}

codex_reload_cli() {
    log_info "[Codex] Skills installed to ~/.codex/skills/ — restart Codex for changes to appear in the Skills panel."
    log_success "[Codex] Reload complete."
    return 0
}

codex_doctor() {
    local target_dir
    target_dir=$(codex_get_skill_directory)

    log_info "[Codex] Diagnostics running..."

    if [ ! -d "$target_dir" ]; then
        log_warn "[Codex] Skills directory not initialized at $target_dir"
        return 0
    fi

    if ! check_write_access "$target_dir"; then
        log_error "[Codex] Skills directory is not writable: $target_dir"
    fi

    # Check for broken symlinks
    for dir in "$target_dir"/*/; do
        if [ -d "$dir" ]; then
            local file="${dir}/SKILL.md"
            if [ -L "$file" ]; then
                verify_symlink "$file"
                if [ $? -eq 2 ]; then
                    log_error "[Codex] Broken symlink detected at: $file"
                fi
            fi
        fi
    done

    local skill_count
    skill_count=$(find "$target_dir" -maxdepth 2 -name "SKILL.md" | wc -l)
    log_info "[Codex] $skill_count skill(s) installed in $target_dir"
    return 0
}

codex_validate() {
    if [ -d "$HOME/.codex" ]; then
        return 0
    fi
    return 1
}
