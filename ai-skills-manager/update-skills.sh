#!/usr/bin/env bash

# update-skills.sh - Synchronizes local skillset files with target CLI configurations

PROJECT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib/common.sh
source "${PROJECT_ROOT}/lib/common.sh"
# shellcheck source=lib/cli_detector.sh
source "${PROJECT_ROOT}/lib/cli_detector.sh"
# shellcheck source=lib/manifest.sh
source "${PROJECT_ROOT}/lib/manifest.sh"
# shellcheck source=lib/validator.sh
source "${PROJECT_ROOT}/lib/validator.sh"
# shellcheck source=lib/installer.sh
source "${PROJECT_ROOT}/lib/installer.sh"

show_help() {
    echo "AI Skills Updater CLI"
    echo "Usage: $0 [targets] [options]"
    echo ""
    echo "Targets:"
    echo "  --agy       Update Antigravity CLI (AGY)"
    echo "  --claude    Update Claude Code"
    echo "  --codex     Update Codex CLI"
    echo "  --gemini    Update Gemini CLI"
    echo "  --cursor    Update Cursor CLI"
    echo "  --all       Update all detected CLIs"
    echo ""
    echo "Common Options:"
    echo "  --verbose   Show detailed execution logs"
    echo "  --dry-run   Simulate execution without modifying files"
    echo "  --force     Force reinstall and overwrite files"
    echo "  --version   Print version information"
    echo "  -h, --help  Show this help menu"
    exit 0
}

if [ "$HELP" = "true" ]; then
    show_help
fi

# Sync target CLI: Install new, update changed, remove deleted skills
sync_cli_skills() {
    local cli="$1"
    
    log_bold "========================================"
    log_info "Synchronizing skillset for: $cli"
    log_bold "----------------------------------------"

    if ! is_cli_installed "$cli"; then
        log_error "✗ Target CLI '$cli' is not detected."
        return 1
    fi

    local target_dir
    target_dir=$(dispatch_cli "$cli" get_skill_directory)
    if [ -z "$target_dir" ] || [ ! -d "$target_dir" ]; then
        log_warn "Target skills directory not initialized/present for $cli. Performing fresh install..."
        install_to_target_cli "$cli"
        return $?
    fi

    local install_sequence
    install_sequence=$(get_install_order)
    local manifest_skills
    manifest_skills=$(get_manifest_skills)

    local updated_count=0
    local installed_count=0

    # 1. Update/Install loop
    for skill_id in $install_sequence; do
        local folder
        folder=$(get_skill_field "$skill_id" "directory")
        local install_mode
        install_mode=$(get_skill_field "$skill_id" "install_mode")
        local local_file="${PROJECT_ROOT}/skillset/${folder}/${skill_id}.md"
        
        # Check supported_clis in manifest
        local supported_clis
        supported_clis=$(get_skill_field "$skill_id" "supported_clis")
        if [[ ! " ${supported_clis} " =~ [[:space:]]${cli}[[:space:]] ]]; then
            if [ "$FORCE" != "true" ]; then
                continue
            fi
        fi

        # Determine target file path
        local installed_file
        if [ "$cli" = "agy" ]; then
            installed_file="${target_dir}/${skill_id}/SKILL.md"
        else
            installed_file="${target_dir}/${skill_id}.md"
        fi

        if [ ! -f "$installed_file" ]; then
            # New skill
            if dispatch_cli "$cli" install_skill "$local_file" "$skill_id" "$install_mode"; then
                log_installed "[New] $skill_id ($install_mode)"
                installed_count=$((installed_count + 1))
            fi
        else
            # Changed skill (version mismatch or forced)
            local local_version
            local_version=$(parse_frontmatter_field "$local_file" "version" 2>/dev/null || echo "1.0.0")
            # Wait, our files don't have frontmatter, so parse_frontmatter_field will return empty.
            # In that case, we compare the local file modification time or assume version "1.0.0".
            # Or we can read the version field from the manifest!
            # Since the version field is in the manifest, we compare the manifest version with the installed file's version in the manifest or check file content changes.
            # Wait! The manifest version is the single source of truth for versioning.
            # Let's extract the version of the installed skill by reading the target file or checking the manifest.
            # Wait, the prompt says "Each skill stores metadata (id, name, version... in skill-manifest.yaml)".
            # If the manifest version changes, we update.
            # But how do we know what version is currently installed in the target CLI?
            # We can write the version or manifest properties to a state file, or check the file hash of the local file vs target file!
            # A file hash check (e.g. `diff` or `md5sum` check) is the most robust way to check if a skill has "changed" because it detects ANY content changes, not just version increments!
            # Yes! Using `diff` or `cmp` to check if target file matches local file is the absolute best standard!
            local has_diff=false
            if [ "$cli" = "agy" ]; then
                if ! cmp -s "$local_file" "$installed_file"; then
                    has_diff=true
                fi
            else
                if ! cmp -s "$local_file" "$installed_file"; then
                    has_diff=true
                fi
            fi

            if [ "$has_diff" = "true" ] || [ "$FORCE" = "true" ]; then
                if dispatch_cli "$cli" install_skill "$local_file" "$skill_id" "$install_mode"; then
                    log_updated "[Changed] $skill_id"
                    updated_count=$((updated_count + 1))
                fi
            fi
        fi
    done

    # 2. Remove deleted skills loop
    local removed_count=0
    if [ "$cli" = "agy" ]; then
        # For AGY, target skills are folders
        for dir in "${target_dir}"/*; do
            if [ -d "$dir" ]; then
                local skill_id
                skill_id=$(basename "$dir")
                # Verify if it is in manifest
                if [[ ! " ${manifest_skills} " =~ [[:space:]]${skill_id}[[:space:]] ]]; then
                    if dispatch_cli "$cli" remove_skill "$skill_id"; then
                        log_warn "✗ Removed deleted skill from $cli: $skill_id"
                        removed_count=$((removed_count + 1))
                    fi
                fi
            fi
        done
    else
        # For other CLIs, target skills are files
        for file in "${target_dir}"/*.md; do
            if [ -f "$file" ]; then
                local skill_id
                skill_id=$(basename "$file" .md)
                if [[ ! " ${manifest_skills} " =~ [[:space:]]${skill_id}[[:space:]] ]]; then
                    if dispatch_cli "$cli" remove_skill "$skill_id"; then
                        log_warn "✗ Removed deleted skill from $cli: $skill_id"
                        removed_count=$((removed_count + 1))
                    fi
                fi
            fi
        done
    fi

    # Report
    if [ "$installed_count" -eq 0 ] && [ "$updated_count" -eq 0 ] && [ "$removed_count" -eq 0 ]; then
        log_success "$cli: All skills are already synchronized."
    else
        log_success "$cli: Sync completed ($installed_count installed, $updated_count updated, $removed_count removed)."
        dispatch_cli "$cli" reload_cli
    fi
    return 0
}

main() {
    local target_clis=()
    local update_all=false

    for arg in "${CLI_ARGS[@]}"; do
        case "$arg" in
            --agy) target_clis+=("agy") ;;
            --claude) target_clis+=("claude") ;;
            --codex) target_clis+=("codex") ;;
            --gemini) target_clis+=("gemini") ;;
            --cursor) target_clis+=("cursor") ;;
            --all) update_all=true ;;
            *)
                log_error "Unknown argument: $arg"
                show_help
                ;;
        esac
    done

    if [ ${#target_clis[@]} -eq 0 ] && [ "$update_all" = "false" ]; then
        log_info "No targets specified. Auto-detecting and updating all installed CLIs..."
        update_all=true
    fi

    if [ "$update_all" = "true" ]; then
        local adapters
        adapters=$(get_adapters)
        for cli in $adapters; do
            if is_cli_installed "$cli"; then
                target_clis+=("$cli")
            fi
        done
    fi

    # Step 1: Validate skillset
    if ! validate_skillset; then
        log_error "Skillset validation failed. Aborting update."
        exit 1
    fi

    # Step 2: Sync targets
    local failures=0
    for cli in "${target_clis[@]}"; do
        if ! sync_cli_skills "$cli"; then
            failures=$((failures + 1))
        fi
    done

    log_bold "----------------------------------------"
    if [ "$failures" -eq 0 ]; then
        log_success "AI Skills update sync complete!"
        exit 0
    else
        log_error "AI Skills update sync failed with $failures failures."
        exit 1
    fi
}

main "$@"
