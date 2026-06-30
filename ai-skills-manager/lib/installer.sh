#!/usr/bin/env bash

# installer.sh - Installer engine handling topological sorting and dependency ordering

if [ -z "$PROJECT_ROOT" ]; then
    PROJECT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
    # shellcheck source=lib/common.sh
    source "${PROJECT_ROOT}/lib/common.sh"
fi

# Source detectors and manifest libraries
# shellcheck source=lib/cli_detector.sh
source "${PROJECT_ROOT}/lib/cli_detector.sh"
# shellcheck source=lib/manifest.sh
source "${PROJECT_ROOT}/lib/manifest.sh"
# shellcheck source=lib/symlink.sh
source "${PROJECT_ROOT}/lib/symlink.sh"

# Compute topological order of installation based on dependency graph
get_install_order() {
    python3 -c "
import yaml, sys

try:
    with open('${MANIFEST_PATH}') as f:
        data = yaml.safe_load(f)
except Exception as e:
    print(f'Error reading manifest: {e}', file=sys.stderr)
    sys.exit(1)

skills = data.get('skills', [])
graph = {s['id']: s.get('dependencies', []) for s in skills}

# Topological sort (Kahn's algorithm or DFS)
visited = {} # 0=unvisited, 1=visiting, 2=visited
order = []

def dfs(node):
    visited[node] = 1
    for dep in graph.get(node, []):
        if dep not in graph:
            print(f'Error: Dependency \"{dep}\" not found in manifest!', file=sys.stderr)
            sys.exit(1)
        if visited.get(dep, 0) == 1:
            print(f'Error: Circular dependency detected involving \"{node}\" and \"{dep}\"', file=sys.stderr)
            sys.exit(1)
        elif visited.get(dep, 0) == 0:
            dfs(dep)
    visited[node] = 2
    order.append(node)

for skill in graph:
    if visited.get(skill, 0) == 0:
        dfs(skill)

print(' '.join(order))
"
}

# Install all skills into a target CLI, resolving dependencies first
install_to_target_cli() {
    local cli="$1"
    
    log_bold "========================================"
    log_info "Initiating install procedure for: $cli"
    log_bold "----------------------------------------"

    # Step 1: Detect if CLI is installed on system
    if ! is_cli_installed "$cli"; then
        log_error "✗ Target CLI '$cli' is not detected on this system."
        return 1
    fi
    
    # Step 2: Query topological install order
    local install_sequence
    install_sequence=$(get_install_order)
    if [ $? -ne 0 ] || [ -z "$install_sequence" ]; then
        log_error "Failed to resolve dependency graph. Aborting."
        return 1
    fi
    
    if [ "$VERBOSE" = "true" ]; then
        log_info "Topological install sequence: $install_sequence"
    fi

    # Step 3: Sequentially install
    local failures=0
    for skill_id in $install_sequence; do
        local folder
        folder=$(get_skill_field "$skill_id" "directory")
        local install_mode
        install_mode=$(get_skill_field "$skill_id" "install_mode")
        local source_path="${PROJECT_ROOT}/skillset/${folder}/${skill_id}.md"
        
        # Check if this CLI is supported by the skill
        local supported_clis
        supported_clis=$(get_skill_field "$skill_id" "supported_clis")
        
        # Verify supported_clis lists this target CLI
        if [[ ! " ${supported_clis} " =~ [[:space:]]${cli}[[:space:]] ]]; then
            if [ "$FORCE" != "true" ]; then
                log_warn "Skill '$skill_id' does not list '$cli' in supported_clis. Skipping (use --force to install anyway)."
                continue
            fi
            log_warn "Forcing installation of unsupported skill '$skill_id' to '$cli'."
        fi
        
        # Call adapter install_skill
        if ! dispatch_cli "$cli" install_skill "$source_path" "$skill_id" "$install_mode"; then
            log_error "Failed to install skill '$skill_id' to '$cli'."
            failures=$((failures + 1))
        fi
    done
    
    # Step 4: Reload CLI if supported
    if [ "$failures" -eq 0 ]; then
        dispatch_cli "$cli" reload_cli
        log_success "Successfully completed installation to: $cli"
        return 0
    else
        log_error "Installation completed with $failures errors for target: $cli"
        return 1
    fi
}

# Remove skills from target CLI
uninstall_from_target_cli() {
    local cli="$1"
    
    log_bold "========================================"
    log_info "Initiating uninstall procedure for: $cli"
    log_bold "----------------------------------------"

    if ! is_cli_installed "$cli"; then
        log_error "✗ Target CLI '$cli' is not detected."
        return 1
    fi

    local skills
    skills=$(get_manifest_skills)
    
    local failures=0
    for skill_id in $skills; do
        if ! dispatch_cli "$cli" remove_skill "$skill_id"; then
            failures=$((failures + 1))
        fi
    done
    
    if [ "$failures" -eq 0 ]; then
        log_success "Successfully removed all skills from: $cli"
        return 0
    else
        log_error "Uninstallation completed with $failures errors for target: $cli"
        return 1
    fi
}
